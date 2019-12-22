# Armbian auto testing

Collection of basic auto tests

1. Connects to host
2. Changes password and creates username
3. Run iper3 test on wlan0 if defined
4. Run stress test and reboots n-times

To do:

- expand scripting
- make use of existing 3rd party test suites to run extensive testings
- run stress test and power cycle n-times
- support custom test board https://forum.armbian.com/topic/10841-the-testing-thread

![Semantic description of image](https://forum.armbian.com/uploads/monthly_2019_09/IMG_0031.thumb.JPG.25382da99ba09c22c27cf8d274141b8b.JPG "Image Title")

Dependencies:

	apt install expect sshpass
