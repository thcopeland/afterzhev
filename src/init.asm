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
    ; ldi r25, GAME_OVER_WIN
    ; ldi r25, GAME_OVER_DEAD
    ; call load_credits
    ; call load_gameover
    ; ldi r25, 219
    ; sts mode_clock, r25

    ; call init_game_state
    ; call load_explore
    ;
    ; ldi r25, ITEM_iron_staff
    ; sts player_weapon, r25
    ;
    ; ldi r25, ITEM_mithril_armor
    ; sts player_armor, r25
    ;
    ; ldi r25, ITEM_strength_potion
    ; sts player_inventory, r25
    ;
    ; ldi r25, ITEM_health_potion
    ; sts player_inventory+2, r25
    ;
    ; ldi r25, ITEM_blessed_sword
    ; sts player_inventory+3, r25
    ;
    ; ldi r22, 20
    ; ldi r23, 20
    ; ldi r24, 24
    ; ldi r25, 20
    ; sts player_stats + STATS_STRENGTH_OFFSET, r22
    ; sts player_stats + STATS_VITALITY_OFFSET, r23
    ; sts player_stats + STATS_DEXTERITY_OFFSET, r24
    ; sts player_stats + STATS_INTELLECT_OFFSET, r25
    ;
    ; ldi r25, 130
    ; sts player_position_x, r25
    ; ldi r25, 80
    ; sts player_position_y, r25
    ; call reset_camera
    ;
    ; ldi ZL, byte3(2*sector_table)
    ; out RAMPZ, ZL
    ; .equ SECTOR = SECTOR_START_2
    ; ldi ZL, low(2*sector_table + SECTOR*SECTOR_MEMSIZE)
    ; ldi ZH, high(2*sector_table + SECTOR*SECTOR_MEMSIZE)
    ; call load_sector

    ; ldi r24, low(2*_conv_cant_leave)
    ; ldi r25, high(2*_conv_cant_leave)
    ; call load_conversation

    rjmp main
