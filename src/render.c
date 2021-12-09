#include <avr/pgmspace.h>
#include "tile.h"
#include "map.h"
#include "display.h"
#include "render.h"

void render_partial_tile(uint8_t *buffer, uint8_t tile, uint8_t row_min, uint8_t col_min, uint8_t height, uint8_t width) {
    const __flash uint8_t *p = tileset[tile] + TILE_WIDTH*row_min + col_min;
    for (uint8_t i = 0; i < height; i++) {
        for (uint8_t j = 0; j < width; j++) {
            *(buffer++) = *(p++);
        }
        p += TILE_WIDTH-width;
        buffer += DISPLAY_WIDTH-width;
    }
}

/*inline void render_tile_fast(uint8_t *buffer, uint8_t tile, uint8_t row_min, uint8_t row_max) {
    uint16_t p = (uint16_t) tileset[tile] + TILE_WIDTH*row_min;
    for (uint8_t i = row_min; i < row_max; i++) {
        // static JUMP TABLE?
        asm volatile(
            "lpm __tmp_reg__, %a0+\n\t"
            "st %a1+, __tmp_reg__\n\t"
            "lpm __tmp_reg__, %a0+\n\t"
            "st %a1+, __tmp_reg__\n\t"
            "lpm __tmp_reg__, %a0+\n\t"
            "st %a1+, __tmp_reg__\n\t"
            "lpm __tmp_reg__, %a0+\n\t"
            "st %a1+, __tmp_reg__\n\t"
            "lpm __tmp_reg__, %a0+\n\t"
            "st %a1+, __tmp_reg__\n\t"
            "lpm __tmp_reg__, %a0+\n\t"
            "st %a1+, __tmp_reg__\n\t"
            "lpm __tmp_reg__, %a0+\n\t"
            "st %a1+, __tmp_reg__\n\t"
            "lpm __tmp_reg__, %a0+\n\t"
            "st %a1+, __tmp_reg__\n\t"
            "lpm __tmp_reg__, %a0+\n\t"
            "st %a1+, __tmp_reg__\n\t"
            "lpm __tmp_reg__, %a0+\n\t"
            "st %a1+, __tmp_reg__\n\t"
            "lpm __tmp_reg__, %a0+\n\t"
            "st %a1+, __tmp_reg__\n\t"
            "lpm __tmp_reg__, %a0+\n\t"
            "st %a1+, __tmp_reg__\n\t"
            : "+z" (p), "+e" (buffer)
        );
        p += TILE_WIDTH - width;
        buffer += DISPLAY_WIDTH - TILE_WIDTH;
    }
}*/

inline void render_tile(uint8_t *buff, uint8_t tile, uint8_t row_min, uint8_t row_max) {
    uint16_t p = (uint16_t) tileset[tile] + TILE_WIDTH*row_min;

    for (uint8_t i = row_min; i < row_max; i++) {
        asm volatile(
            "lpm __tmp_reg__, %a0+\n\t"
            "st %a1+, __tmp_reg__\n\t"
            "lpm __tmp_reg__, %a0+\n\t"
            "st %a1+, __tmp_reg__\n\t"
            "lpm __tmp_reg__, %a0+\n\t"
            "st %a1+, __tmp_reg__\n\t"
            "lpm __tmp_reg__, %a0+\n\t"
            "st %a1+, __tmp_reg__\n\t"
            "lpm __tmp_reg__, %a0+\n\t"
            "st %a1+, __tmp_reg__\n\t"
            "lpm __tmp_reg__, %a0+\n\t"
            "st %a1+, __tmp_reg__\n\t"
            "lpm __tmp_reg__, %a0+\n\t"
            "st %a1+, __tmp_reg__\n\t"
            "lpm __tmp_reg__, %a0+\n\t"
            "st %a1+, __tmp_reg__\n\t"
            "lpm __tmp_reg__, %a0+\n\t"
            "st %a1+, __tmp_reg__\n\t"
            "lpm __tmp_reg__, %a0+\n\t"
            "st %a1+, __tmp_reg__\n\t"
            "lpm __tmp_reg__, %a0+\n\t"
            "st %a1+, __tmp_reg__\n\t"
            "lpm __tmp_reg__, %a0+\n\t"
            "st %a1+, __tmp_reg__\n\t"
            : "+z" (p), "+e" (buff)
        );
        buff += DISPLAY_WIDTH-TILE_WIDTH;
    }
}


void render_visible_sectors(uint8_t *fbuff,
                            const __flash struct sector *upper_left,
                            const __flash struct sector *upper_right,
                            const __flash struct sector *lower_left,
                            const __flash struct sector *lower_right,
                            uint8_t lr_offset_x_h, uint8_t lr_offset_x_l,
                            uint8_t lr_offset_y_h, uint8_t lr_offset_y_l) {
    /*if (lr_offset_x_l || lr_offset_y_l) { // general case
        uint8_t *buff = fbuff;
        uint8_t extra_row = lr_offset_y_l != 0,
                extra_col = lr_offset_x_l != 0;

        for (uint8_t row = lr_offset_y_h; row < SECTOR_HEIGHT; row++) {
            render_partial_tile(buff,
                                upper_left->tiles[row*SECTOR_WIDTH+(SECTOR_WIDTH-lr_offset_x_h-1)],
                                lr_offset_y_l,
                                TILE_WIDTH-lr_offset_x_l,
                                TILE_HEIGHT-lr_offset_y_l,
                                lr_offset_x_l);
            // render_partial_tile(buff,
            //                     0,
            //                     lr_offset_y_l,
            //                     TILE_WIDTH-lr_offset_x_l,
            //                     TILE_HEIGHT-lr_offset_y_l,
            //                     lr_offset_x_l);
            buff += DISPLAY_WIDTH*TILE_HEIGHT;
        }
    }*/

    if (lr_offset_x_l && lr_offset_y_l) {

    } else if (lr_offset_x_l) {
        uint8_t *buff = fbuff;

        for (uint8_t row = lr_offset_y_h; row < SECTOR_HEIGHT; row++) {
            render_partial_tile(buff,
                                upper_left->tiles[row*SECTOR_WIDTH+(SECTOR_WIDTH-lr_offset_x_h-1)],
                                0,
                                TILE_WIDTH-lr_offset_x_l,
                                TILE_HEIGHT,
                                lr_offset_x_l);

            render_partial_tile(buff + DISPLAY_WIDTH-TILE_WIDTH+lr_offset_x_l,
                                upper_right->tiles[row*SECTOR_WIDTH+lr_offset_x_h],
                                0,
                                0,
                                TILE_HEIGHT,
                                lr_offset_x_l);

            buff += DISPLAY_WIDTH*TILE_HEIGHT;
        }
    } else if (lr_offset_y_l) {

    }

    // render the upper row except for the leftmost and rightmost tiles
    // TODO
    // fbuff += DISPLAY_WIDTH*lr_offset_y_l;

    // render the inside tiles of the upper left and upper right sectors
    // fbuff += lr_offset_x_l;
    // render_tile_fast(fbuff, upper_left->tiles[0], 0, 12);

    // for (uint8_t row = lr_offset_y_h+1; row < SECTOR_HEIGHT; row++) {
    //     for (uint8_t col = (SECTOR_WIDTH-lr_offset_x_h); col < SECTOR_WIDTH; col++) {
    //         render_tile_fast(fbuff, upper_left->tiles[row*SECTOR_WIDTH + col], 0, 12);
    //         fbuff += TILE_WIDTH;
    //     }
    //
    //     for (uint8_t col = 0; col < (SECTOR_WIDTH-lr_offset_x_h-1); col++) {
    //         render_tile_fast(fbuff, upper_right->tiles[row*SECTOR_WIDTH + col], 0, 12);
    //         fbuff += TILE_WIDTH;
    //     }
    //
    //     fbuff += DISPLAY_WIDTH*(TILE_HEIGHT - 1) + TILE_WIDTH;
    // }

    // render the inside tiles of the lower left and lower right sectors



    // for (uint8_t row = lr_offset_y_h; row < SECTOR_HEIGHT; row++) {
    //     for (uint8_t col = (SECTOR_WIDTH-lr_offset_x_h); col < SECTOR_WIDTH; col++) {
    //         render_tile(fbuff, upper_left->tiles[row*SECTOR_WIDTH + col], 0, 12);
    //         fbuff += TILE_WIDTH;
    //     }
    //
    //     for (uint8_t col = 0; col < (SECTOR_WIDTH-lr_offset_x_h); col++) {
    //         render_tile(fbuff, upper_right->tiles[row*SECTOR_WIDTH + col], 0, 12);
    //         fbuff += TILE_WIDTH;
    //     }
    //
    //     fbuff += DISPLAY_WIDTH*(TILE_HEIGHT - 1);
    // }
}
