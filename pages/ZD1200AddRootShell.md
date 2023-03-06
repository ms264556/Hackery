# Accessing a Root Shell on Ruckus ZoneDirectors

## ZoneDirector 10.4 - 10.5.1

The procedure below permanently adds a root shell command to your ZoneDirector CLI.  
If you prefer a temporary, one-time use, root shell then [follow the instructions here](ZD1200AddOneTimeRootShell.md).

[This patch](../images/zd1200.rootshell.patch.img) should be uploaded as a Software Upgrade (`Administer` > `Upgrade` > `Software Upgrade`).  

The upload process completes the patching; no upgrade will be offered. Instead you will be given instructions on using the root shell:-

![](../images/Root_Support_APs_1031.png)

> The upgrade will also add a temporary Upgrade Entitlement if necessary.

>Subsequent software upgrades will disable the root shell: you will need to re-apply this patch each time you upgrade your ZoneDirector's software.

In case you miss the instructions, to access the root shell from the CLI:-

```console
ruckus> enable 
ruckus# debug 
You have all rights in this mode.
ruckus(debug)# script 
ruckus(script)# exec .root.sh
Ruckus Wireless ZoneDirector -- Command Line Interface
ruckus$
```

Although [the patch](../images/zd1200.rootshell.patch.img) can be directly downloaded and used, I recommend either [creating the patch yourself](../Scripts/create_zd1200_root_patch.sh) or [decrypting the patch](DecryptRuckusBackups.md) to verify it does only what it should.

## ZoneDirector 9.3 - 10.3

Use [CVE-2019-19834](https://alephsecurity.com/vulns/aleph-2019004#proof-of-concept):-

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

## ZoneDirector 3.0 - 8.x

The CLI has an unprivileged `!v54!` command which drops you straight to the root shell:-

```console
ruckus% !v54!
ruckus% 
```

> Really though, you should just upgrade to 9.3 or later.   
If you're still using 3.0 because upgrade functionality is broken on modern PCs then [follow the steps here](ZD1000UpgradeFromV3.md).

