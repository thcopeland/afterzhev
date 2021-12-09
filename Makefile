OBJ            = main.o map.o tile.o render.o coords.o
SRC 		   = src
OPTIMIZE       = -O2
DEFS           =
LIBS           =
CC             = avr-gcc
MCU_TARGET	   = atmega1280
CFLAGS		   = -g -flto -Wall -Wextra $(OPTIMIZE) -mmcu=$(MCU_TARGET) $(DEFS)
OBJCOPY        = avr-objcopy
OBJDUMP        = avr-objdump

all: game.elf game.hex game.lst

upload: all
	avrdude -p atmega1280 -c arduino -P /dev/ttyUSB0 -b 57600 -D -U flash:w:game.hex:i

game.elf: $(OBJ)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^ $(LIBS)

%.o: $(SRC)/%.c
	$(CC) $(CFLAGS) $(LDFLAGS) -c -o $@ $^ $(LIBS)

clean:
	rm -rf *.o *.elf *.hex *.lst *.i *.res *.s *.out

%.lst: %.elf
	$(OBJDUMP) -h -S $< > $@

%.hex: %.elf
	$(OBJCOPY) -j .text -j .data -O ihex $< $@
