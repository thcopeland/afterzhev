load_about:
    ldi r25, MODE_ABOUT
    sts game_mode, r25
    ret

about_update:
    call update_sound_effects
    rcall about_render
    rcall about_handle_controls
    jmp _loop_reenter

about_handle_controls:
    lds r20, prev_controller_values
    lds r21, controller_values
    com r20
    and r20, r21
    andi r20, (1<<CONTROLS_SPECIAL1)|(1<<CONTROLS_SPECIAL2)|(1<<CONTROLS_SPECIAL3)|(1<<CONTROLS_SPECIAL4)
    breq _ahc_end
    call restart_game
_ahc_end:
    ret

about_render:
    clr r22
    ldi r24, DISPLAY_WIDTH
    ldi r25, DISPLAY_HEIGHT
    ldi XL, low(framebuffer)
    ldi XH, high(framebuffer)
    call render_rect
    ldi YL, low(framebuffer + 9 + DISPLAY_WIDTH*3)
    ldi YH, high(framebuffer + 9 + DISPLAY_WIDTH*3)
    ldi ZL, byte3(2*about_str)
    out RAMPZ, ZL
    ldi ZL, low(2*about_str)
    ldi ZH, high(2*about_str)
    ldi r21, 27
    ldi r23, 255
    call puts
    ret
