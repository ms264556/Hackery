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
cat <<END >upgrade_tool.sh
exit 1
END

cat <<END >upgrade_tool
killall dropbear > /dev/null 2>&1
rm -f /writable/data/dropbear/dropbear_rsa_key > /dev/null 2>&1

dropbearkey -t ecdsa -f /writable/data/dropbear/dropbear_rsa_key > /dev/null 2>&1
dropbearkey -y -f /writable/data/dropbear/dropbear_rsa_key | sed -e'1 d' -e'3 d' > /writable/data/dropbear/dropbear_rsa_key.pub
dropbearkey -y -f /writable/data/dropbear/dropbear_rsa_key | sed -e'1,2 d' -e's/.* .* \(.*\)/\1/' > /writable/data/dropbear/dropbear_rsa_key.md5.fingerprint

# Ideally we'd just restart dropbear. Doesn't seem to work though (we get into an endless loop), so just reboot for now until I have time to investigate
# /usr/sbin/dropbear -e /var/run/-login -I 900 -p 22 -r /writable/data/dropbear/dropbear_rsa_key -j -k -A none
reboot
echo Patched ECDSA
exit 1
END
chmod +x upgrade_tool
chmod +x upgrade_tool.sh
cp upgrade_tool.sh upgrade_download_tool.sh

rm -f unleashed.patch.tgz
tar czf unleashed.patch.tgz upgrade_tool upgrade_tool.sh upgrade_download_tool.sh
rks_encrypt unleashed.patch.tgz "$1"
rm unleashed.patch.tgz upgrade_tool upgrade_tool.sh upgrade_download_tool.sh
