.equ TILE_SOLID_GREEN = 39
.equ TILE_SOLID_BLACK = 73
.equ TILE_SOLID_BEIGE = 176
.equ TILE_SOLID_BROWN = 186
.equ TILE_WOOD_FLOOR = 198

; Write an entire tile or a horizontal slice of a tile to a framebuffer. This is
; slightly faster but less flexible than write_partial_tile.
;
; Register Usage
;   r0, r1          multiplication
;   r21             slice min y (param)
;   r22             slice height (param)
;   r23             tile number (param)
;   X (r26:r27)     framebuffer pointer (param)
;   Z (r30:r31)     tile pointer
write_entire_tile:
    cpi r23, TILE_SOLID_GREEN
    brlo _wet_main
    brne _wet_check_solid_2
    ldi r23, 0x58
    rjmp write_solid_tile
_wet_check_solid_2:
    cpi r23, TILE_SOLID_BLACK
    brne _wet_check_solid_3
    ldi r23, 0x00
    rjmp write_solid_tile
_wet_check_solid_3:
    cpi r23, TILE_SOLID_BROWN
    brne _wet_check_solid_4
    ldi r23, 0x0a
    rjmp write_solid_tile
_wet_check_solid_4:
    cpi r23, TILE_SOLID_BEIGE
    brne _wet_check_wood
    ldi r23, 0x65
    rjmp write_solid_tile
_wet_check_wood:
    cpi r23, TILE_WOOD_FLOOR
    breq write_wood_tile
_wet_main:
    ldi r20, TILE_MEMSIZE
    mul r23, r20
    movw ZL, r0
    ldi r20, TILE_WIDTH
    mul r21, r20
    add ZL, r0
    adc ZH, r1
    clr r1
    subi ZL, low(-2*tile_table)
    sbci ZH, high(-2*tile_table)
    inc r22
    rjmp _wet_loop_chk
_wet_loop:
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
_wet_loop_chk:
    dec r22
    brne _wet_loop
    ret

; Write an entire monochromatic tile or a horizontal slice of a tile to the
; framebuffer.
;
; Register Usage
;   r22             slice height (param)
;   r23             color (param)
;   X (r26:r27)     framebuffer pointer (param)
write_solid_tile:
    inc r22
    rjmp _wst_loop_chk
_wst_loop:
    st X+, r23
    st X+, r23
    st X+, r23
    st X+, r23
    st X+, r23
    st X+, r23
    st X+, r23
    st X+, r23
    st X+, r23
    st X+, r23
    st X+, r23
    st X+, r23
    subi XL, low(-(DISPLAY_WIDTH - TILE_WIDTH))
    sbci XH, high(-(DISPLAY_WIDTH - TILE_WIDTH))
_wst_loop_chk:
    dec r22
    brne _wst_loop
    ret

; Write an entire monochromatic tile or a horizontal slice of a tile to the
; framebuffer.
;
; Register Usage
;   r21             slice min y (param)
;   r22             slice height (param)
;   r23             calculations
;   X (r26:r27)     framebuffer pointer (param)
write_wood_tile:
    inc r22
    rjmp _wwt_loop_chk
_wwt_loop:
    andi r21, 3
_wwt_light_brown:
    cpi r21, 0
    brne _wwt_mid_brown
    ldi r23, 0x1d
    rjmp _wwt_write
_wwt_mid_brown:
    cpi r21, 3
    brsh _wwt_dark_brown
    ldi r23, 0x14
    rjmp _wwt_write
_wwt_dark_brown:
    ldi r23, 0x0a
_wwt_write:
    st X+, r23
    st X+, r23
    st X+, r23
    st X+, r23
    st X+, r23
    st X+, r23
    st X+, r23
    st X+, r23
    st X+, r23
    st X+, r23
    st X+, r23
    st X+, r23
    subi XL, low(-(DISPLAY_WIDTH - TILE_WIDTH))
    sbci XH, high(-(DISPLAY_WIDTH - TILE_WIDTH))
    inc r21
_wwt_loop_chk:
    dec r22
    brne _wwt_loop
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
write_partial_tile:
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
    subi ZL, low(-2*tile_table)
    sbci ZH, high(-2*tile_table)
    ldi r23, TILE_WIDTH
    sub r23, r24
    ldi r21, DISPLAY_WIDTH
    sub r21, r24
    ldi r24, low(_wpt_loop)
    ldi r25, high(_wpt_loop)
    add r24, r23
    adc r25, r1
    add r24, r23
    adc r25, r1
    inc r22
    rjmp _wpt_loop_chk
_wpt_loop:
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
_wpt_loop_chk:
    dec r22
    breq _wpt_end
    ; push an address to the stack and return, effectively a somewhat slow indirect
    ; jump. Unlike ijmp, however, we aren't restricted to using Z.
    push r24
    push r25
.if PC_SIZE == 3
    push r1
.endif
_wpt_end:
    ret

; Quickly render an entire 12x12 sprite to the screen, taking transparency into
; account. This functionality is technically redundant, but improves performance.
;
; Register Usage
;   r22-r23         preserve Y
;   r24-r25         calculations
;   X (r26:r27)     framebuffer pointer (param)
;   Y (r28:r29)     working framebuffer pointer (param)
;   Z (r30:r31)     sprite pointer (param)
write_12x12_sprite:
    movw r22, YL
    movw YL, XL
    ldi r24, TRANSPARENT
    ldi r25, 12
_r12x12s_iter:
    elpm r0, Z+
    cpse r0, r24
    st Y, r0
    elpm r0, Z+
    cpse r0, r24
    std Y+1, r0
    elpm r0, Z+
    cpse r0, r24
    std Y+2, r0
    elpm r0, Z+
    cpse r0, r24
    std Y+3, r0
    elpm r0, Z+
    cpse r0, r24
    std Y+4, r0
    elpm r0, Z+
    cpse r0, r24
    std Y+5, r0
    elpm r0, Z+
    cpse r0, r24
    std Y+6, r0
    elpm r0, Z+
    cpse r0, r24
    std Y+7, r0
    elpm r0, Z+
    cpse r0, r24
    std Y+8, r0
    elpm r0, Z+
    cpse r0, r24
    std Y+9, r0
    elpm r0, Z+
    cpse r0, r24
    std Y+10, r0
    elpm r0, Z+
    cpse r0, r24
    std Y+11, r0
    subi YL, low(-DISPLAY_WIDTH)
    sbci YH, high(-DISPLAY_WIDTH)
    dec r25
    brne _r12x12s_iter
    movw YL, r22
    ret

; Render any rectangular section of a sprite, taking transparency into account.
; This subroutine uses the same indirect jump trick as write_partial_tile.
; Both the X and Y register pairs are preserved.
;
; Register Usage
;   r21             sprite width (param), delta sprite pointer
;   r22             slice min y (param), reused to hold transparency value
;   r23             slice height (param)
;   r24             slice min x (param), reused for jump low
;   r25             slice width (param), reused for jump high
;   X (r26:r27)     framebuffer pointer (param)
;   Y (r28:r29)     working framebuffer pointer (it'd be more natural to use X, but the std instruction supports only Y and Z)
;   Z (r30:r31)     sprite pointer (param)
write_sprite:
    push YL
    push YH
    add ZL, r24
    adc ZH, r1
    mul r21, r22
    add ZL, r0
    adc ZH, r1
    clr r1
    sub r21, r25
    ldi r24, TILE_WIDTH
    sub r24, r25
    movw YL, XL
    sub YL, r24
    sbci YH, 0
    mov r25, r24 ; multiply r24 by 3
    add r24, r25
    add r24, r25
    clr r25
    subi r24, low(-_ws_loop)
    sbci r25, high(-_ws_loop)
    inc r23
    ldi r22, TRANSPARENT
    rjmp _ws_loop_check
_ws_loop:
    elpm r0, Z+
    cpse r0, r22
    st Y, r0
    elpm r0, Z+
    cpse r0, r22
    std Y+1, r0
    elpm r0, Z+
    cpse r0, r22
    std Y+2, r0
    elpm r0, Z+
    cpse r0, r22
    std Y+3, r0
    elpm r0, Z+
    cpse r0, r22
    std Y+4, r0
    elpm r0, Z+
    cpse r0, r22
    std Y+5, r0
    elpm r0, Z+
    cpse r0, r22
    std Y+6, r0
    elpm r0, Z+
    cpse r0, r22
    std Y+7, r0
    elpm r0, Z+
    cpse r0, r22
    std Y+8, r0
    elpm r0, Z+
    cpse r0, r22
    std Y+9, r0
    elpm r0, Z+
    cpse r0, r22
    std Y+10, r0
    elpm r0, Z+
    cpse r0, r22
    std Y+11, r0
    add ZL, r21
    adc ZH, r1
    subi YL, low(-DISPLAY_WIDTH)
    sbci YH, high(-DISPLAY_WIDTH)
_ws_loop_check:
    dec r23
    breq _ws_end
    push r24
    push r25
.if PC_SIZE == 3
    push r1
.endif
    ret
_ws_end:
    pop YH
    pop YL
    ret

; Render any rectangular section of a sprite flipped horizontally (across the
; vertical axis). The final result is the same as mirroring the original sprite,
; then rendering it with write_sprite.
;
; Register Usage
;   r21             sprite width (param), delta sprite pointer
;   r22             slice min y (param), reused to hold transparency value
;   r23             slice height (param)
;   r24             slice min x (param), reused for jump low
;   r25             slice width (param), reused for jump high
;   X (r26:r27)     framebuffer pointer (param)
;   Y (r28:r29)     working framebuffer pointer
;   Z (r30:r31)     sprite pointer (param)
write_sprite_flip_x:
    push YL
    push YH
    mul r21, r22
    add ZL, r0
    adc ZH, r1
    clr r1
    sub r21, r25
    add ZL, r21
    adc ZH, r1
    sub ZL, r24
    sbc ZH, r1
    ldi r24, TILE_WIDTH
    sub r24, r25
    movw YL, XL
    mov r25, r24 ; multiply r24 by 3
    add r24, r25
    add r24, r25
    clr r25
    subi r24, low(-_wsfx_loop)
    sbci r25, high(-_wsfx_loop)
    inc r23
    ldi r22, TRANSPARENT
    rjmp _ws_loop_check
_wsfx_loop:
    elpm r0, Z+
    cpse r0, r22
    std Y+11, r0
    elpm r0, Z+
    cpse r0, r22
    std Y+10, r0
    elpm r0, Z+
    cpse r0, r22
    std Y+9, r0
    elpm r0, Z+
    cpse r0, r22
    std Y+8, r0
    elpm r0, Z+
    cpse r0, r22
    std Y+7, r0
    elpm r0, Z+
    cpse r0, r22
    std Y+6, r0
    elpm r0, Z+
    cpse r0, r22
    std Y+5, r0
    elpm r0, Z+
    cpse r0, r22
    std Y+4, r0
    elpm r0, Z+
    cpse r0, r22
    std Y+3, r0
    elpm r0, Z+
    cpse r0, r22
    std Y+2, r0
    elpm r0, Z+
    cpse r0, r22
    std Y+1, r0
    elpm r0, Z+
    cpse r0, r22
    st Y, r0
    add ZL, r21
    adc ZH, r1
    subi YL, low(-DISPLAY_WIDTH)
    sbci YH, high(-DISPLAY_WIDTH)
_wsfx_loop_check:
    dec r23
    breq _wsfx_end
    push r24
    push r25
.if PC_SIZE == 3
    push r1
.endif
    ret
_wsfx_end:
    pop YH
    pop YL
    ret

; Render any rectangular section of a sprite flipped vertically (across the
; horizontal axis). The final result is the same as flipping the original sprite,
; then rendering it with write_sprite.
;
; NOTE: The sprite pointer should point to the address following the last pixel
; in the sprite.
;
; Register Usage
;   r21             sprite width (param), delta sprite pointer
;   r22             slice min y (param), reused to hold transparency value
;   r23             slice height (param)
;   r24             slice min x (param), reused for jump low
;   r25             slice width (param), reused for jump high
;   X (r26:r27)     framebuffer pointer (param)
;   Y (r28:r29)     working framebuffer pointer
;   Z (r30:r31)     sprite pointer (param)
write_sprite_flip_y:
    push YL
    push YH
    add ZL, r24
    adc ZH, r1
    add r22, r23
    mul r21, r22
    sub ZL, r0
    sbc ZH, r1
    ldi r24, DISPLAY_WIDTH
    mul r23, r24
    add XL, r0
    adc XH, r1
    clr r1
    subi XL, low(DISPLAY_WIDTH)
    sbci XH, high(DISPLAY_WIDTH)
    sub r21, r25
    ldi r24, TILE_WIDTH
    sub r24, r25
    movw YL, XL
    sub YL, r24
    sbc YH, r1
    mov r25, r24
    add r24, r25
    add r24, r25
    clr r25
    subi r24, low(-_wsfy_loop)
    sbci r25, high(-_wsfy_loop)
    inc r23
    ldi r22, TRANSPARENT
    rjmp _ws_loop_check
_wsfy_loop:
    elpm r0, Z+
    cpse r0, r22
    st Y, r0
    elpm r0, Z+
    cpse r0, r22
    std Y+1, r0
    elpm r0, Z+
    cpse r0, r22
    std Y+2, r0
    elpm r0, Z+
    cpse r0, r22
    std Y+3, r0
    elpm r0, Z+
    cpse r0, r22
    std Y+4, r0
    elpm r0, Z+
    cpse r0, r22
    std Y+5, r0
    elpm r0, Z+
    cpse r0, r22
    std Y+6, r0
    elpm r0, Z+
    cpse r0, r22
    std Y+7, r0
    elpm r0, Z+
    cpse r0, r22
    std Y+8, r0
    elpm r0, Z+
    cpse r0, r22
    std Y+9, r0
    elpm r0, Z+
    cpse r0, r22
    std Y+10, r0
    elpm r0, Z+
    cpse r0, r22
    std Y+11, r0
    add ZL, r21
    adc ZH, r1
    subi YL, low(DISPLAY_WIDTH)
    sbci YH, high(DISPLAY_WIDTH)
_wsfy_loop_check:
    dec r23
    breq _wsfy_end
    push r24
    push r25
.if PC_SIZE == 3
    push r1
.endif
    ret
_wsfy_end:
    pop YH
    pop YL
    ret

; Render any rectangular section of a sprite flipped across the horizontal and
; vertical axes (same as rotation by 180 degrees). The final result is the same
; as rotating the original sprite, then rendering it with write_sprite.
;
; NOTE: The sprite pointer should point to the address following the last pixel
; in the sprite.
;
; Register Usage
;   r21             sprite width (param), delta sprite pointer
;   r22             slice min y (param), reused to hold transparency value
;   r23             slice height (param)
;   r24             slice min x (param), reused for jump low
;   r25             slice width (param), reused for jump high
;   X (r26:r27)     framebuffer pointer (param)
;   Y (r28:r29)     working framebuffer pointer
;   Z (r30:r31)     sprite pointer (param)
write_sprite_flip_xy:
    push YL
    push YH
    add r22, r23
    mul r21, r22
    sub ZL, r0
    sbc ZH, r1
    ldi r24, DISPLAY_WIDTH
    mul r23, r24
    add XL, r0
    adc XH, r1
    clr r1
    subi XL, low(DISPLAY_WIDTH)
    sbci XH, high(DISPLAY_WIDTH)
    sub r21, r25
    ldi r24, TILE_WIDTH
    sub r24, r25
    movw YL, XL
    mov r25, r24
    add r24, r25
    add r24, r25
    clr r25
    subi r24, low(-_wsfxy_loop)
    sbci r25, high(-_wsfxy_loop)
    inc r23
    ldi r22, TRANSPARENT
    rjmp _ws_loop_check
_wsfxy_loop:
    elpm r0, Z+
    cpse r0, r22
    std Y+11, r0
    elpm r0, Z+
    cpse r0, r22
    std Y+10, r0
    elpm r0, Z+
    cpse r0, r22
    std Y+9, r0
    elpm r0, Z+
    cpse r0, r22
    std Y+8, r0
    elpm r0, Z+
    cpse r0, r22
    std Y+7, r0
    elpm r0, Z+
    cpse r0, r22
    std Y+6, r0
    elpm r0, Z+
    cpse r0, r22
    std Y+5, r0
    elpm r0, Z+
    cpse r0, r22
    std Y+4, r0
    elpm r0, Z+
    cpse r0, r22
    std Y+3, r0
    elpm r0, Z+
    cpse r0, r22
    std Y+2, r0
    elpm r0, Z+
    cpse r0, r22
    std Y+1, r0
    elpm r0, Z+
    cpse r0, r22
    st Y, r0
    add ZL, r21
    adc ZH, r1
    subi YL, low(DISPLAY_WIDTH)
    sbci YH, high(DISPLAY_WIDTH)
_wsfxy_loop_check:
    dec r23
    breq _wsfxy_end
    push r24
    push r25
.if PC_SIZE == 3
    push r1
.endif
    ret
_wsfxy_end:
    pop YH
    pop YL
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
    rcall write_partial_tile ; upper left
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
    rcall write_partial_tile ; upper right
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
    rcall write_partial_tile ; lower right
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
    rcall write_partial_tile ; lower left
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
    rcall write_partial_tile
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
    rcall write_partial_tile
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
    rcall write_entire_tile  ; top edge
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
    rcall write_entire_tile  ; bottom edge
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
    rcall write_entire_tile
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

; Render a sprite at the given absolute position, taking camera position into
; account and cropping the sprite as necessary to prevent exceeding the display
; edges.
;
; If the width is negative, the sprite is flipped horizontally. If the height
; is negative, the sprite is flipped vertically. If neither are negative, the
; sprite is rendered as usual.
;
; Register Usage
;   r18-r21         camera position, calculations
;   r22, r23        sprite width (param), sprite height (param); calculations
;   r24, r25        sprite position (param)
;   X (r26:r27)     framebuffer pointer
;   Z (r30:r31)     sprite pointer (param)
render_sprite:
    ldi XL, low(framebuffer)
    ldi XH, high(framebuffer)
_rs_fast_path:
    cpi r22, 12
    cpc r23, r22
    brne _rs_main
    lds r18, camera_position_y
    mov r21, r25
    sub r21, r18
    brlo _rs_main
    cpi r21, DISPLAY_HEIGHT-FOOTER_HEIGHT-12
    brsh _rs_main
    lds r18, camera_position_x
    mov r20, r24
    sub r20, r18
    brlo _rs_main
    cpi r20, DISPLAY_WIDTH-12
    brsh _rs_main
    add XL, r20
    adc XH, r1
    ldi r20, DISPLAY_WIDTH
    mul r20, r21
    add XL, r0
    adc XH, r1
    clr r1
    rcall write_12x12_sprite
    ret
_rs_main:
    mov r20, r23 ; save height, necessary for y and xy flips
    lsl r20
    lsl r20
_rs_check_flip_x:
    cpi r22, 128
    brlo _rs_check_flip_y
    ori r20, 0x01
    neg r22
_rs_check_flip_y:
    cpi r23, 128
    brlo _rs_save_flipped
    ori r20, 0x02
    neg r23
_rs_save_flipped:
    push r20
_rs_calc_vertical_offset:
    lds r20, camera_position_y
    sub r25, r20
    brlo _rs_check_vertical_offset
    cpi r25, SECTOR_HEIGHT*TILE_HEIGHT
    brsh _rs_check_vertical_offset
    ldi r20, DISPLAY_WIDTH
    mul r25, r20
    add XL, r0
    adc XH, r1
    clr r1
_rs_check_vertical_offset:
    mov r20, r23
    neg r20
    cp r25, r20
    brlt _rs_end
    cpi r25, DISPLAY_HEIGHT-FOOTER_HEIGHT
    brge _rs_end
_rs_calc_horizonal_offset:
    cpi r24, (SECTOR_WIDTH*TILE_WIDTH+255)/2
    brsh _rs_check_horizontal_offset
    lds r20, camera_position_x
    sub r24, r20
    brlo _rs_check_horizontal_offset
    add XL, r24
    adc XH, r1
_rs_check_horizontal_offset:
    mov r20, r22
    neg r20
    cp r24, r20
    brlt _rs_end
    cpi r24, DISPLAY_WIDTH
    brge _rs_end
    movw r18, r24
    mov r21, r22
    clr r22
    clr r24
    mov r25, r21
_rs_left_cut:
    cpi r18, 0
    brge _rs_right_cut
    mov r24, r18
    neg r24
    add r25, r18
_rs_right_cut:
    ldi r20, DISPLAY_WIDTH
    sub r20, r21
    cp r18, r20
    brlt _rs_top_cut
    ldi r25, DISPLAY_WIDTH
    sub r25, r18
_rs_top_cut:
    cpi r19, 0
    brge _rs_bottom_cut
    mov r22, r19
    neg r22
    add r23, r19
_rs_bottom_cut:
    ldi r20, DISPLAY_HEIGHT-FOOTER_HEIGHT
    sub r20, r23
    cp r19, r20
    brlt _rs_write_sprite
    ldi r23, DISPLAY_HEIGHT-FOOTER_HEIGHT
    sub r23, r19
_rs_write_sprite:
    pop r20
    mov r19, r20
    andi r20, 0x03
    brne _rs_write_sprite_flip_x
_rs_write_sprite_unflipped:
    rcall write_sprite
    ret
_rs_end:
    pop r20
    ret
_rs_write_sprite_flip_x:
    cpi r20, 1
    brne _rs_write_sprite_flip_y
    rcall write_sprite_flip_x
    ret
_rs_write_sprite_flip_y:
    asr r19
    asr r19
    neg r19
    mul r19, r21
    add ZL, r0
    adc ZH, r1
    clr r1
    cpi r20, 2
    brne _rs_write_sprite_flip_xy
    rcall write_sprite_flip_y
    ret
_rs_write_sprite_flip_xy:
    rcall write_sprite_flip_xy
    ret

; Render a character, taking camera position, animations, and weapons into account.
; The character data pointer should point to memory with the following layout:
;   base sprite idx (1 byte)
;   weapon idx      (1 byte)
;   armor idx       (1 byte)
;   direction       (1 byte)
;   current action  (1 byte)
;   action frame    (1 byte)
;   effect          (1 byte) [direction:2][effect:3][frame:3]
;
; Register Usage
;   r16-r17         store character position
;   r18-r23         calculations
;   r24, r25        character position (param), calculations
;   X (r26:r27)     framebuffer pointer
;   Y (r28:r29)     character data pointer (param), character animation pointer
;   Z (r30:r21)     flash memory pointer, temporary pointer
render_character:
    push r16
    push r17
    movw r16, r24
    ldd r23, Y+CHARACTER_DIRECTION_OFFSET
    cpi r23, DIRECTION_UP
    brlo _rc_render_character
_rc_render_weapon_below:
    ldd r22, Y+CHARACTER_WEAPON_OFFSET
    tst r22
    breq _rc_render_character
    ldd r24, Y+CHARACTER_ACTION_OFFSET
    ldd r25, Y+CHARACTER_FRAME_OFFSET
    call determine_weapon_sprite
    movw r24, r16
    elpm r20, Z+
    elpm r21, Z+
    subi r20, 16
    subi r21, 4
    sub r24, r20
    add r25, r21
    elpm r22, Z+
    elpm r23, Z+
    movw ZL, r22
    elpm r22, Z+
    elpm r23, Z+
    sub r24, r22
_rc_weapon_below_flip_x:
    neg r22
_rc_weapon_below_flip_y:
    ldd r18, Y+CHARACTER_DIRECTION_OFFSET
    cpi r18, DIRECTION_UP
    brne _rc_do_render_weapon_below
    neg r23
    subi r25, 2
_rc_do_render_weapon_below:
    rcall render_sprite
_rc_render_character:
    ldd r22, Y+CHARACTER_SPRITE_OFFSET
    sbrs r22, 7
    rjmp _rc_dynamic_character
_rc_static_character:
    andi r22, 0x7f
    ldi ZL, byte3(2*static_character_sprite_table)
    out RAMPZ, ZL
    ldi ZL, low(2*static_character_sprite_table)
    ldi ZH, high(2*static_character_sprite_table)
    ldi r23, CHARACTER_SPRITE_MEMSIZE
    mul r22, r23
    add ZL, r0
    adc ZH, r1
    clr r1
    rjmp _rc_do_render_character
_rc_dynamic_character:
    ldd r23, Y+CHARACTER_DIRECTION_OFFSET
    ldd r24, Y+CHARACTER_ACTION_OFFSET
    ldd r25, Y+CHARACTER_FRAME_OFFSET
    call determine_character_sprite
_rc_do_render_character:
    ldi r22, CHARACTER_SPRITE_WIDTH
    ldi r23, CHARACTER_SPRITE_HEIGHT
    movw r24, r16
    rcall render_sprite
    ldd r22, Y+CHARACTER_ARMOR_OFFSET
    tst r22
    breq _rc_write_effect
_rc_write_armor_sprite:
    ldd r23, Y+CHARACTER_DIRECTION_OFFSET
    ldd r24, Y+CHARACTER_ACTION_OFFSET
    ldd r25, Y+CHARACTER_FRAME_OFFSET
    call determine_armor_sprite
    movw r24, r16
    elpm r20, Z+
    elpm r21, Z+
    subi r20, 4
    subi r21, 4
    add r24, r20
    add r25, r21
    elpm r22, Z+
    elpm r23, Z+
    movw ZL, r22
    elpm r22, Z+
    elpm r23, Z+
    rcall render_sprite
_rc_write_effect:
    ldd r22, Y+CHARACTER_EFFECT_OFFSET
    movw r24, r16
    rcall render_effect_animation
_rc_render_weapon_above:
    ldd r23, Y+CHARACTER_DIRECTION_OFFSET
    cpi r23, DIRECTION_UP
    brsh _rc_end
    ldd r22, Y+CHARACTER_WEAPON_OFFSET
    tst r22
    breq _rc_end
    ldd r24, Y+CHARACTER_ACTION_OFFSET
    ldd r25, Y+CHARACTER_FRAME_OFFSET
    call determine_weapon_sprite
    movw r24, r16
    elpm r20, Z+
    elpm r21, Z+
    subi r20, 4
    subi r21, 4
    add r24, r20
    add r25, r21
    elpm r22, Z+
    elpm r23, Z+
    movw ZL, r22
    elpm r22, Z+
    elpm r23, Z+
    rcall render_sprite
_rc_end:
    pop r17
    pop r16
    ret

; Render the character in the down-idle position, for viewing in the UI.
;
; Register Usage
;   r18:r19         temporary storage
;   r20-r25         calculations
;   X (r26:r27)     framebuffer pointer (param)
;   Y (r28:r29)     character data pointer (param)
;   Z (r30:r21)     flash memory pointer, temporary pointer
render_character_icon:
    ldd r22, Y+CHARACTER_SPRITE_OFFSET
    sbrs r22, 7
    rjmp _rci_dynamic_character
_rci_static_character:
    andi r22, 0x7f
    ldi ZL, byte3(2*static_character_sprite_table)
    out RAMPZ, ZL
    ldi ZL, low(2*static_character_sprite_table)
    ldi ZH, high(2*static_character_sprite_table)
    ldi r23, CHARACTER_SPRITE_MEMSIZE
    mul r22, r23
    add ZL, r0
    adc ZH, r1
    clr r1
    rjmp _rci_render_character
_rci_dynamic_character:
    ldi r23, DIRECTION_DOWN
    ldi r24, ACTION_IDLE
    clr r25
    call determine_character_sprite
_rci_render_character:
    ldi r21, CHARACTER_SPRITE_WIDTH
    clr r22
    ldi r23, CHARACTER_SPRITE_HEIGHT
    clr r24
    ldi r25, CHARACTER_SPRITE_WIDTH
    rcall write_sprite
    ldd r22, Y+CHARACTER_ARMOR_OFFSET
    tst r22
    breq _rci_write_weapon_sprite
    ldi r23, DIRECTION_DOWN
    ldi r24, ACTION_IDLE
    clr r25
    call determine_armor_sprite
    movw r18, XL
    elpm r20, Z+
    elpm r21, Z+
    subi r20, 4
    subi r21, 4
    add XL, r20
    adc XH, r1
    ldi r20, DISPLAY_WIDTH
    mulsu r21, r20
    add XL, r0
    adc XH, r1
    clr r1
    elpm r22, Z+
    elpm r23, Z+
    movw ZL, r22
    elpm r21, Z+
    elpm r23, Z+
    clr r22
    clr r24
    mov r25, r21
    rcall write_sprite
    movw XL, r18
_rci_write_weapon_sprite:
    ldd r22, Y+CHARACTER_WEAPON_OFFSET
    tst r22
    breq _rci_end
    ldi r23, DIRECTION_DOWN
    ldi r24, ACTION_IDLE
    clr r25
    call determine_weapon_sprite
    elpm r20, Z+
    elpm r21, Z+
    subi r20, 4
    subi r21, 4
    add XL, r20
    adc XH, r1
    ldi r20, DISPLAY_WIDTH
    mulsu r21, r20
    add XL, r0
    adc XH, r1
    clr r1
    elpm r22, Z+
    elpm r23, Z+
    movw ZL, r22
    elpm r21, Z+
    elpm r23, Z+
    clr r22
    clr r24
    mov r25, r21
    rcall write_sprite
_rci_end:
    ret

; Render an effect animation. This is used for several things, including blood
; splashes, fire, healing.
;
; Register Usage
;   r20-r21         calculations
;   r22             effect data, [direction:2][effect:3][frame:3] (param)
;   r23             calculations
;   r24, r25        effect location (param)
;   Z (r30:r31)     effect pointer
render_effect_animation:
    mov r23, r22
    lsr r23
    lsr r23
    lsr r23
    andi r23, 0x7
    brne _rce_effect_props
    rjmp _rce_end
_rce_effect_props:
    mov r21, r22
    andi r21, 0xc0
    andi r22, 0x7
    ldi ZL, byte3(2*effect_sprite_table)
    out RAMPZ, ZL
    ; At this point, r21 - direction, r22 - frame, r23 - effect
    ldi ZL, low(2*effect_sprite_table-16)
    ldi ZH, high(2*effect_sprite_table-16)
    ldi r20, 16
    mul r20, r23
    add ZL, r0
    adc ZH, r1
    clr r1
_rce_effect_healing:
    cpi r23, EFFECT_HEALING
    brne _rce_effect_potion
    subi r22, EFFECT_HEALING_DELAY
    brsh _rce_determine_sprite
    rjmp _rce_end
_rce_effect_potion:
    cpi r23, EFFECT_POTION
    brne _rce_effect_upgrade
    subi r22, EFFECT_POTION_DELAY
    brsh _rce_determine_sprite
    rjmp _rce_end
_rce_effect_upgrade:
    cpi r23, EFFECT_UPGRADE
    brne _rce_effect_alternating
    subi r22, EFFECT_UPGRADE_DELAY
    brsh _rce_determine_sprite
    rjmp _rce_end
_rce_effect_alternating:
    cpi r23, EFFECT_FIREBALL
    brlo _rce_effect_orientable
    andi r22, 1
_rce_effect_orientable:
    cpi r23, EFFECT_ARROW
    brne _rce_effect_orientable_2
    sbrc r21, 6
    inc r22
    rjmp _rce_determine_sprite
_rce_effect_orientable_2:
    cpi r23, EFFECT_FIREBALL
    brlo _rce_determine_sprite
    sbrc r21, 6
    subi r22, low(-2)
_rce_determine_sprite:
    mov r23, r20
    lsl r22
    add ZL, r22
    adc ZH, r1
    elpm r22, Z+
    elpm r23, Z
    movw ZL, r22
    elpm r22, Z+
    elpm r23, Z+
    add r24, r22
    add r25, r23
    elpm r22, Z+
    elpm r23, Z+
_rce_effect_flip:
    cpi r20, EFFECT_ARROW
    brlo _rce_render_sprite
_rce_check_up:
    cpi r21, DIRECTION_UP<<6
    brne _rce_check_left
    neg r23
_rce_check_left:
    cpi r21, DIRECTION_LEFT<<6
    brne _rce_render_sprite
    neg r22
_rce_render_sprite:
    rcall render_sprite
_rce_end:
    ret

; Render an item for viewing in the UI.
;
; Register Usage
;   r25             item index (param)
;   r21-r25         arguments
;   X (r26:r27)     framebuffer pointer (param)
;   Z (r30:r31)     flash pointer
render_item_icon:
    tst r25
    breq _rii_end
    dec r25
    ldi ZL, byte3(2*static_item_sprite_table)
    out RAMPZ, ZL
    ldi ZL, low(2*static_item_sprite_table)
    ldi ZH, high(2*static_item_sprite_table)
    ldi r22, STATIC_ITEM_MEMSIZE
    mul r25, r22
    add ZL, r0
    adc ZH, r1
    clr r1
    ldi r21, STATIC_ITEM_WIDTH
    clr r22
    ldi r23, STATIC_ITEM_HEIGHT
    clr r24
    ldi r25, STATIC_ITEM_WIDTH
    rcall write_sprite
_rii_end:
    ret

; Print a single character to the framebuffer.
;
; Register Usage
;   r22, r23        character (param), foreground color (param)
;   r24, r25        character data
;   X (r26:r27)     framebuffer pointer (param, preserved)
;   Z (r30:r31)     flash pointer, working framebuffer pointer
putc:
    ldi ZL, low(2*font_character_table)
    ldi ZH, high(2*font_character_table)
    subi r22, 32
    lsl r22
    add ZL, r22
    adc ZH, r1
    lpm r25, Z+
    lpm r24, Z
    movw ZL, XL
    sbrs r25, 7
    rjmp _putc_write_pixels
    subi ZL, low(-DISPLAY_WIDTH)
    sbci ZH, high(-DISPLAY_WIDTH)
_putc_write_pixels:
    sbrs r25, 6
    st Z, r23
    sbrs r25, 5
    std Z+1, r23
    sbrs r25, 4
    std Z+2, r23
    subi ZL, low(-DISPLAY_WIDTH)
    sbci ZH, high(-DISPLAY_WIDTH)
    sbrs r25, 3
    st Z, r23
    sbrs r25, 2
    std Z+1, r23
    sbrs r25, 1
    std Z+2, r23
    subi ZL, low(-DISPLAY_WIDTH)
    sbci ZH, high(-DISPLAY_WIDTH)
    sbrs r25, 0
    st Z, r23
    sbrs r24, 7
    std Z+1, r23
    sbrs r24, 6
    std Z+2, r23
    subi ZL, low(-DISPLAY_WIDTH)
    sbci ZH, high(-DISPLAY_WIDTH)
    sbrs r24, 5
    st Z, r23
    sbrs r24, 4
    std Z+1, r23
    sbrs r24, 3
    std Z+2, r23
    subi ZL, low(-DISPLAY_WIDTH)
    sbci ZH, high(-DISPLAY_WIDTH)
    sbrs r24, 2
    st Z, r23
    sbrs r24, 1
    std Z+1, r23
    sbrs r24, 0
    std Z+2, r23
    ret

; Print a single character to the framebuffer using the small font variant.
;
; Register Usage
;   r22, r23        character (param), foreground color (param)
;   r24, r25        character data
;   X (r26:r27)     framebuffer pointer (param, preserved)
;   Z (r30:r31)     flash pointer, working framebuffer pointer
putc_small:
    ldi ZL, low(2*small_font_character_table)
    ldi ZH, high(2*small_font_character_table)
    subi r22, 32
    lsl r22
    add ZL, r22
    adc ZH, r1
    lpm r25, Z+
    lpm r24, Z
    movw ZL, XL
    sbrs r25, 6
    st Z, r23
    sbrs r25, 5
    std Z+1, r23
    sbrs r25, 4
    std Z+2, r23
    subi ZL, low(-DISPLAY_WIDTH)
    sbci ZH, high(-DISPLAY_WIDTH)
    sbrs r25, 3
    st Z, r23
    sbrs r25, 2
    std Z+1, r23
    sbrs r25, 1
    std Z+2, r23
    subi ZL, low(-DISPLAY_WIDTH)
    sbci ZH, high(-DISPLAY_WIDTH)
    sbrs r25, 0
    st Z, r23
    sbrs r24, 7
    std Z+1, r23
    sbrs r24, 6
    std Z+2, r23
    subi ZL, low(-DISPLAY_WIDTH)
    sbci ZH, high(-DISPLAY_WIDTH)
    sbrs r24, 5
    st Z, r23
    sbrs r24, 4
    std Z+1, r23
    sbrs r24, 3
    std Z+2, r23
    ret

; Write an unsigned 8 bit integer to the framebuffer in base 10. NOTE: the framebuffer
; pointer is the upper-left corner of the rightmost character.
;
; Register Usage
;   r21             value (param)
;   r23             foreground color (param)
;   r22-25          calculations
;   X (r26:r27)     framebuffer (param)
putb:
    divmod10u r21, r24, r22
    mov r21, r24
    subi r22, -'0'
    rcall putc
    sbiw XL, FONT_DISPLAY_WIDTH
    tst r21
    brne putb
    ret

; Write an unsigned 8 bit integer to the framebuffer in base 10 using the small
; font variant.
;
; Register Usage
;   r21             value (param)
;   r23             foreground color (param)
;   r22-25          calculations
;   X (r26:r27)     framebuffer (param)
putb_small:
    divmod10u r21, r24, r22
    mov r21, r24
    subi r22, -'0'
    rcall putc_small
    sbiw XL, FONT_DISPLAY_WIDTH
    tst r21
    brne putb_small
    ret

; Write an unsigned 16 bit integer to the framebuffer in base 10. NOTE: the framebuffer
; pointer is the upper-left corner of the rightmost character.
;
; Register Usage
;   r18:r19         value (param)
;   r23             foreground color (param)
;   r20-25, r30-r31 calculations
;   X (r26:r27)     framebuffer (param)
putw:
    divmodw10u r18, r19, r20, r21, r24, r25, r30, r31
    movw r18, r20
    mov r22, r24
    subi r22, -'0'
    rcall putc
    sbiw XL, FONT_DISPLAY_WIDTH
    tst r18
    brne putw
    tst r19
    brne putw
    ret

; Write an unsigned 16 bit integer to the framebuffer in base 10 using the small
; font variant.
;
; Register Usage
;   r18:r19         value (param)
;   r23             foreground color (param)
;   r20-25, r30-r31 calculations
;   X (r26:r27)     framebuffer (param)
putw_small:
    divmodw10u r18, r19, r20, r21, r24, r25, r30, r31
    movw r18, r20
    mov r22, r24
    subi r22, -'0'
    rcall putc_small
    sbiw XL, FONT_DISPLAY_WIDTH
    tst r18
    brne putw_small
    tst r19
    brne putw_small
    ret

; Write a string to the framebuffer.
;
; Register Usage
;   r18-r19         storage across calls
;   r20             counter
;   r21             number of horizontal characters to print (param)
;   r22             character
;   r23             foreground color (param)
;   X (r26:r27)     working framebuffer pointer
;   Y (r28:r29)     framebuffer pointer (param)
;   Z (r30:r31)     string flash pointer (param)
puts:
    mov r20, r21
    lsl r20
    movw XL, YL
_puts_loop:
    elpm r22, Z+
    cpi r22, 0
    breq _puts_end
    cpi r22, 10 ; '\n'
    breq _puts_newline
    cpi r22, ' '
    breq _puts_halfwidth
    cpi r22, 'i'
    breq _puts_halfwidth
    cpi r22, '.'
    breq _puts_halfwidth
    cpi r22, '!'
    breq _puts_halfwidth
    cpi r22, ':'
    breq _puts_halfwidth
    cpi r22, 39 ; '\''
    breq _puts_halfwidth
_puts_char:
    movw r18, ZL
    rcall putc
    movw ZL, r18
    adiw XL, FONT_DISPLAY_WIDTH
    subi r20, 2
    brsh _puts_loop
_puts_newline:
    mov r20, r21
    lsl r20
    subi YL, low(-FONT_DISPLAY_HEIGHT*DISPLAY_WIDTH)
    sbci YH, high(-FONT_DISPLAY_HEIGHT*DISPLAY_WIDTH)
    movw XL, YL
    rjmp _puts_loop
_puts_halfwidth:
    sbiw XL, FONT_DISPLAY_WIDTH/4
    movw r18, ZL
    rcall putc
    movw ZL, r18
    adiw XL, 3*FONT_DISPLAY_WIDTH/4
    subi r20, 1
    brsh _puts_loop
    rjmp _puts_newline
_puts_end:
    ret

; Write up to N characters of a string to the framebuffer.
;
; Register Usage
;   r18-r19         storage across calls
;   r20             counter
;   r21             number of horizontal characters to print (param)
;   r22             character
;   r23             foreground color (param)
;   r24             number of characters to print (param)
;   X (r26:r27)     working framebuffer pointer
;   Y (r28:r29)     framebuffer pointer (param)
;   Z (r30:r31)     string flash pointer (param)
puts_n:
    .if PC_SIZE == 3
    pop r0  ; save a byte
    .endif
    push r17
    mov r17, r24
    mov r20, r21
    lsl r20
    movw XL, YL
_putsn_loop:
    subi r17, 1
    brlo _putsn_end
    elpm r22, Z+
    cpi r22, 0
    breq _putsn_end
    cpi r22, 10 ; '\n'
    breq _putsn_newline
    cpi r22, ' '
    breq _putsn_halfwidth
    cpi r22, 'i'
    breq _putsn_halfwidth
    cpi r22, '.'
    breq _putsn_halfwidth
    cpi r22, '!'
    breq _putsn_halfwidth
    cpi r22, ':'
    breq _putsn_halfwidth
    cpi r22, 39 ; '\''
    breq _putsn_halfwidth
_putsn_char:
    movw r18, ZL
    rcall putc
    movw ZL, r18
    adiw XL, FONT_DISPLAY_WIDTH
    subi r20, 2
    brsh _putsn_loop
_putsn_newline:
    mov r20, r21
    lsl r20
    subi YL, low(-FONT_DISPLAY_HEIGHT*DISPLAY_WIDTH)
    sbci YH, high(-FONT_DISPLAY_HEIGHT*DISPLAY_WIDTH)
    movw XL, YL
    rjmp _putsn_loop
_putsn_halfwidth:
    sbiw XL, FONT_DISPLAY_WIDTH/4
    movw r18, ZL
    rcall putc
    movw ZL, r18
    adiw XL, 3*FONT_DISPLAY_WIDTH/4
    subi r20, 1
    brsh _putsn_loop
    rjmp _putsn_newline
_putsn_end:
    mov r24, r17
    pop r17
    .if PC_SIZE == 3
    push r1
    .endif
    ret

; Render a UI element with the given dimensions, taking transparency into account.
; The entire element is rendered.
;
; Register Usage
;   r21             delta
;   r22             transparency
;   r23             counter
;   r24             element width (param)
;   r25             element height (param)
;   X (r26:r27)     framebuffer pointer (param)
;   Z (r30:r31)     element pointer (param)
render_element:
    ldi r22, TRANSPARENT
    ldi r21, DISPLAY_WIDTH
    sub r21, r24
_re_outer:
    mov r23, r24
_re_inner:
    elpm r0, Z+
    cpse r22, r0
    st X, r0
    adiw XL, 1
    dec r23
    brne _re_inner
    add XL, r21
    adc XH, r1
    dec r25
    brne _re_outer
    ret

; Render a rectangle of a single color. Mainly useful to fill the screen quickly.
; The width is rounded down a multiple of four.
;
; Register Usage
;   r21             delta
;   r22             color (param)
;   r23             counter
;   r24             element width (param)
;   r25             element height (param)
;   X (r26:r27)     framebuffer pointer (param)
render_rect:
    andi r24, 0xfc
    ldi r21, DISPLAY_WIDTH
    sub r21, r24
_rr_outer:
    mov r23, r24
_rr_inner:
    st X+, r22
    st X+, r22
    st X+, r22
    st X+, r22
    subi r23, 4
    brne _rr_inner
    add XL, r21
    adc XH, r1
    dec r25
    brne _rr_outer
    ret

; Render a (player) effect icon. The less time remaining on the effect, the fewer
; pixels rendered.
;
; Register Usage
;   r25             effect index (param)
;   r21-25          calculations
;   X (r26:r27)     framebuffer pointer (param)
;   Y (r28:r29)     working framebuffer pointer
;   Z (r30:r31)     memory lookups
render_effect_progress:
    push YL
    push YH
    ldi ZL, low(player_effects)
    ldi ZH, high(player_effects)
    lsl r25
    add ZL, r25
    adc ZH, r1
    ld r24, Z+
    ld r25, Z+
    tst r24
    brne _rep_calculate_sprite
    rjmp _rep_end
_rep_calculate_sprite:
    dec r24
    ldi ZL, byte3(2*static_item_sprite_table)
    out RAMPZ, ZL
    ldi ZL, low(2*static_item_sprite_table)
    ldi ZH, high(2*static_item_sprite_table)
    ldi r22, STATIC_ITEM_MEMSIZE
    mul r24, r22
    add ZL, r0
    adc ZH, r1
    ldi r22, STATIC_ITEM_HEIGHT+1
    mul r25, r22
    sub r22, r1
    dec r22
    clr r1
    ldi r23, STATIC_ITEM_HEIGHT
    movw YL, XL
    ldi r24, TRANSPARENT
    tst r22
    breq _rep_row_iter2
_rep_row_iter1:
    elpm r0, Z+
    mov r25, r0
    andi r25, 0xb6
    lsr r25
    cpse r0, r24
    st Y, r25
    elpm r0, Z+
    mov r25, r0
    andi r25, 0xb6
    lsr r25
    cpse r0, r24
    std Y+1, r25
    elpm r0, Z+
    mov r25, r0
    andi r25, 0xb6
    lsr r25
    cpse r0, r24
    std Y+2, r25
    elpm r0, Z+
    mov r25, r0
    andi r25, 0xb6
    lsr r25
    cpse r0, r24
    std Y+3, r25
    elpm r0, Z+
    mov r25, r0
    andi r25, 0xb6
    lsr r25
    cpse r0, r24
    std Y+4, r25
    elpm r0, Z+
    mov r25, r0
    andi r25, 0xb6
    lsr r25
    cpse r0, r24
    std Y+5, r25
    subi YL, low(-DISPLAY_WIDTH)
    sbci YH, high(-DISPLAY_WIDTH)
    dec r23
    dec r22
    brne _rep_row_iter1
    tst r23
    breq _rep_end
_rep_row_iter2:
    elpm r0, Z+
    cpse r0, r24
    st Y, r0
    elpm r0, Z+
    cpse r0, r24
    std Y+1, r0
    elpm r0, Z+
    cpse r0, r24
    std Y+2, r0
    elpm r0, Z+
    cpse r0, r24
    std Y+3, r0
    elpm r0, Z+
    cpse r0, r24
    std Y+4, r0
    elpm r0, Z+
    cpse r0, r24
    std Y+5, r0
    subi YL, low(-DISPLAY_WIDTH)
    sbci YH, high(-DISPLAY_WIDTH)
    dec r23
    brne _rep_row_iter2
_rep_end:
    pop YH
    pop YL
    ret

; Render an item icon with a nice-looking underbar. The underbar is rendered
; whether or not the item is present.
;
; Register Usage
;   r22-r24         internal
;   r25             item (param)
;   X (r26:r37)     framebuffer pointer (param)
render_item_with_underbar:
    rcall render_item_icon
    subi XL, low(-(STATIC_ITEM_HEIGHT*DISPLAY_WIDTH-1))
    sbci XH, high(-(STATIC_ITEM_HEIGHT*DISPLAY_WIDTH-1))
    ldi r22, 0x0
    ldi r24, INVENTORY_UI_COL_WIDTH-1
    ldi r25, 1
    rcall render_rect
    ret

; Render a small popup to the framebuffer.
;
; Register Usage
;   r20-r23         calculations
;   r24             width (param)
;   r25             height (param)
;   X (r26:r27)     framebuffer pointer (param)
;   Z (r30:r31)     string pointer (param)
render_popup:
    andi r24, 0xfc
    ldi XL, low(framebuffer + 44*DISPLAY_WIDTH + DISPLAY_WIDTH/2 - 1)
    ldi XH, high(framebuffer + 44*DISPLAY_WIDTH + DISPLAY_WIDTH/2 - 1)
    mov r23, r24
    lsr r23
    sub XL, r23
    sbc XH, r1
    ldi r21, DISPLAY_WIDTH-2
    sub r21, r24
_rp_top:
    ldi r22, 0x1d
    ldi r20, 0x6e
    mov r23, r24
    st X+, r22
_rp_top_loop:
    st X+, r22
    st X+, r22
    st X+, r22
    st X+, r22
    subi r23, 4
    brne _rp_top_loop
    st X+, r22
    add XL, r21
    adc XH, r1
_rp_inside_row:
    mov r23, r24
    st X+, r22
_rp_inside4:
    st X+, r20
    st X+, r20
    st X+, r20
    st X+, r20
    subi r23, 4
    brne _rp_inside4
    st X+, r22
    add XL, r21
    adc XH, r1
    dec r25
    brne _rp_inside_row
    mov r23, r24
    st X+, r22
_rp_bottom_loop:
    st X+, r22
    st X+, r22
    st X+, r22
    st X+, r22
    subi r23, 4
    brne _rp_bottom_loop
    st X+, r22
    ldi YL, low(framebuffer + 47*DISPLAY_WIDTH + DISPLAY_WIDTH/2)
    ldi YH, high(framebuffer + 47*DISPLAY_WIDTH + DISPLAY_WIDTH/2)
    lsr r24
    sub YL, r24
    sbc YH, r1
    ldi r21, 30
    clr r23
    rcall puts
    ret

; Render an entire screen.
;
;   r24-r25        calculations
;   Y (r28:r29)     framebuffer pointer
;   Z (r30:r31)     screen pointer (parm)
render_full_screen:
    ldi r24, low(DISPLAY_WIDTH*DISPLAY_HEIGHT-4)
    ldi r25, high(DISPLAY_WIDTH*DISPLAY_HEIGHT-4)
    ldi YL, low(framebuffer)
    ldi YH, high(framebuffer)
_rfs_loop:
    elpm r0, Z+
    st Y+, r0
    elpm r0, Z+
    st Y+, r0
    elpm r0, Z+
    st Y+, r0
    elpm r0, Z+
    st Y+, r0
    sbiw r24, 4
    brsh _rfs_loop
    ret

; Render a partial screen (used for slide-in-out animations).
;
; Register Usage
;   r21             calculations
;   r22, r23        min x, width (params)
;   r24, r25        min y, height (params)
;   Y (r28:r29)     framebuffer pointer (param)
;   Z (r30:r31)     screen pointer (param)
render_partial_screen:
    add ZL, r22
    adc ZH, r1
    ldi r22, DISPLAY_WIDTH
    mul r22, r24
    add ZL, r0
    adc ZH, r1
    clr r1
    subi r25, 1
    brlo _rps_end
_rps_col_loop:
    mov r21, r23
    sbrs r21, 0
    rjmp _rps_prerow
    elpm r0, Z+
    st Y+, r0
    subi r21, 1
_rps_prerow:
    subi r21, 1
    brlo _rps_next_col
_rps_row_loop:
    elpm r0, Z+
    st Y+, r0
    elpm r0, Z+
    st Y+, r0
    subi r21, 2
    brsh _rps_row_loop
_rps_next_col:
    sub YL, r23
    sbc YH, r1
    subi YL, low(-DISPLAY_WIDTH)
    sbci YH, high(-DISPLAY_WIDTH)
    sub ZL, r23
    sbc ZH, r1
    subi ZL, low(-DISPLAY_WIDTH)
    sbci ZH, high(-DISPLAY_WIDTH)
    subi r25, 1
    brsh _rps_col_loop
_rps_end:
    ret

; Fade in some text, hold it, then fade it out.
;
; Register Usage
;   r20             calculations
;   r21             printing width (param)
;   r22             calculations
;   r23             color (param)
;   r24             fade in time (param)
;   r25             fade out time (param)
;   Y (r28:r29)     framebuffer pointer (param)
;   Z (r30:r31)     text pointer (param)
fade_text:
    lds r20, mode_clock
_ft_fade_in:
    mov r22, r24
    subi r22, 7
    cp r20, r22
    brlo _ft_end
    cp r20, r24
    brsh _ft_fade_out
    sub r24, r20
    fade_color r23, r20, r22, r24
    rjmp _ft_render
_ft_fade_out:
    cp r20, r25
    brlo _ft_render
    mov r22, r25
    subi r22, low(-8)
    cp r20, r22
    brsh _ft_end
    sub r20, r25
    fade_color r23, r25, r22, r20
_ft_render:
    call puts
_ft_end:
    ret

; Fade out some text, hold it, then fade in out. This allows us to fade black
; text onto any background.
;
; Register Usage
;   r20             calculations
;   r21             printing width (param)
;   r22             calculations
;   r23             color (param)
;   r24             fade out time (param)
;   r25             fade in time (param)
;   Y (r28:r29)     framebuffer pointer (param)
;   Z (r30:r31)     text pointer (param)
fade_text_inverse:
    lds r20, mode_clock
_fti_fade_out:
    mov r22, r24
    subi r22, 7
    cp r20, r22
    brlo _fti_end
    cp r20, r24
    brsh _fti_hold
    sub r20, r24
    subi r20, low(-8)
    fade_color r23, r24, r22, r20
    rjmp _fti_render
_fti_hold:
    cp r20, r25
    brsh _fti_fade_in
    clr r23
    rjmp _fti_render
_fti_fade_in:
    mov r22, r25
    subi r22, low(-8)
    cp r20, r22
    brsh _fti_end
    sub r25, r20
    subi r25, low(-8)
    fade_color r23, r20, r22, r25
_fti_render:
    call puts
_fti_end:
    ret
