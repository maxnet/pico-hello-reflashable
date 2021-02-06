#!/bin/sh
#
# Script to flash .uf2 to Pico
# Putting the Pico into flash mode if necessary first
#

# USB vendor ID to look for
USBVENDORID="2e8a"
# File system label to look for
FSLABEL="RPI-RP2"
# Folder that will be mounted to
MOUNTFOLDER="/media/$USER/$FSLABEL"

USBIDVENDORFILE=$(grep -l $USBVENDORID /sys/bus/usb/devices/*/idVendor);
if [ -z "$USBIDVENDORFILE" ]; then
    echo "No Raspberry Pi Pico connected"
    exit 1
fi

USBPATH=$(dirname "$USBIDVENDORFILE");
ACMTTY=$(ls -1 "$USBPATH"/*:1.0/tty 2>/dev/null);

UF2FILE="$1"

if [ -z "$UF2FILE" ]; then
    UF2FILE=$(ls -1 *.uf2 2>/dev/null);
fi

if [ -z "$UF2FILE" ]; then
    echo "Usage: $0 [.uf2 file]"
    echo ""
    echo "If no [.uf2 file] specified explicity, it will use first .uf2 file in directory"
    echo "Error: no .uf2 file found in directory"
    exit 1
fi

if [ ! -f "$UF2FILE" ]; then
    echo "'$UF2FILE' does not exist, or is not a regular file"
    exit 1
fi

echo "Pico detected at: $USBPATH"

if [ -z "$ACMTTY" ]; then
    echo "No ACM TTY detected. Cannot send command"
else
    if [ ! -w "/dev/$ACMTTY" ]; then
        echo "/dev/$ACMTTY is not writable by current user. Make sure your user is part of the right group (e.g. dailout)"
        exit 1
    fi

    echo "Sending command to /dev/$ACMTTY"
    printf "\0" > /dev/$ACMTTY
fi

echo "Waiting for Pico to switch to flash mode"
while [ ! -e "/dev/disk/by-label/$FSLABEL" ]; do
    sleep 0.1
done
sleep 0.1

if [ ! -e "$MOUNTFOLDER" ]; then
    echo "Trying to mount"
    udisksctl mount -b "/dev/disk/by-label/$FSLABEL"
fi    

if [ ! -e "$MOUNTFOLDER" ]; then
    echo "Failed to mount. Mount point $MOUNTFOLDER does not exists."
    exit 1
fi

if mountpoint "$MOUNTFOLDER"; then
    echo "Filesystem is mounted"
else
    echo "Waiting for filesystem to be mounted"
    until mountpoint "$MOUNTFOLDER"
    do
        sleep 0.1
    done
fi

echo "Flashing $UF2FILE"
cp "$UF2FILE" "$MOUNTFOLDER"

exit 0
