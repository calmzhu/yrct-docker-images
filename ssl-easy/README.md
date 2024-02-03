# Use certbot to request Let's Encrypt SSL. verified by DNS

support alibaba cloud DNS and CloudFlare DNS.

## Usage

### AliCloud DNS
```shell

export EMAIL_ACCOUNT="foo@bar.com" # Your real email accounts.Email notifications about certificates will be send to this address
export Auth_Domain="*.yourdomain.com" # what domain this certificate is for.Support both single domain or wildcard domain
acme_server="https://acme-v02.api.letsencrypt.org/directory" # let's encrypt server address.
# acme_server="https://acme-staging-v02.api.letsencrypt.org/directory" #for testing purpose. please use stage server of let's encrypt. To avoid frequency limit
export AliCloud_ACCESS_KEY_ID='ADD*****' # AliCloud Access key id,Must have permission to read/right dns records.
export AliCloud_ACCESS_KEY_SECRET="XXXX*****" # AliCloud Access key secret
docker run -it --rm --name certbot \
    -e AliCloud_ACCESS_KEY_ID \
    -e AliCloud_ACCESS_KEY_SECRET \
    -e Auth_Domain \
    -v certbot:/etc/letsencrypt \
    yrct/ssl-easy \
    certonly \
    --manual \
	--preferred-challenges dns \
	--manual-auth-hook "python /hooks/acme_auth.py alicloud auth"\
	--manual-cleanup-hook "python /hooks/acme_auth.py alicloud clean"\
	--server "$acme_server" \
	-m "$EMAIL_ACCOUNT" \
	-n \
	--agree-tos \
	-d "$Auth_Domain"
```


### Cloud Flare DNS
```shell
export EMAIL_ACCOUNT="foo@bar.com" # Your real email accounts.Email notifications about certificates will be send to this address
export Auth_Domain="*.yourdomain.com" # what domain this certificate is for.Support both single domain or wildcard domain
acme_server="https://acme-v02.api.letsencrypt.org/directory" # let's encrypt server address.
export CLOUDFLARE_TOKEN=XXXXXX # your bearer token from cloudflare.Must have permission to read/right dns records.
docker run -it --rm --name certbot \
    -e CLOUDFLARE_TOKEN \
    -e Auth_Domain \
    -v certbot:/etc/letsencrypt \
    yrct/ssl-easy \
    certonly \
    --manual \
	--preferred-challenges dns \
	--manual-auth-hook "python /hooks/acme_auth.py cloudflare auth"\
	--manual-cleanup-hook "python /hooks/acme_auth.py cloudflare clean"\
	--server "$acme_server" \
	-m "$EMAIL_ACCOUNT" \
	-n \
	--agree-tos \
	-d "$Auth_Domain"
```

Now you can get new requested ssl certificates files in dir ROOT_OF_YOUR_MOUNT_VOLUME/live
