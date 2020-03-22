# Armbian auto testing

Collection of basic auto tests

# Introduction
TL;DR  It is installed on any Linux device in your network. Adapt the configuration-file to your requirements. Start the test procedure. Let it finish. Check the output for errors. Enjoy the nice report.html :+1:


## Privacy concerns
It runs locally in your network, no data is sent anywhere. Icons come from the internet.


# Getting started
You are running the script on your Linux desktop, server or SBC, which saves the hassle of copying the files onto the devices you want to test. The bash-script will ping the IP-Address or scan the local network. If you set a SUBNET, it will scan for devices on that subnet.   
It will create logins based on the configuration-file and run different tests to see if the board is working properly.  In the event you already have a root-user login, just put your password there instead of the generic 12345678. More information about the configuration you find below.  
All you need to do is configure the configuration-file, hook up the power and network cable and you are ready for running the test. That's it.

## Prerequisites
Download the latest armbian image. We recommend to use .torrent because this does the file integrity check for you automatically.  
Write the data to the SDcard, find tipps here https://docs.armbian.com/User-Guide_Getting-Started/#how-to-prepare-a-sd-card

Put the SDcard into your device, power it up and let it sit for 2 minutes, to do the standard initial setup.


## Prepare your system
To run the bash-scripts you need 4 small programs, check if they are already installed on your Linux device:  
`dpkg -l sshpass git iperf3 jq`  
If the result shows `ii` at the begin of the line, you have it installed. 
If dpkg-query:  returns with: not found, you can quickly install these small programs:  
`sudo apt-get install sshpass git iperf3 jq`

1. Go to a folder where you want to store it. The following command will create a folder called 'autotests'. Clone the sources from Github and open the folder autotests:
```
git clone https://github.com/armbian/autotests
cd autotests
./go.sh
```
if the download is not finished after 1 min, abort with: ctrl + c  and start over.
 
2. Edit `lib/configuration.sh`  
	- change number of passes (optional)
	- change stress time in seconds (optional)  

What is your device(s) IP-Address or do you have a dedicated subnet for your devices.
To find the device, login to your router or use this tool http://angryip.org/, to find your boards IP-Address(es).
	- set IP-Address (HOSTS) or Subnet
	- set WLAN_SSID and password (2,4 or 5,0GHz)
	- set BLUEDEV MAC-Address of a Blueooth device (Android phone for example)

How to find the Bluetooth MAC-Address - on your mobile or Linux device. Put your phones BT to discoverable mode and run:  
`hcitool scan` 
on a Linux computer that has a BT-Dongle. On an Android device you find the MAC-Address in the phones settings/about the phone/Status.  


3. Run :+1: :
The script will display which board gets tested
```
./go.sh
```
4. Once finished, go to `/autotests/logs`  double click: `report.html`


# What this tool does?

It Connects to the host(s) or all Armbian hosts in your subnet and runs the tests found in folder tests in alphabetical order.

Example of one test cycle:

	[ o.k. ] Host x.x.x.x found [ Run 1 out of 1 ]
	[ o.k. ] 0001-connect-wireless-devices-on-2.4Ghz.bash [ Tinkerboard @ x.x.x.x ]
	[ o.k. ] ...  [ wlan0 ]
	[ o.k. ] ...  [ wlxxxxxxxxxxxxx ]
	[ o.k. ] ...  [ wlxxxxxxxxxxxxx ]
	[ o.k. ] ...  [ wlxxxxxxxxxxxxx ]
	[ o.k. ] 0003-iperf-on-all-interfaces.bash [ Tinkerboard @ x.x.x.x ]
	[ o.k. ] ..."eth0" ethernet (rk_gmac-dwmac), hw, mtu 1500 [ ~941 MBits/s ~944 MBits/s ]
	[ o.k. ] ..."wlan0" wifi (rtl8723bs), hw, mtu 1500 [  ~50 MBits/s ]
	[ o.k. ] ..."148f 7601" wifi (mt7601u), hw, mtu 1500 [  ~28 MBits/s ]
	[ o.k. ] ..."Realtek 802.11n NIC" wifi (8188eu), hw, mtu 1500 [  ~60 MBits/s ]
	[ o.k. ] ..."Realtek 802.11ac NIC" wifi (rtl8821cu), hw, mtu 1500 [  ~0 MBits/s ]
	[ o.k. ] ..."Realtek 802.11ac WLAN Adapter" wifi (rtl88xxau), hw, mtu 2312 [  ~61 MBits/s ]
	[ o.k. ] ..."Ralink 802.11 n WLAN" wifi (rt2800usb), hw, mtu 1500 [  ~55 MBits/s ]
	[ o.k. ] ..."Realtek AC1200 MU-MIMO USB2.0 Adapter" wifi (rtl88x2bu), hw, mtu 1500 [  ~58 MBits/s ]
	[ o.k. ] 0005-connect-wireless-devices-on-5.0Ghz.bash [ Tinkerboard @ x.x.x.x ]
	[ o.k. ] ...  [ wlan0 ]
	[ o.k. ] ...  [ wlxxxxxxxxxxxxx ]
	[ o.k. ] ...  [ wlxxxxxxxxxxxxx ]
	[ o.k. ] ...  [ wlxxxxxxxxxxxxx ]
	[ o.k. ] 0003-iperf-on-all-interfaces.bash [ Tinkerboard @ x.x.x.x ]
	[ o.k. ] ..."eth0" ethernet (rk_gmac-dwmac), hw, mtu 1500 [ ~941 MBits/s ~944 MBits/s ]
	[ o.k. ] ..."wlan0" wifi (rtl8723bs), hw, mtu 1500 [  ~22 MBits/s ]
	[ o.k. ] ..."Realtek 802.11ac NIC" wifi (rtl8821cu), hw, mtu 1500 [  ~118 MBits/s ]
	[ o.k. ] ..."Realtek AC1200 MU-MIMO USB2.0 Adapter" wifi (rtl88x2bu), hw, mtu 1500 [  ~130 MBits/s ]
	[ o.k. ] 0008-bluetoth.bash [ Tinkerboard @ x.x.x.x ]
	[ o.k. ] Bluetooth ping to your test device was succesfull [ Mi Telefon ]
	[ o.k. ] 0016-dvfs.bash [ Tinkerboard @ x.x.x.x ]
	[ o.k. ] DVFS works [ 600 - 1800 Mhz ]
	[ o.k. ] 9999-reboot.bash [ 21:51:57 ]
	[ o.k. ] Rebooting in 3 seconds [ x.x.x.x ]

# Which tests are executed?

| test name | function |
|:-|:-|
|0000-read-board-data.bash| Read board OS information|
|0001-nigtly-stable-switch.bash| Switching between nightly and stable, odd/even|
|0002-update-and-upgrade.bash| Upgrade all packages|
|0008-connect-wireless-devices-on-2.4Ghz.bash|Connects wireless devices on 2.4G band|
|0013-iperf-on-all-wired-interfaces.bash|Check speed on all wired devices|
|0014-iperf-on-all-wireless-interfaces.bash|Check speed on all wireless devices|
|0015-connect-wireless-devices-on-5.0Ghz.bash|Connects wireless devices on 5G band|
|0017-iperf-on-all-wireless-interfaces.bash|Check speed on all wireless devices|
|0018-io-tests-memory.bash| Determine maximum memory random write speed|
|0019-io-tests-drive.bash| Determine maximum SD/eMMC random write speed|
|0111-bluetoth.bash|Ping Bluetooth device to check basic BT functionality|
|0115-strong-stressing.bash|Running heavy stressing for n seconds|
|0116-dvfs.bash|Get min and max CPU temperature to see if DVFS is operational|
|0119-7-zip-benchmark.bash.disabled|Run 7Zip benchmark|
|9999-reboot.bash|Reboot the board|


## To do's:
- [ ] improve errors catching  
- [ ] create XML data export for single board and together  
- [ ] common data collecting  
- [ ] support custom test board https://forum.armbian.com/topic/10841-the-testing-thread  

![Semantic description of image](https://forum.armbian.com/uploads/monthly_2019_09/IMG_0031.thumb.JPG.25382da99ba09c22c27cf8d274141b8b.JPG "Image Title")
