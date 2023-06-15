SRC            = src
BIN            = bin
SIM            = sim
DATA           = $(SRC)/data
DEFS           = -D DEV -D TARGET=$(TARGET)
AS             = avra
OBJDUMP        = avr-objdump
SLIMAVR        = $(SIM)/slimavr-0.1.5
CFLAGS         = $(shell pkg-config --cflags --libs sdl2) -O2 -Wall -Wextra
EMCC_FLAGS     = -sUSE_SDL=2 --preload-file $(BIN)/afterzhev.hex

all: $(BIN)/afterzhev.hex $(BIN)/afterzhev.lst

$(BIN)/%.hex: $(SRC)/main.asm $(SRC)/*.asm $(DATA)/*.asm
	$(AS) $(DEFS) -I $(SRC) -I $(DATA) -o $@ -e /dev/null -d /dev/null $<

$(BIN)/%.lst: $(BIN)/%.hex
	$(OBJDUMP) -m avr51 -Dz $< > $@

upload: all
	avrdude -p atmega2560 -c wiring -P /dev/ttyACM0 -b 115200 -D -U flash:w:$(BIN)/afterzhev.hex:i

sim: $(BIN)/afterzhev.hex $(BIN)/simulate .FORCE
	./$(BIN)/simulate

$(BIN)/simulate: $(SIM)/simulate.c
	make -C $(SLIMAVR)
	$(CC) $< $(SLIMAVR)/libslimavr.a -o $@ $(CFLAGS)

debug: $(BIN)/afterzhev.hex $(BIN)/simulate-full .FORCE
	./$(BIN)/simulate-full

$(BIN)/simulate-full: $(SIM)/simulate_full.c
	make -C $(SLIMAVR)
	$(CC) $< $(SLIMAVR)/libslimavr.a -o $@ $(CFLAGS)

wasm: all
	CC=emcc AR=emar make -C $(SLIMAVR)
	emcc $(CFLAGS) $(EMCC_FLAGS) $(SLIMAVR)/libslimavr.a $(SIM)/simulate.c --shell-file $(SIM)/web-shell.html -o $(BIN)/afterzhev.html

clean:
	make -C $(SLIMAVR) clean
	rm -rf $(BIN)/*

.FORCE:
