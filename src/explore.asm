explore_update_game:
    rcall render_game
    rcall handle_controls
    rcall move_player
    rcall update_player
    call update_effects_progress
    rcall move_camera
    ret

; Render the game while in the EXPLORE mode. The current sector, NPCs, items,
; the player must all be rendered.
;
; Register Usage
render_game:
    push r16
    push r17
    push YL
    push YH
    lds r20, camera_position_x
    lds r21, camera_position_x+1
    lds r22, camera_position_y
    lds r23, camera_position_y+1
    lds r24, current_sector
    lds r25, current_sector+1
    call render_sector
_rg_render_loose_items:
    clt
    ldi YL, low(sector_loose_items)
    ldi YH, high(sector_loose_items)
    ldi r16, SECTOR_DYNAMIC_ITEM_COUNT
_rg_render_loose_items_iter:
    ld r18, Y
    tst r18
    breq _rg_render_loose_items_check
    ldi ZL, byte3(2*static_item_sprite_table)
    out RAMPZ, ZL
    ldi r19, STATIC_ITEM_MEMSIZE
    dec r18
    mul r18, r19
    movw ZL, r0
    clr r1
    subi ZL, low(-2*static_item_sprite_table)
    sbci ZH, high(-2*static_item_sprite_table)
    ldi r20, STATIC_ITEM_WIDTH
    ldi r21, STATIC_ITEM_HEIGHT
    ldi r22, (TILE_WIDTH-STATIC_ITEM_WIDTH)/2
    ldd r23, Y+2
    ldi r24, (TILE_HEIGHT-STATIC_ITEM_HEIGHT)/2
    ldd r25, Y+3
    call render_sprite
_rg_render_loose_items_check:
    adiw YL, SECTOR_DYNAMIC_ITEM_MEMSIZE
    dec r16
    brne _rg_render_loose_items_iter
_rg_render_npcs:
    ldi YL, low(sector_npcs)
    ldi YH, high(sector_npcs)
    ldi r16, SECTOR_DYNAMIC_NPC_COUNT
_rg_render_npcs_iter:
    ldd r17, Y+NPC_IDX_OFFSET
    dec r17
    brmi _rg_render_npcs_next
    ldi ZL, low(2*npc_table+NPC_TABLE_CHARACTER_OFFSET)
    ldi ZH, high(2*npc_table+NPC_TABLE_CHARACTER_OFFSET)
    ldi r18, NPC_TABLE_ENTRY_MEMSIZE
    mul r17, r18
    add ZL, r0
    adc ZH, r1
    clr r1
    lpm r18, Z+
_rg_render_static_npc:
    cpi r18, 128
    brlo _rg_render_dynamic_npc
    andi r18, low(~128)
    clt
    ldi ZL, byte3(2*static_character_sprite_table)
    out RAMPZ, ZL
    ldi ZL, low(2*static_character_sprite_table)
    ldi ZH, high(2*static_character_sprite_table)
    ldi r19, CHARACTER_SPRITE_MEMSIZE
    mul r18, r19
    add ZL, r0
    adc ZH, r1
    clr r1
    ldi r20, CHARACTER_SPRITE_WIDTH
    ldi r21, CHARACTER_SPRITE_HEIGHT
    ldd r22, Y+NPC_X_POSITION_OFFSET+NPC_POSITION_LOW_OFFSET
    ldd r23, Y+NPC_X_POSITION_OFFSET+NPC_POSITION_HIGH_OFFSET
    ldd r24, Y+NPC_Y_POSITION_OFFSET+NPC_POSITION_LOW_OFFSET
    ldd r25, Y+NPC_Y_POSITION_OFFSET+NPC_POSITION_HIGH_OFFSET
    call render_sprite
    ldi ZL, byte3(2*npc_table)
    out RAMPZ, ZL
_rg_render_npcs_next:
    adiw YL, NPC_MEMSIZE
    dec r16
    brne _rg_render_npcs_iter
    rjmp _rg_render_player
_rg_render_dynamic_npc:
    sts character_render+CHARACTER_SPRITE_OFFSET, r18
    lpm r18, Z+
    sts character_render+CHARACTER_WEAPON_OFFSET, r18
    lpm r18, Z+
    sts character_render+CHARACTER_ARMOR_OFFSET, r18
    ldd r18, Y+NPC_ANIM_OFFSET
    mov r19, r18
    andi r19, 3
    sts character_render+CHARACTER_DIRECTION_OFFSET, r19
    lsr r18
    mov r19, r18
    lsr r19
    andi r19, 7
    sts character_render+CHARACTER_FRAME_OFFSET, r19
    swap r18
    lsr r18
    andi r18, 7
    sts character_render+CHARACTER_ACTION_OFFSET, r18
    ldd r22, Y+NPC_X_POSITION_OFFSET+NPC_POSITION_LOW_OFFSET
    ldd r23, Y+NPC_X_POSITION_OFFSET+NPC_POSITION_HIGH_OFFSET
    ldd r24, Y+NPC_Y_POSITION_OFFSET+NPC_POSITION_LOW_OFFSET
    ldd r25, Y+NPC_Y_POSITION_OFFSET+NPC_POSITION_HIGH_OFFSET
    movw r14, YL
    ldi YL, low(character_render)
    ldi YH, high(character_render)
    call render_character
    movw YL, r14
    rjmp _rg_render_npcs_next
_rg_render_player:
    lds r22, player_position_x
    lds r23, player_position_x+1
    lds r24, player_position_y
    lds r25, player_position_y+1
    ldi YL, low(player_character)
    ldi YH, high(player_character)
    call render_character
    pop YH
    pop YL
    pop r17
    pop r16
    ret

; Handle button presses.
;
; Register Usage
;   r18             previous button states
;   r19             current button state
;   r19-r21         miscellaneous
;   Z (r30:r31)     flash memory lookups
handle_controls:
    lds r18, prev_controller_values
    lds r19, controller_values
    lds r20, player_acceleration
_hc_up:
    sbrs r19, CONTROLS_UP
    rjmp _hc_down
    lds r21, player_velocity_y
    sbnv r21, r20
    sts player_velocity_y, r21
    ldi r21, DIRECTION_UP
    sts player_direction, r21
_hc_down:
    sbrs r19, CONTROLS_DOWN
    rjmp _hc_left
    lds r21, player_velocity_y
    adnv r21, r20
    sts player_velocity_y, r21
    ldi r21, DIRECTION_DOWN
    sts player_direction, r21
_hc_left:
    sbrs r19, CONTROLS_LEFT
    rjmp _hc_right
    lds r21, player_velocity_x
    sbnv r21, r20
    sts player_velocity_x, r21
    ldi r21, DIRECTION_LEFT
    sts player_direction, r21
_hc_right:
    sbrs r19, CONTROLS_RIGHT
    rjmp _hc_button1
    lds r21, player_velocity_x
    adnv r21, r20
    sts player_velocity_x, r21
    ldi r21, DIRECTION_RIGHT
    sts player_direction, r21
_hc_button1:
    sbrs r19, CONTROLS_SPECIAL1
    rjmp _hc_button2
    sbrc r18, CONTROLS_SPECIAL1
    rjmp _hc_button2
    rcall handle_main_button
    rjmp _hc_end
_hc_button2:
_hc_button3:
_hc_button4:
    sbrs r19, CONTROLS_SPECIAL4
    rjmp _hc_end
    sbrc r18, CONTROLS_SPECIAL4
    rjmp _hc_end
    sts player_velocity_x, r1
    sts player_velocity_y, r1
    sti game_mode, MODE_INVENTORY
_hc_end:
    ret

; The main button allows interaction with the environment. If there are nearby
; items, one of them is added to the player's inventory.
;
; Register Usage
;   r18-r22         calculations
;   X (r26:r27)     memory pointer 2
;   Z (r30:r31)     memory pointer
handle_main_button:
_hmb_pickup_items:
    lds r18, player_position_y
    lds r19, player_position_y+1
    lds r20, player_position_x
    lds r21, player_position_x+1
    subi r18, -CHARACTER_SPRITE_HEIGHT/2
    qmod r18, r19, TILE_HEIGHT
    subi r20, -CHARACTER_SPRITE_WIDTH/2
    qmod r20, r21, TILE_WIDTH
    mov r18, r21
    ldi ZL, low(sector_loose_items)
    ldi ZH, high(sector_loose_items)
    ldi r20, SECTOR_DYNAMIC_ITEM_COUNT
_hmb_loose_item_iter:
    ldd r0, Z+SECTOR_ITEM_IDX_OFFSET
    tst r0
    breq _hmb_loose_item_next
    ldd r0, Z+SECTOR_ITEM_X_OFFSET
    cp r0, r18
    brne _hmb_loose_item_next
    ldd r0, Z+SECTOR_ITEM_Y_OFFSET
    cp r0, r19
    breq _hmb_nearby_item_found
_hmb_loose_item_next:
    adiw ZL, SECTOR_DYNAMIC_ITEM_MEMSIZE
    dec r20
    brne _hmb_loose_item_iter
    rjmp _hmb_end
_hmb_nearby_item_found:
    ldi XL, low(player_inventory)
    ldi XH, high(player_inventory)
    ldi r20, PLAYER_INVENTORY_SIZE
_hmb_inventory_iter:
    ld r0, X+
    tst r0
    breq _hmb_empty_inventory_slot_found
_hmb_inventory_next:
    dec r20
    brne _hmb_inventory_iter
    rjmp _hmb_end
_hmb_empty_inventory_slot_found:
    ldd r0, Z+SECTOR_ITEM_IDX_OFFSET
    st -X, r0   ; fill the empty slot
    std Z+SECTOR_ITEM_IDX_OFFSET, r1
    ldd r20, Z+SECTOR_ITEM_PREPLACED_IDX_OFFSET
    tst r20
    breq _hmb_end
    mov r21, r20    ; if a preplaced item, mark as unavailable
    lsr r20
    lsr r20
    lsr r20
    ldi XL, low(preplaced_item_presence)
    ldi XH, high(preplaced_item_presence)
    add XL, r20
    adc XH, r1
    ld r20, X
    ldi r22, 1
    mpow2 r22, r21
    com r22
    and r20, r22
    st X, r20
_hmb_end:
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
    adiw ZL, 3
    ldi r22, TILE_WIDTH-1
    ldi r23, SECTOR_WIDTH-2
    rjmp _rpm_switch_sector
_rpm_check_sector_right:
    cpi r23, SECTOR_WIDTH-1
    brlt _rpm_check_sector_top
    adiw ZL, 1
    clr r22
    clr r23
    rjmp _rpm_switch_sector
_rpm_check_sector_top:
    cpi r25, 0
    brge _rpm_check_sector_bottom
    adiw ZL, 2
    ldi r24, TILE_HEIGHT-1
    ldi r25, SECTOR_HEIGHT-2
    rjmp _rpm_switch_sector
_rpm_check_sector_bottom:
    cpi r25, SECTOR_HEIGHT-1
    brlt _rmp_resolve_collisions
    clr r24
    clr r25
_rpm_switch_sector:
    sts player_position_x, r22
    sts player_position_x+1, r23
    sts player_position_y, r24
    sts player_position_y+1, r25
    lpm r20, Z
    ldi r21, SECTOR_MEMSIZE
    mul r20, r21
    ldi ZL, byte3(2*sector_table)
    out RAMPZ, ZL
    ldi ZL, low(2*sector_table)
    ldi ZH, high(2*sector_table)
    add ZL, r0
    adc ZH, r1
    clr r1
    call load_sector
    ret
_rmp_resolve_collisions:
    ldi ZL, low(2*class_table+CLASS_DIMS_OFFSET)
    ldi ZH, high(2*class_table+CLASS_DIMS_OFFSET)
    lds r18, player_class
    ldi r19, CLASS_MEMSIZE
    mul r18, r19
    add ZL, r0
    adc ZH, r1
    clr r1
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

; Update the player's animation and general state.
;
; Register Usage
;   r18-r19         calculations
update_player:
    lds r18, player_action
    lds r20, player_velocity_x
    lds r21, player_velocity_y
    sbrc r20, 7
    neg r20
    sbrc r21, 7
    neg r21
    add r20, r21
_up_idle:
    cpi r18, ACTION_IDLE
    brne _up_walk
_up_idle_check_speed:
    cpi r20, IDLE_MAX_SPEED ; there's an asymmetric transition between walk and idle, helps prevent jittering when running into objects
    brlo _up_idle_pass
    ldi r18, ACTION_WALK
    sts player_action, r18
    sts player_frame, r1
_up_idle_pass:
    rjmp _up_end
_up_walk:
    cpi r18, ACTION_WALK
    brne _up_hurt
_up_walk_check_speed:
    lds r19, clock
    cpi r20, RUN_MIN_SPEED
    brsh _up_run_check_clock
    tst r20
    brne _up_walk_check_clock
_up_walk_to_idle:
    ldi r18, ACTION_IDLE
    sts player_action, r18
    sts player_frame, r1
    rjmp _up_end
_up_run_check_clock:
    andi r19, RUN_FRAME_DURATION_MASK
_up_walk_check_clock:
    andi r19, WALK_FRAME_DURATION_MASK
    brne _up_walk_pass
    lds r18, player_frame
    inc r18
    andi r18, 3
    sts player_frame, r18
_up_walk_pass:
    rjmp _up_end
_up_hurt:
_up_attack1:
_up_attack2:
_up_attack3:
_up_end:
    ret

; Change sectors. Every sector has its own set of items and NPCs, these must be
; loaded as necessary.
;
; Register Usage
;   r18-r24         calculations
;   X (r26:r27)     data pointer
;   Y (r28:r29)     second data pointer
;   Z (r30:r31)     pointer to the new sector (param)
load_sector:
    push YL
    push YH
    sts current_sector, ZL
    sts current_sector+1, ZH
_ls_clear_loose_items:
    ldi YL, low(sector_loose_items)
    ldi YH, high(sector_loose_items)
    ldi r18, SECTOR_DYNAMIC_ITEM_COUNT
_ls_clear_loose_items_iter:
    st Y+, r1
    st Y+, r1
    st Y+, r1
    st Y+, r1
    dec r18
    brne _ls_clear_loose_items_iter
_ls_load_preplaced_items:
    subi ZL, low(-SECTOR_ITEMS_OFFSET)
    sbci ZH, high(-SECTOR_ITEMS_OFFSET)
    ldi YL, low(sector_loose_items)
    ldi YH, high(sector_loose_items)
    ldi r18, SECTOR_PREPLACED_ITEM_COUNT
_ls_load_preplaced_items_iter:
    elpm r19, Z+
    elpm r20, Z+
    elpm r21, Z+
    elpm r22, Z+
    ldi XL, low(preplaced_item_presence)
    ldi XH, high(preplaced_item_presence)
    mov r23, r20
    mov r24, r20
    lsr r23
    lsr r23
    lsr r23
    add XL, r23
    adc XH, r1
    ld r23, X
    nbit r23, r24 ; check that the item is still available
    breq _ls_load_preplaced_items_next
    st Y, r19
    std Y+1, r20
    std Y+2, r21
    std Y+3, r22
_ls_load_preplaced_items_next:
    adiw YL, SECTOR_PREPLACED_ITEM_MEMSIZE
    dec r18
    brne _ls_load_preplaced_items_iter
_ls_clear_npcs:
    ldi YL, low(sector_npcs)
    ldi YH, high(sector_npcs)
    ldi r18, SECTOR_DYNAMIC_NPC_COUNT
_ls_clear_npcs_iter:
    st Y, r1
    adiw YL, NPC_MEMSIZE
    dec r18
    brne _ls_clear_npcs_iter
_ls_load_npcs:
    ldi YL, low(sector_npcs)
    ldi YH, high(sector_npcs)
    lds XL, current_sector
    lds XH, current_sector+1
    subi XL, low(-SECTOR_NPC_OFFSET)
    sbci XH, high(-SECTOR_NPC_OFFSET)
    ldi ZL, byte3(2*sector_table)
    out RAMPZ, ZL
    ldi r18, SECTOR_NPC_COUNT
_ls_load_npcs_iter:
    movw ZL, XL
    elpm r19, Z+
    mov r20, r19
    movw XL, ZL
    dec r20
    brmi _ls_npcs_loaded
    mov r21, r20
    mov r22, r20
    lsr r22
    lsr r22
    lsr r22
    ldi ZL, low(npc_presence)
    ldi ZH, high(npc_presence)
    add ZL, r22
    adc ZH, r1
    ld r23, Z
    nbit r23, r21
    breq _ls_load_npcs_next
    std Y+NPC_IDX_OFFSET, r19
    ldi ZL, low(2*npc_table+NPC_TABLE_DIRECTION_OFFSET)
    ldi ZH, high(2*npc_table+NPC_TABLE_DIRECTION_OFFSET)
    ldi r21, NPC_TABLE_ENTRY_MEMSIZE
    mul r20, r21
    add ZL, r0
    add ZH, r1
    clr r1
    lpm r19, Z+    ; direction
    std Y+NPC_ANIM_OFFSET, r19
    lpm r19, Z+    ; x pos
    std Y+NPC_X_POSITION_OFFSET+NPC_POSITION_SUBPIXEL_OFFSET, r1
    std Y+NPC_X_POSITION_OFFSET+NPC_POSITION_LOW_OFFSET, r1
    std Y+NPC_X_POSITION_OFFSET+NPC_POSITION_HIGH_OFFSET, r19
    std Y+NPC_X_VELOCITY_OFFSET, r1
    lpm r19, Z+    ; y pos
    std Y+NPC_Y_POSITION_OFFSET+NPC_POSITION_SUBPIXEL_OFFSET, r1
    std Y+NPC_Y_POSITION_OFFSET+NPC_POSITION_LOW_OFFSET, r1
    std Y+NPC_Y_POSITION_OFFSET+NPC_POSITION_HIGH_OFFSET, r19
    std Y+NPC_X_VELOCITY_OFFSET, r1
    adiw ZL, 1
    lpm r19, Z      ; initial health
    std Y+NPC_HEALTH_OFFSET, r19
    std Y+NPC_STATUS_OFFSET, r1
_ls_load_npcs_next:
    adiw YL, NPC_MEMSIZE
    dec r18
    brne _ls_load_npcs_iter
_ls_npcs_loaded:
    pop YH
    pop YL
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
