# Add a Root Shell to Ruckus Unleashed

Until late 2019 you could escape from the Ruckus CLI to a root shell.  
You can add this functionality back to your Unleashed AP, if you'd find it useful.  

[This patch](../images/unleashed.root.patch.dbg) should be uploaded as a `Preload Image` (`Admin & Services` > `Administration` > `Upgrade` > `Local Upgrade` > `Preload Image`).  
> The upload process completes the patching; no upgrade will be offered. Simply wait a few seconds after the upload, and the root shell will be available.
> ![](../images/Unleashed_Root_Shell.png)

To access the root shell from the CLI:-

```console
ruckus> enable 
ruckus# debug 
You have all rights in this mode.
ruckus(debug)# script 
ruckus(script)# exec .root.sh

Ruckus Wireless Unleashed -- Command Line Interface
Enter 'help' for a list of built-in commands.

ruckus$ 
```

## Creating the Patch Image yourself (from Linux or WSL)

> Although [the patch](../images/unleashed.root.patch.dbg) can be directly downloaded and used, I recommend either [creating the patch yourself](../Scripts/create_unleashed_root_patch.sh) or [decrypting the patch](DecryptRuckusBackups.md) to verify it does only what it should.
