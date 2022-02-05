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

sim: $(BIN)/main.hex $(BIN)/simulate
	./$(BIN)/simulate $(MCU_TARGET)

$(BIN)/simulate: $(SIM)/simulate.c
	gcc $< -O2 -o $@ -lglut -lGL -lpthread -lsimavr

clean:
	rm -rf $(BIN)/* $(SIM)/simulate
