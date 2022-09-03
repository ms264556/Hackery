#!/bin/bash

# Create an Unleashed Upgrade Preload Image which converts a locked US AP to an unlocked WW AP.

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
bsp set fixed_ctry_code 0
bsp commit
rm -rf /tmp/unleashed_upgrade
echo Unlocked Country Code
exit 1
END
chmod +x upgrade_tool
cp upgrade_tool upgrade_tool.sh
cp upgrade_tool upgrade_download_tool.sh

rm -f unleashed.patch.tgz
tar czf unleashed.patch.tgz upgrade_tool upgrade_tool.sh upgrade_download_tool.sh
rks_encrypt unleashed.patch.tgz unleashed.unlock.dbg
rm unleashed.patch.tgz upgrade_tool upgrade_tool.sh upgrade_download_tool.sh
