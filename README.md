# Command lines linux
## py-spy
```sh
python3 ./setup.py install --prefix ~/py-spy-install
sudo env PATH="$PATH" RUST_BACKTRACE=1 py-spy record --threads --idle --duration 200 --rate 5 --native --nonblocking --output $2.svg --pid $1
sudo env PATH="$PATH" py-spy top --nonblocking --pid $1
```
## perf
```sh
#Profiling single thread: step 1 outside docker, saving data in files and cache into .debug
TID=12345
PREFIX=main
sudo sh -c 'echo 1 > /proc/sys/kernel/sched_schedstats'
sudo env HOME=`pwd` perf record -t $TID --call-graph dwarf,65528 -o ${PREFIX}_sched -e sched:sched_stat_sleep -e sched:sched_switch -m1G -- sleep 50 &
sudo env HOME=`pwd` perf record -t $TID --call-graph dwarf,65528 -o ${PREFIX}_oncpu -F 20 -- sleep 50 &
wait
sudo env HOME=`pwd` perf inject -s -i ${PREFIX}_sched -o ${PREFIX}_slept

#Profiling single thread: step 2 inside docker
PREFIX=main

sudo env HOME=`pwd` perf script -i ${PREFIX}_slept -F ip,sym,symoff,dso,tid,trace,period,event > ${PREFIX}_slept.txt
sudo env HOME=`pwd` perf script -i ${PREFIX}_oncpu -F ip,sym,symoff,dso,tid > ${PREFIX}_oncpu.txt

awk '
/sched:sched_switch: prev_comm=/ { samples_1kkk=int($2)/50; $2=$1"TID-OffCPU"; $1=""}
NF < 1 {printf "%d\n\n", samples_1kkk}
{print}
' ${PREFIX}_slept.txt > ${PREFIX}_slept_counted.txt

awk '                       
NF < 1 {printf "1000000\n\n"}
NF == 1 {$1 = $1"TID-OnCPU"}
{print}
' ${PREFIX}_oncpu.txt > ${PREFIX}_oncpu_counted.txt

(echo -e "\n\n\n\n\n"; cat ${PREFIX}_oncpu_counted.txt ${PREFIX}_slept_counted.txt)| c++filt |grep -v ' _start+' | grep -v '/usr/bin/python3.6' | sed -e "s/(/[/g;s/)/]/g;s/\+/_/g" | sed -e 's/[0-9a-f]\+ \([^[]\)/\1/' | ~/FlameGraph/stackcollapse.pl | ~/FlameGraph/flamegraph.pl --title ${PREFIX}_all > ${PREFIX}_all_flame.svg
```

## video
```sh
#webcam-record
TARGET_DIR=~/some-dir
DEV=/dev/video0
mkdir -p $TARGET_DIR
killall -9 vlc
sleep 1
power_line_frequency
v4l2-ctl --device $DEV --set-ctrl exposure_auto_priority=0
vlc -v v4l2://$DEV:chroma=MJPG:width=1280:height=960:fps=25 :input-slave=pulse:// --no-sout-display-audio --sout-file-format --sout "#duplicate{dst='transcode{acodec=mp3,ab=160,channels=1,vcodec=x264{crf=15}}:file{mux=mp4,dst=${TARGET_DIR}/webcam-record-%Y-%m-%d_%Hh%Mm%Ss.mp4}',dst='display'}"

killall -9 vlc
sleep 1

vlc ${TARGET_DIR}/$(ls -t ${TARGET_DIR}|head -n 1)```


#change h264 fps to a fixed, including bitstrea, fps
mkvmerge --default-duration 0:30fps --fix-bitstream-timing-information 0 input-file.ext -o f30.mkv

# adjust ausio-video position and cut
ffmpeg -i overview.mp3 -ss 00:00:06 -i overview.mp4 -ss 00:00:05 -t 00:01:40 -pix_fmt yuv420p -threads 3 -c:a aac v0.2overview.mp4

# x11 grab rect
ffmpeg -video_size 480x800 -framerate 30 -f x11grab -i :0.0 -pix_fmt yuv420p -threads 3 overview.mp4
```

## git
```sh
# download HEAD subfolder via ssh (gitlab)
git archive --remote=ssh://git@gitlab.host.com/cv-srs/srs-extra.git HEAD Research/docker-files | tar xvf - --strip-components=2
# branches head
git clone https://github.com/VENDOR/REPO.git --branch master --single-branch --depth 1
```

## kernel
```
#usb webcam mic sound fix
usbcore.autosuspend=-1

#low-memory
zswap.enabled=1 zswap.zpool=zsmalloc zswap.compressor=zstd zswap.max_pool_percent=42
#drm tracing
log_buf_len=4M drm.debug=0x1e

#zswap stats
# for f in /sys/kernel/debug/zswap/*; do echo -n "$f: "; cat $f; done

#nvidia i2c ina3221
$ nvidia-smi
$ modprobe i2c-dev
$ i2cdetect -l
$ i2cget -y 3 0x40 0x01 w

# make raid resync not eat all resources
echo 42000 > /proc/sys/dev/raid/speed_limit_max
# initiate fast raid readd
mdadm /dev/md1 -a /dev/sdc3

#nvidia rmmod
sudo kill -9 $(pidof nvidia-persistenced)
sleep 0.1
sudo rmmod nvidia_drm nvidia_modeset nvidia_uvm nvidia

#reboot now
#!/bin/sh
echo 1 > /proc/sys/kernel/sysrq
#echo e > /proc/sysrq-trigger
sleep 1
echo s > /proc/sysrq-trigger 
nohup sh -c 'sleep 1; echo u > /proc/sysrq-trigger; echo s > /proc/sysrq-trigger;  sleep 10; echo b > /proc/sysrq-trigger' &
killall -9 sshd


```
### single module rebuild for distro kernel
* edit Makefile
```Makefile
VERSION = 5
PATCHLEVEL = 7
SUBLEVEL = 0
EXTRAVERSION = -1-cloud-amd64
```
* copy config from distro as .config
* copy Module.symvers from distro
* run `make prepare scripts`
* remove unneeded objects from folders `drivers/net/Makefile`
* run `make M=drivers/net modules`
* check that Module.symvers not deleted
* use generated .ko

## mount
```
# mount smb as readonly via cmdline
$ sudo mount.cifs //lurat-pc/RO RO -o user=vgalkin,uid=$(id -u),gid=$(id -u),file_mode=0555,dir_mode=0555
```
## hdd
```
# seek speed
$ sudo ioping -R /dev/sdX

# seq read speed
hdparm -tT /dev/sdX

# configure SAS drives for home use: Write cache on, backgroubd scan off
$ sudo sdparm --set=WCE -S /dev/sdX
$ sudo sdparm --set=EN_BMS=0 -S /dev/sdX
```

## docker
```
# create container without command from image
docker run -id -v $(pwd):/data:ro --name new_cont_name image_id bash
```
## pulseaudio
```
#mixer, add to /etc/pulse/default.pa
load-module module-null-sink sink_name=MixerOutput sink_properties="device.description='MixerOutput'"
load-module module-loopback sink=MixerOutput source_output_properties="media.name='MixerInput1'" latency_msec=5
load-module module-loopback sink=MixerOutput source_output_properties="media.name='MixerInput2'" latency_msec=5
```
## ssh server-side redirect
```
Match User firefly
	X11Forwarding no
	AllowTcpForwarding no
	ForceCommand ssh -q -t firefly@10.42.0.247 $SSH_ORIGINAL_COMMAND
```

## sh
```sh
SELF=`realpath "$0"`
SELF_DIR=`dirname "$SELF"`

#single arg as command
#requires python
/usr/bin/python3 '-cimport os;os.system("ls -l")'
#portable, side effects
/usr/bin/script '-cls -l'
#20.04+
/usr/bin/env '-Sls -l'
```
## grub
```
#install grub entirely on the efi partition
grub-install --compress xz --boot-directory=/boot/efi --themes= --recheck --efi-directory=/boot/efi
grub-mkconfig > /boot/efi/grub/grub.cfg
```

## systemd
```ini
#/etc/systemd/system/dup.service
[Service]
ExecStart=/etc/galkinvv/dup.nft
[Install]
WantedBy=multi-user.targetroot
#activate autostart by systemctl enable dup
```

## network
### duplicate packets over bad connecetion via "nft < `file`". Put into a file:
```
#!/usr/sbin/nft -f
table ip duppertable {
  chain dupperchain {
    type filter hook postrouting priority 100;
    ip daddr 10.186.61.10 dup to 10.186.61.10;
    ip protocol != udp ip daddr 10.186.61.10 dup to 10.186.61.10;
    ip protocol != udp ip daddr 10.186.61.10 dup to 10.186.61.10;
    ip protocol != udp ip daddr 10.186.61.10 dup to 10.186.61.10;
    ip protocol != udp ip daddr 10.186.61.10 mark set numgen inc mod 5;
    udp sport != 443 ip daddr 10.186.61.10 dup to 10.186.61.10;
    udp sport != 443 ip daddr 10.186.61.10 dup to 10.186.61.10;
    udp sport != 443 ip daddr 10.186.61.10 dup to 10.186.61.10;
    #mark duplicates as 0, 1, 2 for later different delaying
    udp sport != 443 ip daddr 10.186.61.10 mark set numgen inc mod 5;

    #ip daddr 10.186.61.10 dup to 10.186.61.10;
  }
}

#install nftables
#check with nft list tables
#delete with nft delete table duppertable
```

### ttl local & forwarded set to 64 via nftables
```
#!/usr/sbin/nft -f

table inet localttlset {
        chain output {
                type filter hook output priority 0;
                ip ttl set 64
        }
}
table ip inttlset {
        chain prerouting {
                type filter hook prerouting priority 0; policy accept;
                ip ttl set 65
        }
}

```
### port forwarding to existing nat
```
table ip portfwd {
  chain portfwdchain {
    type nat hook prerouting priority 90;
    #transmission torrent
    tcp dport 51413 dnat to 10.186.61.10;
  }
}
```

### traffic shaping
```sh
TCIF=wghub
tc qdisc del dev $TCIF root
tc qdisc add dev $TCIF root handle 1: prio priomap 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2
#tc qdisc add dev $TCIF parent 1:2 tbf rate 9mbit latency 900ms burst 1540
tc qdisc add dev $TCIF parent 1:1 netem delay 35ms limit 20
tc filter add dev $TCIF parent 1: protocol ip prio 1 handle 1 fw flowid 1:1
tc qdisc add dev $TCIF parent 1:2 netem delay 300ms limit 100
tc filter add dev $TCIF parent 1: protocol ip prio 1 handle 2 fw flowid 1:2
#view results
tc -s qdisc ls dev $TCIF
```
### test net perf
```
scp -o 'Compression no' 185.189.12.232:/tmp/100Mb .
iperf3 -c 10.186.61.1 --time 10000 -i 0.5 -l 1K -w 65000 --reverse
```

### bpf fast drop
```c
//build with: clang-10 -I/usr/include/x86_64-linux-gnu/  -O2 -Wall -target bpf -c xdp-drop.c -o xdp-drop.o
//load with: sudo ip -force link set dev ens3 xdpgeneric obj xdp-drop.o
#include <linux/bpf.h>
#include <linux/if_ether.h>
#include <netinet/in.h>
#include <stdint.h>

__attribute__((section("prog"), used))
int xdp_drop(struct xdp_md *ctx)
{
    // Read data
    void* data_end = (void*)(long)ctx->data_end;
    void* data = (void*)(long)ctx->data;

    // Handle data as an ethernet frame header
    struct ethhdr *eth = data;

    // Check frame header size
    if (data + sizeof(*eth) > data_end) {
        return XDP_DROP;
    }

    // Check ip6
    if ((uint16_t)eth->h_proto == htons(ETH_P_IPV6)) {
        return XDP_DROP;
    }
    return XDP_PASS;
}

__attribute__((section("licence"), used))
char __license[] = "GPL";

```
## pacman
Partial upgrade with deps
```pacman -S --needed $(pactree -u mkinitcpio)```

# Windows
## Win7 SP1 fast & less risky core update
https://support.microsoft.com/en-us/topic/may-14-2019-kb4499175-security-only-update-4633b67f-f683-7731-f332-e1e7ec35bfc5

## Win7 API set dlls
https://www.nuget.org/packages/runtime.win7-x64.Microsoft.NETCore.Windows.ApiSets/1.0.1
Updates core files with
```
API-MS-Win-Base-Util-L1-1-0.dll
api-ms-win-core-com-l1-1-0.dll
api-ms-win-core-com-private-l1-1-0.dll
api-ms-win-core-comm-l1-1-0.dll
api-ms-win-core-console-l2-1-0.dll
api-ms-win-core-datetime-l1-1-1.dll
api-ms-win-core-debug-l1-1-1.dll
api-ms-win-core-errorhandling-l1-1-1.dll
api-ms-win-core-fibers-l1-1-1.dll
api-ms-win-core-file-l1-2-1.dll
api-ms-win-core-file-l2-1-1.dll
api-ms-win-core-heap-obsolete-l1-1-0.dll
api-ms-win-core-io-l1-1-1.dll
api-ms-win-core-kernel32-legacy-l1-1-0.dll
api-ms-win-core-kernel32-legacy-l1-1-1.dll
api-ms-win-core-kernel32-legacy-l1-1-2.dll
API-MS-Win-Core-Kernel32-Private-L1-1-0.dll
API-MS-Win-Core-Kernel32-Private-L1-1-1.dll
API-MS-Win-Core-Kernel32-Private-L1-1-2.dll
api-ms-win-core-libraryloader-l1-1-1.dll
api-ms-win-core-localization-l1-2-1.dll
api-ms-win-core-localization-l2-1-0.dll
api-ms-win-core-localization-obsolete-l1-2-0.dll
api-ms-win-core-memory-l1-1-1.dll
api-ms-win-core-memory-l1-1-2.dll
api-ms-win-core-memory-l1-1-3.dll
api-ms-win-core-namedpipe-l1-2-1.dll
api-ms-win-core-normalization-l1-1-0.dll
API-MS-Win-Core-PrivateProfile-L1-1-0.dll
api-ms-win-core-privateprofile-l1-1-1.dll
api-ms-win-core-processenvironment-l1-2-0.dll
api-ms-win-core-processsecurity-l1-1-0.dll
api-ms-win-core-processthreads-l1-1-2.dll
API-MS-Win-Core-ProcessTopology-Obsolete-L1-1-0.dll
api-ms-win-core-psapi-ansi-l1-1-0.dll
api-ms-win-core-psapi-l1-1-0.dll
api-ms-win-core-psapi-obsolete-l1-1-0.dll
api-ms-win-core-realtime-l1-1-0.dll
api-ms-win-core-registry-l1-1-0.dll
api-ms-win-core-registry-l2-1-0.dll
api-ms-win-core-shlwapi-legacy-l1-1-0.dll
api-ms-win-core-shlwapi-obsolete-l1-1-0.dll
api-ms-win-core-shutdown-l1-1-0.dll
api-ms-win-core-shutdown-l1-1-1.dll
API-MS-Win-Core-String-L2-1-0.dll
api-ms-win-core-string-obsolete-l1-1-0.dll
api-ms-win-core-string-obsolete-l1-1-1.dll
API-MS-Win-Core-StringAnsi-L1-1-0.dll
api-ms-win-core-stringloader-l1-1-0.dll
api-ms-win-core-stringloader-l1-1-1.dll
api-ms-win-core-sysinfo-l1-2-0.dll
api-ms-win-core-sysinfo-l1-2-1.dll
api-ms-win-core-sysinfo-l1-2-2.dll
api-ms-win-core-sysinfo-l1-2-3.dll
api-ms-win-core-threadpool-l1-2-0.dll
api-ms-win-core-threadpool-legacy-l1-1-0.dll
api-ms-win-core-threadpool-private-l1-1-0.dll
api-ms-win-core-url-l1-1-0.dll
api-ms-win-core-version-l1-1-0.dll
api-ms-win-core-winrt-error-l1-1-0.dll
api-ms-win-core-winrt-error-l1-1-1.dll
api-ms-win-core-winrt-l1-1-0.dll
api-ms-win-core-winrt-registration-l1-1-0.dll
api-ms-win-core-winrt-robuffer-l1-1-0.dll
api-ms-win-core-winrt-roparameterizediid-l1-1-0.dll
api-ms-win-core-winrt-string-l1-1-0.dll
api-ms-win-core-wow64-l1-1-0.dll
API-MS-Win-devices-config-L1-1-0.dll
API-MS-Win-devices-config-L1-1-1.dll
API-MS-Win-Eventing-ClassicProvider-L1-1-0.dll
API-MS-Win-Eventing-Consumer-L1-1-0.dll
API-MS-Win-Eventing-Controller-L1-1-0.dll
API-MS-Win-Eventing-Legacy-L1-1-0.dll
API-MS-Win-Eventing-Provider-L1-1-0.dll
API-MS-Win-EventLog-Legacy-L1-1-0.dll
api-ms-win-ro-typeresolution-l1-1-0.dll
api-ms-win-security-cpwl-l1-1-0.dll
api-ms-win-security-cryptoapi-l1-1-0.dll
api-ms-win-security-lsalookup-l2-1-0.dll
api-ms-win-security-lsalookup-l2-1-1.dll
API-MS-Win-Security-LsaPolicy-L1-1-0.dll
api-ms-win-security-provider-l1-1-0.dll
api-ms-win-service-core-l1-1-1.dll
api-ms-win-service-private-l1-1-0.dll
api-ms-win-service-private-l1-1-1.dll
ext-ms-win-advapi32-encryptedfile-l1-1-0.dll
ext-ms-win-ntuser-keyboard-l1-2-1.dll
```
And from windbg distro:
```
api-ms-win-downlevel-kernel32-l2-1-0.dll
api-ms-win-eventing-provider-l1-1-0.dll
```

## Command lines
```cmd
::show stderr and stdout of a GUI app (still buffered)
cmd /k GUIapp.exe 2>&1 | findstr .
```
## VirtualBox fix access to raw drive:
* diskpart
    * `select disk 0`
    * `offline disk`
    * `ATTRIBUTES DISK CLEAR READONLY`
* close VirtualBox
* reopen VirtualBox as admin

## Ramdisk
https://sourceforge.net/projects/imdisk-toolkit
For best speed: Format as NTFS, mark as fixed.

## Store
* enable installation of all apps in security settings
* get appx & blockmap from https://store.rg-adguard.net/
* install via Add-AppxPackage
* start LicenseManager (Windows License Manager Service)
* start wlidsvc (Microsoft Account Sign-in Assistant)
* run app first time 
* stop services

## Use net 4 for .net App.exe
* Create `App.exe.config` with
```xml
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <startup>
    <supportedRuntime version="v4.0" />
  </startup>
</configuration>
```

## MSVC debugger find vtables in memory related to address
```(void***(*(*(*)[1000])[1000])[1000])0x0000000073330040, 1000```

# Crossplatform
## Aria2c
```sh
#robust download
aria2c --max-connection-per-server=5 --min-split-size=1M --summary-interval=9 --show-console-readout=false --retry-wait=10 #add-url-here
```

# Optimizing performance
## CPU, Cuda, Opencl
Programming Parallel Computers  Aalto University - http://ppc.cs.aalto.fi/
