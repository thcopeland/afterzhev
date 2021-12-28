init:
    clr r1
    stiw vid_fbuff_offset, framebuffer
    sti vid_fbuff_offset, DISPLAY_VERTICAL_STRETCH
    sti vid_fbuff_offset+1, 0
    sti vid_fbuff_offset, 0
    stiw player_position_x, 0x0200
    stiw player_position_y, 0x0200
    sti player_velocity_x, 0
    sti player_velocity_y, 0
    stiw player_class, 2*class_table
    stiw current_sector, 2*sector_table
    stiw camera_position_x, 0x0200
    stiw camera_position_y, 0x0200

    rjmp main
