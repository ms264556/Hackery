#!/bin/bash

# Create a ZoneDirector Upgrade Image which tells SSH server to use ECDSA rather than RSA.

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
VERSION=10.99.99.99
BUILD=999
REQUIRE_SIZE=1000
REQUIRE_VERSIONS=9.9.0.0 9.10.0.0 9.10.1.0 9.10.2.0 9.12.0.0 9.12.1.0 9.12.2.0 9.12.3.0 9.13.0.0 9.13.1.0 9.13.2.0 9.13.3.0 10.0.0.0 10.1.0.0 10.1.1.0 10.1.2.0 10.2.0.0 10.2.1.0 10.3.0.0 10.3.1.0 10.4.0.0 10.4.1.0 10.5.0
REQUIRE_PLATFORM=nar5520
REQUIRE_SUBPLATFORM=cob7402
END

cat <<END >all_files
*
END

cat <<END >upgrade_check.sh
#!/bin/sh

killall dropbear > /dev/null 2>&1
rm -f /etc/airespider/dropbear/dropbear_host_rsa_key > /dev/null 2>&1
dropbearkey -t ecdsa -f /etc/airespider/dropbear/dropbear_host_rsa_key > /dev/null 2>&1
/etc/init.d/dropbear > /dev/null 2>&1

echo "SSH is now using ECDSA.\n<br />"
END

chmod +x upgrade_check.sh
rm -f zd.patch.tgz
tar czf zd.patch.tgz metadata all_files upgrade_check.sh
rks_encrypt zd.patch.tgz zd1200.ecdsa.patch.img
rm all_files metadata upgrade_check.sh zd.patch.tgz
