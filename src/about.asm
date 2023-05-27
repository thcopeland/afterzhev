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
    ldi YL, low(framebuffer + 8 + DISPLAY_WIDTH*4)
    ldi YH, high(framebuffer + 8 + DISPLAY_WIDTH*4)
    ldi ZL, byte3(2*about_str)
    out RAMPZ, ZL
    ldi ZL, low(2*about_str)
    ldi ZH, high(2*about_str)
    ldi r21, 27
    ldi r23, 255
    call puts
    ldi YL, low(framebuffer + 80 + DISPLAY_WIDTH*37)
    ldi YH, high(framebuffer + 80 + DISPLAY_WIDTH*37)
    rcall render_logo
    ret

render_logo:
    ldi ZL, byte3(2*logo_image)
    out RAMPZ, ZL
    ldi ZL, low(2*logo_image)
    ldi ZH, high(2*logo_image)
    ldi r25, 29
_rl_row:
    ldi r24, 22-2
_rl_col:
    elpm r0, Z+
    st Y+, r0
    elpm r0, Z+
    st Y+, r0
    subi r24, 2
    brsh _rl_col
    subi YL, low(-DISPLAY_WIDTH+22)
    sbci YH, high(-DISPLAY_WIDTH+22)
    subi r25, 1
    brsh _rl_row
    ret
