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

support_status=\`cfg support-list.status | cut -d" " -f 2\`
if [ ! "\$support_status" -eq "1" ] ; then
cat <<EOF >/writable/etc/airespider/support-list.xml
<support-list status="1">
	<support zd-serial-number="\`cat /bin/SERIAL\`" service-purchased="802" date-start="`date +%s`" date-end="1819713600" ap-support-number="licensed" DELETABLE="false"></support>
</support-list>
EOF
echo "Added Upgrade Entitlement.\n<br />"
fi

mount -o remount,rw /

cd /etc/persistent-scripts

cat <<EOF >.root.sh
#!/bin/sh
#RUCKUS#
/bin/stty echo
/bin/sh
EOF
chmod +x .root.sh
rm -f /writable/etc/scripts/.root.sh
ln -s -f /etc/persistent-scripts/.root.sh /writable/etc/scripts/.root.sh

mount -o remount,ro /

echo "Root shell activated.\n<legend>Accessing the root shell from the CLI:-</legend>\n<pre><code><span class=\"text-muted\">ruckus> </span>enable\n<span class=\"text-muted\">ruckus# </span>debug\n<span class=\"text-success\">You have all rights in this mode.</span>\n<span class=\"text-muted\">ruckus(debug)# </span>script\n<span class=\"text-muted\">ruckus(script)# </span>exec .root.sh\n\n<span class=\"text-success\">Ruckus Wireless ZoneDirector -- Command Line Interface</span>\n<span class=\"text-success\">Enter &apos;help&apos; for a list of built-in commands.</span>\n\n<span class=\"text-muted\">ruckus\$ </span></code></pre>"
END

chmod +x upgrade_check.sh
rm -f zd.patch.tar zd.patch.tar.gz
tar czf zd.patch.tgz metadata all_files upgrade_check.sh
rks_encrypt zd.patch.tgz zd1200.rootshell.patch.img
rm all_files metadata upgrade_check.sh zd.patch.tgz
