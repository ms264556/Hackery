# Add a URL Filtering License to Unleashed

Ruckus won't let you buy a URL Filtering license for your Unleashed network unless you are the original purchaser of the APs.

If you have a used Unleashed AP and would like to enable URL Filtering, you may use the procedure here to apply a license.

[This patch](../images/unleashed.url_filtering_license.patch.dbg) should be uploaded as a `Preload Image` (`Admin & Services` > `Administration` > `Upgrade` > `Local Upgrade` > `Preload Image`).  
> The upload process completes the patching; no upgrade will be offered. Simply wait a few seconds after the upload, and the license should be enabled.
> ![](../images/Unleashed_Root_Shell.png)

## Creating the Patch Image yourself (from Linux or WSL)

Although [the patch](../images/unleashed.url_filtering_license.patch.dbg) can be directly downloaded and used, I recommend either [creating the patch yourself](../Scripts/create_unleashed_licenses_patch.sh) or [decrypting the patch](DecryptRuckusBackups.md) to verify it does only what it should.
