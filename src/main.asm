.include "device.inc"
.include "vga.inc"
.include "utils.inc"
.include "dimensions.inc"
.include "gamedefs.inc"

.cseg
    .org 0x0000
    jmp init
    .org OC1Aaddr
    jmp isr_display_row

.include "init.asm"

main:
    ldi r18, 0xFF
    ldi r19, 0x00
    out DDRA, r18   ; VGA image output
    out DDRB, r18   ; PB6 is VGA HSYNC
    out DDRE, r18   ; PE4 is VGA VSYNC
    out DDRC, r19   ; controls
    out PORTC, r18  ; pull-up (?)

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

isr_display_row:
    ; normally, ISRs should be as short as possible and preserve CPU state. Since
    ; everything is done within this ISR, however, that's unnecessary.
    lds r18, TCNT3L
    lds r19, TCNT3H
    cpiw r18, r19, DISPLAY_CLK_TOP, r20
    brpl _idr_active_test2
    rjmp _idr_work
_idr_active_test2:
    cpiw r18, r19, DISPLAY_CLK_BOTTOM, r20
    brlo _idr_active_screen
    rjmp _idr_work
_idr_active_screen:
    ; output a single row from the framebuffer as quickly as reasonably possible.
    lds XL, vid_fbuff_offset
    lds XH, vid_fbuff_offset+1
    lds r16, vid_row_repeat
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
    sts vid_work_complete, r1 ; reset working state (somewhat out of place here, but simple)
    out PORTA, r1
    dec r16
    brpl _idr_quick_work
    sts vid_fbuff_offset, XL
    sts vid_fbuff_offset+1, XH
    ldi r16, DISPLAY_VERTICAL_STRETCH-1
_idr_quick_work:
    sts vid_row_repeat, r16
    ; After writing a row to the screen, there's a brief period (~75 cycles) where
    ; we can do other work (this corresponds to the VGA front porch and sync pulse).
    ; In particular, we write the footer to the top of the video buffer. No
    ; registers need to be preserved.
    rjmp _idr_end
_idr_work:
    lds r18, vid_work_complete
    inc r18
    cpi r18, 1
    brne _idr_reset_render_state
    sts vid_work_complete, r18
    ; At this point, we've rendered a complete image (main image + footer) to the
    ; screen, and there's a fairly long gap (~99,300 cycles) where we fill the
    ; render buffer and update the game. This corresponds to the VGA vertical front
    ; porch and sync pulse, in addition to the time we save with any blank rows
    ; (the latter is the most significant). NOTE: The interrupt period is a mere
    ; 512 cycles, which means several thousand interrupts would ordinarily occur
    ; during this time, but since the necessary VGA signal has already been sent
    ; and interrupts are disabled, we can ignore this as long as we clear any
    ; pending interrupts before reti'ing. No registers need to be preserved.
    .ifdef DEV
    ; heartbeat
    in r0, PORTB
    ldi r16, 0x80
    eor r0, r16
    out PORTB, r0
    .endif

    lds r24, clock
    lds r25, clock+1
    adiw r24, 1
    sts clock, r24
    sts clock+1, r25

    call read_controls
    lds r18, game_mode
    cpi r18, MODE_EXPLORE
    breq _idr_explore
    cpi r18, MODE_INVENTORY
    breq _idr_inventory
_idr_shop:
    call shop_update_game
    rjmp _idr_end_work
_idr_inventory:
    call inventory_update_game
    rjmp _idr_end_work
_idr_explore:
    call explore_update_game
    rjmp _idr_end_work
_idr_end_work:

_idr_reset_render_state:
    sti vid_row_repeat, DISPLAY_VERTICAL_STRETCH
    stiw vid_fbuff_offset, framebuffer
    sbi TIFR1, OCF1A ; clear any pending interrupts
_idr_end:
    reti

.include "math.asm"
.include "controls.asm"
.include "animation.asm"
.include "character.asm"
.include "render.asm"
.include "stats.asm"
.include "explore.asm"
.include "inventory.asm"
.include "shop.asm"
.include "rodata.asm"
.include "data.asm"
