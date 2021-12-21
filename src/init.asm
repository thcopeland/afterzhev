init:
    clr r1
    stiw sig_fbuff_offset, framebuffer
    sti sig_current_row, DISPLAY_VERTICAL_STRETCH
    sti sig_current_row+1, 0
    sti sig_work_complete, 0

    ; init framebuffer
    ldi r23, 0
    ldi r24, low(120*60)
    ldi r25, high(120*60)
    ldi XL, low(framebuffer)
    ldi XH, high(framebuffer)
_init_lp:
    st X+, r23
    inc r23
    ; st X+, r1
    ; st X+, r1
    ; st X+, r1
    ; st X+, r1
_init_chk:
    sbiw r24, 1
    brne _init_lp

    rjmp main