#include "dimensions.h"

.global render_partial_tile2    ; void render_partial_tile(uint8_t *buff, uint8_t tile,
                                ;   `                      uint8_t min_y, uint8_t height,
                                ;                          uint8_t x_edge, uint8_t direction)
.extern tileset

render_partial_tile2:
    ; buff - r25, r24
    ; tile - r22
    ; min_y - r20
    ; height - r18
    ; x_edge - r16
    ; direction - r15

    ; copy to more convenient registers
    movw X, r24 ; X is the buffer pointer
    ldi r21, TILE_SIZE
    mul r21, r22
    movw Z, r0
    adiw Z, tileset ; Z is the tile pointer
    clr r1

    ; regs
    ; Z - tile pointer (31 30)
    ; X - buffer pointer (29 28)
    ;

    ; jmp rpt_loop_check
column_1:
    lpm r0, Z+
    st X+, r0
column_2:
    lpm r0, Z+
    st X+, r0
column_3:
    lpm r0, Z+
    st X+, r0
column_4:
    lpm r0, Z+
    st X+, r0
column_5:
    lpm r0, Z+
    st X+, r0
column_6:
    lpm r0, Z+
    st X+, r0
column_7:
    lpm r0, Z+
    st X+, r0
column_8:
    lpm r0, Z+
    st X+, r0
column_9:
    lpm r0, Z+
    st X+, r0
column_10:
    lpm r0, Z+
    st X+, r0
column_11:
    lpm r0, Z+
    st X+, r0
column_12:
    lpm r0, Z+
    st X+, r0
rpt_loop_check:

    ret
