init:
    clr r1
    stiw vid_fbuff_offset, framebuffer
    stiw player_class, 2*class_table
    stiw current_sector, 2*sector_table
    stiw camera_position_x, 0x0000
    stiw camera_position_y, 0x0200
    stiw player_position_x, 0x0600
    stiw player_position_y, 0x0200
    sti player_velocity_x, 0
    sti player_velocity_y, 0
    sti player_character, 0
    sti player_weapon, 1
    sti player_armor, 0
    sti player_action, ACTION_WALK
    sti player_frame, 0

    stiw preplaced_item_availability, 0xffff

    ldi ZL, byte3(2*sector_table)
    out RAMPZ, ZL
    ldi ZL, low(2*sector_table)
    ldi ZH, high(2*sector_table)
    call load_sector

    rjmp main
