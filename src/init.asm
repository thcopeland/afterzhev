init:
    clr r1
    stiw vid_fbuff_offset, framebuffer
    stiw current_sector, 2*sector_table
    stiw camera_position_x, 0x0000
    stiw camera_position_y, 0x0200
    stiw player_position_x, 0x0600
    stiw player_position_y, 0x0200
    sti player_class, 1
    sti player_acceleration, 12
    sti player_velocity_x, 0
    sti player_velocity_y, 0
    sti player_character, 0
    sti player_weapon, 1
    sti player_armor, 1
    sti player_action, ACTION_WALK
    sti player_frame, 0
    sti player_inventory+2, 2
    sti player_inventory+10, 3
    sti player_inventory+1, 4

    sti player_stats,   32
    sti player_stats+1, 0
    sti player_stats+2, 6
    sti player_stats+3, 32
    sti player_gold, 153
    sti player_max_health, 16
    sti player_health, 13

    sti game_mode, MODE_EXPLORE

    sti inventory_selection, 2

    stiw preplaced_item_availability, 0xffff

    ldi ZL, byte3(2*sector_table)
    out RAMPZ, ZL
    ldi ZL, low(2*sector_table)
    ldi ZH, high(2*sector_table)
    call load_sector

    rjmp main
