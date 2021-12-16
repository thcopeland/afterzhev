#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/sleep.h>
#include "display.h"
#include "map.h"
#include "tile.h"
#include "coords.h"
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
        // game_data.active_sector = sectors;
        tmp++;
        if (tmp > 0) {
            tmp = 0;
            // x++;
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
        // if (x > 11) x = 0;
        render_sector(fbuff, game_data.active_sector, game_data.offset_x_h, game_data.offset_x_l, game_data.offset_y_h, game_data.offset_y_l);
        // render_sector(fbuff, game_data.active_sector, 0, 0, game_data.offset_y_h, game_data.offset_y_l);
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
    // for (uint16_t i = 0; i < sizeof(fbuff); i++) {
    //     fbuff[i] = i;
    // }
    //
    // fbuff[0] = 0xc7; fbuff[1] = 0xc7; fbuff[2] = 0xd; fbuff[3] = 0xd; fbuff[4] = 0x48; fbuff[5] = 0x48; fbuff[6] = 0x48; fbuff[7] = 0x48; fbuff[8] = 0x48; fbuff[9] = 0xc7; fbuff[10] = 0xc7; fbuff[11] = 0xc7;
    // fbuff[120] = 0xc7; fbuff[121] = 0x48; fbuff[122] = 0x48; fbuff[123] = 0x2f; fbuff[124] = 0xd1; fbuff[125] = 0xd1; fbuff[126] = 0xd1; fbuff[127] = 0xd1; fbuff[128] = 0x48; fbuff[129] = 0x48; fbuff[130] = 0x48; fbuff[131] = 0xc7;
    // fbuff[240] = 0xc7; fbuff[241] = 0xc7; fbuff[242] = 0xa; fbuff[243] = 0x48; fbuff[244] = 0x48; fbuff[245] = 0xd1; fbuff[246] = 0xd1; fbuff[247] = 0x48; fbuff[248] = 0x48; fbuff[249] = 0xa; fbuff[250] = 0xc7; fbuff[251] = 0xc7;
    // fbuff[360] = 0xc7; fbuff[361] = 0xc7; fbuff[362] = 0x13; fbuff[363] = 0x6e; fbuff[364] = 0x6e; fbuff[365] = 0x48; fbuff[366] = 0x48; fbuff[367] = 0x6e; fbuff[368] = 0x6e; fbuff[369] = 0x13; fbuff[370] = 0xc7; fbuff[371] = 0xc7;
    // fbuff[480] = 0xc7; fbuff[481] = 0xc7; fbuff[482] = 0x5d; fbuff[483] = 0xa; fbuff[484] = 0xa; fbuff[485] = 0x6e; fbuff[486] = 0x6e; fbuff[487] = 0xa; fbuff[488] = 0xa; fbuff[489] = 0x5d; fbuff[490] = 0xc7; fbuff[491] = 0xc7;
    // fbuff[600] = 0xc7; fbuff[601] = 0xc7; fbuff[602] = 0x5d; fbuff[603] = 0xff; fbuff[604] = 0x48; fbuff[605] = 0x6e; fbuff[606] = 0x6e; fbuff[607] = 0x48; fbuff[608] = 0xff; fbuff[609] = 0x5d; fbuff[610] = 0xc7; fbuff[611] = 0xc7;
    // fbuff[720] = 0xc7; fbuff[721] = 0xc7; fbuff[722] = 0xc7; fbuff[723] = 0x5d; fbuff[724] = 0x5d; fbuff[725] = 0x5d; fbuff[726] = 0x5d; fbuff[727] = 0x5d; fbuff[728] = 0x5d; fbuff[729] = 0xc7; fbuff[730] = 0xc7; fbuff[731] = 0xc7;
    // fbuff[840] = 0xc7; fbuff[841] = 0xc7; fbuff[842] = 0x77; fbuff[843] = 0x2f; fbuff[844] = 0x48; fbuff[845] = 0xd1; fbuff[846] = 0xd1; fbuff[847] = 0x48; fbuff[848] = 0x2f; fbuff[849] = 0x77; fbuff[850] = 0xc7; fbuff[851] = 0xc7;
    // fbuff[960] = 0xc7; fbuff[961] = 0xc7; fbuff[962] = 0x48; fbuff[963] = 0x48; fbuff[964] = 0xd1; fbuff[965] = 0x48; fbuff[966] = 0x48; fbuff[967] = 0xd1; fbuff[968] = 0x48; fbuff[969] = 0x48; fbuff[970] = 0xc7; fbuff[971] = 0xc7;
    // fbuff[1080] = 0xc7; fbuff[1081] = 0xc7; fbuff[1082] = 0x5d; fbuff[1083] = 0x6e; fbuff[1084] = 0x48; fbuff[1085] = 0x48; fbuff[1086] = 0x48; fbuff[1087] = 0x48; fbuff[1088] = 0x6e; fbuff[1089] = 0x5d; fbuff[1090] = 0xc7; fbuff[1091] = 0xc7;
    // fbuff[1200] = 0xc7; fbuff[1201] = 0xc7; fbuff[1202] = 0xc7; fbuff[1203] = 0x48; fbuff[1204] = 0x48; fbuff[1205] = 0xa; fbuff[1206] = 0xa; fbuff[1207] = 0x48; fbuff[1208] = 0x48; fbuff[1209] = 0xc7; fbuff[1210] = 0xc7; fbuff[1211] = 0xc7;
    // fbuff[1320] = 0xc7; fbuff[1321] = 0xc7; fbuff[1322] = 0xc7; fbuff[1323] = 0xa; fbuff[1324] = 0xa; fbuff[1325] = 0xc7; fbuff[1326] = 0xc7; fbuff[1327] = 0xa; fbuff[1328] = 0xa; fbuff[1329] = 0xc7; fbuff[1330] = 0xc7; fbuff[1331] = 0xc7;
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
