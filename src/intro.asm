load_intro:
    ldi r25, MODE_INTRO
    sts game_mode, r25
    sts mode_clock, r1
    ret

intro_update_game:
    rcall intro_render
    rcall intro_handle_controls

    lds r25, clock
    andi r25, 0x03
    brne _iug_end
    lds r25, mode_clock
    subi r25, low(-1)
    sts mode_clock, r25
    brcs _iug_end
    ldi r25, MODE_EXPLORE
    sts game_mode, r25
_iug_end:
    jmp _loop_reenter

intro_handle_controls:
    lds r24, prev_controller_values
    lds r25, controller_values
    com r24
    and r24, r25
    breq _inhc_end
    lds r25, mode_clock
    subi r25, low(-30)
    brcc _inhc_end
    sts mode_clock, r25
_inhc_end:
    ret

.equ INTRO_1_MARGIN = 10 + DISPLAY_WIDTH*6
.equ INTRO_2_MARGIN = 12 + DISPLAY_WIDTH*16
.equ INTRO_3_MARGIN = 6 + DISPLAY_WIDTH*26
.equ INTRO_4_MARGIN = 5 + DISPLAY_WIDTH*36
.equ INTRO_5_MARGIN = 8 + DISPLAY_WIDTH*46

intro_render:
    ldi ZL, byte3(2*parchment_screen)
    out RAMPZ, ZL
    ldi ZL, low(2*parchment_screen)
    ldi ZH, high(2*parchment_screen)
    call render_full_screen
    ldi r21, 29
    ldi r23, 0x6e
    ldi r24, 20
    ldi r25, 52
    ldi YL, low(framebuffer+INTRO_1_MARGIN)
    ldi YH, high(framebuffer+INTRO_1_MARGIN)
    ldi ZL, byte3(2*intro_str_1)
    out RAMPZ, ZL
    ldi ZL, low(2*intro_str_1)
    ldi ZH, high(2*intro_str_1)
    call fade_text_inverse
    ldi r23, 0x6e
    ldi r24, 64
    ldi r25, 96
    ldi YL, low(framebuffer+INTRO_2_MARGIN)
    ldi YH, high(framebuffer+INTRO_2_MARGIN)
    ldi ZL, low(2*intro_str_2)
    ldi ZH, high(2*intro_str_2)
    call fade_text_inverse
    ldi r23, 0x6e
    ldi r24, 108
    ldi r25, 140
    ldi YL, low(framebuffer+INTRO_3_MARGIN)
    ldi YH, high(framebuffer+INTRO_3_MARGIN)
    ldi ZL, low(2*intro_str_3)
    ldi ZH, high(2*intro_str_3)
    call fade_text_inverse
    ldi r23, 0x6e
    ldi r24, 152
    ldi r25, 184
    ldi YL, low(framebuffer+INTRO_4_MARGIN)
    ldi YH, high(framebuffer+INTRO_4_MARGIN)
    ldi ZL, low(2*intro_str_4)
    ldi ZH, high(2*intro_str_4)
    call fade_text_inverse
    ldi r23, 0x6e
    ldi r24, 196
    ldi r25, 228
    ldi YL, low(framebuffer+INTRO_5_MARGIN)
    ldi YH, high(framebuffer+INTRO_5_MARGIN)
    ldi ZL, low(2*intro_str_5)
    ldi ZH, high(2*intro_str_5)
    call fade_text_inverse
    ret
