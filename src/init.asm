init:
    clr r1
_clear_memory:
    ldi XL, low(framebuffer + DISPLAY_WIDTH*DISPLAY_HEIGHT)
    ldi XH, high(framebuffer + DISPLAY_WIDTH*DISPLAY_HEIGHT)
    ldi r24, low(RAMEND - (framebuffer + DISPLAY_WIDTH*DISPLAY_HEIGHT))
    ldi r25, high(RAMEND - (framebuffer + DISPLAY_WIDTH*DISPLAY_HEIGHT))
_clear_memory_loop:
    st X+, r1
    sbiw r24, 1
    brne _clear_memory_loop
_init_video:
    ldi r24, low(framebuffer)
    ldi r25, high(framebuffer)
    out GPIOR0, r24 ; stores the video framebuffer offset (low)
    out GPIOR1, r25 ; stores the video framebuffer offset (high)
    out GPIOR2, r1  ; video frame status
_init_audio:
    sts audio_state, r1
    sts channel1_dphase, r1
    sts channel1_dphase+1, r1
    sts channel1_volume, r1
    sts channel1_wave, r1
    sts channel2_dphase, r1
    sts channel2_dphase+1, r1
    sts channel2_volume, r1
    sts channel2_wave, r1
    ldi r24, low(2*music_null)
    ldi r25, high(2*music_null)
    sts music_track, r24
    sts music_track+1, r25
    sts music_track+2, r24
    sts music_track+3, r25
    sts sfx_track, r1
    sts sfx_track+1, r1
_init_random:
    ldi r25, 1
    mov r2, r25
    clr r3
_init_game:
    sts start_selection, r1
    call restart_game
    rjmp main
