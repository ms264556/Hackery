# Add Licenses and Upgrade Entitlement to ZoneDirector

To prevent e-waste and save these from landfills, you may use the procedure here to enable upgrades, enable URL filtering and apply the maximum number of AP licenses to your ZoneDirector for use in a homelab or personal environment.

The appropriate patch should be uploaded as a Software Upgrade (`Administer` > `Upgrade` > `Software Upgrade`):-

* [ZD1000](../images/zd1000.licenses.patch.img)
* [ZD1100](../images/zd1100.licenses.patch.img)
* [ZD1200](../images/zd1200.licenses.patch.img)
* [ZD3000](../images/zd3000.licenses.patch.img)

The upload process completes the patching; no upgrade will be offered. Instead you will receive confirmation the patch has successfully completed:-

![](../images/Support_And_Licenses_1031.png)

>Subsequent software upgrades will remove the patched support license: you will need to re-apply this patch each time you upgrade your ZoneDirector's software.

You can, if you wish, create the patch yourself. Build scripts are here: [[ZD1000](../Scripts/create_zd1000_licenses_patch.sh)/[ZD1100](../Scripts/create_zd1100_licenses_patch.sh)/[ZD1200](../Scripts/create_zd1200_licenses_patch.sh)/[ZD3000](../Scripts/create_zd3000_licenses_patch.sh)].  
Alternatively, you can [decrypt the patch](DecryptRuckusBackups.md) to verify it's only doing what it should.

## Adding Licenses to a ZD5000 or your Unleashed network

If you have a ZoneDirector 5000 then you can still add AP Licenses.  
Follow the manual instructions here: [Add AP Licenses to a ZoneDirector](ZDAddLicenses.md)

If you want to enable URL filtering on your Unleashed network, follow the instructions here: [Add Licenses to Unleashed](UnleashedAddLicenses.md)
