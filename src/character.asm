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
;   r18-r24         calculations
;   Y (r28:r29)     character data pointer (param)
move_character:
_mc_horizontal_component:
    ldd r18, Y+CHARACTER_POSITION_X_H
    ldd r19, Y+CHARACTER_POSITION_X_L
    ldd r20, Y+CHARACTER_POSITION_DX
    tst r20
    breq _mc_vertical_component
    ext r20, r21
    add r19, r20
    adc r18, r21
    add r19, r20
    adc r18, r21
    std Y+CHARACTER_POSITION_X_L, r19
    decay_95p r20, r21, r22     ; friction
    std Y+CHARACTER_POSITION_DX, r20
    mov r24, r18
    ldd r25, Y+CHARACTER_POSITION_Y_H
    rcall resolve_character_movement
_mc_vertical_component:
    ldd r18, Y+CHARACTER_POSITION_Y_H
    ldd r19, Y+CHARACTER_POSITION_Y_L
    ldd r20, Y+CHARACTER_POSITION_DY
    tst r20
    breq _mc_end
    ext r20, r21
    add r19, r20
    adc r18, r21
    add r19, r20
    adc r18, r21
    std Y+CHARACTER_POSITION_Y_L, r19
    decay_95p r20, r21, r22     ; friction
    std Y+CHARACTER_POSITION_DY, r20
    ldd r24, Y+CHARACTER_POSITION_X_H
    mov r25, r18
    rcall resolve_character_movement
_mc_end:
    ret

; Check for collisions. If none occur, the new position is saved.
;
; Register Usage
;   r20-r23         calculations
;   r24             new x position (param)
;   r25             new y position (param)
;   Y (r28:r29)     character position pointer (param)
;   Z (r30:r31)     sector pointer
resolve_character_movement:
    ldi ZL, byte3(2*sector_table)
    out RAMPZ, ZL
_rcm_check_upper_left:
    lds ZL, current_sector
    lds ZH, current_sector+1
    movw r18, r24
    subi r18, low(-(TILE_WIDTH-CHARACTER_COLLIDER_WIDTH)/2)
    subi r19, low(-(TILE_HEIGHT-CHARACTER_COLLIDER_HEIGHT)/2)
    div12u r18, r20
    div12u r19, r21
    ldi r22, SECTOR_WIDTH
    mul r21, r22
    add ZL, r0
    adc ZH, r1
    clr r1
    add ZL, r20
    adc ZH, r1
    elpm r22, Z
    cpi r22, MIN_BLOCKING_TILE_IDX
    brlo _rcm_check_upper_right
    rjmp _rcm_collision
_rcm_check_upper_right:
    lds ZL, current_sector
    lds ZH, current_sector+1
    mov r18, r24
    subi r18, low(-(TILE_WIDTH+CHARACTER_COLLIDER_WIDTH-1)/2)
    div12u r18, r20
    ldi r22, SECTOR_WIDTH
    mul r21, r22
    add ZL, r0
    adc ZH, r1
    clr r1
    add ZL, r20
    adc ZH, r1
    elpm r22, Z
    cpi r22, MIN_BLOCKING_TILE_IDX
    brsh _rcm_collision
_rcm_check_lower_left:
    lds ZL, current_sector
    lds ZH, current_sector+1
    movw r18, r24
    subi r18, low(-(TILE_WIDTH-CHARACTER_COLLIDER_WIDTH)/2)
    subi r19, low(-(TILE_HEIGHT+CHARACTER_COLLIDER_HEIGHT-1)/2)
    div12u r18, r20
    div12u r19, r21
    ldi r22, SECTOR_WIDTH
    mul r21, r22
    add ZL, r0
    adc ZH, r1
    clr r1
    add ZL, r20
    adc ZH, r1
    elpm r22, Z
    cpi r22, MIN_BLOCKING_TILE_IDX
    brsh _rcm_collision
_rcm_check_lower_right:
    lds ZL, current_sector
    lds ZH, current_sector+1
    mov r18, r24
    subi r18, low(-(TILE_WIDTH+CHARACTER_COLLIDER_WIDTH-1)/2)
    div12u r18, r20
    ldi r22, SECTOR_WIDTH
    mul r21, r22
    add ZL, r0
    adc ZH, r1
    clr r1
    add ZL, r20
    adc ZH, r1
    elpm r22, Z
    cpi r22, MIN_BLOCKING_TILE_IDX
    brsh _rcm_collision
_rcm_no_collision:
    std Y+CHARACTER_POSITION_X_H, r24
    std Y+CHARACTER_POSITION_Y_H, r25
    ret
_rcm_collision:
    ldd r18, Y+CHARACTER_POSITION_X_H
    cpse r18, r24
    std Y+CHARACTER_POSITION_DX, r1
    ldd r18, Y+CHARACTER_POSITION_Y_H
    cpse r18, r25
    std Y+CHARACTER_POSITION_DY, r1
    ret

; Update the character's animation and some general state.
;
; Register Usage
;   r18-r21     calculations
;   r22         character action (param)
;   r23         character frame (param)
;   r24         character velocity x (param)
;   r25         character velocity y (param)
update_character_animation:
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
    brne _uca_action_hurt
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
_uca_action_hurt:
    cpi r22, ACTION_HURT
    brne _uca_action_attack
_uca_action_attack:
    lds r19, clock
    andi r19, ATTACK_FRAME_DURATION_MASK
    brne _uca_end
    inc r23
    cpi r23, ITEM_ANIM_ATTACK_FRAMES
    brlo _uca_end
_uca_attack_to_idle:
    ldi r22, ACTION_IDLE
    clr r23
_uca_end:
    ret
