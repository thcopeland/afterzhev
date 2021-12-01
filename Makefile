PRG            = main
OBJ            = main.o
OPTIMIZE       = -O2
DEFS           =
LIBS           =
CC             = avr-gcc
MCU_TARGET	   = atmega1280

# Override is only needed by avr-lib build system.
override CFLAGS        = -g -Wall -Wextra -Werror $(OPTIMIZE) -mmcu=$(MCU_TARGET) $(DEFS)

OBJCOPY        = avr-objcopy
OBJDUMP        = avr-objdump

all: $(PRG).elf $(PRG).hex $(PRG).lst

$(PRG).elf: $(OBJ)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^ $(LIBS)

main.o: main.c

clean:
	rm -rf *.o *.elf *.hex *.lst

upload: all
	avrdude -p atmega1280 -c arduino -P /dev/ttyUSB0 -b 57600 -D -U flash:w:$(PRG).hex:i

%.lst: %.elf
	$(OBJDUMP) -h -S $< > $@

%.hex: %.elf
	$(OBJCOPY) -j .text -j .data -O ihex $< $@
