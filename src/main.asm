.include "device.asm"
.include "vga.asm"
.include "utils.asm"
.include "layout.asm"
.include "gamedefs.asm"

.cseg
    .org 0x0000
    jmp init
    .org OC1Aaddr
    jmp isr_loop

.include "init.asm"

main:
    ldi r18, 0xFF
    ldi r19, 0x00
    out DDRA, r18   ; VGA image output
    out DDRB, r18   ; PB6 is VGA HSYNC
    out DDRE, r18   ; PE4 is VGA VSYNC
    out DDRC, r19   ; controls
    out PORTC, r18  ; pull-up

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

isr_loop:
    ; drop stack frame to save a few bytes
    pop r18
    pop r18
    .if PC_SIZE == 3
    pop r18
    .endif

    ; normally, ISRs should be as short as possible and preserve CPU state. Since
    ; everything is done within this ISR, however, that's unnecessary.
    lds r18, TCNT3L
    lds r19, TCNT3H
    cpiw r18, r19, DISPLAY_CLK_TOP, r20
    brpl _loop_active_test2
    rjmp _loop_work
_loop_active_test2:
    cpiw r18, r19, DISPLAY_CLK_BOTTOM, r20
    brlo _loop_active_screen
    rjmp _loop_work
_loop_active_screen:
    ; output a single row from the framebuffer as quickly as reasonably possible.
    in XL, GPIOR0
    in XH, GPIOR1
    in r16, GPIOR2
    andi r16, 0x7f
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
    nop
    dec r16
    out PORTA, r1
    brpl _loop_quick_work
    out GPIOR0, XL
    out GPIOR1, XH
    ldi r16, DISPLAY_VERTICAL_STRETCH-1
_loop_quick_work:
    out GPIOR2, r16
    ; After writing a row to the screen, there's a brief period (~75 cycles) where
    ; we can do other work (this corresponds to the VGA front porch and sync pulse).
    rjmp _loop_end
_loop_work:
    in r16, GPIOR2
    sbrc r16, 7
    rjmp _loop_reset_render_state
    ori r16, 0x80
    out GPIOR2, r16
    ; At this point, we've rendered a complete image to the screen, and there's a
    ; fairly long gap (~99,300 cycles) where we fill the framebuffer and update
    ; the game. This corresponds to the VGA vertical front porch and sync pulse,
    ; in addition to the time we save with any blank rows (the latter is the most
    ; significant).
    ; heartbeat, used for syncing with the emulator
    in r0, PORTB
    ldi r16, 0x80
    eor r0, r16
    out PORTB, r0

    call rand
    clr r1

    lds r24, clock
    lds r25, clock+1
    adiw r24, 1
    sts clock, r24
    sts clock+1, r25

    call read_controls

    lds r18, game_mode
_loop_explore:
    cpi r18, MODE_EXPLORE
    brne _loop_inventory
    jmp explore_update_game
_loop_inventory:
    cpi r18, MODE_INVENTORY
    brne _loop_shop
    jmp inventory_update_game
_loop_shop:
    cpi r18, MODE_SHOPPING
    brne _loop_conversation
    jmp shop_update_game
_loop_conversation:
    cpi r18, MODE_CONVERSATION
    brne _loop_upgrade
    jmp conversation_update_game
_loop_upgrade:
    cpi r18, MODE_UPGRADE
    brne _loop_gameover
    jmp upgrade_update_game
_loop_gameover:
    cpi r18, MODE_GAMEOVER
    brne _loop_reenter
    jmp gameover_update_game

_loop_reenter:

_loop_reset_render_state:
    in r16, GPIOR2
    andi r16, 0x80
    ori r16, DISPLAY_VERTICAL_STRETCH
    out GPIOR2, r16
    ldi r16, low(framebuffer)
    ldi r17, high(framebuffer)
    out GPIOR0, r16
    out GPIOR1, r17
    sbi TIFR1, OCF1A ; clear any pending interrupts
_loop_end:
    ; exit from interrupt
    sei
    rjmp _main_stall

.include "math.asm"
.include "controls.asm"
.include "animation.asm"
.include "character.asm"
.include "battle.asm"
.include "render.asm"
.include "stats.asm"
.include "npc.asm"
.include "explore.asm"
.include "inventory.asm"
.include "shop.asm"
.include "conversation.asm"
.include "upgrade.asm"
.include "gameover.asm"
.include "logic.asm"
.include "rodata.asm"
.include "data.asm"
