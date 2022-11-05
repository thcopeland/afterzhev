; Simple character physics. Horizontal and vertical movements are calculated
; separately in order to allow sliding on collisions.
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
;   r18-r25         calculations
;   r26             whether to apply friction (param)
;   Y (r28:r29)     character data pointer (param)
;   Z (r30:r31)     flash pointer
move_character:
    ldd r20, Y+CHARACTER_POSITION_X_H
    ldd r21, Y+CHARACTER_POSITION_Y_H
    sts subroutine_tmp, r20
    sts subroutine_tmp+1, r21
    ldd r22, Y+CHARACTER_POSITION_DX
    ldd r23, Y+CHARACTER_POSITION_DY
    ext r22, r24
    ldd r25, Y+CHARACTER_POSITION_X_L
    add r25, r22
    adc r20, r24
    add r25, r22
    adc r20, r24
    std Y+CHARACTER_POSITION_X_L, r25
    ext r23, r24
    ldd r25, Y+CHARACTER_POSITION_Y_L
    add r25, r23
    adc r21, r24
    add r25, r23
    adc r21, r24
    std Y+CHARACTER_POSITION_Y_L, r25
    tst r26
    breq _mc_save_speed
    decay_90p r22, r24, r25
    decay_90p r23, r24, r25
_mc_save_speed:
    std Y+CHARACTER_POSITION_DX, r22
    std Y+CHARACTER_POSITION_DY, r23
_mc_check_out_up:
    cpi r21, TILE_HEIGHT*SECTOR_HEIGHT
    brlo _mc_check_out_down
    std Y+CHARACTER_POSITION_Y_H, r21
    ret
_mc_check_out_down:
    cpi r21, TILE_HEIGHT*SECTOR_HEIGHT-CHARACTER_SPRITE_HEIGHT
    brlo _mc_check_out_left
    std Y+CHARACTER_POSITION_Y_H, r21
    ret
_mc_check_out_left:
    cpi r20, TILE_WIDTH*SECTOR_WIDTH
    brlo _mc_check_out_right
    std Y+CHARACTER_POSITION_X_H, r20
    ret
_mc_check_out_right:
    cpi r20, TILE_WIDTH*SECTOR_WIDTH-CHARACTER_SPRITE_WIDTH
    brlo _mc_check_collisions
    std Y+CHARACTER_POSITION_X_H, r20
    ret
_mc_check_collisions:
    std Y+CHARACTER_POSITION_X_H, r20
    std Y+CHARACTER_POSITION_Y_H, r21
    subi r20, low(-CHARACTER_COLLIDER_OFFSET_X)
    subi r21, low(-CHARACTER_COLLIDER_OFFSET_Y)
    ldi ZL, byte3(2*sector_table)
    out RAMPZ, ZL
    lds ZL, current_sector
    lds ZH, current_sector+1
    divmod12u r21, r24, r25
    ldi r21, SECTOR_WIDTH
    mul r21, r24
    add ZL, r0
    adc ZH, r1
    clr r1
    divmod12u r20, r21, r24
    add ZL, r21
    adc ZH, r1
    elpm r26, Z
    ldi r20, low(-1)
    ldi r21, 1
_mc_check_no_collision:
    cpi r26, END_FULL_BLOCKING_IDX
    brlo _mc_check_upper_left_blocked
    ret
_mc_check_upper_left_blocked:
    cpi r26, END_UPPER_LEFT_BLOCKING_IDX
    brsh _mc_check_lower_right_blocked
    rjmp _mc_resolve_angle_collision
_mc_check_lower_right_blocked:
    cpi r26, END_LOWER_RIGHT_BLOCKING_IDX
    brsh _mc_check_lower_left_blocked
    subi r24, 12
    neg r24
    subi r25, 12
    neg r25
    rjmp _mc_resolve_angle_collision
_mc_check_lower_left_blocked:
    neg r20
    cpi r26, END_LOWER_LEFT_BLOCKING_IDX
    brsh _mc_check_upper_right_blocked
    subi r25, 12
    neg r25
    rjmp _mc_resolve_angle_collision
_mc_check_upper_right_blocked:
    cpi r26, END_UPPER_RIGHT_BLOCKING_IDX
    brsh _mc_resolve_full_collison
    subi r24, 12
    neg r24
    rjmp _mc_resolve_angle_collision
_mc_resolve_full_collison:
    cpi r24, FULL_BLOCKING_MARGIN
    brsh _mc_rfc_right
    sbrs r22, 7
    neg r22
    asr r22
    asr r22
    rjmp _mc_rfc_top
_mc_rfc_right:
    cpi r24, TILE_WIDTH-FULL_BLOCKING_MARGIN
    brlo _mc_rfc_top
    sbrc r22, 7
    neg r22
    asr r22
    asr r22
_mc_rfc_top:
    cpi r25, FULL_BLOCKING_MARGIN
    brsh _mc_rfc_bottom
    sbrs r23, 7
    neg r23
    asr r23
    asr r23
    rjmp _mc_writeback_collision
_mc_rfc_bottom:
    cpi r25, TILE_HEIGHT-FULL_BLOCKING_MARGIN
    brlo _mc_writeback_collision
    sbrc r23, 7
    neg r23
    asr r23
    asr r23
    rjmp _mc_writeback_collision
_mc_resolve_angle_collision:
    add r24, r25
    cpi r24, TILE_WIDTH+1
    brsh _mc_end
    ; optimized sliding calculation for 45 degree walls
    ; v, v', s                ; initial velocity, final velocity, wall parallel
    ; s_x = +-1, s_y = +-1
    ; S = s (dot) v           ; resulting speed along wall
    ;   = s_xv_x + s_yv_y
    ; v' = Ss/sqrt(2)
    ; => v_x' = (v_x + s_xs_yv_y)/sqrt(2)
    ;         = v_x/sqrt(2) + s_xs_y(v_y/sqrt(2))
    ; => v_y' = (v_xs_yv_x + v_y)/sqrt(2)
    ;         = s_xs_y(v_x/sqrt(2)) + v_y/sqrt(2)
    movw r24, r22
    asr r24
    asr r24
    asr r25
    asr r25
    sub r22, r24 ; using 0.75 as a 1/sqrt(2) approximation
    sub r23, r25
    sbrc r21, 7
    neg r20
    movw r24, r22
    sbrc r20, 7
    neg r24
    sbrc r20, 7
    neg r25
    adnv r22, r25
    adnv r23, r24
_mc_writeback_collision:
    std Y+CHARACTER_POSITION_DX, r22
    std Y+CHARACTER_POSITION_DY, r23
    lds r0, subroutine_tmp
    std Y+CHARACTER_POSITION_X_H, r0
    lds r0, subroutine_tmp+1
    std Y+CHARACTER_POSITION_Y_H, r0
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
_uca_effect_heal: ; TODO
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
    cpi r23, ITEM_ANIM_ATTACK_FRAMES
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
_csd_end:
    ret
