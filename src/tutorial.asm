load_help:
    ldi r25, MODE_HELP
    sts game_mode, r25
    sts sector_data, r1
    sts mode_clock, r1
    ret

load_tutorial:
    call init_game_state
    ldi r25, MODE_EXPLORE
    sts game_mode, r25
    ldi r25, CLASS_PALADIN
    sts player_class, r25
    ldi r25, CHARACTER_MAN
    sts player_character, r25
    call init_player_stats
    ldi r25, DIRECTION_UP
    sts player_direction, r25
    ldi r24, 18
    ldi r25, 155
    sts player_position_x, r24
    sts player_position_y, r25
    ldi r24, 10
    ldi r25, 120
    sts camera_position_x, r24
    sts camera_position_y, r25
    ldi r25, 0xff
    sts savepoint_used, r25
    sts player_inventory, r1
    sts player_inventory+1, r1
    sts player_inventory+2, r1
    ldi ZL, byte3(2*sector_table)
    out RAMPZ, ZL
    ldi ZL, low(2*sector_table + SECTOR_TUTORIAL*SECTOR_MEMSIZE)
    ldi ZH, high(2*sector_table + SECTOR_TUTORIAL*SECTOR_MEMSIZE)
    call load_sector
    ret

help_update:
    lds r25, mode_clock
    inc r25
    cpi r25, 16
    brlo _hu_fade
    ldi r24, 2
    sts start_selection, r24
    call restart_game
    rjmp _hu_end
_hu_fade:
    sts mode_clock, r25
    call screen_fade_out
_hu_end:
    jmp _loop_reenter
