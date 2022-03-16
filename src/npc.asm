; Move around at a constant speed, negating x velocity when colliding with a
; horizontal barrier, and negating y velocity when colliding with a vertical
; barrier.
;
; Register Usage
;   r16-r17         call-saved values
;   r20-r25         calculations
;   Y (r28:r29)     enemy pointer (param)
enemy_patrol:
    push r16
    push r17
    ldd r16, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DX
    ldd r17, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DY
    clr r26
    adiw YL, NPC_POSITION_OFFSET
    call move_character
    sbiw YL, NPC_POSITION_OFFSET
_ep_test_reverse_x:
    ldd r24, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DX
    cp r16, r24
    brne _ep_reverse_x
    ldd r24, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H
    cpi r24, 1
    brlo _ep_reverse_x
    cpi r24, TILE_WIDTH*SECTOR_WIDTH - CHARACTER_SPRITE_WIDTH
    brlo _ep_test_reverse_y
_ep_reverse_x:
    ldd r24, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H
    neg r16
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DX, r16
_ep_test_reverse_y:
    ldd r25, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DY
    cp r17, r25
    brne _ep_reverse_y
    ldd r25, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H
    cpi r25, 1
    brlo _ep_reverse_y
    cpi r25, TILE_HEIGHT*SECTOR_HEIGHT - CHARACTER_SPRITE_HEIGHT
    brlo _ep_calculate_direction
_ep_reverse_y:
    neg r17
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DY, r17
_ep_calculate_direction:
    ldd r16, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DX
    movw r18, r16
    sbrc r18, 7
    neg r18
    sbrc r19, 7
    neg r19
    cp r18, r19
    brlo _ep_vertical
_ep_horizontal:
    ldi r20, DIRECTION_RIGHT
    sbrc r16, 7
    ldi r20, DIRECTION_LEFT
    rjmp _ep_set_direction
_ep_vertical:
    ldi r20, DIRECTION_DOWN
    sbrc r17, 7
    ldi r20, DIRECTION_UP
_ep_set_direction:
    ldd r21, Y+NPC_ANIM_OFFSET
    andi r21, 0xfc
    or r21, r20
    std Y+NPC_ANIM_OFFSET, r21
_ep_end:
    pop r17
    pop r16
    ret

; If within striking range, attack. Otherwise, head towards the player.
;
; Register Usage
;   r18-r26         calculations
;   Y (r28:r29)     enemy pointer (param)
;   Z (r30:r31)     flash pointer
enemy_charge:
    ser r26
    adiw YL, NPC_POSITION_OFFSET
    call move_character
    sbiw YL, NPC_POSITION_OFFSET
    lds r18, player_position_x
    lds r19, player_position_y
    ldd r20, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H
    ldd r21, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H
    movw r22, r20
    sub r22, r18
    sub r23, r19
    sbrc r22, 7
    neg r22
    sbrc r23, 7
    neg r23
    cp r22, r23
    brlo _ec_orient_vertical
_ec_orient_horizontal:
    ldi r25, DIRECTION_LEFT
    cp r20, r18
    brsh _ec_save_direction
    ldi r25, DIRECTION_RIGHT
    rjmp _ec_save_direction
_ec_orient_vertical:
    ldi r25, DIRECTION_UP
    cp r21, r19
    brsh _ec_save_direction
    ldi r25, DIRECTION_DOWN
_ec_save_direction:
    ldd r24, Y+NPC_ANIM_OFFSET
    andi r24, 0xfc
    or r24, r25
    std Y+NPC_ANIM_OFFSET, r24
_ec_calculate_distance:
    movw r22, r20
    mov r26, r25
    lds r24, player_position_x
    lds r25, player_position_y
    call biased_character_distance
    mov r26, r25
    ldi ZL, byte3(2*npc_table)
    out RAMPZ, ZL
    ldi ZL, low(2*npc_table+NPC_TABLE_WEAPON_OFFSET)
    ldi ZH, high(2*npc_table+NPC_TABLE_WEAPON_OFFSET)
    ldd r24, Y+NPC_IDX_OFFSET
    ldi r25, NPC_TABLE_ENTRY_MEMSIZE
    dec r24
    mul r24, r25
    add ZL, r0
    adc ZH, r1
    clr r1
    elpm r25, Z
    call character_striking_distance
    cp r26, r0
    brsh _ec_approach_player
_ec_attack_player:
    ldd r24, Y+NPC_ANIM_OFFSET
    cpi r24, ACTION_ATTACK<<5
    brsh _ec_attack_end
    andi r24, 0x1f
    ori r24, ACTION_ATTACK<<5
    std Y+NPC_ANIM_OFFSET, r24
_ec_attack_end:
    ret
_ec_approach_player:
    ldi ZL, low(2*npc_table+NPC_TABLE_ENEMY_ACC_OFFSET)
    ldi ZH, high(2*npc_table+NPC_TABLE_ENEMY_ACC_OFFSET)
    ldd r24, Y+NPC_IDX_OFFSET
    ldi r25, NPC_TABLE_ENTRY_MEMSIZE
    dec r24
    mul r24, r25
    add ZL, r0
    adc ZH, r1
    clr r1
    elpm r26, Z
    mov r27, r26
    ldd r24, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DX
    ldd r25, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DY
_ec_horizontal_movement:
    cpi r22, STRIKING_DISTANCE
    brsh _ec_horizontal_direction
    lsr r26
    cpi r22, STRIKING_DISTANCE/2
    brlo _ec_vertical_movement
_ec_horizontal_direction:
    cp r18, r20
    brsh _ec_acc_x
    neg r26
_ec_acc_x:
    adnv r24, r26
_ec_vertical_movement:
    cpi r23, STRIKING_DISTANCE
    brsh _ec_vertical_direction
    lsr r27
    cpi r23, STRIKING_DISTANCE/2
    brlo _ec_random_boost
_ec_vertical_direction:
    cp r19, r21
    brsh _ec_acc_y
    neg r27
_ec_acc_y:
    adnv r25, r27
_ec_random_boost:
    lds r22, clock
    andi r22, 0x1f
    brne _ec_save_velocity
    call rand
    movw r20, r0
    clr r1
    asr r20
    asr r20
    asr r21
    asr r21
    adnv r24, r20
    adnv r25, r21
_ec_save_velocity:
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DX, r24
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DY, r25
    ret

; Update the enemy's animations, resolve attacks, and check for collisions.
;
; Register Usage
;   r21-r25         calculations
;   Y (r28:r29)     enemy pointer (param)
;   Z (r30:r31)     aux enemy pointer, flash pointer
enemy_update:
    ldd r21, Y+NPC_EFFECT_OFFSET
    ldd r23, Y+NPC_ANIM_OFFSET
    lsr r23
    mov r22, r23
    lsr r23
    andi r23, 7
    swap r22
    andi r22, 7
    ldd r24, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DX
    ldd r25, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DY
    call update_character_animation
    std Y+NPC_EFFECT_OFFSET, r21
    ldd r24, Y+NPC_ANIM_OFFSET
    andi r24, 3
    swap r22
    lsl r22
    or r24, r22
    lsl r23
    lsl r23
    or r24, r23
    std Y+NPC_ANIM_OFFSET, r24
_eu_collisions:
    rcall enemy_fighting_space
_eu_npc_on_npc_collision:
    ldi ZL, low(sector_npcs+(SECTOR_DYNAMIC_NPC_COUNT-1)*NPC_MEMSIZE)
    ldi ZH, high(sector_npcs+(SECTOR_DYNAMIC_NPC_COUNT-1)*NPC_MEMSIZE)
_eu_npc_iter:
    ldd r22, Z+NPC_IDX_OFFSET
    tst r22
    breq _eu_npc_next
    cp YL, ZL
    cpc YH, ZH
    breq _eu_end
    rcall enemy_personal_space
_eu_npc_next:
    sbiw ZL, NPC_MEMSIZE
    rjmp _eu_npc_iter
_eu_end:
    ret

; Constrain the enemy to the sector bounds.
;
; Register Usage
;   r20-r21         calculations
;   Y (r28:r29)     enemy pointer (param)
enemy_sector_bounds:
    ldd r20, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H
    ldd r21, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H
_esb_left_edge:
    cpi r20, 250
    brlo _esb_right_edge
    clr r20
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DX, r1
_esb_right_edge:
    cpi r20, SECTOR_WIDTH*TILE_WIDTH-CHARACTER_SPRITE_WIDTH+1
    brlo _esb_top_edge
    ldi r20, SECTOR_WIDTH*TILE_WIDTH-CHARACTER_SPRITE_WIDTH
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DX, r1
_esb_top_edge:
    cpi r21, 250
    brlo _esb_bottom_edge
    clr r21
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DY, r1
_esb_bottom_edge:
    cpi r21, SECTOR_HEIGHT*TILE_HEIGHT-CHARACTER_SPRITE_HEIGHT+1
    brlo _esb_save_position
    ldi r21, SECTOR_HEIGHT*TILE_HEIGHT-CHARACTER_SPRITE_HEIGHT
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DY, r1
_esb_save_position:
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H, r20
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H, r21
    ret

; Apply a repulsive force between an enemy and another nearby enemy to ensure
; that they don't overlap.
;
; Register Usage
;   r22-25          calculations
;   Y (r28:r29)     enemy 1 (param)
;   Z (r30:r31)     enemy 2 (param)
enemy_personal_space:
    ldd r22, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H
    ldd r23, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H
    ldd r24, Z+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H
    ldd r25, Z+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H
_eps_horiz:
    sub r22, r24
    ldi r24, NPC_NPC_REPULSION
    brsh _eps_vert
    neg r22
    neg r24
_eps_vert:
    sub r23, r25
    ldi r25, NPC_NPC_REPULSION
    brsh _eps_check_dist
    neg r23
    neg r25
_eps_check_dist:
    cpi r22, CHARACTER_COLLIDER_WIDTH+1
    brsh _eps_end
    cpi r23, CHARACTER_COLLIDER_HEIGHT+1
    brsh _eps_end
    add r22, r23
    cpi r22, (CHARACTER_COLLIDER_WIDTH+CHARACTER_COLLIDER_HEIGHT+6)/2
    brsh _eps_end
    ldd r22, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DX
    ldd r23, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DY
    adnv r22, r24
    adnv r23, r25
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DX, r22
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DY, r23
    ldd r22, Z+NPC_POSITION_OFFSET+CHARACTER_POSITION_DX
    ldd r23, Z+NPC_POSITION_OFFSET+CHARACTER_POSITION_DY
    sbnv r22, r24
    sbnv r23, r25
    std Z+NPC_POSITION_OFFSET+CHARACTER_POSITION_DX, r22
    std Z+NPC_POSITION_OFFSET+CHARACTER_POSITION_DY, r23
_eps_end:
    ret

; Apply a repulsive force on an enemy so that it and the player don't overlap.
;
; Register Usage
;   r22-25          calculations
;   Y (r28:r29)     enemy (param)
enemy_fighting_space:
    ldd r22, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H
    ldd r23, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H
    call calculate_push_acceleration
    mov r24, r25
_efs_horiz:
    lds r0, player_position_x
    sub r22, r0
    brsh _efs_vert
    neg r22
    neg r24
_efs_vert:
    lds r0, player_position_y
    sub r23, r0
    brsh _efs_check_dist
    neg r23
    neg r25
_efs_check_dist:
    cpi r22, CHARACTER_COLLIDER_WIDTH
    brsh _efs_end
    cpi r23, CHARACTER_COLLIDER_HEIGHT
    brsh _efs_end
    add r22, r23
    cpi r22, (CHARACTER_COLLIDER_WIDTH+CHARACTER_COLLIDER_HEIGHT+2)/2
    brsh _efs_end
    ldd r22, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DX
    ldd r23, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DY
    adnv r22, r24
    adnv r23, r25
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DX, r22
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DY, r23
    call calculate_push_resistance
    lds r23, player_velocity_x
    mulsu r23, r22
    sts player_velocity_x, r1
    lds r23, player_velocity_y
    mulsu r23, r22
    sts player_velocity_y, r1
    clr r1
_efs_end:
    ret

; Reorder NPCs so that corpses are rendered first.
;
; NOTE: This routine only swaps at most one corpse and one non-corpse. Since this
; should be called every frame, this isn't a problem.
;
; Register Usage
;   r22, r23, r24   calculations
;   r25             counter
;   X (r26:r27)     slow pointer
;   Z (r30:r31)     fast pointer
reorder_npcs:
    ldi XL, low(sector_npcs)
    ldi XH, high(sector_npcs)
    ldi r25, SECTOR_DYNAMIC_NPC_COUNT
_rn_skip_corpses_iter:
    ld r24, X
    cpi r24, CORPSE_NPC
    brne _rn_reorder
    adiw XL, NPC_MEMSIZE
    dec r25
    brne _rn_skip_corpses_iter
    ret ; all corpses
_rn_reorder:
    movw ZL, XL
_rn_fast_iter:
    ld r24, Z
    cpi r24, CORPSE_NPC
    brne _rn_fast_next
_rn_slow_iter:
    ld r23, X
    cpi r23, CORPSE_NPC
    breq _rn_slow_next
_rn_swap:
    ldi r22, NPC_MEMSIZE
_rn_swap_iter:
    st X+, r24
    st Z+, r23
    ld r23, X
    ld r24, Z
_rn_swap_next:
    dec r22
    brne _rn_swap_iter
    ; NOTE: uncomment to move ALL corpses, not just the first
    ; dec r25
    ; brne _rn_fast_iter
    ret
_rn_slow_next:
    adiw XL, NPC_MEMSIZE
    cp XL, ZL
    cpc XH, ZH
    brne _rn_slow_iter
_rn_fast_next:
    adiw ZL, NPC_MEMSIZE
    dec r25
    brne _rn_fast_iter
    ret

; Update a corpse. All dead, only one thing to do.
;
; Register Usage
;   r24-r25         calculations
;   Y (r28:r29)     npc pointer (param)
corpse_update:
    ldd r25, Y+NPC_EFFECT_OFFSET
    mov r24, r25
    swap r25
    andi r24, 0xf
    andi r25, 0xf
    cpi r25, EFFECT_BLOOD
    brne _cu_later
    cpi r24, EFFECT_BLOOD_DURATION-1
    brsh _cu_later
    lds r25, clock
    andi r25, EFFECT_BLOOD_FRAME_DURATION_MASK
    brne _cu_later
    ldd r25, Y+NPC_EFFECT_OFFSET
    inc r25
    std Y+NPC_EFFECT_OFFSET, r25
_cu_later:
    ret
