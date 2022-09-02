# Add a Root Shell to your Ruckus Unleashed network

Until late 2019 you could escape from the Ruckus CLI to a root shell.  
You can add this functionality back to your Unleashed network, if you'd find it useful.  

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

> Although [the patch](../images/unleashed.root.patch.dbg) can be directly downloaded and used, I recommend either creating the patch yourself or [decrypting the patch](DecryptRuckusBackups.md) to verify it does only what it should.

Save the script below to e.g. `create_patched_unleash.sh`, make it executable (e.g. `chmod +x create_patched_unleash.sh`), then you can create an upgrade an installation image:-
```bash
./create_patched_unleash.sh unleashed.root.patch.dbg
```

```bash
#!/bin/bash

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

cat <<END >upgrade_tool
cat <<EOF >/writable/etc/scripts/.root.sh
#!/bin/sh
#RUCKUS#
/bin/stty echo
/bin/sh
EOF
chmod +x /writable/etc/scripts/.root.sh
rm -rf /tmp/unleashed_upgrade
echo Patched Root Shell
exit 1
END
chmod +x upgrade_tool
cp upgrade_tool upgrade_tool.sh
cp upgrade_tool upgrade_download_tool.sh

rm -f unleashed.patch.tgz
tar czf unleashed.patch.tgz upgrade_tool upgrade_tool.sh upgrade_download_tool.sh
rks_encrypt unleashed.patch.tgz "$1"
rm unleashed.patch.tgz upgrade_tool upgrade_tool.sh upgrade_download_tool.sh
```
