; Simple character physics. Horizontal and vertical movements are calculated
; separately in order to allow nice sliding on collisions (I think this wouldn't
; be necessary if collisions considered more than a single tile, but I don't
; really want to go there.)
;
; Five different types of collision tiles are supported.
;   - FULLY_BLOCKED is resolved as a square
;   - UPPER_LEFT_BLOCKED is resolved as a triangle filling the upper-left half of
;     the tile.
;   - UPPER_RIGHT_BLOCKED, LOWER_LEFT_BLOCKED, and LOWER_RIGHT_BLOCKED follow the
;     same pattern as you'd expect.
;
; Collisions against features are also resolved here, since those are considered
; part of the world map (as opposed to NPCs, which are handled elsewhere). These
; are resolved as a 45-degree angle square, an easy approximation to the ideal circle.
;
; The character pointer should be a pointer to memory with the following layout:
;   x position (1 byte)
;   x subpixel position (1 byte)
;   x velocity (1 byte)
;   y position (1 byte)
;   y subpixel position (1 byte)
;   y velocity (1 byte)
;
; Register Usage
;   r20-r25         calculations
;   Y (r28:r29)     character data pointer (param)
;   Z (r30:r31)     flash pointer
move_character:
    ldi ZL, byte3(2*sector_table)
    out RAMPZ, ZL
_mc_x_movement:
    ldd r20, Y+CHARACTER_POSITION_X_H
    mov r21, r20
    sts subroutine_tmp, r20
    ldd r22, Y+CHARACTER_POSITION_DX
    ext r22, r24
    ldd r25, Y+CHARACTER_POSITION_X_L
    add r25, r22
    adc r20, r24
    add r25, r22
    adc r20, r24
    add r25, r22
    adc r20, r24
    std Y+CHARACTER_POSITION_X_L, r25
    std Y+CHARACTER_POSITION_X_H, r20
    decay_90p r22, r24, r25
_mcx_save_speed:
    std Y+CHARACTER_POSITION_DX, r22
_mcx_check_out_of_bounds:
    cpi r20, TILE_WIDTH*SECTOR_WIDTH
    brsh _mcx_out_of_bounds
    cpi r20, TILE_WIDTH*SECTOR_WIDTH-CHARACTER_SPRITE_WIDTH
    brlo _mcx_check_collision
_mcx_out_of_bounds:
    ret
_mcx_check_collision:
    ldd r23, Y+CHARACTER_POSITION_Y_H
    subi r20, low(-CHARACTER_COLLIDER_OFFSET_X)
    subi r23, low(-CHARACTER_COLLIDER_OFFSET_Y)
    lds ZL, current_sector
    lds ZH, current_sector+1
    divmod12u r23, r24, r25
    ldi r23, SECTOR_WIDTH
    mul r23, r24
    add ZL, r0
    adc ZH, r1
    clr r1
    divmod12u r20, r23, r24
    add ZL, r23
    adc ZH, r1
    elpm r20, Z
_mcx_check_no_collision:
    cpi r20, END_FULL_BLOCKING_IDX
    brlo _mcx_check_upper_left_blocked
    rjmp _mc_y_movement
_mcx_check_upper_left_blocked:
    cpi r20, END_UPPER_LEFT_BLOCKING_IDX
    brsh _mcx_check_lower_right_blocked
    ldi r20, -1
    rjmp _mcx_resolve_angle_collision
_mcx_check_lower_right_blocked:
    cpi r20, END_LOWER_RIGHT_BLOCKING_IDX
    brsh _mcx_check_lower_left_blocked
    subi r24, TILE_WIDTH-1
    neg r24
    subi r25, TILE_HEIGHT-1
    neg r25
    ldi r20, -1
    rjmp _mcx_resolve_angle_collision
_mcx_check_lower_left_blocked:
    cpi r20, END_LOWER_LEFT_BLOCKING_IDX
    brsh _mcx_check_upper_right_blocked
    subi r25, TILE_HEIGHT-1
    neg r25
    ldi r20, 1
    rjmp _mcx_resolve_angle_collision
_mcx_check_upper_right_blocked:
    cpi r20, END_UPPER_RIGHT_BLOCKING_IDX
    brsh _mcx_resolve_full_collison
    subi r24, TILE_WIDTH-1
    neg r24
    ldi r20, 1
    rjmp _mcx_resolve_angle_collision
_mcx_resolve_full_collison:
    asr r22
    asr r22
    neg r22
    std Y+CHARACTER_POSITION_DX, r22
    std Y+CHARACTER_POSITION_X_H, r21
    rjmp _mc_y_movement
_mcx_resolve_angle_collision:
    add r24, r25
    cpi r24, TILE_WIDTH
    brsh _mc_y_movement
    ldd r23, Y+CHARACTER_POSITION_DY
    movw r24, r22
    asr r24
    asr r24
    asr r25
    asr r25
    sub r22, r24 ; using 0.75 as a 1/sqrt(2) approximation
    sub r23, r25
    std Y+CHARACTER_POSITION_DX, r22
    sbrc r20, 7
    neg r22
    adnv r23, r22
    std Y+CHARACTER_POSITION_DY, r23
    std Y+CHARACTER_POSITION_X_H, r21
_mc_y_movement:
    ldd r20, Y+CHARACTER_POSITION_Y_H
    mov r21, r20
    sts subroutine_tmp+1, r20
    ldd r22, Y+CHARACTER_POSITION_DY
    ext r22, r24
    ldd r25, Y+CHARACTER_POSITION_Y_L
    add r25, r22
    adc r20, r24
    add r25, r22
    adc r20, r24
    add r25, r22
    adc r20, r24
    std Y+CHARACTER_POSITION_Y_L, r25
    std Y+CHARACTER_POSITION_Y_H, r20
    decay_90p r22, r24, r25
_mcy_save_speed:
    std Y+CHARACTER_POSITION_DY, r22
_mcy_check_out_of_bounds:
    cpi r20, TILE_HEIGHT*SECTOR_HEIGHT
    brsh _mcy_out_of_bounds
    cpi r20, TILE_HEIGHT*SECTOR_HEIGHT-CHARACTER_SPRITE_HEIGHT
    brlo _mcy_check_collision
_mcy_out_of_bounds:
    ret
_mcy_check_collision:
    ldd r23, Y+CHARACTER_POSITION_X_H
    subi r20, low(-CHARACTER_COLLIDER_OFFSET_Y)
    subi r23, low(-CHARACTER_COLLIDER_OFFSET_X)
    lds ZL, current_sector
    lds ZH, current_sector+1
    divmod12u r23, r25, r24
    add ZL, r25
    adc ZH, r1
    divmod12u r20, r23, r25
    ldi r20, SECTOR_WIDTH
    mul r23, r20
    add ZL, r0
    adc ZH, r1
    clr r1
    elpm r20, Z
_mcy_check_no_collision:
    cpi r20, END_FULL_BLOCKING_IDX
    brlo _mcy_check_upper_left_blocked
    rjmp _mc_check_features
_mcy_check_upper_left_blocked:
    cpi r20, END_UPPER_LEFT_BLOCKING_IDX
    brsh _mcy_check_lower_right_blocked
    ldi r20, -1
    rjmp _mcy_resolve_angle_collision
_mcy_check_lower_right_blocked:
    cpi r20, END_LOWER_RIGHT_BLOCKING_IDX
    brsh _mcy_check_lower_left_blocked
    subi r24, TILE_WIDTH-1
    neg r24
    subi r25, TILE_HEIGHT-1
    neg r25
    ldi r20, -1
    rjmp _mcy_resolve_angle_collision
_mcy_check_lower_left_blocked:
    cpi r20, END_LOWER_LEFT_BLOCKING_IDX
    brsh _mcy_check_upper_right_blocked
    subi r25, TILE_HEIGHT-1
    neg r25
    ldi r20, 1
    rjmp _mcy_resolve_angle_collision
_mcy_check_upper_right_blocked:
    cpi r20, END_UPPER_RIGHT_BLOCKING_IDX
    brsh _mcy_resolve_full_collison
    subi r24, TILE_WIDTH-1
    neg r24
    ldi r20, 1
    rjmp _mcy_resolve_angle_collision
_mcy_resolve_full_collison:
    asr r22
    asr r22
    neg r22
    std Y+CHARACTER_POSITION_DY, r22
    std Y+CHARACTER_POSITION_Y_H, r21
    rjmp _mc_check_features
_mcy_resolve_angle_collision:
    add r24, r25
    cpi r24, TILE_WIDTH
    brsh _mc_check_features
    ldd r23, Y+CHARACTER_POSITION_DX
    movw r24, r22
    asr r24
    asr r24
    asr r25
    asr r25
    sub r22, r24
    sub r23, r25
    std Y+CHARACTER_POSITION_DY, r22
    sbrc r20, 7
    neg r22
    adnv r23, r22
    std Y+CHARACTER_POSITION_DX, r23
    std Y+CHARACTER_POSITION_Y_H, r21
_mc_check_features:
    lds ZL, current_sector
    lds ZH, current_sector+1
    subi ZL, low(-SECTOR_FEATURES_OFFSET)
    sbci ZH, high(-SECTOR_FEATURES_OFFSET)
    ldd r24, Y+CHARACTER_POSITION_X_H
    ldd r25, Y+CHARACTER_POSITION_Y_H
    subi r24, low(-CHARACTER_COLLIDER_OFFSET_X+FEATURE_SPRITE_WIDTH/2)
    subi r25, low(-CHARACTER_COLLIDER_OFFSET_Y+FEATURE_SPRITE_HEIGHT/2)
    ldi r26, SECTOR_FEATURE_COUNT
_mc_features_iter:
    elpm r20, Z+
    elpm r22, Z+
    elpm r23, Z+
    dec r20
    brmi _mcf_next_trampoline
    cpi r20, MAX_FEATURE_COLLIDE_IDX
    brlo _mcf_calculate_distance
_mcf_next_trampoline:
    rjmp _mc_features_next
_mcf_calculate_distance:
    sub r22, r24
    mov r21, r22
    brcc _mfc_cd_1
    neg r21
_mfc_cd_1:
    sub r23, r25
    mov r0, r23
    brcc _mfc_cd_2
    neg r0
_mfc_cd_2:
    add r21, r0
    brcc _mfc_cd_3
    ser r21
_mfc_cd_3:
    cpi r21, FEATURE_COLLIDE_RANGE
    brsh _mc_features_next
    ; NOTE: Not particularly proud of the "check_horizontal/vertical_corners" special
    ; casing. Without it, though, there's a tendency to get stuck on the corners.
    ; I tried a lot of stuff to fix it, this is the only one that worked really
    ; reliable.
_mcf_check_horizonal_corners:
    tst r23
    brne _mcf_check_vertical_corners
    lds r24, subroutine_tmp
    std Y+CHARACTER_POSITION_X_H, r24
    ret
_mcf_check_vertical_corners:
    tst r22
    brne _mcf_tilted_square_check
    lds r25, subroutine_tmp+1
    std Y+CHARACTER_POSITION_Y_H, r25
    ret
_mcf_tilted_square_check:
    mov r21, r22
    eor r21, r23 ; cunning quadrant check
    ldd r22, Y+CHARACTER_POSITION_DX
    ldd r23, Y+CHARACTER_POSITION_DY
    asr r22
    asr r23
    movw r24, r22
    sbrs r21, 7
    neg r25
    adnv r22, r25
    sbrs r21, 7
    neg r24
    adnv r23, r24
    std Y+CHARACTER_POSITION_DX, r22
    std Y+CHARACTER_POSITION_DY, r23
    lds r24, subroutine_tmp
    lds r25, subroutine_tmp+1
    std Y+CHARACTER_POSITION_X_H, r24
    std Y+CHARACTER_POSITION_Y_H, r25
    ret
_mc_features_next:
    dec r26
    breq _mc_end
    rjmp _mc_features_iter
_mc_end:
    ret

; Update the character's animation and some general state.
;
; Register Usage
;   r18-r20     calculations
;   r21         character effect (param)
;   r22         character action (param)
;   r23         character frame (param)
;   r24         character velocity x (param)
;   r25         character velocity y (param)
update_character_animation:
_uca_check_effect:
    mov r20, r21
    andi r20, 0x38
    breq _uca_action_idle
_uca_effect_damage:
    cpi r20, EFFECT_DAMAGE<<3
    brne _uca_effect_heal
    lds r20, clock
    andi r20, EFFECT_DAMAGE_FRAME_DURATION_MASK
    brne _uca_action_idle
    ldi r20, EFFECT_DAMAGE_DURATION
    sbrc r21, 2
    ldi r20, 2*EFFECT_DAMAGE_DURATION
    rjmp _uca_update_effect
_uca_effect_heal:
    cpi r20, EFFECT_HEALING<<3
    brne _uca_effect_upgrade
    lds r20, clock
    andi r20, EFFECT_HEALING_FRAME_DURATION_MASK
    brne _uca_action_idle
    ldi r20, EFFECT_HEALING_DURATION
    rjmp _uca_update_effect
_uca_effect_upgrade:
_uca_update_effect:
    inc r21
    mov r19, r21
    andi r19, 0x7
    breq _uca_clear_effects
    cp r19, r20
    brlo _uca_action_idle
_uca_clear_effects:
    clr r21
_uca_action_idle:
    cpi r22, ACTION_IDLE
    brne _uca_action_walk
    movw r18, r24
    sbrc r18, 7
    neg r18
    sbrc r19, 7
    neg r19
    add r18, r19
    cpi r18, IDLE_MAX_SPEED
    brlo _uca_end
    ldi r22, ACTION_WALK
    clr r23
    ret
_uca_action_walk:
    cpi r22, ACTION_WALK
    brne _uca_action_attack
    movw r18, r24
    sbrc r18, 7
    neg r18
    sbrc r19, 7
    neg r19
    add r18, r19
    breq _uca_walk_to_idle
    lds r19, clock
    cpi r18, RUN_MIN_SPEED
    brsh _uca_walk_fast
_uca_walk_slow:
    andi r19, WALK_FRAME_DURATION_MASK
    brne _uca_end
    inc r23
    andi r23, 3
    ret
_uca_walk_fast:
    andi r19, RUN_FRAME_DURATION_MASK
    brne _uca_end
    inc r23
    andi r23, 3
    ret
_uca_walk_to_idle:
    ldi r22, ACTION_IDLE
    clr r23
    ret
_uca_action_attack:
    cpi r22, ACTION_ATTACK
    brne _uca_action_dash
    lds r19, clock
    andi r19, ATTACK_FRAME_DURATION_MASK
    brne _uca_end
    inc r23
    cpi r23, WEAPON_ATTACK_FRAMES
    brlo _uca_end
    tst r24
    brne _uca_attack_to_walk
    tst r25
    brne _uca_attack_to_walk
_uca_attack_to_idle:
    ldi r22, ACTION_IDLE
    clr r23
    rjmp _uca_end
_uca_attack_to_walk:
    ldi r22, ACTION_WALK
    clr r23
_uca_action_dash:
    cpi r22, ACTION_DASH
    brne _uca_end
    lds r19, clock
    andi r19, DASH_FRAME_DURATION_MASK
    inc r23
    cpi r23, DASH_DURATION
    brlo _uca_end
    ldi r22, ACTION_WALK
    clr r23
_uca_end:
    ret

; Calculate the distance between two characters, accounting for the facing direction
; of the reference character.
;
; Register Usage
;   r22             reference character x (param), calculated horizontal distance
;   r23             reference character y (param), calculated vertical distance
;   r24             second character x (param), calculations
;   r25             second character y (param), manhattan distance
;   r26             reference character direction (param)
biased_character_distance:
    cpi r26, DIRECTION_DOWN
    brne _bdc_facing_right
    subi r23, -DIRECTION_BIAS
_bdc_facing_right:
    cpi r26, DIRECTION_RIGHT
    brne _bdc_facing_up
    subi r22, -DIRECTION_BIAS
_bdc_facing_up:
    cpi r26, DIRECTION_UP
    brne _bdc_facing_left
    subi r23, DIRECTION_BIAS
_bdc_facing_left:
    cpi r26, DIRECTION_LEFT
    brne _bdc_calculate_distance
    subi r22, DIRECTION_BIAS
_bdc_calculate_distance:
    sub r22, r24
    sbrc r22, 7
    neg r22
    sub r23, r25
    sbrc r23, 7
    neg r23
    mov r25, r22
    add r25, r23
    ret

; Calculate the striking distance of the given weapon.
;
; Register Usage
;   r0              result
;   r24             calculations
;   r25             weapon id (param)
;   Z (r30:r31)     flash pointer
character_striking_distance:
    dec r25
    brmi _csd_end
    ldi ZL, byte3(2*item_table)
    out RAMPZ, ZL
    ldi ZL, low(2*item_table+ITEM_FLAGS_OFFSET)
    ldi ZH, high(2*item_table+ITEM_FLAGS_OFFSET)
    ldi r24, ITEM_MEMSIZE
    mul r24, r25
    add ZL, r0
    adc ZH, r1
    elpm r25, Z
    andi r25, 0xc0
    swap r25
    lsr r25
    lsr r25
    inc r25
    ldi r24, STRIKING_DISTANCE
    mul r24, r25
    lsr r1
    ror r0
    clr r1
    lsr r24
    add r0, r24
_csd_end:
    ret
