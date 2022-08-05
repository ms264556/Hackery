# Customize Ruckus ZoneDirector Software

The ZoneDirector upgrade process just runs a script (`ac_upg.sh`) from the Software Image, and nothing is signed! So it's very easy to customize your ZoneDirector.

You'll need the to decrypt/encrypt the images. I include bash functions to do this here. If you prefer C# then look in the Decryption/Encryption page.

## Ruckus Crypt bash Functions (using Python)
> Python turned out to be really slow to work with bytes (80 seconds to process a ~170MB ZoneDirector image on my PC), so I changed the Python version to work with a struct of ints instead. If you're just processing backups then this is unimportant: they're tiny so they only take a second.

```bash
function rks_encrypt {
RUCKUS_SRC="$1" RUCKUS_DEST="$2" python3 - <<END
import os
import struct

input_path = os.environ['RUCKUS_SRC']
output_path = os.environ['RUCKUS_DEST']

(xor_int, xor_flip) = struct.unpack('QQ', b')\x1aB\x05\xbd,\xd6\xf25\xad\xb8\xe0?T\xc58')
structInt8 = struct.Struct('Q')

with open(input_path, "rb") as input_file:
    with open(output_path, "wb") as output_file:
        input_len = os.path.getsize(input_path)
        input_blocks = input_len // 8
        output_int = 0
        input_data = input_file.read(input_blocks * 8)
        for input_int in struct.unpack_from(str(input_blocks) + "Q", input_data):
            output_int ^= xor_int ^ input_int
            xor_int ^= xor_flip
            output_file.write(structInt8.pack(output_int))
        
        input_block = input_file.read()
        input_padding = 8 - len(input_block)
        input_int = structInt8.unpack(input_block.ljust(8, bytes([input_padding | input_padding << 4])))[0]
        output_int ^= xor_int ^ input_int
        output_file.write(structInt8.pack(output_int))
END
}
```
```bash
function rks_decrypt {
RUCKUS_SRC="$1" RUCKUS_DEST="$2" python3 - <<END
import os
import struct

input_path = os.environ['RUCKUS_SRC']
output_path = os.environ['RUCKUS_DEST']

(xor_int, xor_flip) = struct.unpack('QQ', b')\x1aB\x05\xbd,\xd6\xf25\xad\xb8\xe0?T\xc58')
structInt8 = struct.Struct('Q')

with open(input_path, "rb") as input_file:
    with open(output_path, "wb") as output_file:
        input_data = input_file.read()
        previous_input_int = 0
        for input_int in struct.unpack_from(str(len(input_data) // 8) + "Q", input_data):
            output_bytes = structInt8.pack(previous_input_int ^ xor_int ^ input_int)
            xor_int ^= xor_flip
            previous_input_int = input_int
            output_file.write(output_bytes)
        
        output_padding = int.from_bytes(output_bytes[-1:], 'big') & 0xf
        output_file.seek(-output_padding, os.SEEK_END)
        output_file.truncate()
END
}
```
### Decrypt a backup
```bash
rks_decrypt ruckus_db_073122_14_17.bak ruckus_db_073122_14_17.bak.tgz
```
### Re-encrypt a backup
```bash
rks_encrypt ruckus_db_073122_14_17.bak.tgz ruckus_db_073122_14_17.modded.bak
```

## Give Yourself 5 Years of ZoneDirector Support (Upgrade) Entitlement

We can patch out the code which signature-checks support entitlement files, then upload a 5 year (or longer) entitlement.

>The Ruckus Support Activation Server (at https://supportactivation.ruckuswireless.com/) is currently handing out 30 day entitlements when asked, so that ZoneDirectors have an endless rolling 30 day entitlement.
>It's useful to see how content can be injected into the software image, or if Ruckus start enforcing Support licenses again in the future.

### Extract the upgrade image
```bash
rks_decrypt zd1200_10.5.1.0.176.ap_10.5.1.0.176.img zd1200_10.5.1.0.176.ap_10.5.1.0.176.img.tgz
gzip -d zd1200_10.5.1.0.176.ap_10.5.1.0.176.img.tgz
tar -xvf zd1200_10.5.1.0.176.ap_10.5.1.0.176.img.tar ac_upg.sh metadata
```

### Edit the upgrade image

Edit the `ac_upg.sh` file, adding code to inject your changes. You can insert your injection script immediately following these lines within the `_upg_rootfs()` function:-

Before:-
```bash
cd /mnt; 
echo "FILE:`/usr/bin/md5sum ./$ZD_KERNEL`" >>/mnt/file_list.txt
```

After
```bash
cd /mnt; 
echo "FILE:`/usr/bin/md5sum ./$ZD_KERNEL`" >>/mnt/file_list.txt
CUR_WRAP_MD5=`md5sum /mnt/bin/sys_wrapper.sh | cut -d' ' -f1`
sed -i -e '/uudecode.*signature\.ud.*signature\.tmp/d' -e 's/openssl dgst .*verify .*signature\.ud .*support\.tmp/true/' /mnt/bin/sys_wrapper.sh
NEW_WRAP_MD5=`md5sum /mnt/bin/sys_wrapper.sh | cut -d' ' -f1`
sed -i -e "s/$CUR_WRAP_MD5/$NEW_WRAP_MD5/" /mnt/file_list.txt
```

If you're on the same firmware version as the upgrade, you can also edit the metadata file, and increase the BUILD number to 999, so this is treated as a version upgrade.

### Repackage the image

```bash
tar uvf zd1200_10.5.1.0.176.ap_10.5.1.0.176.img.tar ac_upg.sh metadata
gzip zd1200_10.5.1.0.176.ap_10.5.1.0.176.img.tar
rks_encrypt zd1200_10.5.1.0.176.ap_10.5.1.0.176.img.tar.gz zd1200_10.5.1.0.176.ap_10.5.1.0.176.patched.img
```

Now you can use the image to do an upgrade directly from the Web UI.

### Create a support file, and upload it

The support file looks like this (but with your ZoneZirector's serial number instead of 000000000):-

```xml
<support-list>
	<support zd-serial-number="000000000" service-purchased="904" date-start="1659369540" date-end="1817135940" ap-support-number="licensed" DELETABLE="false"></support>
<signature></signature>
</support-list>
```

You'll need to save this file as `support` (no extension), and then poke it into a `.tgz` file:-

```bash
tar -czf support.tgz support
```

Then upload it!

## Directly editing the ext2 root image

This doesn't work so far. I tried the below, but the ZoneDirector just rebooted into the un-upgraded software.  
If you have time and manage to get this working then let me know.

```bash
mkdir zdimage
tar -xzvf zd1200_10.5.1.0.176.ap_10.5.1.0.176.decrypted.tgz -C zdimage
mv zdimage/rootfs.i386.ext2.director1200.img rootfs.i386.ext2.director1200.img.gz
gzip -d rootfs.i386.ext2.director1200.img.gz
mkdir zdroot
sudo mount -o loop,rw,noatime -t ext2 rootfs.i386.ext2.director1200.img zdroot
pushd zdroot/etc/persistent-scripts/
sudo ln -s ../../bin/busybox sh
popd
sudo umount zdroot
gzip rootfs.i386.ext2.director1200.img
mv rootfs.i386.ext2.director1200.img.gz zdimage/rootfs.i386.ext2.director1200.img
md5sum zdimage/rootfs.i386.ext2.director1200.img # copy the md5
nano zdimage/metadata # paste the new md5 over the old ROOTFS_MD5SUM
find zdimage -printf "%P\n" | tar -czf zd1200_10.5.1.0.176.ap_10.5.1.0.176.modified.tgz --no-recursion -C zdimage -T -
```
