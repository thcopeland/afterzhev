OBJ            = main.o map.o tile.o render.o
SRC 		   = src
OPTIMIZE       = -O2 -fno-inline # TODO: -finline (and -flto) would be nice, but has problems near ISR_NAKED. The situation could be improved by marking specific functions as __attribute__ ((noinline))
DEFS           = -DDEV
LIBS           =
CC             = avr-gcc
MCU_TARGET	   = atmega1280
CFLAGS		   = -Wall -Wextra -mmcu=$(MCU_TARGET) $(OPTIMIZE) $(DEFS)
LDFLAGS		   = $(LIBS)
OBJCOPY        = avr-objcopy
OBJDUMP        = avr-objdump

all: game.elf game.hex game.lst

upload: all
	avrdude -p atmega1280 -c arduino -P /dev/ttyUSB0 -b 57600 -D -U flash:w:game.hex:i

game.elf: $(OBJ)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

%.o: $(SRC)/%.c
	$(CC) $(CFLAGS) -c -o $@ $^ $(LDFLAGS)

clean:
	rm -rf *.o *.elf *.hex *.lst *.i *.res *.s *.out

%.lst: %.elf
	$(OBJDUMP) -d $< > $@

%.hex: %.elf
	$(OBJCOPY) -j .text -j .data -O ihex $< $@
