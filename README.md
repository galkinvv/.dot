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

#nvidia rmmod
sudo kill -9 $(pidof nvidia-persistenced)
sleep 0.1
sudo rmmod nvidia_drm nvidia_modeset nvidia_uvm nvidia


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
SELF=`readlink -f "$0"`
SELF_DIR=`dirname "$SELF"`
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

# Windows
## Command lines
```cmd
::show stderr and stdout of a GUI app (still buffered)
cmd /k GUIapp.exe 2>&1 | findstr .
```
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

# Crossplatform
## Aria2c
```sh
#robust download
aria2c --max-connection-per-server=5 --min-split-size=1M --summary-interval=9 --show-console-readout=false --retry-wait=10 #add-url-here
```

# Optimizing performance
## CPU, Cuda, Opencl
Programming Parallel Computers  Aalto University - http://ppc.cs.aalto.fi/
