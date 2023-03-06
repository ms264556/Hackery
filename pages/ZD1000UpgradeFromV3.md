# Upgrade a ZoneDirector running software version 3.0

The 3.0 ZoneDirector CLI has no method to perform a firmware upgrade, and the web UI upgrade functionality fails on all browsers I tried (because of TLS and XSS errors).

If you setup a TFTP server then you can use this to upgrade the ZoneDirector via a root shell:-

```console
ssh -oKexAlgorithms=+diffie-hellman-group1-sha1 -oHostKeyAlgorithms=+ssh-rsa -oCiphers=+aes256-cbc 192.168.0.2

!v54!

cd /tmp
tftp -g -l upgrade_file -r zd_6.0.3.0.19.ap_6.0.3.0.21.img 192.168.0.22
/bin/sys_wrapper.sh verify-upgrade upgrade_file
mkdir upg
cd upg
cat ../upgrade_file.decrypted | gunzip | tar x
./ac_upg.sh
```
