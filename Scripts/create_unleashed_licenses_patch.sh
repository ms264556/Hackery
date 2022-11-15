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
cp -f /tmp/unleashed_upgrade/upgrade_tool.sh /tmp/unleashed_upgrade/upgrade_tool

cat <<EOF >/etc/airespider/license-list.xml
<license-list name="128 AP Management" max-ap="128" max-client="2048" value="0x0000000f" urlfiltering-ap-license="128" is_temporal="true" is_url="1">
    <license id="1" name="URL Filtering Temporal License" feature-id="38" ap-num="128" generated-by="URL Filtering Temporal license" serial-number="\`cfg system.unleashed-network.unleashed-network-token | cut -d" " -f 2\`" end-time="1819713600" start-time="1661947200" countdown="157766400" status="0" detail="This license is available for 1826 days." />
</license-list>
EOF
cat <<EOF >/etc/airespider-images/license-list.xml
<license-list name="128 AP Management" max-ap="128" max-client="2048" value="0x0000000f" urlfiltering-ap-license="0" />
EOF

echo Added URL Filtering License
exit 1
END
chmod +x upgrade_tool
chmod +x upgrade_tool.sh
cp upgrade_tool.sh upgrade_download_tool.sh

rm -f unleashed.patch.tgz
tar czf unleashed.patch.tgz upgrade_tool upgrade_tool.sh upgrade_download_tool.sh
rks_encrypt unleashed.patch.tgz unleashed.url_filtering_license.patch.dbg
rm unleashed.patch.tgz upgrade_tool upgrade_tool.sh upgrade_download_tool.sh
