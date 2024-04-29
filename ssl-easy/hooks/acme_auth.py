import os
import sys
import time
from abc import ABCMeta, abstractmethod
from functools import reduce, lru_cache
from cloudeasy.alicloud import DnsManager, Config
from CloudFlare import CloudFlare
import logging

logger = logging.getLogger(__name__)


class DNSAcmeProvider(metaclass=ABCMeta):

    @abstractmethod
    def ensure_auth_record_exists(self, fqdn, value, rr_type):
        pass

    @abstractmethod
    def delete_auth_record(self, fqdn, value, rr_type):
        pass


class CloudFlareDNSAcmeProvider(DNSAcmeProvider):
    def __init__(self, token) -> None:
        self.cf = CloudFlare(token=token)

    @lru_cache(maxsize=100)
    def get_zone_id_from_fqdn(self, fqdn: str) -> (str, str):
        zones = self.cf.zones.get(
            params={"per_page": 100}
        )
        domain_sorted = sorted([x['name'] for x in zones], key=len, reverse=True)
        for domain in domain_sorted:
            if domain in fqdn:
                zone_id = [x['id'] for x in zones if x['name'] == domain][0]
                hostname = fqdn[0:-1 - len(domain)]
                return hostname, zone_id
        raise NotImplementedError("Cannot found domain for fqdn {}".format(fqdn))

    def ensure_auth_record_exists(self, fqdn, value, rr_type):
        hostname, zone_id = self.get_zone_id_from_fqdn(fqdn)
        dns_records = self.cf.zones.dns_records.get(zone_id, params={"name": fqdn, "content": value, "type": rr_type})
        if len(dns_records) > 0:
            logging.warning(f"DNSRecord {fqdn}-{rr_type}->{value} already exists,skip creation")
        else:
            self.cf.zones.dns_records.post(
                zone_id, data={
                    "name": hostname,
                    "type": rr_type,
                    "content": value
                }
            )

    def delete_auth_record(self, fqdn, value, rr_type):
        _, zone_id = self.get_zone_id_from_fqdn(fqdn)
        dns_records = self.cf.zones.dns_records.get(zone_id, params={"name": fqdn})
        to_delete = [x['id'] for x in dns_records if x['content'] == value][0]
        self.cf.zones.dns_records.delete(zone_id, to_delete)


class AliCloudDNSAcmeProvider(DNSAcmeProvider):

    def __init__(self, access_key_id: str, access_key_secret: str):
        self.dns_manager = DnsManager(Config(access_key_id=access_key_id, access_key_secret=access_key_secret))
        super().__init__()

    def list_domain_records(self) -> list[str]:
        pages = self.dns_manager.list_domains()
        domains = [x['DomainName'] for x in reduce(lambda x, y: x.extend(y) or x, pages, [])]
        return domains

    def get_domain_from_fqdn(self, fqdn: str) -> (str, str):
        domain_sorted = sorted(self.list_domain_records(), key=len, reverse=True)
        for domain in domain_sorted:
            if domain in fqdn:
                return fqdn[0:-1 - len(domain)], domain
        raise NotImplementedError("Cannot found domain for fqdn {}".format(fqdn))

    def ensure_auth_record_exists(self, fqdn, value, rr_type):
        rr_hostname, rr_domain = self.get_domain_from_fqdn(fqdn)
        self.dns_manager.add_resource_record(
            hostname=rr_hostname,
            domain=rr_domain,
            resource_data=value,
            resource_type=rr_type
        )

    def delete_auth_record(self, fqdn, value, rr_type):
        rr_hostname, rr_domain = self.get_domain_from_fqdn(fqdn)
        pages = self.dns_manager.query_resource_record(domain=rr_domain, hostname=rr_hostname)
        records = filter(lambda x: x['Value'] == value and x['Type'] == rr_type.upper(),
                         reduce(lambda x, y: x.extend(y) or x, pages, []))
        records = list(records)
        assert len(records) == 1, "Found conflict records:{records}".format(records=records)
        self.dns_manager.delete_resource_record(records[0]['RecordId'])


class AcmeDNSAuth:
    def __init__(self, _provider: DNSAcmeProvider):
        self.provider = _provider
        self.fqdn = "_acme-challenge." + os.environ["CERTBOT_DOMAIN"]
        self.rr_data = os.environ["CERTBOT_VALIDATION"]
        self.rr_type = 'txt'

    def auth(self):
        self.provider.ensure_auth_record_exists(
            fqdn=self.fqdn, value=self.rr_data, rr_type=self.rr_type
        )
        # give 30s for change to take effect
        time.sleep(30)

    def clean(self):
        self.provider.delete_auth_record(
            fqdn=self.fqdn, value=self.rr_data, rr_type=self.rr_type
        )


if __name__ == "__main__":
    provider, action = sys.argv[1:3]
    match provider.lower():
        case "alicloud":
            dns_auth_provider = AliCloudDNSAcmeProvider(
                access_key_id=os.environ["AliCloud_ACCESS_KEY_ID"],
                access_key_secret=os.environ['AliCloud_ACCESS_KEY_SECRET']
            )
        case "cloudflare":
            dns_auth_provider = CloudFlareDNSAcmeProvider(
                token=os.environ["CLOUDFLARE_TOKEN"]
            )
        case _:
            raise NotImplementedError
    acme_auth = AcmeDNSAuth(_provider=dns_auth_provider)
    match action:
        case 'auth':
            acme_auth.auth()
        case 'clean':
            acme_auth.clean()
        case _:
            raise NotImplementedError
