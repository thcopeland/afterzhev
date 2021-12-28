; All game state and writable data lives here. This will be placed in SRAM, so
; we're limited to 8KB (minus stack). Everything that needs to be initialized will
; be initialized in init.asm.

    .dseg
    .org SRAM_START

framebuffer:        .byte (DISPLAY_WIDTH*(DISPLAY_HEIGHT-FOOTER_HEIGHT))
vid_fbuff_offset:   .byte 2     ; pointer into framebuffer indicating what to draw next
vid_current_row:    .byte 2     ; high byte indicates the row, low byte indicates the row repetitions
vid_work_complete:  .byte 1     ; whether the main work is complete

controller_values:  .byte 1

current_sector:     .byte 2

camera_position_x:  .byte 2
camera_position_y:  .byte 2

player_class:       .byte 2
; player_inventory:   .byte 8
player_subpixel_x:  .byte 1
player_position_x:  .byte 2
player_subpixel_y:  .byte 1
player_position_y:  .byte 2
player_velocity_x:  .byte 1
player_velocity_y:  .byte 1
; player_direction:   .byte 1
; player_status:      .byte 1
; player_frame:       .byte 1
