# Backup Restore tools

# Backup and encrypt local dir to rclone remote drive


backup
```bash
docker run --rm -it \
    -ePassword=YOUR_ENCRYPT_PASS \
    -v /root/.config/rclone:/root/.config/rclone \
    -v /root:/mnt/br \
    yrct/br \
    backup /mnt/br YOUR://RCLONE/PATH.bz2.enc
```

restore
```bash
docker run --rm -it \
    -ePassword=YOUR_ENCRYPT_PASS \
    -v /root/.config/rclone:/root/.config/rclone \
    -v /root:/mnt/br \
    yrct/br \
    restore /mnt/br YOUR://RCLONE/PATH.bz2.enc
```
