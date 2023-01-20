# Enable Wireless Uplink on Solo/Standalone Ruckus APs

You can use the procedure below to bridge your AP to an existing WiFi network.

This may be useful if you have wired-only devices (e.g. printers or SIP phones) but can't easily run an ethernet drop.  
Or maybe your router's WiFi signal is weak & it has no user-accessible ethernet ports (e.g. an LTE travel router or a phone hotspot).  

## Step 1: Obtain a root shell

[Follow the instruction here](StandaloneApRootShell.md) to escape from the Ruckus CLI to a root shell.

## Step 2: Enter the SSID and Passphrase of your uplink WLAN

```bash
MY_UPLINK_SSID="my_uplink_ssid"
MY_UPLINK_PASS="my_uplink_passphrase"
```

## Step 3: Convert WLAN "Wireless16" into an uplink

```bash
mkdir -p /tmp/wirelessuplink/wlans/wlan15
cd /tmp/wirelessuplink/wlans/wlan15

echo -n 0 >wlan-auth-type
echo 2 >wlan-cipher-type
echo 1 >wlan-created-defined
echo 1 >wlan-encrypt-state
echo -n 1 >wlan-encrypt-type
echo -n 1 >wlan-if-flags
echo -n 1 >wlan-if-parent
echo -n 1 >wlan-init-noup
echo allow >wlan-isallowed
echo ${MY_UPLINK_SSID} >wlan-ssid
echo -n up >wlan-state
echo sta >wlan-type
echo Wireless Bridge >wlan-userdef-text
echo -n ${MY_UPLINK_PASS} >wlan-wpa-passphrase
echo -n 2 >wlan-wpa-type

rpm -d wlans/wlan15/*
rpm -m /tmp/wirelessuplink

reboot
```

Your AP will now reboot, and associate to the WLAN you specified in step 2.

> You won't be able to choose the 5Ghz channel anymore. The AP will use the uplink's channel.

> You can choose a different WLAN to convert, if you're already using Wireless16 for something else.  
> Just tweak the script, changing `wlan15` to whichever of `wlan0` - `wlan14` is free. If you choose a 2.4Ghz WLAN then also change `wlan-if-parent` to `0`.
> 
