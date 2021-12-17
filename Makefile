OBJ            = main.o map.o tile.o render.o render_helpers.o
SRC 		   = src
OPTIMIZE       = -O2 -flto
DEFS           = -DDEV
CC             = avr-gcc
MCU_TARGET	   = atmega2560
CFLAGS		   = -Wall -Wextra -mmcu=$(MCU_TARGET) $(DEFS)
OBJCOPY        = avr-objcopy
OBJDUMP        = avr-objdump

all: game.elf game.hex game.lst

upload: all
	avrdude -p $(MCU_TARGET) -c wiring -P /dev/ttyACM0 -b 115200 -D -U flash:w:game.hex:i

game.elf: $(OBJ)
	$(CC) $(CFLAGS) $(OPTIMIZE) -o $@ $^

%.o: $(SRC)/%.c
	$(CC) $(CFLAGS) $(OPTIMIZE) -c -o $@ $^

%.o: $(SRC)/%.S
	$(CC) $(CFLAGS) -c -o $@ $^

clean:
	rm -rf *.o *.elf *.hex *.lst *.i *.res *.s *.out

%.lst: %.elf
	$(OBJDUMP) -d $< > $@

%.hex: %.elf
	$(OBJCOPY) -j .text -j .data -O ihex $< $@
