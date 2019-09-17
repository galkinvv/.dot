# Command lines
## py-spy
```sh
python3 ./setup.py install --prefix ~/py-spy-install
exec sudo env PATH="$PATH" RUST_BACKTRACE=1 py-spy record --threads --idle --duration 200 --rate 5 --native --nonblocking --output $2.svg --pid $1
exec sudo env PATH="$PATH" py-spy top --nonblocking --pid $1
```
