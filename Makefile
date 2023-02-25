SRC            = src
BIN            = bin
SIM            = sim
DATA           = $(SRC)/data
MCU_TARGET     = atmega2560 # NOTE: simulate assumes 2560-like model
DEFS           = -D DEV -D __$(MCU_TARGET) -D TARGET=$(TARGET)
AS             = avra
OBJDUMP        = avr-objdump
SLIMAVR        = $(SIM)/slimavr-0.1.5
CFLAGS         = $(shell pkg-config --cflags --libs sdl2) -O2 -Wall -Wextra
EMCC_FLAGS     = -sUSE_SDL=2 --preload-file $(BIN)/main.hex

all: $(BIN)/main.hex $(BIN)/main.lst

$(BIN)/%.hex: $(SRC)/%.asm $(SRC)/*.asm $(DATA)/*.asm
	$(AS) $(DEFS) -I $(SRC) -I $(DATA) -o $@ -e /dev/null -d /dev/null $<

$(BIN)/%.lst: $(BIN)/%.hex
	$(OBJDUMP) -m avr51 -D $< > $@

upload: all
	avrdude -p $(MCU_TARGET) -c wiring -P /dev/ttyACM0 -b 115200 -D -U flash:w:$(BIN)/main.hex:i

sim: $(BIN)/main.hex $(BIN)/simulate
	./$(BIN)/simulate

$(BIN)/simulate: $(SIM)/simulate.c
	make -C $(SLIMAVR)
	$(CC) $< $(SLIMAVR)/libslimavr.a -o $@ $(CFLAGS)

wasm: clean all
	CC=emcc AR=emar make -C $(SLIMAVR)
	emcc $(CFLAGS) $(EMCC_FLAGS) $(SLIMAVR)/libslimavr.a $(SIM)/simulate.c -o $(BIN)/simulate-fast.html
	make -C $(SLIMAVR) clean

clean:
	make -C $(SLIMAVR) clean
	rm -rf $(BIN)/* $(SIM)/simulate
