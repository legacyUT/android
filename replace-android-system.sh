#!/bin/bash
# modified from https://github.com/janimo/phablet-porting-scripts/blob/68734ca07998b8e784397df77d9aca4b968b3815/build/replace-android-system

# Wait until the adb shell is unavailable, meaning the device is rebooting
wait_for_reboot() {
    while test -n "$(adb shell echo '1' 2>/dev/null)"
    do
        echo -n ".";
        sleep 3;
    done
    echo
}

#Wait until we get a working adb shell, meaning the device is in normal or recovery mode
wait_for_device() {
    while test -z "$(adb shell echo '1' 2>/dev/null)"
    do
        echo -n ".";
        sleep 3;
    done
    echo
}

SYSTEM_IMAGE=$1

if [ ! -f "$SYSTEM_IMAGE" ]; then
    echo "Usage: $0 system.img"
    exit
fi

read -t 10 -n 1 -p "Reboot to recovery (y/n)? " answer
[ -z "$answer" ] && answer="Yes"  # 'yes' is default choice
case ${answer:0:1} in
    y|Y )
        adb reboot recovery;
        wait_for_device;
    ;;
    * )
        echo "Assuming device in recovery mode";
    ;;
esac

echo "Mounting system partition"
adb shell "mkdir /a; if [ -e emmc@android ]; then mount emmc@android /a; else mount /data; mount /data/system.img /a; fi"

if file $SYSTEM_IMAGE | grep -v ": Linux rev 1.0 ext4" >/dev/null; then
    echo "Converting from sparse ext4 image to mountable ext4 image"
    simg2img $SYSTEM_IMAGE tmp.img >/dev/null
    resize2fs -M tmp.img >/dev/null 2>&1
    mv tmp.img $SYSTEM_IMAGE
fi

echo Pushing android system image...
adb push $SYSTEM_IMAGE /a/var/lib/lxc/android/system.img >/dev/null 2>&1 &

SIZE=$(stat -t $SYSTEM_IMAGE |awk '{print $2}')
S=0
while test $S -lt $SIZE
do
    sleep 1
    S=$(adb shell stat -t /a/var/lib/lxc/android/system.img | awk '{print $2}')
    printf "%0.2d%%\r" $[100*$S/$SIZE]
done

echo "Done, rebooting to Ubuntu"

adb reboot

# vim: expandtab: ts=4: sw=4

