loginctl flush-devices
sleep 5
#Note attaching bootup card0 to seat1 leads to problems with xorg that tries to enumerate pcie devices.
#At least when card0=boot vga=NVIDIA, card1=second vga=AMD
CARD=card1
loginctl attach seat1 /sys/$(dirname $(udevadm info -q path /dev/dri/$CARD))/$CARD
sleep 2

#attach usb devices by vendor id
for dev in /dev/input/by-id/*SIGMACH1P* /dev/input/by-id/*COMPANY*; do
#for dev in /dev/input/by-id/*ROCCAT*; do
	sleep 2
	loginctl attach seat1 /sys/"$(dirname "$(udevadm info -q path "$dev")")"
done

#loginctl attach seat1 /sys/devices/platform/i8042/serio1/input/input2 #for ps2 mouse


