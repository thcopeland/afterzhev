gameover_update_game:
    rcall gameover_render_game
    lds r24, mode_clock
    lds r25, mode_clock+1
    adiw r24, 1
    sts mode_clock, r24
    sts mode_clock+1, r25
    jmp _loop_reenter

; Switch to the "game over" screen. This is used for all game endings, both wins
; and losses.
;
; Register Usage
;   r25     game status (param)
load_gameover:
    lds r25, game_mode
    cpi r25, MODE_GAMEOVER
    breq _lg_end
    sts gameover_state, r25
    ldi r25, MODE_GAMEOVER
    sts game_mode, r25
    sts mode_clock, r1
    sts mode_clock+1, r1
_lg_end:
    ret

; Render the game over screen.
;
; Register Usage
;   r24-r25     calculations
gameover_render_game:
    lds r24, mode_clock
    lds r25, mode_clock+1
    cpiw r24, r25, DISPLAY_HEIGHT<<1, r24
    brsh _grg_end
    call gameover_fade_screen
_grg_end:
    ret

; Perform a closing effect on the screen. The player cannot move, but NPCs continue
; to move.
;
; Register Usage
;   r24-r25         calculations
;   Z (r30:r31)     sector update pointer
gameover_fade_screen:
    lds r25, mode_clock
    andi r25, 0x3
    breq _gfs_render
    call update_player
    ldi ZL, byte3(2*sector_table)
    out RAMPZ, ZL
    lds ZL, current_sector
    lds ZH, current_sector+1
    subi ZL, low(-SECTOR_HANDLERS_OFFSET)
    sbci ZH, high(-SECTOR_HANDLERS_OFFSET)
    elpm r24, Z+
    elpm r25, Z+
    tst r25
    breq _gfs_fade
    movw ZL, r24
    icall
    rjmp _gfs_end
_gfs_render:
    call render_game
_gfs_fade:
    ldi XL, low(framebuffer)
    ldi XH, high(framebuffer)
    ldi ZL, low(framebuffer+DISPLAY_WIDTH*DISPLAY_HEIGHT)
    ldi ZH, high(framebuffer+DISPLAY_WIDTH*DISPLAY_HEIGHT)
    lds r25, mode_clock
    lds r24, mode_clock+1
    lsr r24
    ror r25
    lsr r24
    ror r25
_gfs_black_outer:
    ldi r24, DISPLAY_WIDTH
_gfs_black_inner:
    st X+, r1
    st -Z, r1
    dec r24
    brne _gfs_black_inner
    dec r25
    brpl _gfs_black_outer
    ldi r24, DISPLAY_WIDTH
_gfs_dim1:
    ld r25, X
    andi r25, 0x24
    lsr r25
    lsr r25
    st X+, r25
    ld r25, -Z
    andi r25, 0x24
    lsr r25
    lsr r25
    st Z, r25
    dec r24
    brne _gfs_dim1
    ldi r24, DISPLAY_WIDTH
_gfs_dim2:
    ld r25, X
    andi r25, 0xb6
    lsr r25
    st X+, r25
    ld r25, -Z
    andi r25, 0xb6
    lsr r25
    st Z, r25
    dec r24
    brne _gfs_dim2
_gfs_end:
    ret
