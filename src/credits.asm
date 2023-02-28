credits_update:
    lds r25, clock
    andi r25, 0x07
    brne _cu_main
    lds r25, mode_clock
    inc r25
    cpi r25, 220
    brsh _cu_main
    sts mode_clock, r25
_cu_main:
    rcall credits_render
    rcall credits_handle_controls
    rcall credits_render
    jmp _loop_reenter

; Switch to the inventory game mode.
;
; Register Usage
;   r25     temporary value
load_credits:
    ldi r25, MODE_CREDITS
    sts game_mode, r25
    sts mode_clock, r1
    ret

credits_handle_controls:
    lds r24, prev_controller_values
    lds r25, controller_values
    com r24
    and r25, r24
    andi r25, (1<<CONTROLS_SPECIAL1)|(1<<CONTROLS_SPECIAL2)|(1<<CONTROLS_SPECIAL3)|(1<<CONTROLS_SPECIAL4)
    breq _crc_end
    sts start_selection, r1
    call restart_game
_crc_end:
    ret

credits_render:
    ldi ZL, byte3(2*win_screen)
    out RAMPZ, ZL
    ldi ZL, low(2*win_screen)
    ldi ZH, high(2*win_screen)
    call render_full_screen

    ldi r21, 28
    ldi YL, low(framebuffer+22)
    ldi YH, high(framebuffer+22)
    ldi ZL, byte3(2*ui_credits_congrats)
    out RAMPZ, ZL
    ldi ZL, low(2*ui_credits_congrats)
    ldi ZH, high(2*ui_credits_congrats)
    ldi r25, 0
    rcall scrolling_text

    ldi YL, low(framebuffer+46)
    ldi YH, high(framebuffer+46)
    ldi ZL, low(2*ui_credits_1)
    ldi ZH, high(2*ui_credits_1)
    ldi r25, 40
    rcall scrolling_text
    ldi YL, low(framebuffer+36)
    ldi YH, high(framebuffer+36)
    ldi ZL, low(2*ui_credits_2)
    ldi ZH, high(2*ui_credits_2)
    ldi r25, 50
    rcall scrolling_text

    ldi YL, low(framebuffer+48)
    ldi YH, high(framebuffer+48)
    ldi ZL, low(2*ui_credits_3)
    ldi ZH, high(2*ui_credits_3)
    ldi r25, 70
    rcall scrolling_text
    ldi YL, low(framebuffer+36)
    ldi YH, high(framebuffer+36)
    ldi ZL, low(2*ui_credits_4)
    ldi ZH, high(2*ui_credits_4)
    ldi r25, 80
    rcall scrolling_text

    ldi YL, low(framebuffer+46)
    ldi YH, high(framebuffer+46)
    ldi ZL, low(2*ui_credits_5)
    ldi ZH, high(2*ui_credits_5)
    ldi r25, 100
    rcall scrolling_text
    ldi YL, low(framebuffer+33)
    ldi YH, high(framebuffer+33)
    ldi ZL, low(2*ui_credits_6)
    ldi ZH, high(2*ui_credits_6)
    ldi r25, 110
    rcall scrolling_text
    ldi YL, low(framebuffer+41)
    ldi YH, high(framebuffer+41)
    ldi ZL, low(2*ui_credits_7)
    ldi ZH, high(2*ui_credits_7)
    ldi r25, 120
    rcall scrolling_text

    ldi YL, low(framebuffer+38)
    ldi YH, high(framebuffer+38)
    ldi ZL, low(2*ui_credits_8)
    ldi ZH, high(2*ui_credits_8)
    ldi r25, 140
    rcall scrolling_text
    ldi YL, low(framebuffer+34)
    ldi YH, high(framebuffer+34)
    ldi ZL, low(2*ui_credits_9)
    ldi ZH, high(2*ui_credits_9)
    ldi r25, 150
    rcall scrolling_text

    ldi YL, low(framebuffer+25)
    ldi YH, high(framebuffer+25)
    ldi ZL, low(2*ui_credits_10)
    ldi ZH, high(2*ui_credits_10)
    ldi r25, 190
    rcall scrolling_text

    ret


; Write a line of scrolling text, outlined in black. Only one line is supported
; for simplicity.
;
; Register Usage
;   r25             enter time (param)
;   Y (r28:r29)     framebuffer pointer (param)
;   Z (r30:r31)     string flash pointer (param)
scrolling_text:
    lds r24, mode_clock
    sub r25, r24
    brsh _st_end
_st_nick:
    subi r25, low(-DISPLAY_HEIGHT+FONT_DISPLAY_HEIGHT+2)
    brlo _st_end
    inc r25
    ldi r24, DISPLAY_WIDTH
    mul r24, r25
    add YL, r0
    adc YH, r1
    clr r1
    rcall puts_outlined
_st_end:
    ret

; Write a string to the framebuffer, outlined in black. Done by drawing the text
; nine times, which is not particularly efficient but sure is easy.
;
; Register Usage
;   Y (r28:r29)     framebuffer pointer (param)
;   Z (r30:r31)     string flash pointer (param)
puts_outlined:
    sts subroutine_tmp, YL
    sts subroutine_tmp+1, YH
    sts subroutine_tmp+2, ZL
    sts subroutine_tmp+3, ZH
    clr r23
    subi YL, low(DISPLAY_WIDTH+1)
    sbci YH, high(DISPLAY_WIDTH+1)
    call puts
    lds YL, subroutine_tmp
    lds YH, subroutine_tmp+1
    lds ZL, subroutine_tmp+2
    lds ZH, subroutine_tmp+3
    subi YL, low(DISPLAY_WIDTH)
    sbci YH, high(DISPLAY_WIDTH)
    call puts
    lds YL, subroutine_tmp
    lds YH, subroutine_tmp+1
    lds ZL, subroutine_tmp+2
    lds ZH, subroutine_tmp+3
    subi YL, low(DISPLAY_WIDTH-1)
    sbci YH, high(DISPLAY_WIDTH-1)
    call puts
    lds YL, subroutine_tmp
    lds YH, subroutine_tmp+1
    lds ZL, subroutine_tmp+2
    lds ZH, subroutine_tmp+3
    sbiw YL, 1
    call puts
    lds YL, subroutine_tmp
    lds YH, subroutine_tmp+1
    lds ZL, subroutine_tmp+2
    lds ZH, subroutine_tmp+3
    call puts
    lds YL, subroutine_tmp
    lds YH, subroutine_tmp+1
    lds ZL, subroutine_tmp+2
    lds ZH, subroutine_tmp+3
    adiw YL, 1
    call puts
    lds YL, subroutine_tmp
    lds YH, subroutine_tmp+1
    lds ZL, subroutine_tmp+2
    lds ZH, subroutine_tmp+3
    subi YL, low(-DISPLAY_WIDTH-1)
    sbci YH, high(-DISPLAY_WIDTH-1)
    call puts
    lds YL, subroutine_tmp
    lds YH, subroutine_tmp+1
    lds ZL, subroutine_tmp+2
    lds ZH, subroutine_tmp+3
    subi YL, low(-DISPLAY_WIDTH)
    sbci YH, high(-DISPLAY_WIDTH)
    call puts
    lds YL, subroutine_tmp
    lds YH, subroutine_tmp+1
    lds ZL, subroutine_tmp+2
    lds ZH, subroutine_tmp+3
    subi YL, low(-DISPLAY_WIDTH+1)
    sbci YH, high(-DISPLAY_WIDTH+1)
    call puts
    lds YL, subroutine_tmp
    lds YH, subroutine_tmp+1
    lds ZL, subroutine_tmp+2
    lds ZH, subroutine_tmp+3
    ldi r23, 0xff
    call puts
    ret
