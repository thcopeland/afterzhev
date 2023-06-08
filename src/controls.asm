load_controls:
    ldi r25, MODE_CONTROLS
    sts game_mode, r25
    sts sector_data, r1
    sts mode_clock, r1
    ret

controls_update:
    rcall controls_render_game
    rcall controls_handle_controls
    jmp _loop_reenter

controls_handle_controls:
    lds r24, prev_controller_values
    lds r25, controller_values
    com r24
    and r25, r24
    andi r25, (1<<CONTROLS_SPECIAL1)|(1<<CONTROLS_SPECIAL2)|(1<<CONTROLS_SPECIAL3)|(1<<CONTROLS_SPECIAL4)
    breq _chc2_end
    call restart_game
_chc2_end:
    ret

controls_render_game:
.if TARGETING_MCU
    ldi r24, 62
    ldi r25, 25
    ldi XL, low(framebuffer + DISPLAY_WIDTH*2 + (DISPLAY_WIDTH-62)/2)
    ldi XH, high(framebuffer + DISPLAY_WIDTH*2 + (DISPLAY_WIDTH-62)/2)
    ldi ZL, byte3(2*image_controller_nes)
    out RAMPZ, ZL
    ldi ZL, low(2*image_controller_nes)
    ldi ZH, high(2*image_controller_nes)
    call render_element
.else
    ldi r24, 94
    ldi r25, 22
    ldi XL, low(framebuffer + DISPLAY_WIDTH*2 + (DISPLAY_WIDTH-94)/2)
    ldi XH, high(framebuffer + DISPLAY_WIDTH*2 + (DISPLAY_WIDTH-94)/2)
    ldi ZL, byte3(2*image_controller_keyboard)
    out RAMPZ, ZL
    ldi ZL, low(2*image_controller_keyboard)
    ldi ZH, high(2*image_controller_keyboard)
    call render_element
.endif
    ldi r21, 30
    ldi r23, 0xff
    ldi YL, low(framebuffer + DISPLAY_WIDTH*30 + 4)
    ldi YH, high(framebuffer + DISPLAY_WIDTH*30 + 4)
    ldi ZL, byte3(2*controls_line1_str)
    out RAMPZ, ZL
    ldi ZL, low(2*controls_line1_str)
    ldi ZH, high(2*controls_line1_str)
    call puts
    ldi YL, low(framebuffer + DISPLAY_WIDTH*37 + 4)
    ldi YH, high(framebuffer + DISPLAY_WIDTH*37 + 4)
    ldi ZL, low(2*controls_line2_str)
    ldi ZH, high(2*controls_line2_str)
    call puts
    ldi YL, low(framebuffer + DISPLAY_WIDTH*44 + 4)
    ldi YH, high(framebuffer + DISPLAY_WIDTH*44 + 4)
    ldi ZL, low(2*controls_line3_str)
    ldi ZH, high(2*controls_line3_str)
    call puts
    ldi YL, low(framebuffer + DISPLAY_WIDTH*51 + 4)
    ldi YH, high(framebuffer + DISPLAY_WIDTH*51 + 4)
    ldi ZL, low(2*controls_line4_str)
    ldi ZH, high(2*controls_line4_str)
    call puts
    ldi YL, low(framebuffer + DISPLAY_WIDTH*58 + 4)
    ldi YH, high(framebuffer + DISPLAY_WIDTH*58 + 4)
    ldi ZL, low(2*controls_line5_str)
    ldi ZH, high(2*controls_line5_str)
    call puts
    ret
