gameover_update_game:
    rjmp gameover_render_game
_gug_return:
    rcall gameover_handle_controls
    lds r25, clock
    andi r25, 0x3
    brne _gug_end
    lds r25, mode_clock
    inc r25
    breq _gug_end
    sts mode_clock, r25
_gug_end:
    jmp _loop_reenter

; Switch to the "game over" screen. This is used for all game endings, both wins
; and losses.
;
; Register Usage
;   r24     calculations
;   r25     game status (param)
load_gameover:
    lds r25, game_mode
    cpi r25, MODE_GAMEOVER
    breq _lg_end
    sts gameover_state, r25
    ldi r25, MODE_GAMEOVER
    sts game_mode, r25
    sts mode_clock, r1
    sts lightning_clock, r1
_lg_end:
    ret

.equ GAMEOVER_TIMING_FADE_END = (DISPLAY_HEIGHT<<1) + 60
.equ GAMEOVER_TIMING_TEXT_FADE_END = GAMEOVER_TIMING_FADE_END + 31

; Handle controls (resume from last save).
;
; Register Usage
;   r24-r25     calculations
gameover_handle_controls:
    lds r24, prev_controller_values
    lds r25, controller_values
    com r24
    and r24, r25
    breq _ghc_end
    lds r25, mode_clock
    cpi r25, 65
    brlo _ghc_end
    call restore_from_savepoint
    tst r25
    brne _ghc_end ; TODO restart
_ghc_end:
    ret

; Render the game over screen.
;
; Register Usage
;   r24-r25     calculations
gameover_render_game:
    lds r25, mode_clock
    cpi r25, 30
    brsh _grg_check_win
    rjmp gameover_lightning
    rjmp _grg_end
_grg_check_win:
    lds r25, gameover_state
    cpi r25, GAME_OVER_WIN
    brne _grg_check_death
    rcall gameover_render_win
    rjmp _grg_end
_grg_check_death:
    rcall gameover_render_dead
_grg_end:
_grg_return:
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
    ldi r21, 20
    ldi r23, 0x05
    ldi r25, 45
    ldi YL, low(framebuffer+GAMEOVER_UI_HEADER_TEXT_MARGIN)
    ldi YH, high(framebuffer+GAMEOVER_UI_HEADER_TEXT_MARGIN)
    ldi ZL, byte3(2*ui_str_you_died)
    out RAMPZ, ZL
    ldi ZL, low(2*ui_str_you_died)
    ldi ZH, high(2*ui_str_you_died)
    rcall gameover_text
    ldi r21, 28
    ldi r23, 0x05
    ldi r25, 70
    ldi YL, low(framebuffer+GAMEOVER_UI_DEATH_MESSAGE_MARGIN)
    ldi YH, high(framebuffer+GAMEOVER_UI_DEATH_MESSAGE_MARGIN)
    ldi ZL, low(2*ui_str_press_any_button)
    ldi ZH, high(2*ui_str_press_any_button)
    rcall gameover_text
    ret

gameover_render_win:
    ret

; Fade in some text and hold it.
;
; Register Usage
;   r21             printing width (param)
;   r22             calculations
;   r23             color (param)
;   r25             time at which to fade in (param)
;   Y (r28:r29)     framebuffer pointer (param)
;   Z (r30:r31)     text pointer (param)
gameover_text:
    lds r24, mode_clock
    mov r22, r25
    subi r22, 8
    cp r24, r22
    brlo _gt_end
    sub r25, r24
    brlo _gt_render
    fade_color r23, r22, r24, r25
_gt_render:
    call puts
_gt_end:
    ret

gfs_lightning:
    .db 0b11111111, 0b11111111, 0b00000000, 0b00011110, 0b00011000, 0b00000000, 0b00000000, 0b11100111, 0b11111111, 0b00000000

; Perform a dying effect.
;
; Register Usage
;   r24-r25         calculations
;   Z (r30:r31)     sector update pointer
gameover_lightning:
    lds r25, mode_clock
    cpi r25, 28
    brlo _gl_lightning
    ldi r25, 0xff
    out DDRA, r25
    ldi XL, low(framebuffer)
    ldi XH, high(framebuffer)
    clr r22
    ldi r24, DISPLAY_WIDTH
    ldi r25, DISPLAY_HEIGHT
    call render_rect
    rjmp _gl_end
_gl_lightning:
    call render_game
    call update_active_effects
    call update_savepoint_animation
    call update_player
    call update_npcs

    lds r25, mode_clock
    cpi r25, 10
    brlo _gl_end

    lds r25, lightning_clock
    mov r24, r25
    lsr r25
    lsr r25
    lsr r25
    ldi ZL, low(2*gfs_lightning)
    ldi ZH, high(2*gfs_lightning)
    add ZL, r25
    adc ZH, r1
    lpm r23, Z
    clr r25
    nbit r23, r24
    breq _gl_red
    ldi r25, 0x07
_gl_red:
    out DDRA, r25
    lds r25, lightning_clock
    inc r25
    sts lightning_clock, r25
_gl_end:
    rjmp _grg_return
