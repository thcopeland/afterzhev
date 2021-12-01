#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/sleep.h>
#include <avr/pgmspace.h>
#include "/home/tom/src/simavr-master/simavr/sim/avr/avr_mcu_section.h"
#ifndef F_CPU
#define F_CPU 16000000
#endif
AVR_MCU(F_CPU, "atmega1280");
// const struct avr_mmcu_vcd_trace_t _mytrace[]  _MMCU_ = {
//     { AVR_MCU_VCD_SYMBOL("PORTB"), .what = (void*)&PORTB, },
//     { AVR_MCU_VCD_SYMBOL("TCNT1"), .what = (void*)&TCNT1, },
    // { AVR_MCU_VCD_SYMBOL("GTCCR"), .what = (void*)&GTCCR, },
//
// };
AVR_MCU_VCD_PORT_PIN('C', 5, "GREEN");
AVR_MCU_VCD_PORT_PIN('B', 6, "HSYNC");
AVR_MCU_VCD_PORT_PIN('E', 4, "VSYNC");

// PB7 - T1C
// PB6 - T1B
// PB5 - T1A
// PE5 - T3C
// PE4 - T3B
// PE3 - T3A

static uint8_t data[1024];
static uint16_t offset = 0;

ISR(TIMER1_COMPA_vect, ISR_NAKED) {
    // send image data
    // uint8_t clk_l = TCNT3 >> 6;
    // uint8_t clk_h = TCNT3 >> 14;

    // between 31*64 and (480+31)*64
    if (TCNT3 > 31*64 && TCNT3 < (480+31)*64) { // 511
        // __builtin_avr_delay_cycles(6);
        uint8_t *data_line = data + (uint8_t)32*(uint8_t)(offset>>4); // force 8 bit math
        for (uint8_t i = 0; i < 32;) {
            PORTC = data_line[i];
            // PORTC = data_line[i+1];
            // PORTC = data_line[i+2];
            // PORTC = data_line[i+3];
            // PORTC = data_line[i+4];
            // PORTC = data_line[i+5];
            // PORTC = data_line[i+6];
            // PORTC = data_line[i+7];
            i++;
        }
        offset++;
        if (offset >= 480) offset = 0;
        // offset &= 7;
        // offset = (offset + 1) & 1;
        // register unsigned char i = 0;
        // PORTC = data[i++];
        PORTC = 0x00;
    } else {
        // time to work!
    }
    reti();
}

int main(void) {
    for (uint16_t i = 0; i < sizeof(data); i++) {
        data[i] = (i<<4) + ((i>>3)<<1);
    }
    data[0] = 0xFF;
    data[1] = 0x00;
    data[2] = 0xFF;
    data[3] = 0x00;
    data[4] = 0xFF;
    data[5] = 0x00;
    data[6] = 0xFF;
    data[7] = 0x00;

    DDRB = 0xFF;
    DDRC = 0xFF;
    DDRE = 0xFF;

    PORTB = 0x00;
    PORTE = 0x00;

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
    TCCR3B = (1 << WGM32) | (1 << WGM33) | (1 << CS31); // use 64 prescaling?
    // OCR3A = 33599-64*13;
    // OCR3B = 33471-64*13;
    OCR3A = 33599;
    OCR3B = 33471;
    // OCR3A = 33535;
    // OCR3B = 33407;

    // synchronize timers
    TCNT1 = 26; // slight offset for the back porch
    TCNT3 = 0; //OCR3A-64*120;

    // release timers
    GTCCR = 0;

    sei();

    while(1) {
        sleep_mode();
    }

    return 1;
}
