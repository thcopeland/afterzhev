.include "device.asm"
.include "vga.asm"
.include "utils.asm"
.include "layout.asm"
.include "gamedefs.asm"

.cseg
.org 0x0000
    jmp init
.org OC1Aaddr
    jmp loop
.org OC0Aaddr
audio:
    movw r8, r0
    in r10, SREG
_a_noise:
    ; 16-bit xorshift prng
    movw r0, r2
    ; x ^= (x << 7)
    lsr r1
    ror r0
    eor r3, r0
    clr r0
    ror r0
    eor r2, r0
    ; x ^= (x >> 9)
    mov r0, r3
    lsr r0
    eor r2, r0
    ; x ^= (x << 8)
    eor r3, r2
_a_channel_1:
    lds r0, channel1_dphase
    lds r1, channel1_dphase+1
    add r4, r0
    adc r5, r1
    lds r11, channel1_volume
    lds r0, channel1_wave
    sbrc r0, 7
    rjmp a_channel_1_noise
_a_channel_1_sawtooth:
    mul r5, r11
    mov r12, r1
    rjmp _a_channel_2
a_channel_1_noise:
    mul r2, r11
    mov r12, r1
_a_channel_2:
    lds r0, channel2_dphase
    lds r1, channel2_dphase+1
    add r6, r0
    adc r7, r1
    lds r11, channel2_volume
    lds r0, channel2_wave
    sbrc r0, 7
    rjmp _a_channel_2_noise
_a_channel_2_sawtooth:
    mul r7, r11
    add r12, r1
    brcc _a_write
    clr r12
    com r12
    rjmp _a_write
_a_channel_2_noise:
    mul r2, r11
    add r12, r1
    brcc _a_write
    clr r12
    com r12
_a_write:
    out PORTC, r12
    movw r0, r8
    out SREG, r10
    reti

.include "init.asm"

main:
    ser r25
    out DDRA, r25   ; VGA image output
    out DDRB, r25   ; PB6 is VGA HSYNC
    out DDRE, r25   ; PE4 is VGA VSYNC
    out DDRC, r25   ; audio output

    ; Audio: CTC w/ OCRA and 8 prescaling
    ldi r25, AUDIO_SAMPLING_PERIOD/8-1
    out OCR0A, r25
    ldi r25, 1 << OCIE0A
    sts TIMSK0, r25
    ldi r24, (1<<WGM01)
    ldi r25, (1<<CS01)
    out TCCR0A, r24
    out TCCR0B, r25
    ldi r25, 68 ; ensure audio happens during horizontal blank during video generation
    out TCNT0, r25

    ; HSYNC: fast PWM on pin PB6
    ldi r24, low(HSYNC_PERIOD - 1)
    ldi r25, high(HSYNC_PERIOD - 1)
    sts OCR1AH, r25
    sts OCR1AL, r24
    ldi r24, low(HSYNC_PERIOD - HSYNC_SYNC_WIDTH - 1)
    ldi r25, high(HSYNC_PERIOD - HSYNC_SYNC_WIDTH - 1)
    sts OCR1BH, r25
    sts OCR1BL, r24
    ldi r25, 1 << OCIE1A
    sts TIMSK1, r25
    ldi r24, (1 << WGM10) | (1 << WGM11) | (1 << COM1B1) | (1 << COM1B0)
    ldi r25, (1 << WGM12) | (1 << WGM13) | (1 << CS10)
    sts TCCR1A, r24
    sts TCCR1B, r25

    ; VSYNC: fast PWM on pin PE4
    ldi r24, low(VSYNC_PERIOD - 1)
    ldi r25, high(VSYNC_PERIOD - 1)
    sts OCR3AH, r25
    sts OCR3AL, r24
    ldi r24, low(VSYNC_PERIOD - VSYNC_SYNC_WIDTH - 1)
    ldi r25, high(VSYNC_PERIOD - VSYNC_SYNC_WIDTH - 1)
    sts OCR3BH, r25
    sts OCR3BL, r24
    ldi r24, (1 << WGM30) | (1 << WGM31) | (1 << COM3B1) | (1 << COM3B0)
    ldi r25, (1 << WGM32) | (1 << WGM33) | (1 << CS32)
    sts TCCR3A, r24
    sts TCCR3B, r25

    ldi r24, low(HSYNC_PERIOD - 1)
    ldi r25, high(HSYNC_PERIOD - 1)
    sts TCNT1H, r25
    sts TCNT1L, r24
    ldi r24, low(VSYNC_PERIOD - VSYNC_SYNC_WIDTH - 1)
    ldi r25, high(VSYNC_PERIOD - VSYNC_SYNC_WIDTH - 1)
    sts TCNT3H, r25
    sts TCNT3L, r24

    ; enable IDLE sleep mode for reliable interrupt timing
    ldi r25, (1 << SE)
    out SMCR, r25

    sei
_main_stall:
    sleep
    rjmp _main_stall

loop:
    ; drop stack frame to save a few bytes
    pop r25
    pop r25
.if PC_SIZE == 3
    pop r25
.endif

    lds r24, TCNT3L
    lds r25, TCNT3H
    ldi r23, high(DISPLAY_CLK_TOP)
    cpi r24, low(DISPLAY_CLK_TOP)
    cpc r25, r23
    brpl _loop_active_test2
    rjmp _loop_game
_loop_active_test2:
    ldi r23, high(DISPLAY_CLK_BOTTOM)
    cpi r24, low(DISPLAY_CLK_BOTTOM)
    cpc r25, r23
    brlo _loop_video
    rjmp _loop_game
_loop_video:
    in XL, GPIOR0
    in XH, GPIOR1
    in r20, GPIOR2
    andi r20, 0x7f
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
    dec r20
    out PORTA, r1
    brpl _loop_audio
    out GPIOR0, XL
    out GPIOR1, XH
    ldi r20, DISPLAY_VERTICAL_STRETCH-1
_loop_audio:
    out GPIOR2, r20
    rjmp _loop_end
_loop_game:
    in r20, GPIOR2
    sbrc r20, 7
    rjmp _loop_check_audio
    sbr r20, 0x80
    out GPIOR2, r20
_loop_heartbeat: ; used to synch with emulator
    in r25, PORTB
    ldi r24, 0x80
    eor r25, r24
    out PORTB, r25

    ; At this point, there are around 100,000 cycles in which to render and
    ; update the entire game.
    rcall update_audio_channels

    lds r24, clock
    lds r25, clock+1
    lds r23, clock+2
    adiw r24, 1
    adc r23, r1
    sts clock, r24
    sts clock+1, r25
    sts clock+2, r23

    sts TIMSK1, r1
    sei

.if TARGETING_MCU ; the emulator pokes memory directly
    call read_controls
.endif

    lds r25, game_mode
_loop_explore:
    cpi r25, MODE_EXPLORE
    brne _loop_inventory
    jmp explore_update_game
_loop_inventory:
    cpi r25, MODE_INVENTORY
    brne _loop_shop
    jmp inventory_update_game
_loop_shop:
    cpi r25, MODE_SHOPPING
    brne _loop_conversation
    jmp shop_update_game
_loop_conversation:
    cpi r25, MODE_CONVERSATION
    brne _loop_upgrade
    jmp conversation_update_game
_loop_upgrade:
    cpi r25, MODE_UPGRADE
    brne _loop_gameover
    jmp upgrade_update_game
_loop_gameover:
    cpi r25, MODE_GAMEOVER
    brne _loop_start
    jmp gameover_update_game
_loop_start:
    cpi r25, MODE_START
    brne _loop_character_selection
    jmp start_update_game
_loop_character_selection:
    cpi r25, MODE_CHARACTER
    brne _loop_intro
    jmp character_selection_update
_loop_intro:
    cpi r25, MODE_INTRO
    brne _loop_resume
    jmp intro_update_game
_loop_resume:
    cpi r25, MODE_RESUME
    brne _loop_about
    jmp resume_update_game
_loop_about:
    cpi r25, MODE_ABOUT
    brne _loop_help
    jmp about_update
_loop_help:
    cpi r25, MODE_HELP
    brne _loop_credits
    jmp help_update
_loop_credits:
    cpi r25, MODE_CREDITS
    brne _loop_reenter
    jmp credits_update
_loop_reenter:
_loop_check_audio:
    lds r24, TCNT3L
    lds r25, TCNT3H
    sbiw r24, DISPLAY_CLK_TOP/2
    sbiw r24, DISPLAY_CLK_TOP/2
    brlo _loop_reset_render_state
_loop_reset_render_state:
    cli
    sts audio_state, r1
    in r25, GPIOR2
    andi r25, 0x80
    ori r25, DISPLAY_VERTICAL_STRETCH
    out GPIOR2, r25
    ldi r24, low(framebuffer)
    ldi r25, high(framebuffer)
    out GPIOR0, r24
    out GPIOR1, r25
    sbi TIFR1, OCF1A ; clear any pending interrupts
    ldi r25, 1 << OCIE1A
    sts TIMSK1, r25
_loop_end:
    sei
    rjmp _main_stall

.include "audio.asm"
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
.include "credits.asm"
.include "start.asm"
.include "character_selection.asm"
.include "intro.asm"
.include "resume.asm"
.include "about.asm"
.include "tutorial.asm"
.include "logic.asm"
.include "rodata.asm"
.include "data.asm"
