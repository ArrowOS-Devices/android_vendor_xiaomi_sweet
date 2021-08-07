#!/vendor/bin/sh
if ! applypatch --check EMMC:/dev/block/bootdevice/by-name/recovery$(getprop ro.boot.slot_suffix):134217728:99dc4051106cb5f161b4d0c2defea5aa6c1d2a42; then
  applypatch  \
          --patch /vendor/recovery-from-boot.p \
          --source EMMC:/dev/block/bootdevice/by-name/boot$(getprop ro.boot.slot_suffix):134217728:9c86df38b4cef30b15873ab693b34adae085a678 \
          --target EMMC:/dev/block/bootdevice/by-name/recovery$(getprop ro.boot.slot_suffix):134217728:99dc4051106cb5f161b4d0c2defea5aa6c1d2a42 && \
      log -t recovery "Installing new recovery image: succeeded" && \
        echo "Installing new recovery image: succeeded" > /cache/recovery/last_install_recovery_status || \
      (log -t recovery "Installing new recovery image: failed" && \
        echo "Installing new recovery image: failed" > /cache/recovery/last_install_recovery_status)
else
  log -t recovery "Recovery image already installed" && \
  echo "Recovery image already installed" > /cache/recovery/last_install_recovery_status
fi
