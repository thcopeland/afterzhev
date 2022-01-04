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
    subi ZL, low(-(tile_table*2+TILE_DATA_OFFSET))
    sbci ZH, high(-(tile_table*2+TILE_DATA_OFFSET))
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
.if defined(__atmega2560) || defined(__atmega2561)
    push r1 ; atmega256* use 3 byte flash addresses
.endif
_wpt_end:
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
.if defined(__atmega2560) || defined(__atmega2561)
    push r1
.endif
    ret
_ws_end:
    pop YH
    pop YL
    ret

; Render any rectangular section of a sprite flipped across the vertical axis.
; The final result is the same as mirroring the original sprite, then rendering
; it with write_sprite.
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
write_sprite_flipped:
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
    subi r24, low(-_wsf_loop)
    sbci r25, high(-_wsf_loop)
    inc r23
    ldi r22, TRANSPARENT
    rjmp _ws_loop_check
_wsf_loop:
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
_wsf_loop_check:
    dec r23
    breq _wsf_end
    push r24
    push r25
.if defined(__atmega2560) || defined(__atmega2561)
    push r1
.endif
    ret
_wsf_end:
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
    call write_partial_tile ; upper left
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
    call write_partial_tile ; upper right
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
    call write_partial_tile ; lower right
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
    call write_partial_tile ; lower left
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
    call write_partial_tile
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
    call write_partial_tile
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
    call write_entire_tile  ; top edge
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
    call write_entire_tile  ; bottom edge
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
    call write_entire_tile
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
; Register Usage
;   r10             whether or not to mirror the sprite (param)
;   r16, r17        screen x position
;   r18, r19        screen y position, camera position
;   r20, r21        sprite width (param), sprite height (param); calculations
;   r22, r23        sprite x position (param), calculations
;   r24, r25        sprite y position (param)
;   X (r26:r27)     framebuffer pointer
;   Z (r30:r21)     sprite pointer (param)
render_sprite:
    push r16
    push r17
    push r20
    push r21
    ldi XL, low(framebuffer)
    ldi XH, high(framebuffer)
_rs_calc_vertical_offset:
    lds r18, camera_position_y
    lds r19, camera_position_y+1
    sub r24, r18
    sub r25, r19
    qmod r24, r25, TILE_HEIGHT
    movw r18, r24
    cpi r25, 0
    brlt _rs_calc_horizonal_offset
    ldi r20, TILE_HEIGHT
    mul r25, r20
    add r24, r0
    ldi r20, DISPLAY_WIDTH
    mul r24, r20
    add XL, r0
    add XH, r1
    clr r1
_rs_calc_horizonal_offset:
    lds r16, camera_position_x
    lds r17, camera_position_x+1
    sub r22, r16
    sub r23, r17
    qmod r22, r23, TILE_WIDTH
    movw r16, r22
    cpi r23, 0
    brlt _rs_check_display_bounds
    ldi r20, TILE_WIDTH
    mul r23, r20
    add XL, r0
    adc XH, r1
    clr r1
    add XL, r22
    adc XH, r1
_rs_check_display_bounds:
    pop r23
    pop r25
_rs_check_x_too_large:
    movw r20, r16
    cpi r21, DISPLAY_HORIZONTAL_TILES
    brge _rs_end
_rs_check_x_too_small:
    cpi r21, 0
    brge _rs_check_y_too_large
    cpi r21, -1
    brlt _rs_end
    add r20, r25
    cpi r20, TILE_WIDTH
    brlt _rs_end
_rs_check_y_too_large:
    movw r20, r18
    cpi r21, DISPLAY_VERTICAL_TILES
    brge _rs_end
_rs_check_y_too_small:
    cpi r21, 0
    brge _rs_render_sprite
    cpi r21, -1
    brlt _rs_end
    add r20, r23
    cpi r20, TILE_HEIGHT
    brlt _rs_end
_rs_render_sprite:
    clr r22
    clr r24
    mov r21, r25
_rs_test_left_cut:
    cpi r17, 0
    brge _rs_test_right_cut
    ldi r24, TILE_WIDTH
    sub r24, r16
    sub r25, r24
    rjmp _rs_test_top_cut
_rs_test_right_cut:
    cpi r17, DISPLAY_HORIZONTAL_TILES-1
    brlt _rs_test_top_cut
    ldi r24, TILE_WIDTH
    mov r0, r24
    sub r0, r16
    clr r24
    cp r0, r25
    brge _rs_write_sprite
    mov r25, r0
_rs_test_top_cut:
    cpi r19, 0
    brge _rs_test_bottom_cut
    ldi r22, TILE_HEIGHT
    sub r22, r18
    sub r23, r22
    rjmp _rs_write_sprite
_rs_test_bottom_cut:
    cpi r19, DISPLAY_VERTICAL_TILES-1
    brlt _rs_write_sprite
    ldi r22, TILE_HEIGHT
    mov r0, r22
    sub r0, r18
    clr r22
    cp r0, r23
    brge _rs_write_sprite
    mov r23, r0
_rs_write_sprite:
    tst r10
    breq _rs_write_normal
_rs_write_flipped:
    call write_sprite_flipped
    rjmp _rs_end
_rs_write_normal:
    call write_sprite
_rs_end:
    pop r17
    pop r16
    ret

; Render a character, taking camera position, animations, and weapons into account.
; The character data pointer should point to memory with the following layout:
;   base sprite idx (1 byte)
;   weapon idx      (1 byte)
;   armor idx       (1 byte)
;   direction       (1 byte) PERF: if memory is tight, direction, action, and frame could be packed into a single byte
;   current action  (1 byte)
;   action frame    (1 byte)
;
; Register Usage
;   r14, r15        character x position
;   r16, r17        character x position
;   r18-r21         calculations
;   r22, r23        character x position (param)
;   r24, r25        character y position (param)
;   X (r26:r27)     framebuffer pointer
;   Y (r28:r29)     character data pointer (param), character animation pointer
;   Z (r30:r21)     flash memory pointer, temporary pointer
render_character:
    push r10
    push r14
    push r15
    push r16
    push r17
    movw r14, r22
    movw r16, r24
    clr r10
    ldd r18, Y+CHARACTER_DIRECTION_OFFSET
    cpi r18, DIRECTION_UP
    brsh _rc_alpha_under
_rc_alpha_over:
    call _rc_render_character_sprite
    call _rc_render_weapon_sprite
    rjmp _rc_end
_rc_alpha_under:
    ldd r18, Y+CHARACTER_ACTION_OFFSET
    neg r18
    cpi r18, -(ACTION_ATTACK1-1)
    adc r10, r1
    call _rc_render_weapon_sprite
    clr r10
    call _rc_render_character_sprite
    rjmp _rc_end
; _rc_render_character_sprite is sort of a sub-subroutine. It contains a ret, so
; must be call'd, not simple jumped to or entered. It renders both the character
; sprite and (if necessary) the armor sprite, since these are always drawn in
; the same order.
_rc_render_character_sprite:
    ldd r22, Y+CHARACTER_SPRITE_OFFSET
    ldd r23, Y+CHARACTER_DIRECTION_OFFSET
    ldd r24, Y+CHARACTER_ACTION_OFFSET
    ldd r25, Y+CHARACTER_FRAME_OFFSET
    call determine_character_sprite
    ldi r20, CHARACTER_SPRITE_WIDTH
    ldi r21, CHARACTER_SPRITE_HEIGHT
    movw r22, r14
    movw r24, r16
    call render_sprite
    ldd r22, Y+CHARACTER_ARMOR_OFFSET
    cpi r22, 0
    brne _rc_write_armor_sprite
    ret
_rc_write_armor_sprite:
    ldd r23, Y+CHARACTER_DIRECTION_OFFSET
    ldd r24, Y+CHARACTER_ACTION_OFFSET
    ldd r25, Y+CHARACTER_FRAME_OFFSET
    call determine_overlay_sprite
    movw r22, r14
    movw r24, r16
    elpm r21, Z+
    splts r21, r20
    subi r20, -(CHARACTER_SPRITE_WIDTH/2)
    subi r21, -(CHARACTER_SPRITE_HEIGHT/2)
    add r22, r20
    add r24, r21
    qmod r22, r23, TILE_WIDTH
    qmod r24, r25, TILE_HEIGHT
    elpm r21, Z+
    splt r21, r20
    call render_sprite
    ret
; *** end of _rc_render_character_sprite ***
; _rc_render_weapon_sprite is another sub-subroutine. It must also be call'd,
; not simply jumped to or entered.
_rc_render_weapon_sprite:
    ldd r22, Y+CHARACTER_WEAPON_OFFSET
    cpi r22, 0
    brne _rc_write_weapon_sprite
    ret
_rc_write_weapon_sprite:
    ldd r23, Y+CHARACTER_DIRECTION_OFFSET
    ldd r24, Y+CHARACTER_ACTION_OFFSET
    ldd r25, Y+CHARACTER_FRAME_OFFSET
    call determine_overlay_sprite
    movw r22, r14
    movw r24, r16
    elpm r21, Z+
    splts r21, r20
    subi r20, -(CHARACTER_SPRITE_WIDTH/2)
    subi r21, -(CHARACTER_SPRITE_HEIGHT/2)
    add r22, r20
    add r24, r21
    qmod r22, r23, TILE_WIDTH
    qmod r24, r25, TILE_HEIGHT
    elpm r21, Z+
    splt r21, r20
    call render_sprite
    ret
; *** end of _rc_render_weapon_sprite ***
_rc_end:
    pop r17
    pop r16
    pop r15
    pop r14
    pop r10
    ret
