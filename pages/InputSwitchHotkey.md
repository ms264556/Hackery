# Setup Hotkey to Switch Dell monitor between PCs

## Windows PC
### 1) Install Dell Display Manager (DDM)
Currently here:
* [https://dl.dell.com/FOLDER09052092M/1/ddmsetup.exe](https://dl.dell.com/FOLDER09052092M/1/ddmsetup.exe)

### 2) Install DDM Hotkey Manager (DDMHKM)
Currently here:
* [http://www.entechtaiwan.com/files/ddmhkm.exe](http://www.entechtaiwan.com/files/ddmhkm.exe)

### 3) Configure the Hotkey

* Run the downloaded `ddmhkm.exe` to start the DDM Hotkey Manager.
* In the _DDM command-line parameters_ box, type `/1:SetActiveInput HDMI`.  
* Click in the _Select system-wide-hotkey_, and press the hotkey combination.
* Close the DDM Hotkey Manager.
* Exit & Restart the Dell Display Manager.

## Linux PC
### 1) Install ddcutil
```bash
sudo bash
```

```bash
apt install ddcutil
```
### 2) Allow runnning of ddcutil without Administrator prompt
```bash
cat <<EOF >/usr/share/polkit-1/actions/sh.fabi.pkexec.ddcutil.policy
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE policyconfig PUBLIC
 "-//freedesktop//DTD PolicyKit Policy Configuration 1.0//EN"
 "http://www.freedesktop.org/standards/PolicyKit/1/policyconfig.dtd">
<policyconfig>

    <action id="sh.fabi.pkexec.ddcutil">
    <message>Authentication is required to run the ddcutil</message>
    <icon_name>CHOOSEAGOODLOGO</icon_name>
    <defaults>
      <allow_any>yes</allow_any>
      <allow_inactive>yes</allow_inactive>
      <allow_active>yes</allow_active>
    </defaults>
    <annotate key="org.freedesktop.policykit.exec.path">/usr/bin/ddcutil</annotate>
    <annotate key="org.freedesktop.policykit.exec.allow_gui">false</annotate>
  </action>

</policyconfig>
EOF
```
```bash
cat <<EOF >/usr/share/polkit-1/rules.d/49-ddcutil_nopass_tony.rules
polkit.addRule(function(action, subject) {
    if (action.id == "sh.fabi.pkexec.ddcutil" && subject.user == "tony") {
        return polkit.Result.YES;
    }
});
EOF
```


### 3) Create script to Switch Inputs
```bash
cat <<EOF >/usr/local/bin/switch-monitor-to-displayport.sh
#!/bin/bash
pkexec ddcutil setvcp 60 0x0f
EOF
chmod +x /usr/local/bin/switch-monitor-to-displayport.sh
```

> ```60``` is the ddc inputsource, and ```0x0f``` is my monitor's inputsource code for DisplayPort1.  
> If you don't know your monitor's inputsource codes the you can [look them up here](https://github.com/ddccontrol/ddccontrol-db/tree/master/db/monitor).

### 4) Setup the Global Hotkey
Varies depending on Linux distro.

For Linux Mint:
* Open Keyboard Settings > Shortcuts > Custom Shortcuts
* Press _Add custom shortcut_ button
* In the _Name:_ box, enter something like `Switch Monitor To DisplayPort`
* In the _Command:_ box, enter `/usr/local/bin/switch-monitor-to-displayport.sh`
* Press the _Add_ button
* In the _Keyboard bindings_ list, click on first `unassigned` slot
* Press the hotkey combination

