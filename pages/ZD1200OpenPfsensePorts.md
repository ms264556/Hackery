# Configure pfSense for AP to ZoneDirector / Unleashed Dedicated Master communication

You can use ZoneDirector or Unleashed Dedicated Master to manage APs at remote internet-connected locations, and tunnel selected traffic back to a central location.

Your ZoneDirector or Dedicated Master can be behind a NAT router, but this router requires a static IP address.   
Your APs can be behind NAT or double-NAT (e.g. if your ISP uses CGNAT).

# ZoneDirector

You should enable Secure AP Provisioning (which is the default for ZoneDirector 10.5.1).

You need to NAT incoming UDP 12222,12223 & TCP 443,11443 WAN traffic to your ZoneDirector.  
And you need to configure your APs with the public IP address of your ZoneDirector.

The complication is that the ZoneDirector Management Interface also uses port 443, and we don't want to expose this to the internet.  
And you might already be serving an unrelated website on port 443.  
We can address these problems by installing HAProxy on pfSense (if you haven't already), and only passing HTTPS traffic if it matches the specific URL which ZoneDirector AP provisioning requires.

## pfSense configuration steps

### Add Port Aliases

```Firewall``` > ```Aliases``` > ```Ports``` > ```Add```
* Properties > Name: ```ZoneDirectorUdp```
* Port(s) > Port: ```12222:12223```
* ```Save```
 
```Firewall``` > ```Aliases``` > ```Ports``` > ```Add```
* Properties > Name: ```ZoneDirectorTcp```
* Port(s) > Port: ```11443```
* ```Save```
```Apply Changes```

### Add NAT Port Forwards

```Firewall``` > ```NAT``` > ```Port Forward``` > ```Add``` _(the down arrow)_
* Edit Redirect Entry > Protocol: ```UDP```
* Edit Redirect Entry > Destination port range > Custom: ```ZoneDirectorUdp```  
> _If you can apply a Source rule (e.g. an ISP's IP range) then do so_  
* Edit Redirect Entry > Redirect target IP > Address: ```<ZoneDirector IP>```
* Edit Redirect Entry > Redirect target port > Custom: ```ZoneDirectorUdp```
* ```Save```

```Firewall``` > ```NAT``` > ```Port Forward``` > ```Add``` _(the down arrow)_
* Edit Redirect Entry > Destination port range > Custom: ```ZoneDirectorTcp```
> _If you can apply a Source rule (e.g. an ISP's IP range) then do so_  
* Edit Redirect Entry > Redirect target IP > Address: ```<ZoneDirector IP>```
* Edit Redirect Entry > Redirect target port > Custom: ```ZoneDirectorTcp```
* ```Save```
```Apply Changes```

### Add CA and Certificate for HAProxy Frontend
  
```System``` > ```Cert. Manager``` > ```CAs``` > ```Add```
* Create / Edit CA > Descriptive name: ```internal-ca```

```System``` > ```Cert. Manager``` > ```Certificates``` > ```Add/Sign```
* Add Sign a New Certificate > Descriptive name: ```<external IP>```
* Internal Certificate > Certificate authority: ```internal-ca```
* Internal Certificate > Common name: ```<external IP>```
* Certificate Attributes > Certificate Type: ```Server Certificate```
* ```Save```

### Install HAProxy
  
```System``` > ```Package Manager``` > ```Available Packages``` > ```haproxy-devel``` > ```Install``` > ```Confirm```

### Create HAProxy Backend
  
```Services``` > ```HAProxy``` > ```Backend``` > ```Add```
* Edit HAProxy Backend server pool > Name: ```ZoneDirector```
* Edit HAProxy Backend server pool > Server list > ```add another entry``` _(the down arrow)_
	* Name: ```ZDAPConfig```
	* Address: ```<ZoneDirector IP>```
	* Port: ```443```
	* Encrypt: ```tick```
* Health checking > Health check method > ```none```
* ```Save```
```Apply Changes```

### Create HAProxy Frontend
  
```Services``` > ```HAProxy``` > ```Frontend``` > ```Add```
* Edit HAProxy Frontend > Name: ```ZoneDirector```
* External adress > Port: ```443```
* External adress > SSL Offloading: ```tick```
* Default backend, access control lists and actions > Access Control lists > ```add another entry``` _(the down arrow)_
	* Name: ```ZDHost```
	* Expression: ```Host matches:```
	* Value: ```<external IP>```
* Default backend, access control lists and actions > Access Control lists > ```add another entry``` _(the down arrow)_
	* Name: ```ZDFirmwarePath```
	* Expression: ```Path starts with:```
	* Value: ```/firmwares/avpport```
* Default backend, access control lists and actions > Actions > ```add another entry``` _(the down arrow)_
	* Condition acl names: ```ZDHost ZDFirmwarePath```
	* backend: ```ZoneDirector```
* SSL Offloading > Certificate > ```<external IP> (CA: internal-ca) [Server cer]```
* SSL Offloading > Certificate > Add ACL for certificate CommonName. (host header matches the "CN" of the certificate): ```tick```
* ```Save```
```Apply Changes```

### Enable HAProxy
  
```Services``` > ```HAProxy``` > ```Settings```
* General settings > Enable HAProxy: ```tick```
* General settings > Maximum connections: ```5``` _(any number here, the # of APs is a safe bet)_
* ```Save```
```Apply Changes``` _(ignore the warnings)_

### Add Firewall Rule so HAProxy receives traffic
  
```Firewall``` > ```Rules``` > ```WAN``` > ```Add``` _(the down arrow)_
* Destination > Destination > ```This firewall (self)```
* Destination > Destination Port Range > From: ```HTTPS (443)```
> _If you can apply a Source rule (e.g. an ISP's IP range) then do so_  
* ```Save```
```Apply Changes```

# Unleashed Dedicated Master

You need to NAT incoming UDP 12222,12223 & TCP 60000 WAN traffic to your Unleashed Dedicated Master.  
And you need to configure your APs with the public IP address of your Unleashed Dedicated Master.

## pfSense configuration steps

### Add Port Aliases

```Firewall``` > ```Aliases``` > ```Ports``` > ```Add```
* Properties > Name: ```ZoneDirectorUdp```
* Port(s) > Port: ```12222:12223```
* ```Save```
 
```Firewall``` > ```Aliases``` > ```Ports``` > ```Add```
* Properties > Name: ```ZoneDirectorTcp```
* Port(s) > Port: ```60000```
* ```Save```
```Apply Changes```

### Add NAT Port Forwards

```Firewall``` > ```NAT``` > ```Port Forward``` > ```Add``` _(the down arrow)_
* Edit Redirect Entry > Protocol: ```UDP```
* Edit Redirect Entry > Destination port range > Custom: ```ZoneDirectorUdp```  
> _If you can apply a Source rule (e.g. an ISP's IP range) then do so_  
* Edit Redirect Entry > Redirect target IP > Address: ```<Unleashed Dedicated Master IP>```
* Edit Redirect Entry > Redirect target port > Custom: ```ZoneDirectorUdp```
* ```Save```

```Firewall``` > ```NAT``` > ```Port Forward``` > ```Add``` _(the down arrow)_
* Edit Redirect Entry > Destination port range > Custom: ```ZoneDirectorTcp```
> _If you can apply a Source rule (e.g. an ISP's IP range) then do so_  
* Edit Redirect Entry > Redirect target IP > Address: ```<Unleashed Dedicated Master IP>```
* Edit Redirect Entry > Redirect target port > Custom: ```ZoneDirectorTcp```
* ```Save```
```Apply Changes```


# AP configuration steps

* Install the latest Solo software image on your AP
* SSH into the AP's CLI and configure the ZoneDirector's static external IP address:-
	```
	set director ip <external IP>
	reboot
	```

