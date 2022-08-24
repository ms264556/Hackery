# Setup Hotkeys to turn PbP On/Off on Dell monitors

This is useful if you want to run a full-screen Teams/Zoom meeting or watch a full-screen video, but leave a panel free for making notes or surfing the internet.

### 1) Download and Install Dell Display Manager (DDM)
Currently here:
* [https://dl.dell.com/FOLDER08877637M/1/ddmsetup2107.exe?fn=ddmsetup2107.exe](https://dl.dell.com/FOLDER08877637M/1/ddmsetup2107.exe?fn=ddmsetup2107.exe)

### 2) Download DDM Hotkey Manager (DDMHKM)
Currently here:
* [http://www.entechtaiwan.com/files/ddmhkm.exe](http://www.entechtaiwan.com/files/ddmhkm.exe)

### 3) Configure the Hotkey

> My example assumes a Dell monitor supporting 80/20 is installed (e.g. U4021QW), and that the PC has 2 cables connected to ports DP1 & HDMI2.

* Run the downloaded `ddmhkm.exe` to start the DDM Hotkey Manager.
* In the _DDM command-line parameters_ box, type `/1:SetPxPMode Off`.  
* Click in the _Select system-wide-hotkey_, and press the hotkey combination you want for No-PbP.
* Increment the Hotkey from 0 to 1
* In the _DDM command-line parameters_ box, type `/1:SetPxPMode PBP-2H-82 DP1 HDMI2`.  
* Click in the _Select system-wide-hotkey_, and press the hotkey combination you want for 80/20 PbP.
* Close the DDM Hotkey Manager.
* Exit & Restart the Dell Display Manager.

### 4) Fixup the Windows Display Settings

#### 80/20 PbP

* Use your hotkey to turn 80/20 PbP on.
* Go into `Settings` > `System` > `Display`
* Make sure that the Main display and Secondary display are in the correct positions.
* Select the main display
* Make sure `Make this my main display` is ticked.
* Make sure `Extend these displays` is selected (from the button beside `Identify`).
* Make sure `Scale` is set to what you like (e.g. 125%).
* Make sure `Display Resolution` is set correctly (i.e. 4096 x 2160 on a U4021QW).
* Select the 2nd screen
* Make sure `Scale` is set to what you like (e.g. 125%).
* Make sure `Display Resolution` is set correctly (i.e. 1024 x 2160 on a U4021QW).

#### No PbP

* Use your hotkey to turn PbP off.
* Go into `Settings` > `System` > `Display`
* Select the main display
* Make sure `Make this my main display` is ticked.
* Make sure `Show only on 1` is selected (from the button beside `Identify`).
* Make sure `Scale` is set to what you like (e.g. 125%).
* Make sure `Display Resolution` is set correctly (i.e. 5120 x 2160 on a U4021QW).

> Note that after switching to a new layout it will take 10 seconds or so before DDM starts listening to hotkeys again.
