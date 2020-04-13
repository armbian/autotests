# configuration

PASSES=5
SBCBENCHPASS=${PASSES}	# sbc-bench will run on each cycle by default, set to 1 to run only on first
COMPARE="no" # compare with previous buils
PARALLEL="no" # make tests in parallel

# user

USER_ROOT="root"
PASS_ROOT="12345678"
USER_NORMAL="guest"
PASS_NORMAL="12345678"
NAME_NORMAL="Jane Doe"
ROOM_NORMAL="Red"
WORKPHONE_NORMAL=""
HOMEPHONE_NORMAL=""
OTHER_NORMAL=""

# host

HOSTS="" 		# comma delimited IP addresses
# or
SUBNET="" 		# Example 192.168.1.0/24
EXCLUDE=""		# Example 10.0.30.99,10.0.30.1
INCLUDE=""		# Include specific IP outside SUBNET when using SUBNET

WLAN_ID_24=""
WLAN_PASS_24=""

WLAN_ID_50=""
WLAN_PASS_50=""

BLUEDEV=""		# MAC address of your BT device, usually phone which is near by testing devices to make a ping

UPLOAD_SERVER=""			# server for report upload
UPLOAD_LOCATION=""			# location on that server
