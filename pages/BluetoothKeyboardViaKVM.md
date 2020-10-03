# Sharing a Bluetooth Keyboard between Linux and Windows

I plug a USB Bluetooth dongle into my Dell monitor, so it follows me from PC to PC.

There's lots of instructions to pair a bluetooth keyboard in Windows then copy the link key to Linux. I need it the other way around: I want to pair the keyboard with my latest Linux install, then copy the link key to my Windows install.

Download `winexe`: this lets me run commands on a remote Windows PC. I've used the version below on several different Ubuntu-based distros:-
```bash
cd ~
wget https://github.com/ms264556/WinEXE-CentOS7/raw/master/winexe
chmod +x winexe
```

Now retrieve the link key and poke it into the Windows PC.
```bash
sudo bash # we can't see the necessary info as an ordinary user

windows_address=192.168.1.248 # change me to the Windows PCs address or hostname
windows_credentials=DOMAIN/USER%PASS # change me to the windows logon (remove DOMAIN/ if the account is local)

cd /var/lib/bluetooth
grep -r -H -A 1 --include=info "\[LinkKey\]" | sed "s/://g ; s~[/=]~ ~g ; s/.*/\L&/g ; s/-key.*/\U&/g" | awk '{getline;print $1 " /v " $2 " /t REG_BINARY /d " $4}' | xargs -I{} ~/winexe --user=$windows_credentials --system //$windows_address 'reg add HKLM\SYSTEM\CurrentControlSet\services\BTHPORT\Parameters\Keys\{} /f'
```