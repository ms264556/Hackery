# Bypassing the Country Lock for a US model Ruckus AP

Ruckus access points may be cheaper to buy from the USA.

But Ruckus locks the country code on `US` model access points (unlike `WW` models), so you can't use the correct WiFi bands for other countries.
And `US` model access points will refuse to join any existing Unleashed or ZoneDirector network which doesn't have its country code set to US.
The country cannot be changed from the Web interface, and if you try to SSH in and `set countrycode XX` from the CLI then you receive an error: `illegal to change country code`.

Fortunately, it's possible to bypass the country lock, or even turn a locked `US` AP into an unlocked `WW` AP...

## Option 1: Changing the locked Country Code

SSH into the AP (using the same credentials you use to log into the web dashboard).

If your AP is running Unleashed firmware, then you'll need to get it into AP mode:
```console
enable
ap-mode
```

Manually update the country code (my example changes it to New Zealand):
```console
set rpmkey wlan-country-code NZ
```

The real `set countrycode NZ` would have set this rpmkey, but also fixed up the wifi channels. We're not running the fixup code, so it's safest to do a factory reset now:
```console
set factory
reboot
```

Job done.

## Option 2: Permanently removing the country lock from a Solo or Standalone AP

### 1) Obtain a root shell

Follow [these instructions](StandaloneApRootShell.md) to obtain a root shell.  
The unlocking procedure may require you to *temporarily* install an older firmware version on your AP.  

### 2) Remove the Country Lock

```console
# rbd country 0
```
Should see something like this:
```console
bdSave: sizeof(bd)=0x7c, sizeof(rbd)=0xd0
  caching flash data from /dev/mtd8 [ 0x00000000 - 0x00010000 ]
  updating flash data [0x00000000 - 0x0000007c] from [0x7f8cdc88 - 0x7f8cdd04]
  updating flash data [0x00008000 - 0x000080d0] from [0x7f8cdd04 - 0x7f8cddd4]
_erase_flash: offset=0x0 count=1
Erase Total 1 Units
Performing Flash Erase of length 262144 at offset 0x0 done
  caching flash data from /dev/mtd8 [ 0x00000000 - 0x00010000 ]
  verifying flash data [0x00000000 - 0x0000007c] from [0x7f8cdc88 - 0x7f8cdd04]
  verifying flash data [0x00008000 - 0x000080d0] from [0x7f8cdd04 - 0x7f8cddd4]
```

Your Access Point is now permanently unlocked. You can safely upgrade to any newer/older version of the software.
