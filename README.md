# Command lines
## py-spy
```sh
python3 ./setup.py install --prefix ~/py-spy-install
exec sudo env PATH="$PATH" RUST_BACKTRACE=1 py-spy record --threads --idle --duration 200 --rate 5 --native --nonblocking --output $2.svg --pid $1
exec sudo env PATH="$PATH" py-spy top --nonblocking --pid $1
```
## perf
```sh
#Profiling single thread: step 1 outside docker
TID=12345
PREFIX=main
sudo perf record -t $TID --call-graph dwarf,65528 -o ${PREFIX}_sched -e sched:sched_stat_sleep -e sched:sched_switch -m1G -- sleep 500 &
sudo perf record -t $TID --call-graph dwarf,65528 -o ${PREFIX}_oncpu -F 2 -- sleep 500 &
wait
sudo perf inject -s -i ${PREFIX}_sched -o ${PREFIX}_slept

#Profiling single thread: step 2 inside docker
PREFIX=main

sudo perf script -i ${PREFIX}_slept -F ip,sym,symoff,dso,tid,trace,period,event > ${PREFIX}_slept.txt
sudo perf script -i ${PREFIX}_oncpu -F ip,sym,symoff,dso,tid > ${PREFIX}_oncpu.txt

awk '
/sched:sched_switch: prev_comm=/ { samples_1kkk=int($2)/500; $2=$1"TID-OffCPU"; $1=""}
NF < 1 {printf "%d\n\n", samples_1kkk}
{print}
' ${PREFIX}_slept.txt > ${PREFIX}_slept_counted.txt

awk '                       
NF < 1 {printf "1000000\n\n"}
NF == 1 {$1 = $1"TID-OnCPU"}
{print}
' ${PREFIX}_oncpu.txt > ${PREFIX}_oncpu_counted.txt

(echo -e "\n\n\n\n\n"; cat ${PREFIX}_oncpu_counted.txt ${PREFIX}_slept_counted.txt)| grep -v ' _start+' | grep -v '/usr/bin/python3.6' | sed -e "s/(/[/g;s/)/]/g;s/\+/_/g" | sed -e 's/[0-9a-f]\+ \([^[]\)/\1/' | ~/FlameGraph/stackcollapse.pl | ~/FlameGraph/flamegraph.pl --title ${PREFIX}_all > ${PREFIX}_all_flame.svg
```
