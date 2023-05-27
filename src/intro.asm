load_intro:
    ldi r25, MODE_INTRO
    sts game_mode, r25
    sts mode_clock, r1
    ret

intro_update_game:
    call update_sound_effects
    rcall intro_render
    rcall intro_handle_controls

    lds r25, clock
    andi r25, 0x03
    brne _iug_end
    lds r25, mode_clock
    subi r25, low(-1)
    sts mode_clock, r25
    cpi r25, 254
    brlo _iug_end
    call init_game_state
    call load_explore
_iug_end:
    jmp _loop_reenter

intro_handle_controls:
    lds r25, controller_values
    tst r25
    breq _inhc_end
    lds r25, mode_clock
    subi r25, low(-2)
    cpi r25, 254
    brlo _inhc_save_clock
    ldi r25, 244
_inhc_save_clock:
    sts mode_clock, r25
_inhc_end:
    ret

.equ INTRO_TEXT_MARGIN = 5 + DISPLAY_WIDTH*52

intro_render:
    lds r25, mode_clock
    cpi r25, 244
    brlo _ir_main
    call screen_fade_out
    ret
_ir_main:
    ldi ZL, byte3(2*intro_screen)
    out RAMPZ, ZL
    ldi ZL, low(2*intro_screen)
    ldi ZH, high(2*intro_screen)
    call render_full_screen
    ldi r21, 29
    ldi r23, 0x6e
    ldi r24, 20
    ldi r25, 52
    ldi YL, low(framebuffer+INTRO_TEXT_MARGIN)
    ldi YH, high(framebuffer+INTRO_TEXT_MARGIN)
    ldi ZL, byte3(2*intro_str_1)
    out RAMPZ, ZL
    ldi ZL, low(2*intro_str_1)
    ldi ZH, high(2*intro_str_1)
    call fade_text_inverse
    ldi r23, 0x6e
    ldi r24, 68
    ldi r25, 100
    ldi YL, low(framebuffer+INTRO_TEXT_MARGIN)
    ldi YH, high(framebuffer+INTRO_TEXT_MARGIN)
    ldi ZL, low(2*intro_str_2)
    ldi ZH, high(2*intro_str_2)
    call fade_text_inverse
    ldi r23, 0x6e
    ldi r24, 116
    ldi r25, 148
    ldi YL, low(framebuffer+INTRO_TEXT_MARGIN)
    ldi YH, high(framebuffer+INTRO_TEXT_MARGIN)
    ldi ZL, low(2*intro_str_3)
    ldi ZH, high(2*intro_str_3)
    call fade_text_inverse
    ldi r23, 0x6e
    ldi r24, 164
    ldi r25, 196
    ldi YL, low(framebuffer+INTRO_TEXT_MARGIN)
    ldi YH, high(framebuffer+INTRO_TEXT_MARGIN)
    ldi ZL, low(2*intro_str_4)
    ldi ZH, high(2*intro_str_4)
    call fade_text_inverse
    ldi r23, 0x6e
    ldi r24, 212
    ldi r25, 244
    ldi YL, low(framebuffer+INTRO_TEXT_MARGIN)
    ldi YH, high(framebuffer+INTRO_TEXT_MARGIN)
    ldi ZL, low(2*intro_str_5)
    ldi ZH, high(2*intro_str_5)
    call fade_text_inverse
    ret
