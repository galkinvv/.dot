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

## vlc
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
```
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

# Windows
## Command lines
```cmd
::show stderr and stdout of a GUI app (still buffered)
cmd /k GUIapp.exe 2>&1 | findstr .
```
## Ramdisk
https://sourceforge.net/projects/imdisk-toolkit
For best speed: Format as NTFS, mark as fixed.

# Optimizing performance
## CPU, Cuda, Opencl
Programming Parallel Computers  Aalto University - http://ppc.cs.aalto.fi/
