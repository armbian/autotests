# Armbian auto testing

Collection of basic auto tests

# How to start?


	git clone https://github.com/armbian/autotests
	cd autotests
	./go.sh

Then edit userconfig/configuration.sh and add wlan SSID/password, testing subnet or address(s), ...

# What this tool does?

Connects to host(s) or all Armbian hosts in your subnet and run tests found in tests in alphabetical order.

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
