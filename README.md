# Armbian auto testing

Collection of basic auto tests

# How to start?


	git clone https://github.com/armbian/autotests
	cd autotests
	./go.sh

Then edit userconfig/configuration.sh and add wlan SSID/password, testing subnet or address(s), ...

# What this tool does?

Connects to host(s) or all Armbian hosts in your subnet and run tests found in tests in alphabetical order.

One test cycle:

	[ o.k. ] Host x.x.x.x found [ Run 1 out of 3 ]
	[ o.k. ] 0000-armbian-first-login.bash [ 00:37:13 ]
	[ o.k. ] 0001-connect-wireless-devices-on-2.4Ghz.bash [ Cubox i2eX/i4 @ 00:37:26 ]
	[ o.k. ] ...  [ wlan0 ]
	[ o.k. ] ...  [ wlxxxxxxxxxxxxx ]
	[ o.k. ] 0003-iperf-on-all-interfaces.bash [ Cubox i2eX/i4 @ 00:37:49 ]
	[ o.k. ] ..."eth0" ethernet (fec), hw, mtu 1500 [ ~399 MBits/s ~564 MBits/s ]
	[ o.k. ] ..."Broadcom BCM4330" wifi (brcmfmac), hw, mtu 1500 [  ~63 MBits/s ]
	[ o.k. ] ..."Realtek RTL8811AU 802.11a/b/g/n/ac" wifi (88XXau), hw, mtu 2312 [  ~73 MBits/s ]
	[ o.k. ] 0005-connect-wireless-devices-on-5.0Ghz.bash [ Cubox i2eX/i4 @ 00:38:40 ]
	[ o.k. ] ...  [ wlan0 ]
	[ o.k. ] ...  [ wlxxxxxxxxxxxxx ]
	[ o.k. ] 0003-iperf-on-all-interfaces.bash [ Cubox i2eX/i4 @ 00:39:31 ]
	[ o.k. ] ..."eth0" ethernet (fec), hw, mtu 1500 [ ~400 MBits/s ~552 MBits/s ]
	[ o.k. ] ..."Realtek RTL8811AU 802.11a/b/g/n/ac" wifi (88XXau), hw, mtu 2312 [  ~205 MBits/s ]
	[ o.k. ] 0015-strong-stressing.bash [ 00:40:11 + 100s ]
	[ o.k. ] 0019-7-zip-benchmark.bash [ 00:41:52 ]
	[ o.k. ] 9999-reboot.bash [ 00:45:16 ]
	[ warn ] Rebooting in 3 seconds [ x.x.x.x ]

# Which tests are executed?

| test name | function |
|:-|:-|
|0000-armbian-first-login.bash|Changes password and creates username|
|0001-connect-wireless-devices.bash|Connects wireless devices|
|0003-iperf-on-all-interfaces.bash|Check speed on all devices|
|0005-used-wireless-modules.bash|Display used wireless modules|
|0015-strong-stressing.bash|Running heavy stressing for n seconds|
|0019-7-zip-benchmark.bash|Run 7Zip benchmark|
|0030-install-armbian-config.bash|Install armbian-config tool|
|9999-reboot.bash|Reboot the board|


To do:

- add more tests
- make roboust
- data collecting
- support custom test board https://forum.armbian.com/topic/10841-the-testing-thread

![Semantic description of image](https://forum.armbian.com/uploads/monthly_2019_09/IMG_0031.thumb.JPG.25382da99ba09c22c27cf8d274141b8b.JPG "Image Title")
