#! /system/bin/sh

IMEI="000000"
IMEI=$(getprop ro.ril.oem.imei1)
echo $IMEI
mkdir -p /data/misc/tp_selftest_data
FILE_NAME=/data/misc/tp_selftest_data/${IMEI}".csv"
echo $FILE_NAME


if [ -f /sys/bus/platform/devices/goodix_ts.0/chip_info ]; then
    mv /data/misc/tp_selftest_data/Test_Data.csv $FILE_NAME
    #chmod 666 /dev/gtp_tools
    #mkdir -p /data/misc/tp_selftest_data
    ##test_result=$(gt_mp_test -i /vendor/firmware/ -o /data/misc/tp_selftest_data)
    #gt_mp_test -i /vendor/firmware/ -o /data/misc/tp_selftest_data > /dev/null
    #cat /sys/bus/platform/devices/goodix_ts.0/tp_rawdata > $FILE_NAME
    exit
fi

