.nolist
.include "m2560def.inc"
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
    ldi r18, (1 << WGM10) | (1 << WGM11) | (1 << COM1B1) | (1 << COM1B0)
    ldi r19, (1 << WGM12) | (1 << WGM13) | (1 << CS10)
    sts TCCR1A, r18
    sts TCCR1B, r19
    stiw OCR1AL, (HSYNC_PERIOD - 1)
    stiw OCR1BL, (HSYNC_PERIOD - HSYNC_SYNC_WIDTH - 1)
    ldi r18, (1 << OCIE1A)
    sts TIMSK1, r18

    ; VSYNC
    ; initialize timer 3 to fast PWM (pin PE4)
    ldi r18, (1 << WGM30) | (1 << WGM31) | (1 << COM3B1) | (1 << COM3B0)
    ldi r19, (1 << WGM32) | (1 << WGM33) | (1 << CS32)
    sts TCCR3A, r18
    sts TCCR3B, r19
    stiw OCR3AL, (VSYNC_PERIOD - 1)
    stiw OCR3BL, (VSYNC_PERIOD - VSYNC_SYNC_WIDTH - 1)

    ; synchronize timers
    stiw TCNT1L, (HSYNC_PERIOD - 1)
    stiw TCNT3L, (VSYNC_PERIOD - VSYNC_SYNC_WIDTH - 1 - 20*VIRT_ADJUST)

    ; release timers
    out GTCCR, r1

    ; enable IDLE sleep mode
    ldi r18, (1 << SE)
    out SMCR, r18

    sei
_stall:
    sleep
    rjmp _stall

; game loop
isr_display_row:
    ; normally, ISRs should be as short as possible and preserve CPU state. Since
    ; everything is done within this ISR, however, that's unnecessary.
    lds r18, TCNT3L
    lds r19, TCNT3H
    cpiw r18, r19, DISPLAY_CLK_TOP, r20
    brlo _idr_done
    cpiw r18, r19, DISPLAY_CLK_BOTTOM, r20
    brpl _idr_done
_idr_active_screen: ; TCNT3 > DISPLAY_CLK_TOP && TCNT3 <= DISPLAY_CLK_BOTTOM
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ldi r18, 0x2F
    out PORTA, r18
_loop:
    dec r18
    out PORTA, r18
    brne _loop
_loop_end:
    out PORTA, r1

_idr_done:
    reti
