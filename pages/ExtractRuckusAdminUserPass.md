# Extract Ruckus Unleashed / ZoneDirector passwords from Backups

Use this script if you've forgotten the login details for your Ruckus Unleashed/ZoneDirector, but you have access to a backup.

> If your password contained any `~` characters, these aren't stored in the backup.  
> Hopefully the rest of the password jogs your memory enough so you can insert these in the right place.

## Bash script (using Python)

Paste this script into a shell, to create the extraction function:-
```bash
function ruckus_getadmin {
RUCKUS_BAK="$1" python3 - <<END
import io
import os
import struct
import tarfile
import xml.etree.ElementTree as ET

input_path = os.environ['RUCKUS_BAK']

(xor_int, xor_flip) = struct.unpack('QQ', b')\x1aB\x05\xbd,\xd6\xf25\xad\xb8\xe0?T\xc58')
structInt8 = struct.Struct('Q')

with open(input_path, 'rb') as input_file:
    with io.BytesIO() as output_file:
        input_data = input_file.read()
        previous_input_int = 0
        for input_int in struct.unpack_from(str(len(input_data) // 8) + 'Q', input_data):
            output_bytes = structInt8.pack(previous_input_int ^ xor_int ^ input_int)
            xor_int ^= xor_flip
            previous_input_int = input_int
            output_file.write(output_bytes)
        output_file.seek(0)
        with tarfile.open(fileobj = output_file) as tar:
            system_xml = tar.extractfile('etc/airespider/system.xml').read()
            tree = ET.fromstring(system_xml)
            admin = tree.find('./admin')
            username = admin.attrib['username']
            x_password = admin.attrib['x-password']
            password = ''.join(chr(ord(letter)-1) for letter in x_password)
            print('user =', username)
            print('pass =', password)
END
}
```
Now you can point the function at your latest backup:-
```bash
$ ruckus_getadmin ruckus_db_080622_16_21.bak
user = ms264556
pass = MyPassw0rd
$
```
