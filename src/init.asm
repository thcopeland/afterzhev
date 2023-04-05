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
    ldi r24, low(audio_buffer)
    ldi r25, high(audio_buffer)
    movw r4, r24
    ldi r24, low(audio_buffer+AUDIO_BUFFER_SIZE)
    ldi r25, high(audio_buffer+AUDIO_BUFFER_SIZE)
    movw r6, r24
    sts audio_state, r1

    ldi r25, 1
    sts seed, r25
    sts seed+1, r1

    sts channel1_phase, r1
    sts channel1_phase+1, r1
    sts channel1_dphase, r1
    sts channel1_dphase+1, r1
    sts channel1_volume, r1
    sts channel1_wave, r1

    sts channel2_phase, r1
    sts channel2_phase+1, r1
    sts channel2_dphase, r1
    sts channel2_dphase+1, r1
    sts channel2_volume, r1
    sts channel2_wave, r1

    ldi r24, low(2*music_test)
    ldi r25, high(2*music_test)
    sts music_track, r24
    sts music_track+1, r25
    sts sfx_track, r1

    ldi r25, (sfx_confirm-sound_effects)>>1
    sts sfx_track, r25

    sts start_selection, r1
    call restart_game

    call init_game_state
    call load_explore

    ldi r25, ITEM_iron_staff
    sts player_weapon, r25

    ldi r25, ITEM_full_green_cloak
    sts player_armor, r25

    ldi r25, ITEM_strength_potion
    sts player_inventory, r25

    ldi r25, ITEM_health_potion
    sts player_inventory+2, r25

    ldi r22, 14
    ldi r23, 14
    ldi r24, 9
    ldi r25, 3
    sts player_stats + STATS_STRENGTH_OFFSET, r22
    sts player_stats + STATS_VITALITY_OFFSET, r23
    sts player_stats + STATS_DEXTERITY_OFFSET, r24
    sts player_stats + STATS_INTELLECT_OFFSET, r25

    ldi r25, 140
    sts player_position_x, r25
    ldi r25, 100
    sts player_position_y, r25
    call reset_camera

    ldi ZL, byte3(2*sector_table)
    out RAMPZ, ZL
    .equ SECTOR = sector_start_pretown_1
    ldi ZL, low(2*sector_table + SECTOR*SECTOR_MEMSIZE)
    ldi ZH, high(2*sector_table + SECTOR*SECTOR_MEMSIZE)
    call load_sector

    rjmp main
