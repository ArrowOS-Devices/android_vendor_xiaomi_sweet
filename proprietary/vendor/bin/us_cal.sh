# set -x
# $1: device for output
#     us: ultrasound

# tinyplay file.wav [-D card] [-d device] [-p period_size] [-n n_periods]
# sample usage: playback.sh spk
# rcv.wav:-4.5dbfs   spk: -4.8dbfs  ultra: -4.5dbfs  spk_hp:-1.8dbfs


function enable_ultrasound_mic
{
    echo "enable ultrasound mic"
    tinymix 'Audio Stream Capture 0 App Type Cfg' 69938 19 96000 3
    tinymix "TX DEC0 MUX" "SWR_MIC"
    tinymix "TX SMIC MUX0" "ADC2"
    tinymix "TX_CDC_DMA_TX_3 Channels" "One"
    tinymix "TX_AIF1_CAP Mixer DEC0" "1"
    tinymix "ADC2_MIXER Switch" "1"
    tinymix "ADC2 MUX" "INP3"
    tinymix "ADC2 Volume" "12"

}

function disable_ultrasound_mic
{
    echo "disable ultrasound mic"
    tinymix 'Audio Stream Capture 0 App Type Cfg' 0 0 0 0
    tinymix "TX SMIC MUX0" "ZERO"
    tinymix "TX_CDC_DMA_TX_3 Channels" "One"
    tinymix "TX_AIF1_CAP Mixer DEC0" "0"
    tinymix "ADC2_MIXER Switch" "1"
}

function enable_ultrasound
{
    echo "enable ultrasound"
    tinymix 'Audio Stream 0 App Type Cfg' 69937 10001 96000 2
    tinymix 'PRIM_MI2S_RX Channels' 'Two'
    tinymix 'aw_dev_0_prof' 'Receiver'
    tinymix 'aw_dev_0_switch' 'Enable'
    tinymix "PRI_MI2S_RX Audio Mixer MultiMedia1" 1
}

function disable_ultrasound
{
    echo "disable ultrasound"
    tinymix 'aw_dev_0_switch' 'Disable'
    tinymix 'PRIM_MI2S_RX Channels' 'Two'
    tinymix "PRI_MI2S_RX Audio Mixer MultiMedia1" 0
}

case "$1" in
    "far" )
				playfilename=/vendor/etc/mi_us_whitenoise.wav
				recfilename=/sdcard/us_far.wav
        ;;
    "near" )
				playfilename=/vendor/etc/mi_us_whitenoise.wav
				recfilename=/sdcard/us_near.wav
        ;;
    "full" )
				playfilename=/vendor/etc/mi_us_whitenoise.wav
				recfilename=/sdcard/us_cal.wav
        ;;
    "far2near" )
				playfilename=/vendor/etc/mi_us_sweep.wav
				recfilename=/sdcard/us_far2near.wav
        ;;
    "near2far" )
				playfilename=/vendor/etc/mi_us_sweep.wav
				recfilename=/sdcard/us_near2far.wav
        ;;
     "cal_wn" )
				/vendor/bin/mi_ultrasound_test -near /sdcard/us_near2far.wav -far /sdcard/us_far2near.wav
				if [ -f /sdcard/cal.txt ]; then
					echo "ultrasound calibration done"
					sed -n '1p' /sdcard/cal.txt | tee /mnt/vendor/persist/audio/mi_us_cal.txt
				else
					echo "failed to create cal.txt"
				fi
				if [ -f /sdcard/mius_cal.bin ]; then
                                        cp /sdcard/mius_cal.bin /mnt/vendor/persist/audio/mius_cal.bin
				else
					echo "failed to create mius_cal.bin"
				fi
				exit 0
        ;;
     "cal" )
				/vendor/bin/mi_ultrasound_test
				if [ -f /sdcard/cal.txt ]; then
					echo "ultrasound calibration done"
				else
					echo "failed to create cal.txt"
				fi
				exit 0
	;;
    *)
        echo "Usage: us-cal.sh far"
        exit 0
        ;;
esac

enable_ultrasound_mic
tinymix 'MultiMedia1 Mixer TX_CDC_DMA_TX_3' 1
tinymix "TX_CDC_DMA_TX_3 SampleRate" "KHZ_96"

# start recording
echo "start recording"
tinycap $recfilename -r 96000 -b 16 -c 1 -t 10 &

ret=$?
if [ $ret -ne 0 ]; then
    echo "tinycap done, return $ret"
fi
enable_ultrasound

while [ ! -f $recfilename ];
do 
	echo "sleep 0.5"
	sleep 0.5
done
echo "start playing"
tinyplay $playfilename

killall tinycap

disable_ultrasound
disable_ultrasound_mic

tinymix 'MultiMedia1 Mixer TX_CDC_DMA_TX_3' 0
tinymix 'TX_CDC_DMA_TX_3 SampleRate' 'KHZ_48'

exit 0
