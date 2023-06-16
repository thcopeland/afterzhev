## AfterZhev

AfterZhev is a small RPG that runs on a single 16 MHz ATmega2560 microcontroller, plus some passive components, and is compatible with the Arduino Mega 2560. Perhaps unwisely, it was written entirely in AVR assembly.

AfterZhev tells a tale of betrayal, the story of a brave messenger risking everything to recover a stolen letter. Along the way, you encounter bandits, foxes, and a secret cult. You can complete the game in less than four minutes, but first-time players will probably need over half an hour.

The game is sort of intended to be played on physical microcontroller along with a VGA monitor and a NES controller, but you can also play online [here](https://thcopeland.com/projects/afterzhev/play.html)!

![AfterZhev title screen](/assets/screenshot_title_screen.png)

## Building AfterZhev

A prebuilt HEX file containing the most recent version of AfterZhev should be in the `bin/` directory. However, you may want to build the game yourself.

#### Dependencies

- [AVRA](https://github.com/Ro5bert/avra), an open source AVR assembler. The Atmel Studio assembler may be compatible, but I have not tested it.
- GNU Make.
- [SDL2](https://www.libsdl.org/), for graphics and audio when running AfterZhev on a computer.
- [Emscripten](https://emscripten.org/), used to run AfterZhev in a web browser.
- [avrdude](https://github.com/avrdudes/avrdude), to program the microcontroller.
- [flhex](https://github.com/thcopeland/flhex), to work around an Arduino bootloader bug.

#### MCU build

The microcontroller build is intended to be run on a physical chip, or with the full simulator (`make debug`). To build it, set `TARGET=1` and run `make`. The resulting HEX file is correct, but uploading it will expose [a bug](https://thcopeland.com/2023/06/13/avrdude-verification-error-0xff-0x00.html) in the Arduino Mega bootloader. Running `flhex` on the HEX file will fix that. Finally, you can use `avrdude` to program the microcontroller. If you're using an Arduino Mega 2560, `make upload` should do the job.

```
$ TARGET=1 make
...
$ flhex bin/afterzhev.hex -o bin/afterzhev.hex
$ make upload
```

To test the MCU build on a computer, use `make debug`. This runs a simulator (`sim/simulate_full.c`) that emulates a VGA monitor, NES controller, and speaker.

#### PC build

For testing and convenience, AfterZhev can be run on a computer. The microcontroller is simulated with [slimavr](https://github.com/thcopeland/slimavr), and can run much faster than real time. The PC build is largely identical to the MCU build, but it takes a few shortcuts. It fakes an NES controller by twiddling memory directly, generates better quality audio, and doesn't generate a VGA signal. To produce a PC build, set `TARGET=0` and run `make sim` to build the AfterZhev and compile and run the simulator (`sim/simulate.c`).

#### WASM build

The WebAssembly build is identical to the PC build, but the simulator is compiled with `emcc` instead of `gcc`. The resulting simulator can then be run in a web browser. This is significantly slower but still easily runs at the intended 60 frames per second, thanks some shortcuts. To produce a WebAssembly build, set `TARGET=0` and run `make wasm`. You'll have to first run `make clean` to delete native object files if you ran `make sim` earlier.

## Construction

AfterZhev outputs a 60 Hz 640x480 VGA signal:

 - HSYNC on pin PB6 (pin 12 on Arduino Mega 2560)
 - VSYNC on pin PE4 (2 on Arduino)
 - RRRGGGBB image on pins PA0-PA7 (22-29 on Arduino)

You can use proper digital-to-analog circuitry for each channel, but since 8-bit color is pretty imprecise and the VGA impedance is known, I got away with just a 1:2:4 resistor ratio for the channel pins. This approach uses fewer resistors.

AfterZhev also outputs audio on pins PC0-PC7 (37-30 on Arduino), where PC7 (30) is the most significant bit of an unsigned 8-bit sample, and PC0 (37) is the least significant bit. I used an R-2R (R=100 ohms) resistor ladder as a digital-to-analog converter.

Finally, AfterZhev uses a NES controller (I've successfully tried both an original Nintendo controller and a clone):

 - LATCH on pin PG0 (41 on Arduino)
 - CLOCK on pin PG1 (40 on Arduino)
 - DATA on pin PG2 (39 on Arduino)

![AfterZhev schematic](/assets/screenshot_schematic.png)
