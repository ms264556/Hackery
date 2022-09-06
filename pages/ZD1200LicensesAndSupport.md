# Add AP Licenses and Upgrade Entitlement to a ZoneDirector 1100/1200/3000

To prevent e-waste and save these from landfills, you may use the procedure here to enable upgrades and remove the 5 AP limit from your ZoneDirector for use in a homelab or personal environment.

>If you have a ZoneDirector 1000 or 5000 then you can still add AP Licenses, but you'll have to (temporarily) install older software.  
>Follow the instructions here: [Add AP Licenses to a ZoneDirector](ZDAddLicenses.md)

The patch [[ZD1200](../images/zd1200.licenses.patch.img)/[ZD3000](../images/zd3000.licenses.patch.img)/[ZD1100](../images/zd1100.licenses.patch.img)] should be uploaded as a Software Upgrade (`Administer` > `Upgrade` > `Software Upgrade`).  
> The upload process completes the patching; no upgrade will be offered. Instead you will receive confirmation the patch has successfully completed.  
> ![](../images/Support_And_Licenses_1031.png)

Although the above patch can be directly downloaded and used, I recommend either creating the patch yourself [[ZD1200](../Scripts/create_zd1200_licenses_patch.sh)/[ZD3000](../Scripts/create_zd3000_licenses_patch.sh)/[ZD1100](../Scripts/create_zd1100_licenses_patch.sh)] or [decrypting the patch](DecryptRuckusBackups.md) to verify it does only what it should.
