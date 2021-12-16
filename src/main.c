#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/sleep.h>
#include "display.h"
#include "map.h"
#include "tile.h"
#include "render.h"
#include "main.h"

static uint8_t fbuff[FBUFF_SIZE];

static uint8_t current_stage;
static union stage_data stage_data;
static struct game_data game_data = {
    .offset_x_h = 0, .offset_x_l = 0,
    .offset_y_h = 0, .offset_y_l = 0,
    .active_sector = sectors
};

static uint8_t tmp, dir_x = 1, dir_y = 1;

// main loop
// no prologue or epilogue is necessary, since all the game code will run inside
// here. This saves a fair number of cycles.
ISR(TIMER1_COMPA_vect, ISR_NAKED) {
    if (TCNT3 > VSYNC_BACK_PORCH_PRESCALED && TCNT3 <= LINES_TO_TICKS(DISPLAY_VERTICAL_SCALE*DISPLAY_TOTAL_HEIGHT+VGA_VBACK_PORCH_LINES)) {
        uint8_t *fbuff_line = stage_data.output.fbuff_line;
        WRITE_12_PIXELS(fbuff_line, PORTA);
        WRITE_12_PIXELS(fbuff_line, PORTA);
        WRITE_12_PIXELS(fbuff_line, PORTA);
        WRITE_12_PIXELS(fbuff_line, PORTA);
        WRITE_12_PIXELS(fbuff_line, PORTA);
        WRITE_12_PIXELS(fbuff_line, PORTA);
        WRITE_12_PIXELS(fbuff_line, PORTA);
        WRITE_12_PIXELS(fbuff_line, PORTA);
        WRITE_12_PIXELS(fbuff_line, PORTA);
        WRITE_12_PIXELS(fbuff_line, PORTA);
        stage_data.output.current_row_l++;
        PORTA = 0x00;
        if (stage_data.output.current_row_l >= DISPLAY_VERTICAL_SCALE) {
            stage_data.output.current_row_l = 0;
            stage_data.output.fbuff_line = fbuff_line;
            stage_data.output.current_row_h++;
            if (stage_data.output.current_row_h >= FOOTER_HEIGHT && current_stage) {
                current_stage = 2;
            } else if (stage_data.output.current_row_h >= DISPLAY_HEIGHT) {
                stage_data.output.current_row_h = 0;
                stage_data.output.current_row_l = 0;
                // stage_data.output.fbuff_line = fbuff;
                current_stage = 1;
            }
        }

        // ~90 free cycles
        // render a single layer of the footer (120x16)
    } else if (current_stage == 2) {
        tmp++;
        if (tmp > 0) {
            tmp = 0;
            PORTB ^= 0b10000000;
            if (dir_x) {
                if (game_data.offset_x_l < 11) {
                    game_data.offset_x_l++;
                } else if (game_data.offset_x_h < 9) {
                    game_data.offset_x_h++;
                    game_data.offset_x_l = 0;
                } else {
                    dir_x = 0;
                }
            } else {
                if (game_data.offset_x_l > 0) {
                    game_data.offset_x_l--;
                } else if (game_data.offset_x_h > 0) {
                    game_data.offset_x_h--;
                    game_data.offset_x_l = 11;
                } else {
                    dir_x = 1;
                }
            }

            if (game_data.offset_x_l & 1) {
                if (dir_y) {
                    if (game_data.offset_y_l < 11) {
                        game_data.offset_y_l++;
                    } else if (game_data.offset_y_h < 4) {
                        game_data.offset_y_h++;
                        game_data.offset_y_l = 0;
                    } else {
                        dir_y = 0;
                    }
                } else {
                    if (game_data.offset_y_l > 0) {
                        game_data.offset_y_l--;
                    } else if (game_data.offset_y_h > 0) {
                        game_data.offset_y_h--;
                        game_data.offset_y_l = 11;
                    } else {
                        dir_y = 1;
                    }
                }
            }
        }
        render_sector(fbuff, game_data.active_sector, game_data.offset_x_h, game_data.offset_x_l, game_data.offset_y_h, game_data.offset_y_l);
        current_stage++;
        TIFR1 = 0xFF;
    } else if (current_stage > 2) {
        current_stage = 0;
        stage_data.output.current_row_h = 0;
        stage_data.output.current_row_l = 0;
        stage_data.output.fbuff_line = fbuff;
        TIFR1 = 0xFF;
    }
    reti();
}

int main(void) {
    DDRA = 0xFF;
    DDRB = 0xFF;
    DDRE = 0xFF;

    // halt all timers
    GTCCR = (1 << TSM) | (1 << PSRASY) | (1 << PSRSYNC);

    // HSYNC
    // initialize timer 1 to fast PWM (pin PB6)
    TCCR1A = (1 << WGM10) | (1 << WGM11) | (1 << COM1B1) | (1 << COM1B0);
    TCCR1B = (1 << WGM12) | (1 << WGM13) | (1 << CS10);
    OCR1A = HSYNC_PERIOD - 1;
    OCR1B = HSYNC_PERIOD - HSYNC_SYNC_WIDTH - 1;
    TIMSK1 = (1 << OCIE1A);

    // VSYNC
    // initialize timer 3 to fast PWM (pin PE4)
    TCCR3A = (1 << WGM30) | (1 << WGM31) | (1 << COM3B1) | (1 << COM3B0);
    TCCR3B = (1 << WGM32) | (1 << WGM33) | (1 << CS32);
    OCR3A = VSYNC_PERIOD_PRESCALED - 1;
    OCR3B = VSYNC_PERIOD_PRESCALED - VSYNC_SYNC_PRESCALED - 1;

    // synchronize timers
    TCNT1 = OCR1A;
    TCNT3 = OCR3A-VIRT_ADJUST*20;

    // release timers
    GTCCR = 0;

    sei();
    while(1) sleep_mode(); // sleep for consistent interrupt timing (prevents horizontal blurring)
    return 1;
}
