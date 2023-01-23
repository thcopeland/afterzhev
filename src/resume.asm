load_resume:
    ldi r25, MODE_RESUME
    sts game_mode, r25
    sts sector_data, r1
    ret

resume_update_game:
    rcall resume_render
    rcall resume_try_load_save
    rcall resume_handle_controls
    jmp _loop_reenter

resume_try_load_save:
    lds r25, sector_data
    tst r25
    brne _rtls_end
    call restore_from_savepoint
    tst r25
    breq _rtls_end
_rtls_no_saves:
    sts sector_data, r25
_rtls_end:
    ret

resume_handle_controls:
    lds r24, prev_controller_values
    lds r25, controller_values
    com r24
    and r24, r25
    breq _rhc_end
    call restart_game
_rhc_end:
    ret

resume_render:
    clr r22
    ldi r24, DISPLAY_WIDTH
    ldi r25, DISPLAY_HEIGHT
    ldi XL, low(framebuffer)
    ldi XH, high(framebuffer)
    call render_rect
_rr_check_status:
    lds r25, sector_data
    tst r25
    breq _rr_end
_rr_no_resume:
    ldi YL, low(framebuffer + 4 + 3*DISPLAY_WIDTH)
    ldi YH, high(framebuffer + 4 + 3*DISPLAY_WIDTH)
    ldi r21, 29
    ldi r23, 0xff
    ldi ZL, byte3(2*ui_str_no_save)
    out RAMPZ, ZL
    ldi ZL, low(2*ui_str_no_save)
    ldi ZH, high(2*ui_str_no_save)
    call puts
_rr_end:
    ret
