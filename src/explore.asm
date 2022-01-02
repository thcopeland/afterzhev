explore_update_game:
    rcall render_game
    call read_controls
    rcall handle_controls
    rcall move_player
    rcall move_camera
    ret

; Render the game while in the EXPLORE mode. The current sector, NPCs, items,
; the player must all be rendered.
;
; Register Usage
render_game:
    lds r20, camera_position_x
    lds r21, camera_position_x+1
    lds r22, camera_position_y
    lds r23, camera_position_y+1
    lds r24, current_sector
    lds r25, current_sector+1
    call render_sector
    ; render npcs
    ; render player

    ldi ZL, low(framebuffer)
    ldi ZH, high(framebuffer)
    lds r18, camera_position_x
    lds r19, camera_position_x+1
    lds r20, player_position_x
    lds r21, player_position_x+1
    sub r20, r18
    sub r21, r19
    qmod r20, r21, TILE_WIDTH
    add ZL, r20
    adc ZH, r1
    ldi r22, TILE_WIDTH
    mul r22, r21
    add ZL, r0
    adc ZH, r1
    clr r1
    lds r18, camera_position_y
    lds r19, camera_position_y+1
    lds r20, player_position_y
    lds r21, player_position_y+1
    sub r20, r18
    sub r21, r19
    qmod r20, r21, TILE_HEIGHT
    ldi r22, TILE_HEIGHT
    mul r21, r22
    add r20, r0
    clr r1
    ldi r22, DISPLAY_WIDTH
    mul r20, r22
    add ZL, r0
    adc ZH, r1
    clr r1
    ldi r18, 0xC0
    st Z, r18

    ldi r22, 6
    ldi r23, 4
    ldi r24, 6
    ldi r25, 2
    ; lds r22, player_position_x
    ; lds r23, player_position_x+1
    ; lds r24, player_position_y
    ; lds r25, player_position_y+1
    lds r20, player_position_x
    andi r20, 3
    sts player_character, r1
    sts player_weapon, r1
    sts player_armor, r1
    sts player_direction, r1
    sti player_action, ACTION_WALK
    sts player_frame, r20
    ldi YL, low(player_character)
    ldi YH, high(player_character)
    call render_character
    ret

; Handle button presses.
;
; Register Usage
;   r18             button states
;   r19-r21         miscellaneous (player acceleration, velocity)
;   Z (r30:r31)     flash memory lookups
handle_controls:
    lds r18, controller_values
    lds ZL, player_class
    lds ZH, player_class+1
    subi ZL, low(-CLASS_ACC_OFFSET)
    sbci ZH, high(-CLASS_ACC_OFFSET)
    lpm r19, Z
    lds r20, player_velocity_x
    lds r21, player_velocity_y
_hc_up:
    sbrs r18, CONTROLS_UP
    rjmp _hc_down
    sbnv r21, r19
_hc_down:
    sbrs r18, CONTROLS_DOWN
    rjmp _hc_left
    adnv r21, r19
_hc_left:
    sbrs r18, CONTROLS_LEFT
    rjmp _hc_right
    sbnv r20, r19
_hc_right:
    sbrs r18, CONTROLS_RIGHT
    rjmp _hc_button1
    adnv r20, r19
_hc_button1:
_hc_button2:
_hc_button3:
_hc_esc:
_hc_end:
    sts player_velocity_x, r20
    sts player_velocity_y, r21
    ret

; Simple player physics. Horizontal and vertical movements are calculated separately
; in order to allow sliding on collisions.
;
; Register Usage
;   r18, r19        position
;   r20             subpixel position
;   r21, r22        velocity
;   r22-r25         miscellaneous, also camera position
move_player:
_mp_horizontal_component:
    lds r18, player_position_x
    lds r19, player_position_x+1
    lds r20, player_subpixel_x
    lds r21, player_velocity_x
    tst r21
    breq _mp_vertical_component
    ext r21, r22
    add r20, r21
    adc r18, r22
    add r20, r21
    adc r18, r22
    qmod r18, r19, TILE_WIDTH
    sts player_subpixel_x, r20
    decay_94p r21, r22, r23     ; friction
    sts player_velocity_x, r21
    movw r22, r18
    lds r24, player_position_y
    lds r25, player_position_y+1
    rcall resolve_player_movement
_mp_vertical_component:
    lds r18, player_position_y
    lds r19, player_position_y+1
    lds r20, player_subpixel_y
    lds r21, player_velocity_y
    tst r21
    breq _mp_end
    ext r21, r22
    add r20, r21
    adc r18, r22
    add r20, r21
    adc r18, r22
    qmod r18, r19, TILE_WIDTH
    sts player_subpixel_y, r20
    decay_94p r21, r22, r23     ; friction
    sts player_velocity_y, r21
    lds r22, player_position_x
    lds r23, player_position_x+1
    movw r24, r18
    rcall resolve_player_movement
_mp_end:
    ret

; Check for collisions and sector swapping. If no collisions occur, the new
; position values are saved.
;
; Register Usage
; r18, r19      dimensions
; r20, r21      calculations, corner location
; r22           new x position low (param)
; r23           new x position high (param)
; r24           new y position low (param)
; r25           new y position high (param)
; Z (r30:r31)   sector pointer, flash memory pointer
resolve_player_movement:
    lds ZL, current_sector
    lds ZH, current_sector+1
    subi ZL, low(-SECTOR_AJD_OFFSET)
    sbci ZH, high(-SECTOR_AJD_OFFSET)
_rpm_check_sector_left:
    cpi r23, 0
    brge _rpm_check_sector_right
    adiw ZL, 2
    ldi r22, TILE_WIDTH-1
    ldi r23, SECTOR_WIDTH-2
    rjmp _rpm_switch_sector
_rpm_check_sector_right:
    cpi r23, SECTOR_WIDTH-1
    brlt _rpm_check_sector_top
    adiw ZL, 3
    clr r22
    clr r23
    rjmp _rpm_switch_sector
_rpm_check_sector_top:
    cpi r25, 0
    brge _rpm_check_sector_bottom
    ldi r24, TILE_HEIGHT-1
    ldi r25, SECTOR_HEIGHT-2
    rjmp _rpm_switch_sector
_rpm_check_sector_bottom:
    cpi r25, SECTOR_HEIGHT-1
    brlt _rmp_resolve_collisions
    adiw ZL, 1
    clr r24
    clr r25
_rpm_switch_sector:
    lpm r20, Z
    ldi r21, SECTOR_MEMSIZE
    mul r20, r21
    ldi ZL, low(2*sector_table)
    ldi ZH, high(2*sector_table)
    add ZL, r0
    adc ZH, r1
    clr r1
    call load_new_sector
    rjmp _rpm_no_collision
_rmp_resolve_collisions:
    lds ZL, player_class
    lds ZH, player_class+1
    subi ZL, low(-CLASS_DIMS_OFFSET)
    sbci ZH, high(-CLASS_DIMS_OFFSET)
    lpm r18, Z+
    lpm r19, Z
_rpm_check_upper_left:
    lds ZL, current_sector
    lds ZH, current_sector+1
    movw r20, r24
    subi r20, -TILE_HEIGHT
    sub r20, r19
    qmod r20, r21, TILE_HEIGHT
    ldi r20, SECTOR_WIDTH
    mul r21, r20
    add ZL, r0
    adc ZH, r1
    clr r1
    movw r20, r22
    subi r20, -TILE_WIDTH
    sub r20, r18
    qmod r20, r21, TILE_WIDTH
    add ZL, r21
    adc ZH, r1
    lpm r20, Z
    cpi r20, MIN_BLOCKING_TILE_IDX
    brlo _rpm_check_upper_right
    rjmp _rpm_collision
_rpm_check_upper_right:
    mov r0, r21
    movw r20, r22
    add r20, r18
    qmod r20, r21, TILE_WIDTH
    sub r21, r0
    add ZL, r21
    adc ZH, r1
    lpm r20, Z
    cpi r20, MIN_BLOCKING_TILE_IDX
    brsh _rpm_collision
_rpm_check_lower_left:
    lds ZL, current_sector
    lds ZH, current_sector+1
    movw r20, r24
    add r20, r19
    qmod r20, r21, TILE_HEIGHT
    ldi r20, SECTOR_WIDTH
    mul r21, r20
    add ZL, r0
    adc ZH, r1
    clr r1
    movw r20, r22
    subi r20, -TILE_WIDTH
    sub r20, r18
    qmod r20, r21, TILE_WIDTH
    add ZL, r21
    adc ZH, r1
    lpm r20, Z
    cpi r20, MIN_BLOCKING_TILE_IDX
    brsh _rpm_collision
_rpm_check_lower_right:
    mov r0, r21
    movw r20, r22
    add r20, r18
    qmod r20, r21, TILE_WIDTH
    sub r21, r0
    add ZL, r21
    adc ZH, r1
    lpm r20, Z
    cpi r20, MIN_BLOCKING_TILE_IDX
    brlo _rpm_no_collision
_rpm_collision:
    lds r20, player_position_x
    cpse r20, r22
    sts player_velocity_x, r1
    lds r20, player_position_y
    cpse r20, r24
    sts player_velocity_y, r1
    rjmp _rpm_end
_rpm_no_collision:
    sts player_position_x, r22
    sts player_position_x+1, r23
    sts player_position_y, r24
    sts player_position_y+1, r25
_rpm_end:
    ret

; Change sectors. Every sector has its own set of items and npcs, these must be
; changed as necessary.
;
; Register Usage
;   Z (r30:r31)     a pointer to the new sector
load_new_sector:
    sts current_sector, ZL
    sts current_sector+1, ZH
    ; change npcs, loose items, etc
    ret

; Move the "camera" so that the player is within the camera view plus some margin.
; The camera is constrained to the sector bounds, however.
;
; Register Usage
;   r18, r19        player position
;   r20, r21        camera position
;   r22, r23        player-camera position
move_camera:
    lds r18, player_position_x
    lds r19, player_position_x+1
    lds r20, camera_position_x
    lds r21, camera_position_x+1
    movw r22, r18
    sub r22, r20
    sub r23, r21
    qmod r22, r23, TILE_WIDTH
_mc_test_pad_left:
    cpi r23, CAMERA_HORIZONTAL_PADDING_H
    brlt _mc_pad_left
    brne _mc_test_pad_right
    cpi r22, CAMERA_HORIZONTAL_PADDING_L
    brpl _mc_test_pad_right
_mc_pad_left:
    movw r20, r18
    subi r21, CAMERA_HORIZONTAL_PADDING_H
    subi r20, CAMERA_HORIZONTAL_PADDING_L
_mc_test_pad_right:
    cpi r23, DISPLAY_HORIZONTAL_TILES-CAMERA_HORIZONTAL_PADDING_H-2
    brlo _mc_fit_horiz_to_display
    brne _mc_pad_right
    cpi r22, CAMERA_HORIZONTAL_PADDING_L
    brlo _mc_fit_horiz_to_display
_mc_pad_right:
    movw r20, r18
    subi r21, DISPLAY_HORIZONTAL_TILES-CAMERA_HORIZONTAL_PADDING_H-2
    subi r20, CAMERA_HORIZONTAL_PADDING_L
_mc_fit_horiz_to_display:
    qmod r20, r21, TILE_WIDTH
_mc_constrain_x_min:
    cpi r21, 0
    brge _mc_constrain_x_max
    clr r20
    clr r21
_mc_constrain_x_max:
    cpi r21, SECTOR_WIDTH-DISPLAY_HORIZONTAL_TILES
    brlt _mc_save_horizontal_pos
    clr r20
    ldi r21, SECTOR_WIDTH-DISPLAY_HORIZONTAL_TILES
_mc_save_horizontal_pos:
    sts camera_position_x, r20
    sts camera_position_x+1, r21
_mc_vertical_padding:
    lds r18, player_position_y
    lds r19, player_position_y+1
    lds r20, camera_position_y
    lds r21, camera_position_y+1
    movw r22, r18
    sub r22, r20
    sub r23, r21
    qmod r22, r23, TILE_HEIGHT
_mc_test_pad_top:
    cpi r23, CAMERA_VERTICAL_PADDING_H
    brlt _mc_pad_top
    brne _mc_test_pad_bottom
    cpi r22, CAMERA_VERTICAL_PADDING_L
    brpl _mc_test_pad_bottom
_mc_pad_top:
    movw r20, r18
    subi r21, CAMERA_VERTICAL_PADDING_H
    subi r20, CAMERA_VERTICAL_PADDING_L
_mc_test_pad_bottom:
    cpi r23, DISPLAY_VERTICAL_TILES-CAMERA_VERTICAL_PADDING_H-2
    brlo _mc_fit_vert_to_display
    brne _mc_pad_bottom
    cpi r22, CAMERA_VERTICAL_PADDING_L
    brlo _mc_fit_vert_to_display
_mc_pad_bottom:
    movw r20, r18
    subi r21, DISPLAY_VERTICAL_TILES-CAMERA_VERTICAL_PADDING_H-2
    subi r20, CAMERA_VERTICAL_PADDING_L
_mc_fit_vert_to_display:
    qmod r20, r21, TILE_HEIGHT
_mc_constrain_y_min:
    cpi r21, 0
    brge _mc_constrain_y_max
    clr r20
    clr r21
_mc_constrain_y_max:
    cpi r21, SECTOR_HEIGHT-DISPLAY_VERTICAL_TILES
    brlt _mc_save_vertical_pos
    clr r20
    ldi r21, SECTOR_HEIGHT-DISPLAY_VERTICAL_TILES
_mc_save_vertical_pos:
    sts camera_position_y, r20
    sts camera_position_y+1, r21
    ret
