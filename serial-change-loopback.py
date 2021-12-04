#!/usr/bin/env python3
import array
import fcntl
import termios
import sys

port = open((sys.argv[1:2] + ['/dev/ttyAMA0'])[0])
TIOCM_LOOP = 0x8000
modem_control_bits = [(getattr(termios,i), i)
    for i in dir(termios)
    if i.startswith('TIOCM_')] + [
     (0x2000, "TIOCM_OUT1"),
     (0x4000, "TIOCM_OUT2"),
     (TIOCM_LOOP, "TIOCM_LOOP")
    ]
cflag_bits = [(getattr(termios,i), i)
    for i in dir(termios)
    if i in('CRTSCTS', 'CSTOPB', 'PARENB', 'PARODD', 'CS8', 'CREAD', 'HUPCL', 'CLOCAL')]

BAUDRATE_TO_OSPEED = {
        50: termios.B50, 75: termios.B75, 110: termios.B110, 134: termios.B134,
        150: termios.B150, 200: termios.B200, 300: termios.B300,
        600: termios.B600, 1200: termios.B1200, 1800: termios.B1800,
        2400: termios.B2400, 4800: termios.B4800, 9600: termios.B9600,
        19200: termios.B19200, 38400: termios.B38400, 57600: termios.B57600,
        115200: termios.B115200, 230400: termios.B230400,
        # Linux baudrates bits missing in termios module included below
        460800: 0x1004, 500000: 0x1005, 576000: 0x1006,
        921600: 0x1007, 1000000: 0x1008, 1152000: 0x1009,
        1500000: 0x100A, 2000000: 0x100B, 2500000: 0x100C,
        3000000: 0x100D, 3500000: 0x100E, 4000000: 0x100F,
    }
OSPEED_TO_BAUDRATE = {v: k for k, v in BAUDRATE_TO_OSPEED.items()}

def str_bits(val, named_bits):
	out = []
	for bit, name in sorted(named_bits):
		if (val & bit) == bit:
		    out.append('+' + name + "=" + hex(bit))
		else:
		    out.append('-' + name + "=" + hex(bit))
	for bit, name in sorted(named_bits):
		val &= ~bit
	return ', '.join(out) + " other_bits=" + hex(val)

attrs_all = termios.tcgetattr(port)
attrs_cflag, attrs_lflag, attrs_ispeed, attrs_ospeed = attrs_all[2:6]
attrs_cflag &= ~termios.CBAUD
print("cflag", hex(attrs_cflag), str_bits(attrs_cflag, cflag_bits))
print("inspeed, outspeed", OSPEED_TO_BAUDRATE[attrs_ispeed], OSPEED_TO_BAUDRATE[attrs_ospeed])

tbuf = array.array('i', [0])
fcntl.ioctl(port, termios.TIOCMGET, tbuf, True)
print(str_bits(tbuf[0], modem_control_bits))
print("switching loopback TIOCM_LOOP")
if tbuf[0] & TIOCM_LOOP: tbuf[0] = tbuf[0] & ~TIOCM_LOOP
else:                    tbuf[0] = tbuf[0] |  TIOCM_LOOP
fcntl.ioctl(port, termios.TIOCMSET, tbuf, False)
fcntl.ioctl(port, termios.TIOCMGET, tbuf, True)
print(str_bits(tbuf[0], modem_control_bits))

