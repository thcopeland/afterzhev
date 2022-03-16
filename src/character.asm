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
;   r20-r24         calculations
;   r26             whether to apply friction (param)
;   Y (r28:r29)     character data pointer (param)
move_character:
_mc_horizontal_component:
    ldd r20, Y+CHARACTER_POSITION_X_H
    ldd r21, Y+CHARACTER_POSITION_X_L
    ldd r22, Y+CHARACTER_POSITION_DX
    tst r22
    breq _mc_vertical_component
    ext r22, r23
    add r21, r22
    adc r20, r23
    add r21, r22
    adc r20, r23
    std Y+CHARACTER_POSITION_X_L, r21
    tst r26
    breq _mc_post_horizontal_friction
    decay_90p r22, r23, r24     ; friction
_mc_post_horizontal_friction:
    std Y+CHARACTER_POSITION_DX, r22
    mov r24, r20
    ldd r25, Y+CHARACTER_POSITION_Y_H
    rcall resolve_character_movement
_mc_vertical_component:
    ldd r20, Y+CHARACTER_POSITION_Y_H
    ldd r21, Y+CHARACTER_POSITION_Y_L
    ldd r22, Y+CHARACTER_POSITION_DY
    tst r22
    breq _mc_end
    ext r22, r23
    add r21, r22
    adc r20, r23
    add r21, r22
    adc r20, r23
    std Y+CHARACTER_POSITION_Y_L, r21
    tst r26
    breq _mc_post_vertical_friction
    decay_90p r22, r23, r24     ; friction
_mc_post_vertical_friction:
    std Y+CHARACTER_POSITION_DY, r22
    ldd r24, Y+CHARACTER_POSITION_X_H
    mov r25, r20
    rcall resolve_character_movement
_mc_end:
    ret

; Check for collisions. If none occur, the new position is saved.
;
; NOTE - when the character is near the edge of the map, the collision box
; corners may fall outside the sector. We treat these cases as if there were no
; collision and rely on other code to check and handle this situation (for the
; player, switch sectors, for enemies, restrict to the sector.)
;
; TODO - could this be inlined into move_character?
;
; Register Usage
;   r18-r23         calculations
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
    brlt _rcm_no_collision_trampoline
    subi r19, low(-(TILE_HEIGHT-CHARACTER_COLLIDER_HEIGHT)/2)
    brlt _rcm_no_collision_trampoline
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
    cpi r18, SECTOR_WIDTH*TILE_WIDTH
    brsh _rcm_no_collision_trampoline
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
    brlo _rcm_check_lower_left
    rjmp _rcm_collision
_rcm_no_collision_trampoline:
    rjmp _rcm_no_collision
_rcm_check_lower_left:
    lds ZL, current_sector
    lds ZH, current_sector+1
    movw r18, r24
    subi r18, low(-(TILE_WIDTH-CHARACTER_COLLIDER_WIDTH)/2)
    subi r19, low(-(TILE_HEIGHT+CHARACTER_COLLIDER_HEIGHT-1)/2)
    cpi r19, SECTOR_HEIGHT*TILE_HEIGHT
    brsh _rcm_no_collision
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
;   r18-r20     calculations
;   r21         character effect (param)
;   r22         character action (param)
;   r23         character frame (param)
;   r24         character velocity x (param)
;   r25         character velocity y (param)
update_character_animation:
_uca_check_effect:
    cpi r21, 1<<4
    brlo _uca_action_idle
_uca_effect_damage:
    cpi r21, (EFFECT_DAMAGE+1)<<4
    brsh _uca_effect_heal
    lds r20, clock
    andi r20, EFFECT_DAMAGE_FRAME_DURATION_MASK
    brne _uca_action_idle
    ldi r20, EFFECT_DAMAGE_DURATION
_uca_effect_heal: ; TODO
_uca_effect_upgrade:
_uca_update_effect:
    inc r21
    mov r19, r21
    andi r19, 0xf
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
;   r0      result
;   r24     calculations
;   r25     weapon id (param)
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
