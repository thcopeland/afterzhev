#include "tile.h"
#include "map.h"
#include "display.h"
#include "render.h"

void render_whole_tile(uint8_t *buff, uint8_t tile, uint8_t min_y, uint8_t height) {
    const __flash uint8_t *img = tileset[tile] + min_y * TILE_WIDTH;
    // uint16_t img = (uint16_t) tileset[tile] + min_y * TILE_WIDTH;

    // for (int i = 0; i < height; i++) {
    while (height--) {
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
            : "+z" (img), "+e" (buff)
            : : "r0"
        );
        // *(buff++) = *(img++);
        // *(buff++) = *(img++);
        // *(buff++) = *(img++);
        // *(buff++) = *(img++);
        // *(buff++) = *(img++);
        // *(buff++) = *(img++);
        // *(buff++) = *(img++);
        // *(buff++) = *(img++);
        // *(buff++) = *(img++);
        // *(buff++) = *(img++);
        // *(buff++) = *(img++);
        // *(buff++) = *(img++);
        buff += DISPLAY_WIDTH-TILE_WIDTH;
    }
}

/*void render_partial_tile(uint8_t *buff, uint8_t tile,
                         uint8_t min_y, uint8_t height,
                         uint8_t x_edge, uint8_t direction) {
    #ifdef DEV
    // 12 or higher results in a bad jump
    if (x_edge > 11) {
        // for (uint8_t i = 0; i < height; i++) {
        //     for (uint8_t j = 0; j < x_edge; j++) *(buff++) = 0x7;
        //     buff += DISPLAY_WIDTH-x_edge;
        // }
        return;
    }
    #endif
    // PERF this could be faster if written entirely in assembly
    // inline assembly might work, but the C/ASM labels don't mix well.
    // the main idea is to store jmp on the stack and use ret to jump.
    //    asm volatile(
    //        "sbi %0, 0x1\n\t"
    //        "breq end\n\t"
    //        "add %A1, %2\n\t"
    //        "adc %B1, __zero_reg__\n\t"
    //        "push %A3\n\t"
    //        "push %B3\n\t"
    //        "ret\n\t"
    // "end:   nop\n\t"
    //        : "+r" (height), "+z" (img)
    //        : "r" (min_x), "r" (jmp)
    //    );
    const __flash uint8_t *img = tileset[tile] + min_y * TILE_WIDTH;
    static const void *jmps[12] = { &&i, &&ii, &&iii, &&iv, &&v, &&vi, &&vii, &&viii, &&ix, &&x, &&xi, &&xii };
    const void *jmp = jmps[x_edge];

    // uint8_t width = TILE_WIDTH - x_edge;
    // if (direction) width = x_edge;
    // uint8_t width = x_edge;
    // if (direction) width = TILE_WIDTH - x_edge;
    //
    // for (uint8_t i = 0; i < height; i++) {
    //     for (uint8_t j = 0; j < width; j++) {
    //         *(buff++) = *(img++);
    //     }
    //     buff += DISPLAY_WIDTH - width;
    //     img += x_edge;
    // }
    // return;

    if (direction) img += x_edge;
    // while (height--) {
    for (int i = 0; i < height; i++) {
        goto *jmp;
// i:      asm volatile("lpm __tmp_reg__, %a0+\n\tst %a1+, __tmp_reg__\n\t" : "+z" (img), "+e" (buff));
// ii:     asm volatile("lpm __tmp_reg__, %a0+\n\tst %a1+, __tmp_reg__\n\t" : "+z" (img), "+e" (buff));
// iii:    asm volatile("lpm __tmp_reg__, %a0+\n\tst %a1+, __tmp_reg__\n\t" : "+z" (img), "+e" (buff));
// iv:     asm volatile("lpm __tmp_reg__, %a0+\n\tst %a1+, __tmp_reg__\n\t" : "+z" (img), "+e" (buff));
// v:      asm volatile("lpm __tmp_reg__, %a0+\n\tst %a1+, __tmp_reg__\n\t" : "+z" (img), "+e" (buff));
// vi:     asm volatile("lpm __tmp_reg__, %a0+\n\tst %a1+, __tmp_reg__\n\t" : "+z" (img), "+e" (buff));
// vii:    asm volatile("lpm __tmp_reg__, %a0+\n\tst %a1+, __tmp_reg__\n\t" : "+z" (img), "+e" (buff));
// viii:   asm volatile("lpm __tmp_reg__, %a0+\n\tst %a1+, __tmp_reg__\n\t" : "+z" (img), "+e" (buff));
// ix:     asm volatile("lpm __tmp_reg__, %a0+\n\tst %a1+, __tmp_reg__\n\t" : "+z" (img), "+e" (buff));
// x:      asm volatile("lpm __tmp_reg__, %a0+\n\tst %a1+, __tmp_reg__\n\t" : "+z" (img), "+e" (buff));
// xi:     asm volatile("lpm __tmp_reg__, %a0+\n\tst %a1+, __tmp_reg__\n\t" : "+z" (img), "+e" (buff));
// xii:    asm volatile("lpm __tmp_reg__, %a0+\n\tst %a1+, __tmp_reg__\n\t" : "+z" (img), "+e" (buff));
i:      *(buff++) = *(img++);
ii:     *(buff++) = *(img++);
iii:    *(buff++) = *(img++);
iv:     *(buff++) = *(img++);
v:      *(buff++) = *(img++);
vi:     *(buff++) = *(img++);
vii:    *(buff++) = *(img++);
viii:   *(buff++) = *(img++);
ix:     *(buff++) = *(img++);
x:      *(buff++) = *(img++);
xi:     *(buff++) = *(img++);
xii:    *(buff++) = *(img++);
        buff += DISPLAY_WIDTH - (TILE_WIDTH - x_edge);
        img += x_edge;
    }
}*/

void render_partial_tile2(uint8_t *buff, uint8_t tile,
                          uint8_t min_y, uint8_t height,
                          uint8_t min_x, uint8_t width) {
    const __flash uint8_t *img = tileset[tile] + min_y * TILE_WIDTH + min_x;

    // for (uint8_t i = 0; i < height; i++) {
    while (height--) {
        for (uint8_t j = 0; j < width; j++) {
            *(buff++) = *(img++);
        }
        buff += DISPLAY_WIDTH - width;
        img += TILE_WIDTH - width;
    }
}

void render_sector(uint8_t *fbuff,
                   const __flash struct sector *sector,
                   uint8_t offset_x_h, uint8_t offset_x_l,
                   uint8_t offset_y_h, uint8_t offset_y_l) {
    uint8_t row_offset = 0,
            col_offset = 0;

    if (offset_x_l && offset_y_l) {
        uint8_t *buff = fbuff;
        // upper left corner
        uint8_t corner = SECTOR_WIDTH*offset_y_h + offset_x_h;
        // render_partial_tile(buff, sector->tiles[corner], offset_y_l, TILE_HEIGHT-offset_y_l, offset_x_l, 1);
        render_partial_tile2(buff, sector->tiles[corner], offset_y_l, TILE_HEIGHT-offset_y_l, offset_x_l, TILE_WIDTH-offset_x_l);

        // top and bottom edges
        buff += TILE_WIDTH - offset_x_l;
        for (uint8_t col = 1; col < DISPLAY_TILE_WIDTH; col++) {
            uint8_t up = SECTOR_WIDTH*offset_y_h + offset_x_h + col,
                    down = up + SECTOR_WIDTH*DISPLAY_TILE_HEIGHT;
            render_whole_tile(buff, sector->tiles[up], offset_y_l, TILE_HEIGHT-offset_y_l);
            render_whole_tile(buff+DISPLAY_WIDTH*(DISPLAY_HEIGHT-offset_y_l), sector->tiles[down], 0, offset_y_l);
            buff += TILE_WIDTH;
        }

        // upper right corner
        corner = SECTOR_WIDTH*offset_y_h + offset_x_h + DISPLAY_TILE_WIDTH;
        // render_partial_tile(buff, sector->tiles[corner], offset_y_l, TILE_HEIGHT-offset_y_l, TILE_WIDTH-offset_x_l, 0);
        render_partial_tile2(buff, sector->tiles[corner], offset_y_l, TILE_HEIGHT-offset_y_l, 0, offset_x_l);

        // left and right edges
        // buff = fbuff + (TILE_HEIGHT-offset_y_l)*DISPLAY_WIDTH;
        // for (uint8_t row = 1; row < DISPLAY_TILE_HEIGHT; row++) {
        //     uint8_t left = SECTOR_WIDTH*(row+offset_y_h) + offset_x_h,
        //             right = left + DISPLAY_TILE_WIDTH;
        //     render_partial_tile(buff, sector->tiles[left], 0, 12, offset_x_l, 1);
        //     render_partial_tile(buff+DISPLAY_WIDTH-offset_x_l, sector->tiles[right], 0, 12, TILE_WIDTH-offset_x_l, 0);
        //     buff += DISPLAY_WIDTH*TILE_WIDTH;
        // }
        buff = fbuff + (TILE_HEIGHT-offset_y_l)*DISPLAY_WIDTH;
        for (uint8_t row = 1; row < DISPLAY_TILE_HEIGHT; row++) {
            uint8_t left = SECTOR_WIDTH*(row+offset_y_h) + offset_x_h,
                    right = left + DISPLAY_TILE_WIDTH;
            render_partial_tile2(buff, sector->tiles[left], 0, 12, offset_x_l, TILE_WIDTH-offset_x_l);
            render_partial_tile2(buff+DISPLAY_WIDTH-offset_x_l, sector->tiles[right], 0, 12, 0, offset_x_l);
            // render_partial_tile2(buff, sector->tiles[left], 0, 12, 0, 12);
            // render_partial_tile(buff+DISPLAY_WIDTH-offset_x_l, sector->tiles[right], 0, 12, TILE_WIDTH-offset_x_l, 0);
            buff += DISPLAY_WIDTH*TILE_WIDTH;
        }

        // lower left corner
        // corner = SECTOR_WIDTH*(offset_y_h+DISPLAY_TILE_HEIGHT) + offset_x_h;
        // buff = fbuff + DISPLAY_WIDTH*(DISPLAY_HEIGHT-offset_y_l);
        // buff = fbuff + DISPLAY_WIDTH*(DISPLAY_HEIGHT-12);
        // render_partial_tile(fbuff+24, 2, 0, 6, 6, 1);
        corner = SECTOR_WIDTH*(offset_y_h+DISPLAY_TILE_HEIGHT) + offset_x_h;
        buff = fbuff + DISPLAY_WIDTH*(DISPLAY_HEIGHT-offset_y_l);
        render_partial_tile2(buff, sector->tiles[corner], 0, offset_y_l, offset_x_l, TILE_WIDTH-offset_x_l);
        //
        // // lower right corner
        // corner = SECTOR_WIDTH*(offset_y_h+DISPLAY_TILE_HEIGHT) + offset_x_h + DISPLAY_TILE_WIDTH;
        // buff += DISPLAY_WIDTH - offset_x_l;
        // render_partial_tile(buff, sector->tiles[corner], 0, offset_y_l, TILE_WIDTH-offset_x_l, 0);
        corner = SECTOR_WIDTH*(offset_y_h+DISPLAY_TILE_HEIGHT) + offset_x_h + DISPLAY_TILE_WIDTH;
        buff += DISPLAY_WIDTH - offset_x_l;
        render_partial_tile2(buff, sector->tiles[corner], 0, offset_y_l, 0, offset_x_l);

        row_offset = 1;
        col_offset = 1;
        fbuff += DISPLAY_WIDTH*(TILE_HEIGHT-offset_y_l) + (TILE_WIDTH-offset_x_l);
    } else if (offset_x_l) {
        uint8_t *buff = fbuff;
        for (uint8_t row = 0; row < DISPLAY_TILE_HEIGHT; row++) {
            uint8_t left = SECTOR_WIDTH*(row+offset_y_h) + offset_x_h,
                    right = left + DISPLAY_TILE_WIDTH;
            render_partial_tile2(buff, sector->tiles[left], 0, 12, offset_x_l, TILE_WIDTH-offset_x_l);
            render_partial_tile2(buff+DISPLAY_WIDTH-offset_x_l, sector->tiles[right], 0, 12, 0, offset_x_l);
            // render_partial_tile(buff, sector->tiles[left], 0, 12, TILE_WIDTH-offset_x_l, 1);
            // render_partial_tile(buff+DISPLAY_WIDTH-TILE_WIDTH+offset_x_l, sector->tiles[right], 0, 12, offset_x_l, 0);
            buff += DISPLAY_WIDTH*TILE_HEIGHT;
        }

        col_offset = 1;
        fbuff += TILE_WIDTH-offset_x_l;
    } else if (offset_y_l) {
        uint8_t *buff = fbuff;
        for (uint8_t col = 0; col < DISPLAY_TILE_WIDTH; col++) {
            uint8_t up = SECTOR_WIDTH*offset_y_h + offset_x_h + col,
                    down = up + SECTOR_WIDTH*DISPLAY_TILE_HEIGHT;
            render_whole_tile(buff, sector->tiles[up], offset_y_l, TILE_HEIGHT-offset_y_l);
            render_whole_tile(buff+DISPLAY_WIDTH*(DISPLAY_HEIGHT-offset_y_l), sector->tiles[down], 0, offset_y_l);
            buff += TILE_WIDTH;
        }
        row_offset = 1;
        fbuff += DISPLAY_WIDTH*(TILE_HEIGHT-offset_y_l);
    }

    for (uint8_t i = row_offset; i < DISPLAY_TILE_HEIGHT; i++) {
        uint8_t *buff = fbuff;
        for (uint8_t j = col_offset; j < DISPLAY_TILE_WIDTH; j++) {
            uint8_t tile = SECTOR_WIDTH*(i+offset_y_h) + j + offset_x_h;
            render_whole_tile(buff, sector->tiles[tile], 0, 12);
            buff += TILE_WIDTH;
        }
        fbuff += DISPLAY_WIDTH*TILE_HEIGHT;
    }
}
