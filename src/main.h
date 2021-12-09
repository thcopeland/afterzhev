#ifndef MAIN_H
#define MAIN_H

#ifdef DEV
#include "/home/tom/src/simavr-master/simavr/sim/avr/avr_mcu_section.h"
#ifndef F_CPU
#define F_CPU 16000000
#endif
AVR_MCU(F_CPU, "atmega1280");

const struct avr_mmcu_vcd_trace_t _mytrace[]  _MMCU_ = {
	{ AVR_MCU_VCD_SYMBOL("IMAGE"), .what = (void*)&PORTA },
};

AVR_MCU_VCD_PORT_PIN('B', 0, "WORK");
AVR_MCU_VCD_PORT_PIN('B', 6, "HSYNC");
AVR_MCU_VCD_PORT_PIN('E', 4, "VSYNC");
#endif

// types and stuff
union stage_data {
    struct {
        uint8_t current_row_h, current_row_l;
        uint8_t *fbuff_line;
    } output;
    struct {
        const __flash struct sector *upper_left, *upper_right, *lower_left, *lower_right;
        uint8_t ul_start_x, ul_start_y;
    } render;
    struct {
    } update;
};

struct game_data {
    uint8_t offset_x_h, offset_x_l;
    uint8_t offset_y_h, offset_y_l;
    uint8_t active_sector;
    uint8_t tmp;
};

// quick output helper
// avr-gcc *can* generate this code, but it tends to prefer ldd and update the
// counter at the end of the loop, which leads to uneven pixel sizes.
#define WRITE_12_PIXELS(buff, port) \
    asm volatile(                   \
        "ld __tmp_reg__, %a0+\n\t"  \
        "out %1, __tmp_reg__\n\t"   \
        "ld __tmp_reg__, %a0+\n\t"  \
        "out %1, __tmp_reg__\n\t"   \
        "ld __tmp_reg__, %a0+\n\t"  \
        "out %1, __tmp_reg__\n\t"   \
        "ld __tmp_reg__, %a0+\n\t"  \
        "out %1, __tmp_reg__\n\t"   \
        "ld __tmp_reg__, %a0+\n\t"  \
        "out %1, __tmp_reg__\n\t"   \
        "ld __tmp_reg__, %a0+\n\t"  \
        "out %1, __tmp_reg__\n\t"   \
        "ld __tmp_reg__, %a0+\n\t"  \
        "out %1, __tmp_reg__\n\t"   \
        "ld __tmp_reg__, %a0+\n\t"  \
        "out %1, __tmp_reg__\n\t"   \
        "ld __tmp_reg__, %a0+\n\t"  \
        "out %1, __tmp_reg__\n\t"   \
        "ld __tmp_reg__, %a0+\n\t"  \
        "out %1, __tmp_reg__\n\t"   \
        "ld __tmp_reg__, %a0+\n\t"  \
        "out %1, __tmp_reg__\n\t"   \
        "ld __tmp_reg__, %a0+\n\t"  \
        "out %1, __tmp_reg__\n\t"   \
        : "+e" (buff)               \
        : "I" (_SFR_IO_ADDR(port))  \
    )

#endif
