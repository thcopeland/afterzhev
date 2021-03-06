; Move the given enemy around and attack as necessary. The exact behavior is
; specified by npc_move_flags and npc_move_data, see gamedefs.asm.
;
; Register Usage
;   r18-r27         calculations
;   Y (r28:r29)     enemy pointer (param)
;   Z (r30:r31)     enemy data pointer (param)
npc_move:
    ser r26
    lds r20, npc_move_flags
    sbrs r20, log2(NPC_MOVE_FRICTION)
    clr r26
    ldd r20, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DX
    ldd r21, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DY
    push r20
    push r21
    push ZL
    push ZH
    adiw YL, NPC_POSITION_OFFSET
    call move_character
    sbiw YL, NPC_POSITION_OFFSET
    rcall enemy_sector_bounds
    pop ZH
    pop ZL
    pop r25
    pop r24
_nm_test_rebound:
    lds r20, npc_move_flags
    sbrs r20, log2(NPC_MOVE_REBOUND)
    rjmp _nm_test_lookat
    ldd r20, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DX
    ldd r21, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DY
_nm_rebound:
    ldd r22, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H
    tst r20
    breq _nm_rebound_reverse_x
    cpi r22, 1
    brlo _nm_rebound_reverse_x
    cpi r22, TILE_WIDTH*SECTOR_WIDTH - CHARACTER_SPRITE_WIDTH
    brlo _nm_rebound_test_reverse_y
_nm_rebound_reverse_x:
    mov r20, r24
    neg r20
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DX, r20
_nm_rebound_test_reverse_y:
    ldd r23, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H
    tst r21
    breq _nm_rebound_reverse_y
    cpi r23, 1
    brlo _nm_rebound_reverse_y
    cpi r23, TILE_HEIGHT*SECTOR_HEIGHT - CHARACTER_SPRITE_HEIGHT
    brlo _nm_rebound_calculate_direction
_nm_rebound_reverse_y:
    mov r21, r25
    neg r21
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DY, r21
_nm_rebound_calculate_direction:
    movw r22, r20
    sbrc r22, 7
    neg r22
    sbrc r23, 7
    neg r23
    cp r22, r23
    brlo _nm_rebound_vertical
_nm_rebound_horizontal:
    ldi r24, DIRECTION_RIGHT
    sbrc r20, 7
    ldi r24, DIRECTION_LEFT
    rjmp _nm_rebound_set_direction
_nm_rebound_vertical:
    ldi r24, DIRECTION_DOWN
    sbrc r21, 7
    ldi r24, DIRECTION_UP
_nm_rebound_set_direction:
    ldd r25, Y+NPC_ANIM_OFFSET
    andi r25, 0xfc
    or r25, r24
    std Y+NPC_ANIM_OFFSET, r25
_nm_test_lookat:
    lds r20, npc_move_flags
    sbrs r20, log2(NPC_MOVE_LOOKAT)
    rjmp _nm_test_poltroon1
_nm_lookat:
    lds r20, npc_move_data
    lds r21, npc_move_data+1
    ldd r22, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H
    ldd r23, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H
    movw r24, r22
    sub r24, r20
    sub r25, r21
    sbrc r24, 7
    neg r24
    sbrc r25, 7
    neg r25
    lds r18, npc_move_flags
    sbrs r18, log2(NPC_MOVE_FALLOFF)
    rjmp _nm_lookat_orientation
    cpi r24, 2*NPC_INTEREST_DISTANCE
    brsh _nm_test_poltroon1
    cpi r25, 2*NPC_INTEREST_DISTANCE
    brsh _nm_test_poltroon1
_nm_lookat_orientation:
    cp r24, r25
    brlo _nm_lookat_orient_vertical
_nm_lookat_orient_horizontal:
    ldi r24, DIRECTION_LEFT
    cp r22, r20
    brsh _nm_lookat_save_direction
    ldi r24, DIRECTION_RIGHT
    rjmp _nm_lookat_save_direction
_nm_lookat_orient_vertical:
    ldi r24, DIRECTION_UP
    cp r23, r21
    brsh _nm_lookat_save_direction
    ldi r24, DIRECTION_DOWN
_nm_lookat_save_direction:
    ldd r25, Y+NPC_ANIM_OFFSET
    andi r25, 0xfc
    or r25, r24
    std Y+NPC_ANIM_OFFSET, r25
_nm_test_poltroon1:
    lds r20, npc_move_flags
    sbrs r20, log2(NPC_MOVE_POLTROON)
    rjmp _nm_test_attack
    ldd r20, Y+NPC_HEALTH_OFFSET
    cpi r20, NPC_FLEE_HEALTH
    brlo _nm_move_calculations
_nm_test_attack:
    lds r20, npc_move_flags
    sbrs r20, log2(NPC_MOVE_ATTACK)
    rjmp _nm_test_move
    ldd r22, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H
    ldd r23, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H
    lds r24, player_position_x
    lds r25, player_position_y
    ldd r26, Y+NPC_ANIM_OFFSET
    andi r26, 0x03
    call biased_character_distance
    mov r20, r25
    movw XL, ZL
    adiw ZL, NPC_TABLE_WEAPON_OFFSET
    elpm r25, Z
    call character_striking_distance
    movw ZL, XL
    cp r20, r0
    brsh _nm_test_move
_nm_attack:
    ldd r24, Y+NPC_ANIM_OFFSET
    cpi r24, ACTION_ATTACK<<5
    brsh _nm_attack_end
    andi r24, 0x1f
    ori r24, ACTION_ATTACK<<5
    std Y+NPC_ANIM_OFFSET, r24
_nm_attack_end:
    rjmp _nm_end
_nm_test_move:
    lds r25, npc_move_flags
    sbrs r25, log2(NPC_MOVE_GOTO)
    rjmp _nm_end
_nm_move_calculations:
    lds r18, npc_move_data
    lds r19, npc_move_data+1
    ldd r20, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H
    ldd r21, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H
    movw r22, r20
    sub r22, r18
    sub r23, r19
    sbrc r22, 7
    neg r22
    sbrc r23, 7
    neg r23
    adiw ZL, NPC_TABLE_ENEMY_ACC_OFFSET
    elpm r26, Z
    sbiw ZL, NPC_TABLE_ENEMY_ACC_OFFSET
_nm_test_poltroon2:
    lds r25, npc_move_flags
    sbrs r25, log2(NPC_MOVE_POLTROON)
    rjmp _nm_test_return
    ldd r24, Y+NPC_HEALTH_OFFSET
    cpi r24, NPC_FLEE_HEALTH
    brsh _nm_test_return
    neg r26
_nm_poltroon_orientation:
    cp r22, r23
    brlo _nm_poltroon_orient_vertical
_nm_poltroon_orient_horizontal:
    ldi r24, DIRECTION_RIGHT
    cp r20, r18
    brsh _nm_poltroon_save_direction
    ldi r24, DIRECTION_LEFT
    rjmp _nm_poltroon_save_direction
_nm_poltroon_orient_vertical:
    ldi r24, DIRECTION_DOWN
    cp r21, r19
    brsh _nm_poltroon_save_direction
    ldi r24, DIRECTION_UP
_nm_poltroon_save_direction:
    ldd r25, Y+NPC_ANIM_OFFSET
    andi r25, 0xfc
    or r25, r24
    std Y+NPC_ANIM_OFFSET, r25
    rjmp _nm_move
_nm_test_return:
    lds r25, npc_move_flags
    sbrs r25, log2(NPC_MOVE_RETURN)
    rjmp _nm_test_move_falloff
    cpi r22, NPC_INTEREST_DISTANCE
    brsh _nm_return
    cpi r23, NPC_INTEREST_DISTANCE
    brsh _nm_return
    rjmp _nm_test_move_falloff
_nm_return:
    adiw ZL, NPC_TABLE_XPOS_OFFSET
    elpm r18, Z+
    elpm r19, Z
    sbiw ZL, NPC_TABLE_YPOS_OFFSET
    movw r22, r20
    sub r22, r18
    sub r23, r19
    sbrc r22, 7
    neg r22
    sbrc r23, 7
    neg r23
    cpi r22, 6
    brsh _nm_return_orientation
    cpi r23, 6
    brsh _nm_return_orientation
    ldd r24, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DX
    cpi r24, 0
    brne _nm_return_orientation
    ldd r24, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DY
    cpi r24, 0
    brne _nm_return_orientation
    rjmp _nm_end
_nm_return_orientation:
    cp r22, r23
    brlo _nm_return_orient_vertical
_nm_return_orient_horizontal:
    ldi r24, DIRECTION_LEFT
    cp r20, r18
    brsh _nm_return_save_direction
    ldi r24, DIRECTION_RIGHT
    rjmp _nm_return_save_direction
_nm_return_orient_vertical:
    ldi r24, DIRECTION_UP
    cp r21, r19
    brsh _nm_return_save_direction
    ldi r24, DIRECTION_DOWN
_nm_return_save_direction:
    ldd r25, Y+NPC_ANIM_OFFSET
    andi r25, 0xfc
    or r25, r24
    std Y+NPC_ANIM_OFFSET, r25
    rjmp _nm_move
_nm_test_move_falloff:
    lds r25, npc_move_flags
    sbrs r25, log2(NPC_MOVE_FALLOFF)
    rjmp _nm_move
    cpi r22, NPC_INTEREST_DISTANCE
    brsh _nm_end
    cpi r23, NPC_INTEREST_DISTANCE
    brsh _nm_end
_nm_move:
    mov r27, r26
    ldd r24, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DX
    ldd r25, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DY
_nm_goto_horizontal_movement:
    cpi r22, STRIKING_DISTANCE
    brsh _nm_goto_horizontal_direction
    asr r26
    cpi r22, STRIKING_DISTANCE/2
    brlo _nm_goto_vertical_movement
_nm_goto_horizontal_direction:
    cp r18, r20
    brsh _nm_goto_acc_x
    neg r26
_nm_goto_acc_x:
    adnv r24, r26
_nm_goto_vertical_movement:
    cpi r23, STRIKING_DISTANCE
    brsh _nm_goto_vertical_direction
    asr r27
    cpi r23, STRIKING_DISTANCE/2
    brlo _nm_goto_save_velocity
_nm_goto_vertical_direction:
    cp r19, r21
    brsh _nm_goto_acc_y
    neg r27
_nm_goto_acc_y:
    adnv r25, r27
_nm_goto_save_velocity:
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DX, r24
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DY, r25
_nm_end:
    ret

; Update the enemy's animations and check for collisions.
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
; NOTE: The animations are somewhat complicated by the fact that EFFECT_DAMAGE
; contains two separate four-frame animations, one for blood and one for magical
; damage.
;
; Register Usage
;   r23-r25         calculations
;   Y (r28:r29)     npc pointer (param)
corpse_update:
    ldd r25, Y+NPC_EFFECT_OFFSET
    lsr r25
    lsr r25
    lsr r25
    andi r25, 0x7
    cpi r25, EFFECT_DAMAGE
    brne _cu_later
    lds r25, clock
    andi r25, EFFECT_DAMAGE_FRAME_DURATION_MASK
    brne _cu_later
    ldd r25, Y+NPC_EFFECT_OFFSET
    mov r24, r25
    andi r24, 0x7
    ldi r23, EFFECT_DAMAGE_DURATION
    sbrc r24, 2
    ldi r23, 2*EFFECT_DAMAGE_DURATION
    inc r24
    cp r24, r23
    brlo _cu_save
    std Y+NPC_EFFECT_OFFSET, r1
    rjmp _cu_later
_cu_save:
    andi r25, 0xf8
    or r25, r24
    std Y+NPC_EFFECT_OFFSET, r25
_cu_later:
    ret
