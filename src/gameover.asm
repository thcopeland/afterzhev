gameover_update_game:
    rjmp gameover_render_game
_gug_return:
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
;   r24     calculations
;   r25     game status (param)
load_gameover:
    lds r24, game_mode
    cpi r24, MODE_GAMEOVER
    breq _lg_end
    sts gameover_state, r25
    ldi r25, MODE_GAMEOVER
    sts game_mode, r25
    sts mode_clock, r1
    sts mode_clock+1, r1
_lg_end:
    ret

.equ GAMEOVER_TIMING_FADE_END = (DISPLAY_HEIGHT<<1) + 60
.equ GAMEOVER_TIMING_TEXT_FADE_END = GAMEOVER_TIMING_FADE_END + 31

; Render the game over screen.
;
; Register Usage
;   r24-r25     calculations
gameover_render_game:
    lds r24, mode_clock
    lds r25, mode_clock+1
    cpiw r24, r25, GAMEOVER_TIMING_FADE_END, r23
    brsh _grg_check_win
    rjmp gameover_fade_screen
_grg_check_win:
    lds r25, gameover_state
    cpi r25, GAME_OVER_WIN
    brne _grg_check_death
    rcall gameover_render_win
    rjmp _grg_end
_grg_check_death:
    rcall gameover_render_dead
_grg_return:
_grg_end:
    rjmp _gug_return

.equ GAMEOVER_UI_HEADER_TEXT_MARGIN = DISPLAY_WIDTH*(DISPLAY_HEIGHT-FONT_DISPLAY_HEIGHT)/2 + (DISPLAY_WIDTH-FONT_DISPLAY_WIDTH*8)/2
.equ GAMEOVER_UI_DEATH_MESSAGE_MARGIN = DISPLAY_WIDTH*44 + 4

gameover_render_dead:
    ldi XL, low(framebuffer)
    ldi XH, high(framebuffer)
    clr r22
    ldi r24, DISPLAY_WIDTH
    ldi r25, DISPLAY_HEIGHT
    call render_rect
_grd_calc_header_fade:
    ldi r21, 20
    ldi r23, 0x05
    lds r24, mode_clock
    lds r25, mode_clock+1
    subi r24, low(GAMEOVER_TIMING_TEXT_FADE_END)
    sbci r25, high(GAMEOVER_TIMING_TEXT_FADE_END)
    brsh _grd_render_header
    neg r24
    lsr r24
    lsr r24
    fade_color r23, r22, r25, r24
_grd_render_header:
    ldi YL, low(framebuffer+GAMEOVER_UI_HEADER_TEXT_MARGIN)
    ldi YH, high(framebuffer+GAMEOVER_UI_HEADER_TEXT_MARGIN)
    ldi ZL, byte3(2*ui_str_you_died)
    out RAMPZ, ZL
    ldi ZL, low(2*ui_str_you_died)
    ldi ZH, high(2*ui_str_you_died)
    call puts
_grd_message_line1:
    ldi r21, 28
    ldi r23, 0x05
    ldi r24, 7
    ldi r25, 66
    ldi YL, low(framebuffer+GAMEOVER_UI_DEATH_MESSAGE_MARGIN)
    ldi YH, high(framebuffer+GAMEOVER_UI_DEATH_MESSAGE_MARGIN)
    lds r20, gameover_state
    cpi r20, GAME_OVER_POISONED
    breq _grd_line1_poisoned
    ldi ZL, low(2*ui_str_death_message1)
    ldi ZH, high(2*ui_str_death_message1)
    rjmp _grd_write_line1
_grd_line1_poisoned:
    ldi ZL, low(2*ui_str_poisoned_message1)
    ldi ZH, high(2*ui_str_poisoned_message1)
_grd_write_line1:
    rcall gameover_fade_text
_grd_message_line2:
    ldi r23, 0x05
    ldi r24, 80
    ldi r25, 66
    ldi YL, low(framebuffer+GAMEOVER_UI_DEATH_MESSAGE_MARGIN)
    ldi YH, high(framebuffer+GAMEOVER_UI_DEATH_MESSAGE_MARGIN)
    ldi ZL, low(2*ui_str_death_message2)
    ldi ZH, high(2*ui_str_death_message2)
    rcall gameover_fade_text
_grd_message_line3:
    ldi r23, 0x05
    ldi r24, 160
    ldi r25, 66
    ldi YL, low(framebuffer+GAMEOVER_UI_DEATH_MESSAGE_MARGIN)
    ldi YH, high(framebuffer+GAMEOVER_UI_DEATH_MESSAGE_MARGIN)
    ldi ZL, low(2*ui_str_death_message3)
    ldi ZH, high(2*ui_str_death_message3)
    rcall gameover_fade_text
_grd_play_again:
    ldi r23, 0x05
    ldi r24, 240
    ldi r25, 0
    ldi YL, low(framebuffer+GAMEOVER_UI_DEATH_MESSAGE_MARGIN)
    ldi YH, high(framebuffer+GAMEOVER_UI_DEATH_MESSAGE_MARGIN)
    ldi ZL, low(2*ui_str_press_any_button)
    ldi ZH, high(2*ui_str_press_any_button)
    rcall gameover_fade_text
    call restore_from_savepoint
    ret

gameover_render_win:
    ret

; Fade in some text, hold it for some time, then fade it out. If the given duration
; is zero, will never fade out the text.
;
; Register Usage
;   r20, r22        calculations
;   r21             printing width (param)
;   r23             color (param)
;   r24             time at which to fade in (param)
;   r25             duration of text (param)
;   Y (r28:r29)     framebuffer pointer (param)
;   Z (r30:r31)     text pointer (param)
gameover_fade_text:
    lds r20, mode_clock
    lds r22, mode_clock+1
    subi r20, low(GAMEOVER_TIMING_TEXT_FADE_END)
    sbci r22, high(GAMEOVER_TIMING_TEXT_FADE_END)
    brlo _gft_end
    lsr r22
    ror r20
    lsr r22
    ror r20
_gft_fade_in:
    sub r20, r24
    sbc r22, r1
    brlo _gft_end
    cp r20, r25
    cpc r22, r1
    brsh _gft_fade_out
    subi r20, 7
    brsh _gft_render_text
    neg r20
    rjmp _gft_fade_text
_gft_fade_out:
    sub r20, r25
    sbc r22, r1
    brlo _gft_render_text
    tst r25 ; special case
    breq _gft_render_text
    cpi r20, 7
    cpc r22, r1
    brsh _gft_end
_gft_fade_text:
    fade_color r23, r24, r25, r20
_gft_render_text:
    call puts
_gft_end:
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
    breq _gfs_end
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
    rjmp _grg_return
