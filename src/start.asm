restart_game:
    ldi r25, MODE_START
    sts game_mode, r25
    sts mode_clock, r1
    sts clock, r1
    sts clock+1, r1
    sts clock+2, r1
    lds r25, start_selection
    andi r25, 0x03
    sts start_selection, r25
    ldi r24, low(2*music_start_channel_1)
    ldi r25, high(2*music_start_channel_1)
    sts music_track, r24
    sts music_track+1, r25
    ldi r24, low(2*music_start_channel_2)
    ldi r25, high(2*music_start_channel_2)
    sts music_track+2, r24
    sts music_track+3, r25
    sts sfx_track, r1
    sts sfx_track+1, r1
    ret

start_update_game:
    call update_music
    lds r25, mode_clock
    tst r25
    breq _sug_main
    inc r25
    cpi r25, 16
    brlo _sug_fading
    rcall start_change
    rjmp _sug_end
_sug_fading:
    sts mode_clock, r25
    rcall screen_fade_out
    rjmp _sug_end
_sug_main:
    rcall start_render_screen
    rcall start_handle_controls
_sug_end:
    jmp _loop_reenter

.equ TITLE_START_MARGIN = 40 + DISPLAY_WIDTH*51
.equ TITLE_RESUME_MARGIN = 66 + DISPLAY_WIDTH*51
.equ TITLE_HELP_MARGIN = TITLE_START_MARGIN + DISPLAY_WIDTH*8 - 4
.equ TITLE_ABOUT_MARGIN = TITLE_RESUME_MARGIN + DISPLAY_WIDTH*8 + 8

start_render_screen:
    ldi YL, low(framebuffer)
    ldi YH, high(framebuffer)
    ldi ZL, byte3(2*title_screen)
    out RAMPZ, ZL
    ldi ZL, low(2*title_screen)
    ldi ZH, high(2*title_screen)
    call render_full_screen
_srs_start_option:
    ldi YL, low(framebuffer + TITLE_START_MARGIN)
    ldi YH, high(framebuffer + TITLE_START_MARGIN)
    ldi r21, 20
    ldi r23, 0x04
    ldi r24, 0
    lds r25, start_selection
    cpse r25, r24
    clr r23
    ldi ZL, byte3(2*ui_str_start)
    out RAMPZ, ZL
    ldi ZL, low(2*ui_str_start)
    ldi ZH, high(2*ui_str_start)
    call puts
_srs_resume_option:
    ldi YL, low(framebuffer + TITLE_RESUME_MARGIN)
    ldi YH, high(framebuffer + TITLE_RESUME_MARGIN)
    ldi r23, 0x04
    ldi r24, 1
    lds r25, start_selection
    cpse r25, r24
    clr r23
    ldi ZL, low(2*ui_str_resume)
    ldi ZH, high(2*ui_str_resume)
    call puts
_srs_help_option:
    ldi YL, low(framebuffer + TITLE_HELP_MARGIN)
    ldi YH, high(framebuffer + TITLE_HELP_MARGIN)
    ldi r23, 0x04
    ldi r24, 2
    lds r25, start_selection
    cpse r25, r24
    clr r23
    ldi ZL, low(2*ui_str_help)
    ldi ZH, high(2*ui_str_help)
    call puts
_srs_about_option:
    ldi YL, low(framebuffer + TITLE_ABOUT_MARGIN)
    ldi YH, high(framebuffer + TITLE_ABOUT_MARGIN)
    ldi r23, 0x04
    ldi r24, 3
    lds r25, start_selection
    cpse r25, r24
    clr r23
    ldi ZL, low(2*ui_str_about)
    ldi ZH, high(2*ui_str_about)
    call puts
    ret

screen_fade_out:
    lds r25, clock
    andi r25, 0x1
    brne _sfo_end
    ldi YL, low(framebuffer)
    ldi YH, high(framebuffer)
    ldi XL, low(2*fade_table)
    ldi XH, high(2*fade_table)
    ldi r24, low(DISPLAY_WIDTH*DISPLAY_HEIGHT-2)
    ldi r25, high(DISPLAY_WIDTH*DISPLAY_HEIGHT-2)
_sfo_loop:
    ld r0, Y
    movw ZL, XL
    add ZL, r0
    lpm r0, Z
    st Y+, r0
    ld r0, Y
    movw ZL, XL
    add ZL, r0
    lpm r0, Z
    st Y+, r0
    sbiw r24, 2
    brsh _sfo_loop
_sfo_end:
    ret

start_handle_controls:
    lds r20, prev_controller_values
    lds r21, controller_values
    com r20
    and r20, r21
_sthc_check_keys:
    lds r25, start_selection
    sbrc r20, CONTROLS_UP
    subi r25, 2
    sbrc r20, CONTROLS_DOWN
    subi r25, low(-2)
    sbrc r20, CONTROLS_LEFT
    subi r25, 1
    sbrc r20, CONTROLS_RIGHT
    subi r25, low(-1)
    cpi r25, 4
    brsh _sthc_check_submit
    sts start_selection, r25
_sthc_check_submit:
    andi r20, exp2(CONTROLS_SPECIAL1)|exp2(CONTROLS_SPECIAL2)|exp2(CONTROLS_SPECIAL3)|exp2(CONTROLS_SPECIAL4)
    breq _sthc_end
    ldi r25, 1
    sts mode_clock, r25
_sthc_end:
    ret

start_change:
    ; fade the music out
    lds r25, channel1_wave
    ori r25, SFX_FADE_OUT|15
    sts channel1_wave, r25
    lds r25, channel2_wave
    ori r25, SFX_FADE_OUT|15
    sts channel2_wave, r25
    lds r25, start_selection
_sc_check_resume:
    cpi r25, 1
    brne _sc_check_controls
    call load_resume
    ret
_sc_check_controls:
    cpi r25, 2
    brne _sc_check_about
    call load_controls
    ret
_sc_check_about:
    cpi r25, 3
    brne _sc_fallback_start
    call load_about
    ret
_sc_fallback_start:
    call load_character_selection
    ret
