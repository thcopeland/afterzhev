.nolist
.include "m2560def.inc"
.list

.include "vga.inc"
.include "utils.inc"

.cseg
    .org 0x0000
    jmp init

init:
    clr r1
    rjmp main
main:
    ; init IO ports
    ldi r18, 0xFF
    out DDRA, r18
    out DDRB, r18
    out DDRC, r18
    out DDRE, r18

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
    ldi r18, low(HSYNC_PERIOD - 1)
    ldi r19, high(HSYNC_PERIOD - 1)
    sts OCR1AH, r19
    sts OCR1AL, r18
    ldi r18, low(HSYNC_PERIOD - HSYNC_SYNC_WIDTH - 1)
    ldi r19, high(HSYNC_PERIOD - HSYNC_SYNC_WIDTH - 1)
    sts OCR1BH, r19
    sts OCR1BL, r18
    ; ldi r18, (1 << OCIE1A)
    ; sts TIMSK1, r18

    ; VSYNC
    ; initialize timer 3 to fast PWM (pin PE4)
    ldi r18, (1 << WGM30) | (1 << WGM31) | (1 << COM3B1) | (1 << COM3B0)
    ldi r19, (1 << WGM32) | (1 << WGM33) | (1 << CS32)
    sts TCCR3A, r18
    sts TCCR3B, r19
    ldi r18, low(VSYNC_PERIOD - 1)
    ldi r19, high(VSYNC_PERIOD - 1)
    sts OCR3AH, r19
    sts OCR3AL, r18
    ldi r18, low(VSYNC_PERIOD - VSYNC_SYNC_WIDTH - 1)
    ldi r19, high(VSYNC_PERIOD - VSYNC_SYNC_WIDTH - 1)
    sts OCR3BH, r19
    sts OCR3BL, r18

    ; synchronize timers
    ldi r18, low(HSYNC_PERIOD - 1)
    ldi r19, high(HSYNC_PERIOD - 1)
    sts TCNT1H, r19
    sts TCNT1L, r18

    ldi r18, low(VSYNC_PERIOD - VSYNC_SYNC_WIDTH - 1 - 20*VIRT_ADJUST)
    ldi r19, high(VSYNC_PERIOD - VSYNC_SYNC_WIDTH - 1 - 20*VIRT_ADJUST)
    sts TCNT3H, r19
    sts TCNT3L, r18

    ; release timers
    out GTCCR, r1

    sei
stall:
    sleep
    jmp stall
