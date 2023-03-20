# Enable Wireless Uplink on Solo/Standalone Ruckus APs

You can use the procedure below to bridge your AP to an existing WiFi network.

> NOTE: This procedure has stopped working for the latest (100.0+) firmware releases.  
  Make sure you have a 9.6, 9.7 or 9.8 firmware installed before following these steps.

This may be useful if you have wired-only devices (e.g. printers or SIP phones) but can't easily run an ethernet drop.  
Or maybe your router's WiFi signal is weak & it has no user-accessible ethernet ports (e.g. an LTE travel router or a phone hotspot).  

### Step 1: SSH to the AP

```console
$ ssh 192.168.0.1 -oKexAlgorithms=+diffie-hellman-group1-sha1 -oHostKeyAlgorithms=+ssh-rsa -oCiphers=+aes256-cbc
```

> 192.168.0.1 is the default IP address, unless the AP was able to lease another IP from a DHCP server.

Login.

> Default username is "super", password is "sp-admin".

### Step 2: Convert WLAN "Wireless16" into an uplink

Paste the following into the AP's CLI.

> NOTE: you will need to modify the last two `set rpmkey` commands to contain the correct uplink SSID and passphrase for your environment.

```
set rpmkey wlans/wlan15/wlan-cipher-type 2
set rpmkey wlans/wlan15/wlan-encrypt-state 1
set rpmkey wlans/wlan15/wlan-encrypt-type 1
set rpmkey wlans/wlan15/wlan-if-flags 1
set rpmkey wlans/wlan15/wlan-init-noup 1
set rpmkey wlans/wlan15/wlan-userdef-text WirelessBridge
set rpmkey wlans/wlan15/wlan-wpa-type 2
set rpmkey wlans/wlan15/wlan-wpa-eap-enable 0
set rpmkey wlans/wlan15/wlan-type sta
set rpmkey wlans/wlan15/wlan-state up
set rpmkey wlans/wlan15/wlan-ssid REPLACE_ME_WITH_YOUR_SSID
set rpmkey wlans/wlan15/wlan-wpa-passphrase REPLACE_ME_WITH_YOUR_PASSPHRASE
reboot
```

Your AP will now reboot, and associate to the WLAN you specified in step 2.

> You won't be able to choose which 5Ghz channel is used anymore. The AP will use the uplink's channel for all 5Ghz WLANs.

> You can choose a different WLAN to convert, if you're already using Wireless16 for something else or you require a 2.4Ghz uplink.  
> Just tweak the script, changing `wlan15` to whichever of `wlan0` - `wlan7` (for 2.4Ghz uplink) or `wlan8` - `wlan14` (for 5Ghz uplink) is free.
> 
