## AfterZhev

AfterZhev is a small RPG that runs on a single 16 MHz ATmega2560 microcontroller, plus some passive components, and is compatible with the Arduino Mega 2560. Perhaps unwisely, it was written entirely in AVR assembly. The game is intended to be played on a physical microcontroller along with a VGA monitor and a NES controller, but you can also play online [here](https://thcopeland.com/projects/afterzhev/play.html)!

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

For testing and convenience, AfterZhev can be run on a computer. The microcontroller is simulated with [slimavr](https://github.com/thcopeland/slimavr) and can run much faster than real time. The PC build is largely identical to the MCU build, but for performance and simplicity, it takes a few shortcuts. Specifically, it fakes an NES controller by twiddling memory directly, generates better quality audio, and doesn't generate a VGA signal. To produce a PC build, set `TARGET=0` and run `make sim` to build the AfterZhev and compile and run the simulator (`sim/simulate.c`).

#### WASM build

The WebAssembly build is identical to the PC build, but the simulator is compiled with `emcc` instead of `gcc`. The resulting simulator can then be run in a web browser. This is significantly slower but still easily runs at the intended 60 frames per second, thanks some shortcuts. To produce a WebAssembly build, set `TARGET=0` and run `make wasm`. You'll have to first run `make clean` to delete native object files if you ran `make sim` earlier.

## Additional

For information about running AfterZhev on a physical microcontroller and constructing the supporting electronics, visit the [project website](https://thcopeland.com/projects/afterzhev). You may also be interested in Peten Paja's [Toorum's Quest II](https://petenpaja.blogspot.com/2013/11/toorums-quest-ii-retro-video-game.html) or the [Uzebox](https://uzebox.org/) project.
