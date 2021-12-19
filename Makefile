SRC            = src
MCU_TARGET     = atmega2560
DEFS           = -D DEV -D __$(MCU_TARGET)
AS             = avra
OBJDUMP        = avr-objdump

all: main.hex main.lst

%.hex: $(SRC)/%.asm $(SRC)/*.asm $(SRC)/*.inc
	$(AS) $(DEFS) -I $(SRC) -o $@ $<

%.lst: %.hex
	$(OBJDUMP) -m avr51 -D $< > $@

upload: all
	avrdude -p $(MCU_TARGET) -c wiring -P /dev/ttyACM0 -b 115200 -D -U flash:w:main.hex:i

clean:
	rm -rf *.hex *.lst *.i *.o *.s $(SRC)/*.obj $(SRC)/*.eep.hex
