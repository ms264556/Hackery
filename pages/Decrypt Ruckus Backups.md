# Decrypt Ruckus Unleashed / ZoneDirector Backups

I'm using this to decrypt, edit, re-encrypt ZoneDirector upgrade images (which is not working yet).

But it also works for ZoneDirector & Unleashed backups and debug logs, which is useful.

There's a C# and Python version. The C# version is much more efficient, so use that if you have a choice (or want to convert the algorithm to a different language).

## Ruckus Crypt PowerShell Functions (using C#)
```powershell
Add-Type -Language CSharp @"
using System;
using System.IO;
namespace Ms264556
{
    public static class Ruckus
    {
        private static readonly byte[] XorBytes = new byte[] { 0x29, 0x1A, 0x42, 0x05, 0xbd, 0x2c, 0xd6, 0xf2, 0x1c, 0xb7, 0xfa, 0xe5, 0x82, 0x78, 0x13, 0xca };

        public static void DecryptFile(string sourcePath, string destinationPath)
        {
            var inputBlock = new byte[8];
            var previousInputBlock = new byte[8];
            var outputBlock = new byte[8];

            using (var input = File.OpenRead(sourcePath))
            using (var output = File.Open(destinationPath, FileMode.Create))
            {
                int offset = 0;
                while (true)
                {
                    var bytesRead = input.Read(inputBlock, 0, 8);

                    if (offset > 7)
                    {
                        var bytesToWrite = bytesRead == 0 ? (8 - outputBlock[7]) & 0xf : 8;
                        if (bytesToWrite > 0) { output.Write(outputBlock, 0, bytesToWrite); }
                    }

                    if (bytesRead == 0) break;
                    if (bytesRead != 8) throw new Exception("Corrupt input file");

                    for (int i = 0; i < bytesRead; i++)
                    {
                        outputBlock[i] = (byte)(XorBytes[offset++ % 16] ^ inputBlock[i] ^ previousInputBlock[i]);
                        previousInputBlock[i] = inputBlock[i];
                    }
                }
            }
        }

        public static void EncryptFile(string sourcePath, string destinationPath)
        {
            var inputBlock = new byte[8];
            var previousInputBlock = new byte[8];

            using (var input = File.OpenRead(sourcePath))
            using (var output = File.Open(destinationPath, FileMode.Create))
            {
                int offset = 0;
                while (true)
                {
                    var bytesRead = input.Read(inputBlock, 0, 8);
                    if (bytesRead < 8)
                    {
                        byte paddingBytes = (byte)(8 - bytesRead);
                        byte padding = (byte)(paddingBytes | paddingBytes << 4);
                        for (int i = 0; i < paddingBytes; i++) { inputBlock[i + bytesRead] = padding; }
                    }

                    for (int i = 0; i < 8; i++)
                    {
                        inputBlock[i] = (byte)(XorBytes[offset++ % 16] ^ inputBlock[i] ^ previousInputBlock[i]);
                        previousInputBlock[i] = inputBlock[i];
                    }
                    output.Write(inputBlock, 0, 8);

                    if (bytesRead < 8) break;
                }
            }
        }
    }
}
"@;
```
### Decrypt a backup
```powershell
[Ms264556.Ruckus]::DecryptFile("C:\Users\Ms264556\Downloads\ruckus_db_073122_14_17.bak", "C:\Users\Ms264556\Downloads\ruckus_db_073122_14_17.bak.tgz")
```
### Re-encrypt a backup
```powershell
[Ms264556.Ruckus]::EncryptFile("C:\Users\Ms264556\Downloads\ruckus_db_073122_14_17.bak.tgz", "C:\Users\Ms264556\Downloads\ruckus_db_073122_14_17.modded.bak")
```

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

## What about Backup > Decrypt > Edit > Re-encrypt > Restore

I haven't tried this yet. I'll try soon, and update the page. Let me know if you're successful.


## What about installing patched ZoneDirector system images

For ZoneDirector upgrade images, I tried patching a root shell into a decrypted system image using the script below (in WSL).

It passed the initial upgrade checks, but the upgrade didn't happen: after a couple of reboots the system is back to the original firmware.

I don't have time to investigate for a few weeks, so popping the steps I followed here in case anyone spots an obvious bug (my linux skills are very weak) or wants to experiment.

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
