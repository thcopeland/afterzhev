gameover_update_game:
    lds r25, mode_clock
    cpi r25, 32
    brsh _gug_music
_gug_sound_effects:
    call update_sound_effects
    rjmp _gug_render
_gug_music:
    call update_music
_gug_render:
    rjmp gameover_render_game
_gug_return:
    rcall gameover_handle_controls
    lds r25, game_mode
    cpi r25, MODE_GAMEOVER
    brne _gug_end
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
    sts gameover_state, r25
    cpi r25, GAME_OVER_WIN
    brne _lg_lose
_lg_win:
    lds r24, clock
    lds r25, clock+1
    sts final_time, r24
    sts final_time+1, r25
    ldi r25, (sfx_win-sfx_table)>>1
    sts sfx_track, r25
    ldi r24, low(2*music_credits_channel_1)
    ldi r25, high(2*music_credits_channel_1)
    sts music_track, r24
    sts music_track+1, r25
    ldi r24, low(2*music_credits_channel_2)
    ldi r25, high(2*music_credits_channel_2)
    sts music_track+2, r24
    sts music_track+3, r25
    rjmp _lg_setup
_lg_lose:
    ldi r25, (sfx_death-sfx_table)>>1
    sts sfx_track, r25
    ldi r24, low(2*music_death_channel_1)
    ldi r25, high(2*music_death_channel_1)
    sts music_track, r24
    sts music_track+1, r25
    ldi r24, low(2*music_death_channel_2)
    ldi r25, high(2*music_death_channel_2)
    sts music_track+2, r24
    sts music_track+3, r25
_lg_setup:
    ldi r25, MODE_GAMEOVER
    sts game_mode, r25
    sts mode_clock, r1
    sts lightning_clock, r1
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
    lds r25, gameover_state
    cpi r25, GAME_OVER_WIN
    breq _ghc_end
_ghc_dead:
    sbrs r24, CONTROLS_SPECIAL1
    rjmp  _ghc_restart
_ghc_retry:
    ldi r20, low(2*sector_table + SECTOR_MEMSIZE*SECTOR_TUTORIAL)
    ldi r21, high(2*sector_table + SECTOR_MEMSIZE*SECTOR_TUTORIAL)
    lds r22, current_sector
    lds r23, current_sector+1
    cp r20, r22
    cpc r21, r23
    brne _ghc_normal_retry
    call load_tutorial
    rjmp _ghc_end
_ghc_normal_retry:
    call restore_from_savepoint
    tst r25
    breq _ghc_end
    call init_game_state
    call load_explore
    rjmp _ghc_end
_ghc_restart:
    sbrs r24, CONTROLS_SPECIAL2
    rjmp _ghc_end
    sts start_selection, r1
    call restart_game
    ; fade out music
    lds r25, channel1_wave
    ori r25, SFX_FADE_OUT|15
    sts channel1_wave, r25
    lds r25, channel2_wave
    ori r25, SFX_FADE_OUT|15
    sts channel2_wave, r25
_ghc_end:
    ret

; Render the game over screen.
;
; Register Usage
;   r24-r25     calculations
gameover_render_game:
    lds r25, gameover_state
    cpi r25, GAME_OVER_WIN
    brne _grg_check_death
_grg_win:
    lds r25, mode_clock
    cpi r25, 29
    brsh _grg_render_win
    call render_game
    call update_active_effects
    call update_savepoint_animation
    call update_player
    call update_npcs
_grg_render_win:
    rcall gameover_render_win
    rjmp _grg_end
_grg_check_death:
    lds r25, mode_clock
    cpi r25, 30
    brsh  _grg_render_dead
    rjmp gameover_lightning
_grg_render_dead:
    rcall gameover_render_dead
_grg_end:
_grg_return:
    rjmp _gug_return

.equ GAMEOVER_UI_HEADER_TEXT_MARGIN = DISPLAY_WIDTH*(DISPLAY_HEIGHT-FONT_DISPLAY_HEIGHT)/2 + 33
.equ GAMEOVER_UI_DEATH_MESSAGE_MARGIN = DISPLAY_WIDTH*50 + 21
.equ GAMEOVER_UI_RESTART_MESSAGE_MARGIN = DISPLAY_WIDTH*57 + 30

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
    ldi ZL, low(2*ui_str_death_retry)
    ldi ZH, high(2*ui_str_death_retry)
    rcall gameover_text
    ldi r25, 80
    ldi YL, low(framebuffer+GAMEOVER_UI_DEATH_MESSAGE_MARGIN+7*DISPLAY_WIDTH)
    ldi YH, high(framebuffer+GAMEOVER_UI_DEATH_MESSAGE_MARGIN+7*DISPLAY_WIDTH)
    ldi ZL, low(2*ui_str_death_restart)
    ldi ZH, high(2*ui_str_death_restart)
    rcall gameover_text
    ret

gameover_render_win:
    ldi ZL, byte3(2*win_screen)
    out RAMPZ, ZL
    ldi ZL, low(2*win_screen)
    ldi ZH, high(2*win_screen)
    lds r25, mode_clock
    cpi r25, 15
    brsh _grw_fade_screen
    sts lightning_clock, r1
    ret
_grw_fade_screen:
    cpi r25, 42
    brsh _grw_hold_screen
    lds r25, lightning_clock
    cpi r25, 61
    brsh _grw_hold_screen
    ldi YL, low(framebuffer)
    ldi YH, high(framebuffer)
    lds r25, lightning_clock
    inc r25
    sts lightning_clock, r25
    ldi r20, 60
    sub r20, r25
    add YL, r20
    adc YH, r1
    ldi r20, 32
    mov r24, r25
    lsr r24
    sub r20, r24
    ldi r21, DISPLAY_WIDTH
    mul r20, r21
    add YL, r0
    adc YH, r1
    clr r1
    ldi r22, 60
    sub r22, r25
    mov r23, r25
    lsl r23
    lsr r25
    ldi r24, 32
    sub r24, r25
    lsl r25
    call render_partial_screen
    ret
_grw_hold_screen:
    call render_full_screen
    sts lightning_clock, r1
    ldi r21, 20
    lds r24, mode_clock
    cpi r24, 80
    brlo _grw_end
_grw_credits:
    call load_credits
_grw_end:
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
