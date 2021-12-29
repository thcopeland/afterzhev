; Write an entire tile or a horizontal slice of a tile to a framebuffer. This is
; slightly faster but less flexible than render_partial_tile.
;
; Register Usage
;   r0, r1          multiplication
;   r21             slice min y (param)
;   r22             slice height (param)
;   r23             tile number (param)
;   X (r26:r27)     framebuffer pointer (param)
;   Z (r30:r31)     tile pointer
render_whole_tile:
    ldi r20, TILE_MEMSIZE
    mul r23, r20
    movw ZL, r0
    ldi r20, TILE_WIDTH
    mul r21, r20
    add ZL, r0
    adc ZH, r1
    clr r1
    subi ZL, low(-(tile_table*2+TILE_DATA_OFFSET))  ; *2 to convert word address->byte address
    sbci ZH, high(-(tile_table*2+TILE_DATA_OFFSET))
    inc r22
    rjmp _rwt_loop_chk
_rwt_loop:
    elpm r0, Z+
    st X+, r0
    elpm r0, Z+
    st X+, r0
    elpm r0, Z+
    st X+, r0
    elpm r0, Z+
    st X+, r0
    elpm r0, Z+
    st X+, r0
    elpm r0, Z+
    st X+, r0
    elpm r0, Z+
    st X+, r0
    elpm r0, Z+
    st X+, r0
    elpm r0, Z+
    st X+, r0
    elpm r0, Z+
    st X+, r0
    elpm r0, Z+
    st X+, r0
    elpm r0, Z+
    st X+, r0
    subi XL, low(-(DISPLAY_WIDTH - TILE_WIDTH))
    sbci XH, high(-(DISPLAY_WIDTH - TILE_WIDTH))
_rwt_loop_chk:
    dec r22
    brne _rwt_loop
    ret

; Render any rectangular section of a tile.
;
; Register Usage
;   r0, r1          multiplication
;   r20             scratch register
;   r21             slice min y (param) and reused for buffer pointer increment
;   r22             slice height (param)
;   r23             slice min x (param) and reused for tile pointer increment
;   r24             slice width (param) and reused for jump low
;   r25             tile number (param) and reused for jump high
;   X (r26:r27)     framebuffer pointer (param)
;   Z (r30:r31)     tile pointer
render_partial_tile:
    ldi r20, TILE_MEMSIZE
    mul r25, r20
    movw ZL, r0
    ldi r20, TILE_WIDTH
    mul r21, r20
    add ZL, r0
    adc ZH, r1
    clr r1
    add ZL, r23
    adc ZH, r1
    subi ZL, low(-(tile_table*2+TILE_DATA_OFFSET))
    sbci ZH, high(-(tile_table*2+TILE_DATA_OFFSET))
    ldi r23, TILE_WIDTH
    sub r23, r24
    ldi r21, DISPLAY_WIDTH
    sub r21, r24
    ldi r24, low(_rpt_loop)
    ldi r25, high(_rpt_loop)
    add r24, r23
    adc r25, r1
    add r24, r23
    adc r25, r1
    inc r22
    rjmp _rpt_loop_chk
_rpt_loop:
    elpm r0, Z+
    st X+, r0
    elpm r0, Z+
    st X+, r0
    elpm r0, Z+
    st X+, r0
    elpm r0, Z+
    st X+, r0
    elpm r0, Z+
    st X+, r0
    elpm r0, Z+
    st X+, r0
    elpm r0, Z+
    st X+, r0
    elpm r0, Z+
    st X+, r0
    elpm r0, Z+
    st X+, r0
    elpm r0, Z+
    st X+, r0
    elpm r0, Z+
    st X+, r0
    elpm r0, Z+
    st X+, r0
    add ZL, r23
    adc ZH, r1
    add XL, r21
    adc XH, r1
_rpt_loop_chk:
    dec r22
    breq _rpt_end
    ; push an address to the stack and return, effectively a somewhat slow indirect
    ; jump. Unlike ijmp, however, we aren't restricted to using Z.
    push r24
    push r25
.if defined(__atmega2560) || defined(__atmega2561)
    push r1 ; atmega256* use 3 byte flash addresses
.endif
_rpt_end:
    ret

; Render the visible portion of a sector to the framebuffer, as determined by
; the given offsets and tile and display dimensions.
;
; This subroutine follows the avr-gcc ABI (call-used r18-r27 and r30-r31, call-
; saved r2-r17, r28-r29).
;
; Register Usage
;   r0, r1          multiplication
;   r13             counter
;   r14             offset_x_l, also counter
;   r15             offset_x_h, also counter
;   r16             offset_y_l
;   r17             offset_y_h
;   r18:r19         sector pointer
;   r20             horizontal offset mod 12 "offset_x_l" (param), also temporary data
;   r21             horizontal offset div 12 "offset_x_h" (param), also temporary data
;   r22             vertical offset mod 12 "offset_y_l" (param)
;   r23             vertical offset div 12 "offset_y_h" (param)
;   r24:r25         sector pointer (param), also temporary pointer
;   X (r26:r27)     temporary framebuffer pointer
;   Y (r28:r29)     working sector pointer
;   Z (r30:r31)     temporary flash pointer
render_sector:
    push r13
    push r14
    push r15
    push r16
    push r17
    push YL
    push YH
    movw r14, r20
    movw r16, r22
    movw r18, r24
    ldi r24, byte3(2*sector_table)
    out RAMPZ, r24
_rs_test_corners1:
    tst r16
    brne _rs_test_corners2
    rjmp _rs_test_vertical_edges
_rs_test_corners2:
    tst r14
    brne _rs_render_corners
    rjmp _rs_render_horizontal_edges
_rs_render_corners:
    movw YL, r18
    ldi r20, SECTOR_WIDTH
    mul r20, r17
    add YL, r0
    adc YH, r1
    clr r1
    add YL, r15
    adc YH, r1
    mov r21, r16
    ldi r22, TILE_HEIGHT
    sub r22, r16
    mov r23, r14
    ldi r24, TILE_WIDTH
    sub r24, r14
    movw ZL, YL
    elpm r25, Z
    ldi XL, low(framebuffer)
    ldi XH, high(framebuffer)
    call render_partial_tile ; upper left
    adiw YL, DISPLAY_HORIZONTAL_TILES
    mov r21, r16
    ldi r22, TILE_HEIGHT
    sub r22, r16
    clr r23
    mov r24, r14
    movw ZL, YL
    elpm r25, Z
    ldi XL, low(framebuffer + DISPLAY_WIDTH)
    ldi XH, high(framebuffer + DISPLAY_WIDTH)
    sub XL, r24
    sbc XH, r1
    call render_partial_tile ; upper right
    subi YL, low(-(DISPLAY_VERTICAL_TILES*SECTOR_WIDTH))
    sbci YH, high(-(DISPLAY_VERTICAL_TILES*SECTOR_WIDTH))
    clr r21
    mov r22, r16
    clr r23
    mov r24, r14
    movw ZL, YL
    elpm r25, Z
    ldi XL, low(framebuffer + DISPLAY_WIDTH*(DISPLAY_HEIGHT-FOOTER_HEIGHT) + DISPLAY_WIDTH)
    ldi XH, high(framebuffer + DISPLAY_WIDTH*(DISPLAY_HEIGHT-FOOTER_HEIGHT) + DISPLAY_WIDTH)
    ldi r20, DISPLAY_WIDTH
    mul r20, r16
    sub XL, r0
    sbc XH, r1
    clr r1
    sub XL, r14
    sbc XH, r1
    call render_partial_tile ; lower right
    sbiw YL, DISPLAY_HORIZONTAL_TILES
    clr r21
    mov r22, r16
    mov r23, r14
    ldi r24, TILE_WIDTH
    sub r24, r14
    movw ZL, YL
    elpm r25, Z
    ldi XL, low(framebuffer + DISPLAY_WIDTH*(DISPLAY_HEIGHT-FOOTER_HEIGHT))
    ldi XH, high(framebuffer + DISPLAY_WIDTH*(DISPLAY_HEIGHT-FOOTER_HEIGHT))
    ldi r20, DISPLAY_WIDTH
    mul r20, r16
    sub XL, r0
    sbc XH, r1
    call render_partial_tile ; lower left
_rs_test_vertical_edges:
    tst r14
    brne _rs_render_vertical_edges
    rjmp _rs_test_horizontal_edges
_rs_render_vertical_edges:
    ; left vertical edge
    ldi XL, low(framebuffer)
    ldi XH, high(framebuffer)
    ldi r20, DISPLAY_VERTICAL_TILES
    mov r13, r20
    ldi r20, SECTOR_WIDTH
    mul r20, r17
    movw YL, r18
    add YL, r0
    adc YH, r1
    clr r1
    add YL, r15
    adc YH, r1
    tst r16
    breq _rs_render_left_edge
    ldi r20, TILE_HEIGHT
    sub r20, r16
    ldi r21, DISPLAY_WIDTH
    mul r20, r21
    add XL, r0
    adc XH, r1
    clr r1
    dec r13
    adiw YL, SECTOR_WIDTH
_rs_render_left_edge:
    clr r21
    ldi r22, TILE_HEIGHT
    mov r23, r14
    ldi r24, TILE_WIDTH
    sub r24, r14
    movw ZL, YL
    elpm r25, Z
    call render_partial_tile
    adiw YL, SECTOR_WIDTH
    dec r13
    brne _rs_render_left_edge
    ; right vertical edge
    ldi XL, low(framebuffer+DISPLAY_WIDTH)
    ldi XH, high(framebuffer+DISPLAY_WIDTH)
    sub XL, r14
    sbc XH, r1
    ldi r20, DISPLAY_VERTICAL_TILES
    mov r13, r20
    ldi r20, SECTOR_WIDTH
    mul r20, r17
    movw YL, r18
    add YL, r0
    adc YH, r1
    clr r1
    add YL, r15
    adc YH, r1
    adiw YL, DISPLAY_HORIZONTAL_TILES
    tst r16
    breq _rs_render_right_edge
    ldi r20, TILE_HEIGHT
    sub r20, r16
    ldi r21, DISPLAY_WIDTH
    mul r20, r21
    add XL, r0
    adc XH, r1
    clr r1
    dec r13
    adiw YL, SECTOR_WIDTH
_rs_render_right_edge:
    clr r21
    ldi r22, TILE_HEIGHT
    clr r23
    mov r24, r14
    movw ZL, YL
    elpm r25, Z
    call render_partial_tile
    adiw YL, SECTOR_WIDTH
    dec r13
    brne _rs_render_right_edge
_rs_test_horizontal_edges:
    tst r16
    brne _rs_render_horizontal_edges
    rjmp _rs_render_inner_tiles
_rs_render_horizontal_edges:
    ldi r24, low(framebuffer)
    ldi r25, high(framebuffer)
    ldi r20, DISPLAY_HORIZONTAL_TILES
    mov r13, r20
    ldi r20, SECTOR_WIDTH
    mul r20, r17
    movw YL, r18
    add YL, r0
    adc YH, r1
    clr r1
    add YL, r15
    adc YH, r1
    tst r14
    breq _rs_write_horizontal_edges
    ldi r20, TILE_WIDTH
    sub r20, r14
    add r24, r20
    adc r25, r1
    adiw YL, 1
    dec r13
_rs_write_horizontal_edges:
    mov r21, r16
    ldi r22, TILE_HEIGHT
    sub r22, r16
    movw ZL, YL
    elpm r23, Z
    movw XL, r24
    call render_whole_tile  ; top edge
    clr r21
    mov r22, r16
    movw ZL, YL
    subi ZL, low(-SECTOR_WIDTH*DISPLAY_VERTICAL_TILES)
    sbci ZH, high(-SECTOR_WIDTH*DISPLAY_VERTICAL_TILES)
    elpm r23, Z
    movw XL, r24
    subi XL, low(-DISPLAY_WIDTH*(DISPLAY_HEIGHT-FOOTER_HEIGHT))
    sbci XH, high(-DISPLAY_WIDTH*(DISPLAY_HEIGHT-FOOTER_HEIGHT))
    ldi r20, DISPLAY_WIDTH
    mul r16, r20
    sub XL, r0
    sbc XH, r1
    clr r1
    call render_whole_tile  ; bottom edge
    adiw r24, TILE_WIDTH
    adiw YL, 1
    dec r13
    brne _rs_write_horizontal_edges
_rs_render_inner_tiles:
    ldi XL, low(framebuffer)
    ldi XH, high(framebuffer)
    ldi r24, DISPLAY_HORIZONTAL_TILES
    ldi r25, DISPLAY_VERTICAL_TILES
    ldi r20, SECTOR_WIDTH
    mul r20, r17
    movw YL, r18
    add YL, r0
    adc YH, r1
    clr r1
    add YL, r15
    adc YH, r1
_rs_test_top_padding:
    tst r16
    breq _rs_test_left_padding
_rs_add_top_padding:
    ldi r20, DISPLAY_WIDTH
    ldi r21, TILE_HEIGHT
    sub r21, r16
    mul r20, r21
    add XL, r0
    adc XH, r1
    clr r1
    adiw YL, SECTOR_WIDTH
    dec r25
_rs_test_left_padding:
    tst r14
    breq _rs_write_inner_tiles
_rs_add_left_padding:
    ldi r20, TILE_WIDTH
    sub r20, r14
    add XL, r20
    adc XH, r1
    adiw YL, 1
    dec r24
_rs_write_inner_tiles:
    mov r13, r24
    movw r14, r24
    movw r16, XL
    movw r24, XL
_rs_write_inner_row:
    movw r24, r16
_rs_write_inner_tile:
    ldi r21, 0
    ldi r22, 12
    movw ZL, YL
    elpm r23, Z
    movw XL, r24
    call render_whole_tile
    adiw r24, TILE_WIDTH
    adiw YL, 1
    dec r14
    brne _rs_write_inner_tile
    subi r16, low(-DISPLAY_WIDTH*TILE_HEIGHT)
    sbci r17, high(-DISPLAY_WIDTH*TILE_HEIGHT)
    mov r14, r13
    ldi r20, SECTOR_WIDTH
    sub r20, r13
    add YL, r20
    adc YH, r1
    dec r15
    brne _rs_write_inner_row
    pop YH
    pop YL
    pop r17
    pop r16
    pop r15
    pop r14
    pop r13
    ret
