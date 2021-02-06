# pico-hello-reflashable

Minimal code for a Raspberry Pi Pico C project
that allows you to switch to BOOTSEL mode automatically
by sending a special USB command, without any button presses
or having to reconnect USB.


## Build instructions

```
git clone --depth 1 https://github.com/maxnet/pico-hello-reflashable
cd pico-hello-reflashable
git submodule update --init --recursive
mkdir -p build
cd build
cmake ..
make
```

Copy the resulting pico_hello_reflashable.uf2 file to the Pico mass storage device manually (or run ../flash.sh)

Program will start executing.

## To turn the Pico back to BOOTSEL (flash) mode

```
printf "\0" > /dev/ttyACM0
```

(On most Linux distributions your user must be part of dialout group, to be able to write to ttyACM0)

There is also a script provided called flash.sh that will send this command and will flash *.uf2 to the Pico.