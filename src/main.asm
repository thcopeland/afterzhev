.nolist
.if defined(__atmega2560) || defined(__atmega2561)
.include "m2560def.inc" ; TODO: verify 2561
.elseif defined(__atmega1280) || defined(__atmega1281)
.include "m1280def.inc" ; TODO: verify
.else
.error "Device not supported. Supported devices for After Zhev are ATmega1280/1281 and ATmega2560/2561."
.exit
.endif
.list

.include "vga.inc"
.include "dimensions.inc"
.include "utils.inc"

.cseg
    .org 0x0000
    jmp init
    .org OC1Aaddr
    jmp isr_display_row

.include "init.asm"

main:
    ldi r18, 0xFF
    out DDRA, r18   ; VGA image output
    out DDRB, r18   ; PB6 is VGA HSYNC
    out DDRC, r18   ; debugging
    out DDRE, r18   ; PE4 is VGA VSYNC

    ; init timers
    ; halt all timers
    ldi r18, (1 << TSM) | (1 << PSRASY) | (1 << PSRSYNC)
    out GTCCR, r18

    ; HSYNC
    ; initialize timer 1 to fast PWM (pin PB6)
    sti TCCR1A, (1 << WGM10) | (1 << WGM11) | (1 << COM1B1) | (1 << COM1B0)
    sti TCCR1B, (1 << WGM12) | (1 << WGM13) | (1 << CS10)
    stiw OCR1AL, (HSYNC_PERIOD - 1)
    stiw OCR1BL, (HSYNC_PERIOD - HSYNC_SYNC_WIDTH - 1)
    sti TIMSK1, (1 << OCIE1A)

    ; VSYNC
    ; initialize timer 3 to fast PWM (pin PE4)
    sti TCCR3A, (1 << WGM30) | (1 << WGM31) | (1 << COM3B1) | (1 << COM3B0)
    sti TCCR3B, (1 << WGM32) | (1 << WGM33) | (1 << CS32)
    stiw OCR3AL, (VSYNC_PERIOD - 1)
    stiw OCR3BL, (VSYNC_PERIOD - VSYNC_SYNC_WIDTH - 1)

    ; synchronize timers
    stiw TCNT1L, (HSYNC_PERIOD - 1)
    stiw TCNT3L, (VSYNC_PERIOD - VSYNC_SYNC_WIDTH - 1 - 20*VIRT_ADJUST)

    ; release timers
    out GTCCR, r1
    sei

    ; enable IDLE sleep mode for reliable interrupt timing
    ldi r18, (1 << SE)
    out SMCR, r18
_main_stall:
    sleep
    rjmp _main_stall

; game loop
isr_display_row:
    ; normally, ISRs should be as short as possible and preserve CPU state. Since
    ; everything is done within this ISR, however, that's unnecessary.
    lds r18, TCNT3L
    lds r19, TCNT3H
    cpiw r18, r19, DISPLAY_CLK_TOP, r20
    brpl _idr_active_test2      ; TCNT3 > DISPLAY_CLK_TOP
    rjmp _idr_work
_idr_active_test2:
    cpiw r18, r19, DISPLAY_CLK_BOTTOM, r20
    brlo _idr_active_screen     ; TCNT3 <= DISPLAY_CLK_BOTTOM
    rjmp _idr_work
_idr_active_screen:
    ; output a single row from the framebuffer as quickly as reasonably possible.
    ; The only complication is that every row is drawn a few times (DISPLAY_VERTICAL_STRETCH)
    ; to make the "pixels" square.
    lds XL, sig_fbuff_offset
    lds XH, sig_fbuff_offset+1
    lds r16, sig_current_row
    lds r17, sig_current_row+1
    write_12_pixels PORTA, X
    write_12_pixels PORTA, X
    write_12_pixels PORTA, X
    write_12_pixels PORTA, X
    write_12_pixels PORTA, X
    write_12_pixels PORTA, X
    write_12_pixels PORTA, X
    write_12_pixels PORTA, X
    write_12_pixels PORTA, X
    write_12_pixels PORTA, X
    sts sig_work_complete, r1 ; reset working state (somewhat out of place here, but simple)
    out PORTA, r1
    ; update current row counter
    ; sig_current_row/r16 describes the number of times to left to repeat the row,
    ; while sig_current_row+1/r17 describes the actual row number.
    dec r16
    brpl _idr_quick_work
    sts sig_fbuff_offset, XL
    sts sig_fbuff_offset+1, XH
    ldi r16, DISPLAY_VERTICAL_STRETCH-1
    inc r17
    cpi r17, DISPLAY_HEIGHT-FOOTER_HEIGHT
    brne _idr_quick_work
    ; return to the start of the buffer to render the footer, which should have
    ; been populated during _idr_quick_work.
    ; stiw sig_fbuff_offset, framebuffer
    clr r17
_idr_quick_work:
    ; save the current row information
    sts sig_current_row, r16
    sts sig_current_row+1, r17
    ; After writing a row to the screen, there's a brief period (~75 cycles) where
    ; we can do other work (this corresponds to the VGA front porch and sync pulse).
    ; In particular, we write the footer to the top of the video buffer. No
    ; registers need to be preserved.
    rjmp _idr_end
_idr_work:
    ; check sig_work_complete/r18 (0 - not complete; 1 - work complete)
    lds r18, sig_work_complete
    inc r18
    cpi r18, 1
    brne _idr_reset_render_state
    sts sig_work_complete, r18
    ; At this point, we've rendered a complete image (main image + footer) to the
    ; screen, and there's a fairly long gap (~80,000 cycles) where we fill the
    ; render buffer and update the game. This corresponds to the VGA vertical front
    ; porch and sync pulse, in addition to the time we save with any blank rows
    ; (the latter is the most significant). NOTE: The interrupt period is a mere
    ; 512 cycles, which means several thousand interrupts would ordinarily occur
    ; during this time, but since the necessary VGA signal has already been sent
    ; and interrupts are disabled, we can ignore this as long as we clear any
    ; pending interrupts before reti'ing. No registers need to be preserved.
    .ifdef DEV
    ; heartbeat, toggle PB7 every frame
    in r0, PORTB
    ldi r16, 0x80
    eor r0, r16
    out PORTB, r0
    .endif

    lds r16, tmp_offset
    lds r17, tmp_offset+1
    lds r18, tmp_offset_dir
    cpi r18, 0
    breq _tmp_chk_l_mi
_tmp_chk_l_pl:
    inc r16
    cpi r16, 12
    brmi _tmp_save
    ldi r16, 0
    inc r17
    cpi r17, 10
    brmi _tmp_save
    ldi r18, 0
_tmp_chk_l_mi:
    dec r16
    cpi r16, 0
    brpl _tmp_save
    ldi r16, 11
    dec r17
    cpi r17, 0
    brpl _tmp_save
    clr r16
    clr r17
    ldi r18, 1
_tmp_save:
    sts tmp_offset, r16
    sts tmp_offset+1, r17
    sts tmp_offset_dir, r18
    movw r20, r16
    movw r22, r16
    cpi r23, 5
    brmi _tmp_pass
    ldi r22, 0
    ldi r23, 5
_tmp_pass:
    ldi r24, low(sector_table*2)
    ldi r25, high(sector_table*2)
    call render_sector

_idr_reset_render_state:
    ; prepare to output an image signal
    sts sig_current_row+1, r1
    sti sig_current_row, DISPLAY_VERTICAL_STRETCH
    stiw sig_fbuff_offset, framebuffer
    ; clear any pending interrupts. This is necessary because this ISR can run
    ; far, far longer than the interrupt period.
    sbi TIFR1, OCF1A
_idr_end:
    reti

    .include "render.asm"
    .include "rodata.asm"
    .include "data.asm"
