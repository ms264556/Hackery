# Change Unleashed / ZoneDirector SSH Host Key Algorithm to ECDSA

Ruckus Unleashed / ZoneDirector use 2048 bit RSA SSH host keys.  
This algorithm is deprecated, so most SSH clients will refuse to connect unless you explicitly specify `-oHostKeyAlgorithms=+ssh-rsa` on your `ssh` commandline.  
_(If your AP / ZoneDirector is really old, you will need to specify `-oKexAlgorithms=+diffie-hellman-group1-sha1 -oHostKeyAlgorithms=+ssh-rsa`)._

Sure, you can permanently add `HostKeyAlgorithms +ssh-rsa` to your `~/.ssh/config` file.  
But you might prefer to tweak your Unleashed or ZoneDirector to use (secure, non-deprecated) ECDSA instead...

## Unleashed ECDSA SSH Host Key Procedure
> This procedure changes only the Master AP - you will need to follow the same procedure again if another AP begins acting as Master.  

[This patch](../images/unleashed.ecdsa.patch.dbg) should be uploaded as a `Preload Image` (`Admin & Services` > `Administration` > `Upgrade` > `Local Upgrade` > `Preload Image`).  
> The upload process completes the change; no upgrade will be offered.  
> ![](../images/Unleashed_Root_Shell.png)  

Although [the patch](../images/unleashed.ecdsa.patch.dbg) can be directly downloaded and used, I recommend either [creating the patch yourself](../Scripts/create_unleashed_ecdsa_patch.sh) or [decrypting the patch](DecryptRuckusBackups.md) to verify it does only what it should.

> If you run into problems and need to go back to using an RSA host key for SSH then you can apply [this patch](../images/unleashed.restore_rsa.patch.dbg) to generate a new RSA key.

## ZoneDirector 1200 ECDSA SSH Host Key Procedure

[This patch](../images/zd1200.ecdsa.patch.img) should be uploaded as a Software Upgrade (`Administer` > `Upgrade` > `Software Upgrade`).  
> The upload process completes the patching; no upgrade will be offered. Instead you will receive confirmation the patch has successfully completed.  

Although [the patch](../images/zd1200.ecdsa.patch.img) can be directly downloaded and used, I recommend either [creating the patch yourself](../Scripts/create_zd1200_ecdsa_patch.sh) or [decrypting the patch](DecryptRuckusBackups.md) to verify it does only what it should.

> If you run into problems and need to go back to using an RSA host key for SSH then you can apply [this patch](../images/zd1200.restore_rsa.patch.img) to generate a new RSA key.
