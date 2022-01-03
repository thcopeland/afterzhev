init:
    clr r1
    stiw vid_fbuff_offset, framebuffer
    stiw player_position_x, 0x0600
    stiw player_position_y, 0x0200
    sti player_velocity_x, 0
    sti player_velocity_y, 0
    stiw player_class, 2*class_table
    stiw current_sector, 2*sector_table
    stiw camera_position_x, 0x0000
    stiw camera_position_y, 0x0200

    rjmp main
