SRC            = src
BIN            = bin
MCU_TARGET     = atmega2560
DEFS           = -D DEV -D __$(MCU_TARGET)
AS             = avra
OBJDUMP        = avr-objdump

all: $(BIN)/main.hex $(BIN)/main.lst

$(BIN)/%.hex: $(SRC)/%.asm $(SRC)/*.asm $(SRC)/*.inc
	$(AS) $(DEFS) -I $(SRC) -o $@ -e /dev/null -d /dev/null $<

$(BIN)/%.lst: $(BIN)/%.hex
	$(OBJDUMP) -m avr51 -D $< > $@

upload: all
	avrdude -p $(MCU_TARGET) -c wiring -P /dev/ttyACM0 -b 115200 -D -U flash:w:$(BIN)/main.hex:i

clean:
	rm -rf $(BIN)/*
