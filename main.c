#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/sleep.h>
#include "display.h"

uint8_t vbuff[VBUFF_SIZE];
static uint8_t offset_h = 0, // offset in rows divided by 10
               offset_l = 0; // offset in rows mod 10

// avr-gcc can generate this code, but it tends to use ldd and update the counter
// at the end of the loop, which leads to uneven pixel sizes.
#define WRITE_PIXEL(buff, port)     \
    asm volatile(                   \
        "ld __tmp_reg__, %a0+\n\t"  \
        "out %1, __tmp_reg__\n\t"   \
        : "+e" (buff)               \
        : "I" (_SFR_IO_ADDR(port))  \
    )

#define WRITE_PIXEL_DELAY(buff, port)   \
    WRITE_PIXEL(buff, port);            \
    __builtin_avr_nop()

#define WRITE_8_PIXELS(buff, port)  \
    WRITE_PIXEL_DELAY(buff, port);  \
    WRITE_PIXEL_DELAY(buff, port);  \
    WRITE_PIXEL_DELAY(buff, port);  \
    WRITE_PIXEL_DELAY(buff, port);  \
    WRITE_PIXEL_DELAY(buff, port);  \
    WRITE_PIXEL_DELAY(buff, port);  \
    WRITE_PIXEL_DELAY(buff, port);  \
    WRITE_PIXEL_DELAY(buff, port)

// main loop
// no prologue or epilogue is necessary, since all the game code will run inside
// here. This saves a fair number of cycles.
ISR(TIMER1_COMPA_vect, ISR_NAKED) {
    if (TCNT3 > 512/256*31 && TCNT3 <= 512/256*(360+31)) {
        uint8_t *vbuff_line = vbuff + DISPLAY_WIDTH*(uint16_t)offset_h;
        WRITE_8_PIXELS(vbuff_line, PORTA);
        WRITE_8_PIXELS(vbuff_line, PORTA);
        WRITE_8_PIXELS(vbuff_line, PORTA);
        WRITE_8_PIXELS(vbuff_line, PORTA);
        WRITE_8_PIXELS(vbuff_line, PORTA);
        WRITE_8_PIXELS(vbuff_line, PORTA);
        WRITE_8_PIXELS(vbuff_line, PORTA);
        WRITE_8_PIXELS(vbuff_line, PORTA);
        WRITE_8_PIXELS(vbuff_line, PORTA);
        WRITE_8_PIXELS(vbuff_line, PORTA);
        PORTA = 0x00;

        // update and rollover offset_l
        if ((++offset_l) >= 6) {
            offset_l = 0;
            // update and rollover offset_h
            if ((++offset_h) >= DISPLAY_HEIGHT) offset_h = 0;
        }
        // ~75 free cycles
    } else {
        // ~500 free cycles
    }
    reti();
}

int main(void) {
    for (uint16_t i = 0; i < sizeof(vbuff); i++) {
        vbuff[i] = i;
    }
    // first row pattern
    vbuff[0] = 0xFF;
    vbuff[1] = 0x00;
    vbuff[2] = 0xFF;
    vbuff[3] = 0x00;
    vbuff[4] = 0xFF;
    vbuff[5] = 0x00;
    vbuff[6] = 0xFF;
    vbuff[7] = 0x00;

    DDRA = 0xFF;
    DDRB = 0xFF;
    DDRE = 0xFF;

    // halt all timers
    GTCCR = (1 << TSM) | (1 << PSRASY) | (1 << PSRSYNC);

    // HSYNC
    // initialize timer 1 to fast PWM (pin PB6)
    TCCR1A = (1 << WGM10) | (1 << WGM11) | (1 << COM1B1) | (1 << COM1B0);
    TCCR1B = (1 << WGM12) | (1 << WGM13) | (1 << CS10);
    OCR1A = 511;
    OCR1B = 449;
    TIMSK1 = (1 << OCIE1A);

    // VSYNC
    // initialize timer 3 to fast PWM (pin PE4)
    TCCR3A = (1 << WGM30) | (1 << WGM31) | (1 << COM3B1) | (1 << COM3B0);
    TCCR3B = (1 << WGM32) | (1 << WGM33) | (1 << CS32);
    OCR3A = 512/256*(480+11+2+31)-1;
    OCR3B = 512/256*(480+11+2)-1;

    // synchronize timers
    TCNT1 = OCR1A;
    TCNT3 = OCR3A-VIRT_ADJUST*20;

    // release timers
    GTCCR = 0;

    sei();
    while(1) sleep_mode(); // sleep for consistent interrupt timing (prevents horizontal blurring)
    return 1;
}
