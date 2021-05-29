#! /system/bin/sh
brightness=($(cat /sys/class/backlight/panel0-backlight/brightness))
if [ $brightness -eq 0 ];
then
    echo "backlight is 0,pls do tp_selftest when screen on"
    echo "TEST_FAIL"
        exit
fi

if [ -f /sys/bus/platform/devices/goodix_ts.0/chip_info ]; then
	echo "goodix"
	chmod 666 /dev/gtp_tools
	mkdir -p /data/misc/tp_selftest_data
	echo 1 > /sys/bus/platform/devices/goodix_ts.0/tp_test
	test_result=$(cat /sys/bus/platform/devices/goodix_ts.0/tp_test)
	if [ $test_result -eq 0 ];
	then
		echo "TEST_PASS"
	else
		echo "TEST_FAIL"
	fi
fi

mkdir -p /data/misc/tp_selftest_data
echo $test_result >> /data/misc/tp_selftest_data/result.txt
