# Switch the Ruckus Unleashed/ZoneDirector SSH Host Key Algorithm to ECDSA

Ruckus Unleashed / ZoneDirector use RSA 2048 bit for their SSH host keys.  
This algorithm is deprecated, so most clients will require you to specify `-oHostKeyAlgorithms=+ssh-rsa` to connect.

You can tweak things so that Unleashed or ZoneDirector use (non-deprecated) ECDSA instead...

## Unleashed ECDSA SSH Host Key Procedure
> This only changes the Master AP - you will need to follow the same procedure again if another AP begins acting as Master.  
> Since the procedure reboots your Master AP, you will probably have an opportunity to do this immediately.

[This patch](../images/unleashed.ecdsa.patch.dbg) should be uploaded as a `Preload Image` (`Admin & Services` > `Administration` > `Upgrade` > `Local Upgrade` > `Preload Image`).  
> The upload process completes the change and reboots your Master AP; no upgrade will be offered.  
> ![](../images/Unleashed_Root_Shell.png)  

Although [the patch](../images/unleashed.ecdsa.patch.dbg) can be directly downloaded and used, I recommend either [creating the patch yourself](../Scripts/create_unleashed_ecdsa_patch.sh) or [decrypting the patch](DecryptRuckusBackups.md) to verify it does only what it should.

> If you run into problems and need to go back to using an RSA host key for SSH then you can apply [this patch](../images/unleashed.restore_rsa.patch.dbg) to generate a new RSA key.

## ZoneDirector 1200 ECDSA SSH Host Key Procedure

[This patch](../images/zd1200.ecdsa.patch.img) should be uploaded as a Software Upgrade (`Administer` > `Upgrade` > `Software Upgrade`).  
> The upload process completes the patching; no upgrade will be offered. Instead you will receive confirmation the patch has successfully completed.  

Although [the patch](../images/zd1200.ecdsa.patch.img) can be directly downloaded and used, I recommend either [creating the patch yourself](../Scripts/create_zd1200_ecdsa_patch.sh) or [decrypting the patch](DecryptRuckusBackups.md) to verify it does only what it should.

> If you run into problems and need to go back to using an RSA host key for SSH then you can apply [this patch](../images/zd1200.restore_rsa.patch.img) to generate a new RSA key.
