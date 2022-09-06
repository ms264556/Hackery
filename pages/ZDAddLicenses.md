# Add AP Licenses to a ZoneDirector

Ruckus ships ZoneDirector controllers with a license to control a limited number of Access Points.   
Extra APs can be controlled by purchasing and uploading a license file.  
> Unfortunately Ruckus won't sell you AP licenses unless you are the original purchaser of the ZoneDirector.   

To prevent e-waste and save these from landfills, you may use the procedure here to apply free AP licenses to your ZoneDirector for use in a homelab or personal environment.

>If you have a ZoneDirector 1100/1200/3000 then you can add AP Licenses without having to install older software.  
>Follow the instructions here: [Add AP Licenses and Upgrade Entitlement to a ZoneDirector 1100/1200/3000](ZD1200LicensesAndSupport.md)

## 1) Install vulnerable firmware
The unlocking procedure requires you to *temporarily* install an older software version.  
Ensure the installed software was released in November 2019 or earlier. Otherwise, download an older version from [https://support.ruckuswireless.com/software](https://support.ruckuswireless.com/software) (e.g. I used 9.9.0.0.205) and do an 'upgrade' (`Administer` > `Upgrade`).

> If you have already configured your ZD, then backup your configuration (`Administer` > `Back up`). Make a note of your current software version - you'll need to upgrade to this exact version to restore your configuration backup.

> If you can't install firmware because your support has expired, download a 30 day support entitlement file from [https://supportactivation.ruckuswireless.com/](https://supportactivation.ruckuswireless.com/) and upload this to your ZoneDirector.  
> Alternatively, do a factory reset (_after_ you've backed up your configuration, if you don't want to lose it!). So long as the ZD has internet access then it will grab a 30 day support entitlement.  
> Now you can upgrade/downgrade your firmware.

## 2) Obtain a root shell
SSH into the ZD *using the same credentials you use to log into the web dashboard*, then break out to a root shell:

```console
ruckus> enable 
ruckus# debug 
You have all rights in this mode.
ruckus(debug)# script 
ruckus(script)# exec ../../../bin/sh


Ruckus Wireless ZoneDirector -- Command Line Interface
Enter 'help' for a list of built-in commands.

ruckus$ stty echo
ruckus$
```

> You won't be able to see yourself typing `stty echo`. Calling `stty echo` restores local echo so you can see what you're typing.

## 3) Now increase your license count

We're going to completely overwrite your `license-list.xml` file, so probably a good idea to copy and paste it somewhere safe in case anything goes wrong:-

```console
cat /etc/airespider-images/license-list.xml
```
It should look like this, unless you already bought some upgrades:-
```xml
<license-list name="5 AP Management" max-ap="5" max-client="2000" value="0x0000000f" />
```

So let's give ourselves 64 licenses:-
```console
ZD_SERIAL=$(cat /proc/v54bsp/serial) ; cat <<EOF >/etc/airespider-images/license-list.xml
<license-list name="64 AP Management" max-ap="64" max-client="2000" value="0x0000000f">
    <license id="1" name="59 AP Management" inc-ap="59" generated-by="264556" serial-number="$ZD_SERIAL" status="0" detail="" />
</license-list>
EOF
```

Your `license-list.xml` should now look like this (except with your ZD's serial number):-
```xml
<license-list name="64 AP Management" max-ap="64" max-client="2000" value="0x0000000f">
    <license id="1" name="59 AP Management" inc-ap="59" generated-by="264556" serial-number="000000000000" status="0" detail="" />
</license-list>
```

Give your ZD a reboot, and your license count should now be permanently higher:-
```console
reboot
```

## 4) Install a newer firmware
If you downgraded your ZD software in order to run through this procedure, you can now upgrade your firmware again (and import your saved configuration if necessary).

> It's quite likely that the older firmware won't work properly in Chrome/Edge. If you have problems then use Firefox.  
If your firmware is really old then it's possible that even Firefox will refuse to work, because of an insecure TLS version. In this case, download and use an older Firefox release, e.g. version 40.
