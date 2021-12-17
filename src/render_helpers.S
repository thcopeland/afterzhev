#include "dimensions.h"
    .text
; void render_partial_tile3(uint8_t *buff, uint8_t tile, uint8_t min_x, uint8_t width, uint8_t min_y, uint8_t height)
.global render_partial_tile3
    .type   render_partial_tile3, @function
.extern tileset
render_partial_tile3:
    ; buff      r25:r24
    ; tile      r22
    ; min_x     r20
    ; width     r18
    ; min_y     r16
    ; height    r14

    ; calculate tile pointer
    ldi r21, TILE_SIZE              ; Z = TILE_SIZE*tile
    mul r21, r22
    movw r30, r0
    ldi r21, TILE_WIDTH             ; Z += TILE_WIDTH*min_y
    mul r21, r16
    add r30, r0
    adc r31, r1
    clr r1
    add r30, r20                    ; Z += min_x
    adc r31, r1
    ; TODO left shift 2?
    subi r30, lo8(-(tileset))       ; Z += tileset
    sbci r31, hi8(-(tileset))

    ; calculate tile per-line increase
    ldi r21, TILE_WIDTH
    sub r21, r18

    ; calculate jump location
    ldi r22, lo8(rpt_write_loop)    ; r22:r23 = base
    ldi r23, hi8(rpt_write_loop)
    lsr r23                         ; convert to word address (divide by 2)
    ror r22
    add r22, r21
    adc r23, r1
    add r22, r21
    adc r23, r1

    ; calculate buff per-line increase
    ldi r20, DISPLAY_WIDTH
    sub r20, r18

    ; copy buff* to pointer register pair X
    movw r26, r24

    ; copy height to caller-save register and increment to simplify loop condition
    mov r19, r14
    inc r19

    ; regs
    ; Z (r31:r30)   tile flash pointer
    ; X (r27:r26)   buffer pointer
    ; r22:r23       jump location
    ; r21           delta tile pointer
    ; r20           delta buffer
    ; r19           height
    ; r18           width

    jmp rpt_loop_check
rpt_write_loop:
    lpm r0, Z+ ; column 1
    st X+, r0
    lpm r0, Z+ ; column 2
    st X+, r0
    lpm r0, Z+ ; column 3
    st X+, r0
    lpm r0, Z+ ; column 4
    st X+, r0
    lpm r0, Z+ ; column 5
    st X+, r0
    lpm r0, Z+ ; column 6
    st X+, r0
    lpm r0, Z+ ; column 7
    st X+, r0
    lpm r0, Z+ ; column 8
    st X+, r0
    lpm r0, Z+ ; column 9
    st X+, r0
    lpm r0, Z+ ; column 10
    st X+, r0
    lpm r0, Z+ ; column 11
    st X+, r0
    lpm r0, Z+ ; column 12
    st X+, r0
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
rpt_loop_update:
    add r30, r21 ; tile_ptr += TILE_WIDTH - width
    adc r31, r1
    add r26, r20 ; buff += DISPLAY_WIDTH - width
    adc r27, r1
rpt_loop_check:
    dec r19 ; --height
    breq rpt_done
    push r22 ; use ret to ijmp w/o clobbering Z
    push r23
#if defined(__AVR_ATmega2560__) || defined(__AVR_ATmega2561__)
    push r1 ; atmega256* use 24 bit flash addresses
#endif
rpt_done:
    ret
