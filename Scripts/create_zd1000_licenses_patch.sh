#!/bin/bash

# Create a ZoneDirector Upgrade Image which adds 50 AP Licenses and Upgrade Entitlement until August 2027.

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

cat <<END >metadata
PURPOSE=upgrade
VERSION=9.99.99.99
BUILD=999
REQUIRE_SIZE=1000
REQUIRE_VERSIONS=2.0.0.0 2.0.1.0 2.0.1.1 3.0.0.0 3.0.1.0 3.0.2.0 3.0.3.0 3.0.4.0 3.0.5.0 6.0.0.0 6.0.0.1 6.0.0.2 6.0.1.0 6.0.1.1 6.0.2.0 6.0.2.1 6.0.3.0 6.0.3.1 6.0.4.0 7.0.0.0 7.0.1.0 7.0.2.0 7.1.0.0 7.3.0.0 8.0.0.0 8.0.0.1 8.0.1.0 8.0.2.0 8.1.1.0 8.2.0.0 8.2.2.0 8.4.0.0 9.0.0.0 9.1.0.0 9.1.0.3 9.1.1.0 9.1.2.0 9.2.0.0 9.3.0.0 9.3.1.0 9.3.2.0 9.3.4.0
REQUIRE_PLATFORM=ar7100
ABILITY=ZD5000 
END

cat <<END >all_files
*
END

cat <<END >upgrade_check.sh
#!/bin/sh

mount -o remount,rw /

cat <<EOF >/etc/airespider-images/license-list.xml
<license-list name="50 AP Management" max-ap="50" max-client="1250" value="0x0000000f">
</license-list>
EOF

bsp set model ZD1050 > /dev/null 2>&1
bsp commit > /dev/null 2>&1

mount -o remount,ro /

echo "Added AP Licenses.\n<br />"

END

chmod +x upgrade_check.sh
cp upgrade_check.sh ac_upg.sh
rm -f zd.patch.tgz
tar czf zd.patch.tgz metadata all_files upgrade_check.sh ac_upg.sh
rks_encrypt zd.patch.tgz zd1000.licenses.patch.img
rm all_files metadata upgrade_check.sh ac_upg.sh zd.patch.tgz
