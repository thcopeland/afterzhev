#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/sleep.h>
#include "display.h"
#include "map.h"
#include "tile.h"
#include "coords.h"
#include "render.h"
#include "main.h"

static uint8_t vbuff[VBUFF_SIZE];
static uint8_t *fbuff = vbuff + TILE_WIDTH;

static uint8_t current_stage;
static union stage_data stage_data;
static struct game_data game_data = {
    0, 0, 0, 0, 4, 0
};

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
        PORTA = 0x00;

        if ((++stage_data.output.current_row_l) >= DISPLAY_VERTICAL_SCALE) {
            stage_data.output.current_row_l = 0;
            stage_data.output.fbuff_line = fbuff_line;
            if ((++stage_data.output.current_row_h) >= FOOTER_HEIGHT && current_stage) {
                current_stage = 2;
            } else if (stage_data.output.current_row_h >= DISPLAY_HEIGHT) {
                stage_data.output.current_row_h = 0;
                stage_data.output.current_row_l = 0;
                // stage_data.output.fbuff_line = fbuff; // TODO UNCOMMENT ME!!
                current_stage = 1;
            }
        }

        // ~90 free cycles
        // render a single layer of the footer (120x16)
    } else {
        // render/update the game screen (120x60)
        switch (current_stage++) {
            case 2:
                // __builtin_avr_delay_cycles(64000);
                stage_data.render.lower_right = sectors + game_data.active_sector;
                stage_data.render.lower_left = sectors + stage_data.render.lower_right->left;
                stage_data.render.upper_right = sectors + stage_data.render.lower_left->above;
                stage_data.render.upper_left = sectors + stage_data.render.lower_right->above;

                if (game_data.tmp++ > 10) {
                    game_data.offset_x_l++;
                    game_data.tmp = 0;
                    if (game_data.offset_x_l > 12) game_data.offset_x_l = 1;
                }

                render_visible_sectors(fbuff, stage_data.render.upper_left, stage_data.render.lower_left, stage_data.render.upper_right, stage_data.render.upper_left, 0, 2, 0, 0);
                // render_visible_sectors(fbuff, sectors, sectors, sectors, sectors, 0, 0);
                break;
            default:
                // reset to output stage
                current_stage = 0;
                stage_data.output.current_row_h = 0;
                stage_data.output.current_row_l = 0;
                stage_data.output.fbuff_line = fbuff;
                break;
        }

        TIFR1 = 0xFF; // clear any pending interrupts on timer 1
    }
    reti();
}

int main(void) {
    // for (uint16_t i = 0; i < sizeof(vbuff); i++) {
    //     fbuff[i] = i;
    // }
    //
    // vbuff[0] = 0xc7; vbuff[1] = 0xc7; vbuff[2] = 0xd; vbuff[3] = 0xd; vbuff[4] = 0x48; vbuff[5] = 0x48; vbuff[6] = 0x48; vbuff[7] = 0x48; vbuff[8] = 0x48; vbuff[9] = 0xc7; vbuff[10] = 0xc7; vbuff[11] = 0xc7;
    // vbuff[120] = 0xc7; vbuff[121] = 0x48; vbuff[122] = 0x48; vbuff[123] = 0x2f; vbuff[124] = 0xd1; vbuff[125] = 0xd1; vbuff[126] = 0xd1; vbuff[127] = 0xd1; vbuff[128] = 0x48; vbuff[129] = 0x48; vbuff[130] = 0x48; vbuff[131] = 0xc7;
    // vbuff[240] = 0xc7; vbuff[241] = 0xc7; vbuff[242] = 0xa; vbuff[243] = 0x48; vbuff[244] = 0x48; vbuff[245] = 0xd1; vbuff[246] = 0xd1; vbuff[247] = 0x48; vbuff[248] = 0x48; vbuff[249] = 0xa; vbuff[250] = 0xc7; vbuff[251] = 0xc7;
    // vbuff[360] = 0xc7; vbuff[361] = 0xc7; vbuff[362] = 0x13; vbuff[363] = 0x6e; vbuff[364] = 0x6e; vbuff[365] = 0x48; vbuff[366] = 0x48; vbuff[367] = 0x6e; vbuff[368] = 0x6e; vbuff[369] = 0x13; vbuff[370] = 0xc7; vbuff[371] = 0xc7;
    // vbuff[480] = 0xc7; vbuff[481] = 0xc7; vbuff[482] = 0x5d; vbuff[483] = 0xa; vbuff[484] = 0xa; vbuff[485] = 0x6e; vbuff[486] = 0x6e; vbuff[487] = 0xa; vbuff[488] = 0xa; vbuff[489] = 0x5d; vbuff[490] = 0xc7; vbuff[491] = 0xc7;
    // vbuff[600] = 0xc7; vbuff[601] = 0xc7; vbuff[602] = 0x5d; vbuff[603] = 0xff; vbuff[604] = 0x48; vbuff[605] = 0x6e; vbuff[606] = 0x6e; vbuff[607] = 0x48; vbuff[608] = 0xff; vbuff[609] = 0x5d; vbuff[610] = 0xc7; vbuff[611] = 0xc7;
    // vbuff[720] = 0xc7; vbuff[721] = 0xc7; vbuff[722] = 0xc7; vbuff[723] = 0x5d; vbuff[724] = 0x5d; vbuff[725] = 0x5d; vbuff[726] = 0x5d; vbuff[727] = 0x5d; vbuff[728] = 0x5d; vbuff[729] = 0xc7; vbuff[730] = 0xc7; vbuff[731] = 0xc7;
    // vbuff[840] = 0xc7; vbuff[841] = 0xc7; vbuff[842] = 0x77; vbuff[843] = 0x2f; vbuff[844] = 0x48; vbuff[845] = 0xd1; vbuff[846] = 0xd1; vbuff[847] = 0x48; vbuff[848] = 0x2f; vbuff[849] = 0x77; vbuff[850] = 0xc7; vbuff[851] = 0xc7;
    // vbuff[960] = 0xc7; vbuff[961] = 0xc7; vbuff[962] = 0x48; vbuff[963] = 0x48; vbuff[964] = 0xd1; vbuff[965] = 0x48; vbuff[966] = 0x48; vbuff[967] = 0xd1; vbuff[968] = 0x48; vbuff[969] = 0x48; vbuff[970] = 0xc7; vbuff[971] = 0xc7;
    // vbuff[1080] = 0xc7; vbuff[1081] = 0xc7; vbuff[1082] = 0x5d; vbuff[1083] = 0x6e; vbuff[1084] = 0x48; vbuff[1085] = 0x48; vbuff[1086] = 0x48; vbuff[1087] = 0x48; vbuff[1088] = 0x6e; vbuff[1089] = 0x5d; vbuff[1090] = 0xc7; vbuff[1091] = 0xc7;
    // vbuff[1200] = 0xc7; vbuff[1201] = 0xc7; vbuff[1202] = 0xc7; vbuff[1203] = 0x48; vbuff[1204] = 0x48; vbuff[1205] = 0xa; vbuff[1206] = 0xa; vbuff[1207] = 0x48; vbuff[1208] = 0x48; vbuff[1209] = 0xc7; vbuff[1210] = 0xc7; vbuff[1211] = 0xc7;
    // vbuff[1320] = 0xc7; vbuff[1321] = 0xc7; vbuff[1322] = 0xc7; vbuff[1323] = 0xa; vbuff[1324] = 0xa; vbuff[1325] = 0xc7; vbuff[1326] = 0xc7; vbuff[1327] = 0xa; vbuff[1328] = 0xa; vbuff[1329] = 0xc7; vbuff[1330] = 0xc7; vbuff[1331] = 0xc7;
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
