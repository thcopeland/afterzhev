SRC            = src
BIN            = bin
SIM            = sim
DATA           = $(SRC)/data
MCU_TARGET     = atmega2560
DEFS           = -D DEV -D __$(MCU_TARGET)
AS             = avra
OBJDUMP        = avr-objdump

all: $(BIN)/main.hex $(BIN)/main.lst

$(BIN)/%.hex: $(SRC)/%.asm $(SRC)/*.asm $(DATA)/*.asm
	$(AS) $(DEFS) -I $(SRC) -I $(DATA) -o $@ -e /dev/null -d /dev/null $<

$(BIN)/%.lst: $(BIN)/%.hex
	$(OBJDUMP) -m avr51 -D $< > $@

upload: all
	avrdude -p $(MCU_TARGET) -c wiring -P /dev/ttyACM0 -b 115200 -D -U flash:w:$(BIN)/main.hex:i

sim-fast: $(BIN)/main.hex $(BIN)/simulate-fast
	./$(BIN)/simulate-fast $(MCU_TARGET)

sim-slow: $(BIN)/main.hex $(BIN)/simulate-slow
	./$(BIN)/simulate-slow $(MCU_TARGET)

$(BIN)/simulate-fast: $(SIM)/simulate-fast.c
	make -C sim/slimavr-0.1.2
	gcc $< $(SIM)/slimavr-0.1.2/libslimavr.a -O2 -o $@ -lglut -lGL -lpthread

$(BIN)/simulate-slow: $(SIM)/simulate-slow.c
	gcc $< -O2 -o $@ -lglut -lGL -lpthread -lsimavr

clean:
	make -C sim/slimavr-0.1.2 clean
	rm -rf $(BIN)/* $(SIM)/simulate
