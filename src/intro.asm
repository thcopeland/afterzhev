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
    subi r25, low(-50)
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
    clr r22
    ldi r24, DISPLAY_WIDTH
    ldi r25, DISPLAY_HEIGHT
    ldi XL, low(framebuffer)
    ldi XH, high(framebuffer)
    call render_rect

    ldi r21, 29
    ldi r23, 0x65
    ldi r24, 8
    ldi r25, 53
    ldi YL, low(framebuffer+INTRO_1_MARGIN)
    ldi YH, high(framebuffer+INTRO_1_MARGIN)
    ldi ZL, byte3(2*intro_str_1)
    out RAMPZ, ZL
    ldi ZL, low(2*intro_str_1)
    ldi ZH, high(2*intro_str_1)
    rcall fade_text

    ldi r23, 0x65
    ldi r24, 63
    ldi r25, 98
    ldi YL, low(framebuffer+INTRO_2_MARGIN)
    ldi YH, high(framebuffer+INTRO_2_MARGIN)
    ldi ZL, low(2*intro_str_2)
    ldi ZH, high(2*intro_str_2)
    rcall fade_text

    ldi r23, 0x65
    ldi r24, 108
    ldi r25, 153
    ldi YL, low(framebuffer+INTRO_3_MARGIN)
    ldi YH, high(framebuffer+INTRO_3_MARGIN)
    ldi ZL, low(2*intro_str_3)
    ldi ZH, high(2*intro_str_3)
    rcall fade_text

    ldi r23, 0x65
    ldi r24, 163
    ldi r25, 198
    ldi YL, low(framebuffer+INTRO_4_MARGIN)
    ldi YH, high(framebuffer+INTRO_4_MARGIN)
    ldi ZL, low(2*intro_str_4)
    ldi ZH, high(2*intro_str_4)
    rcall fade_text

    ldi r23, 0x65
    ldi r24, 208
    ldi r25, 247
    ldi YL, low(framebuffer+INTRO_5_MARGIN)
    ldi YH, high(framebuffer+INTRO_5_MARGIN)
    ldi ZL, low(2*intro_str_5)
    ldi ZH, high(2*intro_str_5)
    rcall fade_text
    ret

; Fade in some text, hold it, then fade it out.
;
; Register Usage
;   r20             calculations
;   r21             printing width (param)
;   r22             calculations
;   r23             color (param)
;   r24             fade in time (param)
;   r25             fade out time (param)
;   Y (r28:r29)     framebuffer pointer (param)
;   Z (r30:r31)     text pointer (param)
fade_text:
    lds r20, mode_clock
_ft_fade_in:
    mov r22, r24
    subi r22, 7
    cp r20, r22
    brlo _ft_end
    cp r20, r24
    brsh _ft_fade_out
    sub r24, r20
    fade_color r23, r20, r22, r24
    rjmp _ft_render
_ft_fade_out:
    cp r20, r25
    brlo _ft_render
    mov r22, r25
    subi r22, low(-8)
    cp r20, r22
    brsh _ft_end
    sub r20, r25
    fade_color r23, r25, r22, r20
_ft_render:
    call puts
_ft_end:
    ret
