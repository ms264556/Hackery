# Customize Ruckus ZoneDirector Software

The ZoneDirector upgrade process just runs a script (`ac_upg.sh`) from the Software Image, and nothing is signed! So it's very easy to customize your ZoneDirector.

You'll need to decrypt/encrypt the images. I include bash functions to do this here. If you prefer C# then look in the Decryption/Encryption page.

## Ruckus Crypt bash Functions (using Python)
> Use the C# version on the Decrypt/Encrypt page if you want something much faster.

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
### Decrypt a software image
```bash
rks_decrypt zd1200_10.5.1.0.176.ap_10.5.1.0.176.img zd1200_10.5.1.0.176.ap_10.5.1.0.176.img.tgz
```
### Re-encrypt a software image
```bash
rks_encrypt zd1200_10.5.1.0.176.ap_10.5.1.0.176.img.tgz zd1200_10.5.1.0.176.ap_10.5.1.0.176.modded.img
```

## Editing a Software Image

### Extract the upgrade image
```bash
rks_decrypt zd1200_10.5.1.0.176.ap_10.5.1.0.176.img zd1200_10.5.1.0.176.ap_10.5.1.0.176.img.tgz
gzip -d zd1200_10.5.1.0.176.ap_10.5.1.0.176.img.tgz
tar -xvf zd1200_10.5.1.0.176.ap_10.5.1.0.176.img.tar ac_upg.sh
```

### Injecting content during the upgrade process 

Edit the `ac_upg.sh` file, adding code to inject your changes.  
You can insert your injection script immediately into the `_upg_rootfs()` function:-

Before:-
```bash
echo "FILE:`/usr/bin/md5sum ./$ZD_KERNEL`" >>/mnt/file_list.txt
cd $popd;
```

After
```bash
echo "FILE:`/usr/bin/md5sum ./$ZD_KERNEL`" >>/mnt/file_list.txt
#
# Your code goes here.
# The upgraded root fs is now RW mounted at /mnt for you to edit.
# If you have extra files you want to install then add them to the tar file and extract them here.
#
cd $popd;
```

### Repackage the image

```bash
tar uvf zd1200_10.5.1.0.176.ap_10.5.1.0.176.img.tar ac_upg.sh
gzip zd1200_10.5.1.0.176.ap_10.5.1.0.176.img.tar
rks_encrypt zd1200_10.5.1.0.176.ap_10.5.1.0.176.img.tar.gz zd1200_10.5.1.0.176.ap_10.5.1.0.176.patched.img
```

Now you can use the image to do an upgrade directly from the Web UI.

### Making changes directly to your ZoneDirector

If you want to tinker then you can [patch a root shell into your ZoneDirector](ZD1200AddRootShell.md).


`/` is mounted read-only.
Anything which needs to be writable is either linked into `/writable` or is in a tmpfs mount.  

Your ZoneDirector configuration files live in `/etc/airespider` - which is a link to `/writable/etc/airespider` - so  you can edit these files and the changes will be persistent.  
The factory-default versions of these files live in `/etc/airespider-defaults`, in case you need to refer to them.

If you need to make changes outside of the `/writable` mount, then you can temporarily mount `/` read/write:-

```bash
mount -o remount,rw /
# ...now make your modifications
# then remount ro when you're done...
mount -o remount,ro /
```

Many configuration functions are delegated to `/bin/sys_wrapper.sh`. If you're wanting to tweak some behaviour then this is a good first place to check.  
