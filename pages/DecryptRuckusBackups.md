# Decrypt Ruckus Unleashed / ZoneDirector Backups

This code works for ZoneDirector & Unleashed backups and debug logs, and also ZoneDirector Software Images.

There is a faster Windows Powershell/C# version at the bottom of this page.

## Ruckus Crypt bash Functions (using Python)

> Python is really slow. To keep things speedy(ish), this code is more ugly and complicated than the C# version below, and uses lots of memory.

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

## Backup > Decrypt > Edit > Re-encrypt > Restore
Plenty of scope for good stuff. e.g. tweaking the `metadata` file lets you...

### Restore Onto Mismatched Firmware Version / Downlevel Hardware
* Restore a backup from a previous firmware version.
* Restore a backup from a 'bigger' model to a 'smaller' model (e.g. if you replaced an old ZD3000 with a ZD1200).

```bash
rks_decrypt zd1200_103.bak zd1200_1051.bak.tar.gz
gunzip zd1200_1051.bak.tar.gz
cat > metadata <<END
PURPOSE=backup
VERSION=10.5.1.0
BUILD=176
PLATFORM=COB7402
APMODEL=ZD1200
END
tar uvf zd1200_1051.bak.tar metadata
gzip zd1200_1051.bak.tar
rks_encrypt zd1200_1051.bak.tar.gz zd1200_1051.bak
```

### Choose Passwords for Internal DPSK Users

```bash
rks_decrypt ruckus.bak ruckus.bak.tgz
mkdir bakimg
tar -xzvf ruckus.bak.tgz -C bakimg
```

Now edit `bakimg/etc/airespider/dpsk-list.xml` to add/remove users, change VLANs & change passwords.  
Then...

```bash
find bakimg -printf "%P\n" | tar -czf ruckus.modded.bak.tgz --no-recursion -C bakimg -T -
rks_encrypt ruckus.modded.bak.tgz ruckus.modded.bak
```

All done. Restore your modified backup.

#### Encoding DPSK Passphrases

>The only tricky part is the `x-passphrase` attribute for each `<dpsk>`.  
>This needs to be ROT1 encoded, and then HTML encoded. E.g. for the passphrase:-

```
#*_ljpdRdtm/]2*i`SPSK.:%Li/aZDKts5J?pUJX+lp[t]b!RQ+,=-dmx0TE`U
```

>you can run something like this:-

```bash
echo '#*_ljpdRdtm/]2*i`SPSK.:%Li/aZDKts5J?pUJX+lp[t]b!RQ+,=-dmx0TE`U' | tr ' -}' '!-~' | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g'
```

>to obtain the `x-passphrase`:-

```
$+`mkqeSeun0^3+jaTQTL/;&amp;Mj0b[ELut6K@qVKY,mq\u^c&quot;SR,-&gt;.eny1UFaV
```

## Ruckus Crypt PowerShell Functions (using C#)

>These functions are much quicker than the python functions. They use much less memory, and it's easier to see the algorithm too.   
>But if you want to process your backup for re-upload then you need to be careful to use unix line endings in a few places, so it will probably be easier to tinker in WSL if you're a Windows user.

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
