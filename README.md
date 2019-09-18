# Command lines
## py-spy
```sh
python3 ./setup.py install --prefix ~/py-spy-install
exec sudo env PATH="$PATH" RUST_BACKTRACE=1 py-spy record --threads --idle --duration 200 --rate 5 --native --nonblocking --output $2.svg --pid $1
exec sudo env PATH="$PATH" py-spy top --nonblocking --pid $1
```
##perf
```sh
sudo perf record -t <thread_id> -F 2 --call-graph dwarf,65528 -o input_raw_dump_with_large_stacks -- sleep 500
sudo perf script -i input_raw_dump_with_large_stacks -F+dso -F+symoff | grep -v ' _start+' | grep -v '/usr/bin/python3.6' | sed -e "s/^$/1/;s/.*cycles://;s/(/[/g;s/)/]/g;s/\+/_/g" | sed -e 's/[0-9a-f]\+ \([^[]\)/\1/' | ~/FlameGraph/stackcollapse.pl | ~/FlameGraph/flamegraph.pl > flame.svg
```
