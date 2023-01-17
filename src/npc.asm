; must match order of active effects defined in gamedefs.asm
estimated_effect_ranges:
    .db 0, 0, 0, 0, 0,                  \
        EFFECT_ARROW_RANGE_ESTIMATE,    \
        EFFECT_FIREBALL_RANGE_ESTIMATE, \
        EFFECT_MISSILE_RANGE_ESTIMATE   \

; Move the given enemy around and attack as necessary. The exact behavior is
; specified by npc_move_flags, see gamedefs.asm.
;
; Register Usage
;   r18-r27         calculations
;   Y (r28:r29)     enemy pointer (param)
;   Z (r30:r31)     enemy data pointer (param)
npc_move:
    push ZL
    push ZH
    adiw YL, NPC_POSITION_OFFSET
    call move_character
    sbiw YL, NPC_POSITION_OFFSET
    rcall enemy_sector_bounds
    ldi ZL, byte3(2*npc_table)
    out RAMPZ, ZL
    pop ZH
    pop ZL
_nm_setup:
    lds r20, player_position_x
    lds r21, player_position_y
    sts subroutine_tmp, r20
    sts subroutine_tmp+1, r21
    ldi r20, NPC_STOLID
    elpm r25, Z
    cpi r25, NPC_ENEMY
    brne _nm_setup_done
    adiw ZL, NPC_TABLE_ENEMY_FLAGS_OFFSET
    elpm r20, Z
    sbiw ZL, NPC_TABLE_ENEMY_FLAGS_OFFSET
_nm_setup_done:
    sts npc_move_flags, r20
_nm_test_hold:
    sbrs r20, log2(NPC_MOVE_HOLD)
    rjmp _nm_test_patrol
    lds r21, npc_move_flags2
    tst r21
    brne _nm_test_patrol
    rjmp _nm_end
_nm_test_patrol:
    sbrs r20, log2(NPC_MOVE_PATROL)
    rjmp _nm_test_lookat
_nm_test_patrol_health:
    adiw ZL, NPC_TABLE_HEALTH_OFFSET
    elpm r24, Z
    sbiw ZL, NPC_TABLE_HEALTH_OFFSET
    ldd r25, Y+NPC_HEALTH_OFFSET
    cp r25, r24
    brlo _nm_test_lookat
_nm_test_patrol_distance:
    ldd r22, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H
    ldd r23, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H
    lds r24, player_position_x
    lds r25, player_position_y
    distance_between r24, r25, r22, r23
    cpi r25, NPC_PATROL_DISTANCE
    brlo _nm_test_lookat
_nm_patrol:
    ; generate a pseudorandom position based on clock/64, NPC index, and NPC pointer
    lds r21, clock
    lsl r21
    lsl r21
    lds r22, clock+1
    rol r22
    rol r22
    eor r21, YL
    eor r22, YL
    ldi r23, 173
    mul r22, r23
    mov r22, r0
    mov r23, r0
    swap r23
    ldd r20, Y+NPC_IDX_OFFSET
    ldi r21, 97
    mul r20, r21
    eor r22, r0
    eor r23, r1
    clr r1
    cpi r22, TILE_WIDTH*SECTOR_WIDTH
    brlo _nm_patrol_x_clamped
    subi r22, TILE_WIDTH*SECTOR_WIDTH
_nm_patrol_x_clamped:
    cpi r23, TILE_HEIGHT*SECTOR_HEIGHT
    brlo _nm_patrol_y_clamped
    subi r23, TILE_HEIGHT*SECTOR_HEIGHT
_nm_patrol_y_clamped:
    sts subroutine_tmp, r22
    sts subroutine_tmp+1, r23
_nm_test_lookat:
    lds r20, npc_move_flags
    sbrs r20, log2(NPC_MOVE_LOOKAT)
    rjmp _nm_test_poltroon1
_nm_lookat:
    lds r20, subroutine_tmp
    lds r21, subroutine_tmp+1
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
    brsh _nm_test_attack
    rjmp _nm_move_calculations
_nm_test_attack:
    lds r20, npc_move_flags
    sbrs r20, log2(NPC_MOVE_ATTACK)
_nm_test_move_trampoline:
    rjmp _nm_test_move
_nm_test_weapon:
    movw XL, ZL
    adiw ZL, NPC_TABLE_WEAPON_OFFSET
    elpm r20, Z
    sbiw ZL, NPC_TABLE_WEAPON_OFFSET
    dec r20
    brmi _nm_test_move_trampoline
    ldi ZL, byte3(2*item_table+ITEM_FLAGS_OFFSET)
    out RAMPZ, ZL
    ldi ZL, low(2*item_table+ITEM_FLAGS_OFFSET)
    ldi ZH, high(2*item_table+ITEM_FLAGS_OFFSET)
    ldi r21, ITEM_MEMSIZE
    mul r20, r21
    add ZL, r0
    adc ZH, r1
    clr r1
    elpm r21, Z
_nm_estimate_range:
    adiw ZL, ITEM_EXTRA_OFFSET-ITEM_FLAGS_OFFSET
    elpm r20, Z
    andi r20, 0x07
    ldi ZL, low(2*estimated_effect_ranges)
    ldi ZH, high(2*estimated_effect_ranges)
    add ZL, r20
    adc ZH, r1
    lpm r20, Z
    ldi ZL, byte3(2*npc_table)
    out RAMPZ, ZL
    movw ZL, XL
    andi r21, 0x03
    cpi r21, ITEM_RANGED
    brne _nm_test_melee_attack
_nm_test_ranged_attack:
    ldd r24, Y+NPC_ANIM_OFFSET
    mov r21, r24
    cpi r24, ACTION_ATTACK<<5
    brsh _nm_ranged_attack_end
    ldd r21, Y+NPC_ANIM_OFFSET
    andi r21, 0x03
    ldd r22, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H
    ldd r23, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H
    lds r24, player_position_x
    sub r22, r24
    sbrc r22, 7
    neg r22
    lds r25, player_position_y
    sub r23, r25
    sbrc r23, 7
    neg r23
_nm_test_ranged_up:
    cpi r21, DIRECTION_UP
    brne _nm_test_ranged_down
    sbrc r22, 7
    neg r22
    cpi r22, 4*EFFECT_DAMAGE_DISTANCE/3-1
    brsh _nm_test_move
    cp r23, r20
    brsh _nm_test_move
    rjmp _nm_ranged_attack
_nm_test_ranged_down:
    cpi r21, DIRECTION_DOWN
    brne _nm_test_ranged_left
    sbrc r22, 7
    neg r22
    cpi r22, 4*EFFECT_DAMAGE_DISTANCE/3-1
    brsh _nm_test_move
    cp r23, r20
    brsh _nm_test_move
    rjmp _nm_ranged_attack
_nm_test_ranged_left:
    cpi r21, DIRECTION_LEFT
    brne _nm_test_ranged_right
    sbrc r23, 7
    neg r23
    cpi r23, 4*EFFECT_DAMAGE_DISTANCE/3-1
    brsh _nm_test_move
    cp r22, r20
    brsh _nm_test_move
    rjmp _nm_ranged_attack
_nm_test_ranged_right:
    cpi r21, DIRECTION_right
    brne _nm_ranged_attack_end
    sbrc r23, 7
    neg r23
    cpi r23, 4*EFFECT_DAMAGE_DISTANCE/3-1
    brsh _nm_test_move
    cp r22, r20
    brsh _nm_test_move
_nm_ranged_attack:
    ldd r24, Y+NPC_ANIM_OFFSET
    andi r24, 0x1f
    ori r24, ACTION_ATTACK<<5
    std Y+NPC_ANIM_OFFSET, r24
_nm_ranged_attack_end:
    ret
_nm_test_melee_attack:
    ldd r24, Y+NPC_ANIM_OFFSET
    cpi r24, ACTION_ATTACK<<5
    brsh _nm_attack_end
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
_nm_melee_attack:
    ldd r24, Y+NPC_ANIM_OFFSET
    andi r24, 0x1f
    ori r24, ACTION_ATTACK<<5
    std Y+NPC_ANIM_OFFSET, r24
_nm_attack_end:
_nm_test_move:
    lds r25, npc_move_flags
    sbrs r25, log2(NPC_MOVE_GOTO)
    rjmp _nm_end
_nm_move_calculations:
    lds r18, subroutine_tmp
    lds r19, subroutine_tmp+1
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
    ldd r24, Y+NPC_EFFECT_OFFSET
    andi r24, 0x38
    brne _nm_test_move_falloff
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
    ldd r24, Y+NPC_EFFECT_OFFSET
    andi r24, 0x38
    brne _nm_move
    cpi r22, NPC_INTEREST_DISTANCE
    brsh _nm_end
    cpi r23, NPC_INTEREST_DISTANCE
    brsh _nm_end
_nm_move:
    mov r27, r26
    ldd r24, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DX
_nm_goto_horizontal_movement:
    lds r25, player_velocity_x
    sbrc r25, 7
    neg r25
    cpi r25, 40
    brsh _nm_goto_horizontal_direction
    cpi r22, 2*STRIKING_DISTANCE
    brsh _nm_goto_horizontal_direction
    asr r26
    mov r0, r26
    asr r0
    add r26, r0
    cpi r22, 2*STRIKING_DISTANCE/3
    brsh _nm_goto_horizontal_direction
    asr r24
    rjmp _nm_goto_vertical_movement
_nm_goto_horizontal_direction:
    cp r18, r20
    brsh _nm_goto_acc_x
    neg r26
_nm_goto_acc_x:
    adnv r24, r26
_nm_goto_vertical_movement:
    ldd r25, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DY
    lds r22, player_velocity_y
    sbrc r22, 7
    neg r22
    cpi r22, 40
    brsh _nm_goto_vertical_direction
    cpi r23, 2*STRIKING_DISTANCE
    brsh _nm_goto_vertical_direction
    asr r27
    mov r0, r27
    asr r0
    add r27, r0
    cpi r23, 2*STRIKING_DISTANCE/3
    brsh _nm_goto_vertical_direction
    asr r25
    rjmp _nm_goto_save_velocity
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

; Update an NPCs's animations, and if an enemy, move and check for collisions.
; Also, if the NPC is using a ranged weapon, add projectiles.
;
; Register Usage
;   r21-r25         calculations
;   X (r26:r27)     temp pointer
;   Y (r28:r29)     npc pointer (param)
;   Z (r30:r31)     aux enemy pointer, flash pointer
npc_update:
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
_eu_check_type:
    ldi ZL, byte3(2*npc_table)
    out RAMPZ, ZL
    ldi ZL, low(2*npc_table)
    ldi ZH, high(2*npc_table)
    ldd r22, Y+NPC_IDX_OFFSET
    dec r22
    ldi r23, NPC_TABLE_ENTRY_MEMSIZE
    mul r22, r23
    add ZL, r0
    adc ZH, r1
    clr r1
    elpm r25, Z
    cpi r25, NPC_ENEMY
    brne _eu_end_trampoline
_eu_collisions:
    rcall enemy_fighting_space
_eu_npc_on_npc_collision:
    adiw ZL, NPC_TABLE_WEAPON_OFFSET
    elpm r21, Z
    adiw ZL, NPC_TABLE_ENEMY_ATTACK_OFFSET-NPC_TABLE_WEAPON_OFFSET
    elpm r25, Z
    sts subroutine_tmp, r25
    ldi ZL, low(sector_npcs+(SECTOR_DYNAMIC_NPC_COUNT-1)*NPC_MEMSIZE)
    ldi ZH, high(sector_npcs+(SECTOR_DYNAMIC_NPC_COUNT-1)*NPC_MEMSIZE)
_eu_npc_iter:
    ldd r22, Z+NPC_IDX_OFFSET
    tst r22
    breq _eu_npc_next
    cpi r22, NPC_CORPSE
    breq _eu_npc_next
    cp YL, ZL
    cpc YH, ZH
    breq _eu_ranged_attack
    rcall enemy_personal_space
_eu_npc_next:
    sbiw ZL, NPC_MEMSIZE
    rjmp _eu_npc_iter
_eu_ranged_attack:
    lds r22, clock
    andi r22, ATTACK_FRAME_DURATION_MASK
    brne _eu_end
    dec r21
    brmi _eu_end
    ldi ZL, byte3(2*item_table)
    out RAMPZ, ZL
    ldi ZL, low(2*item_table+ITEM_FLAGS_OFFSET)
    ldi ZH, high(2*item_table+ITEM_FLAGS_OFFSET)
    ldi r22, ITEM_MEMSIZE
    mul r21, r22
    add ZL, r0
    adc ZH, r1
    clr r1
    elpm r21, Z
    andi r21, 0x03
    cpi r21, ITEM_RANGED
    brne _eu_end
    ldd r22, Y+NPC_ANIM_OFFSET
    mov r23, r22
    andi r23, 0xe0
    cpi r23, ACTION_ATTACK<<5
    brne _eu_end
    andi r22, 0x1c
    cpi r22, RANGED_LAUNCH_FRAME<<2
    breq _eu_add_ranged_effect
_eu_end_trampoline:
    rjmp _eu_end
_eu_add_ranged_effect:
    elpm r23, Z
    swap r23
    andi r23, 0x0c
    adiw ZL, ITEM_EXTRA_OFFSET-ITEM_FLAGS_OFFSET
    elpm r22, Z
    lds r21, subroutine_tmp
    swap r21
    andi r21, 0xf0
    or r23, r21
    ori r23, EFFECT_ROLE_DAMAGE_PLAYER
    swap r22
    lsr r22
    andi r22, 0x38
    ldd r21, Y+NPC_ANIM_OFFSET
    swap r21
    lsl r21
    lsl r21
    andi r21, 0xc0
    or r22, r21
    ldd r24, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H
    ldd r25, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H
    ldd r21, Y+NPC_ANIM_OFFSET
    andi r21, 0x03
_eu_ranged_facing_up:
    cpi r21, DIRECTION_UP
    brne _eu_ranged_facing_down
    subi r25, 2*EFFECT_SPRITE_HEIGHT/3
_eu_ranged_facing_down:
    cpi r21, DIRECTION_DOWN
    brne _eu_ranged_facing_left
    subi r25, -2*EFFECT_SPRITE_HEIGHT/3
_eu_ranged_facing_left:
    cpi r21, DIRECTION_LEFT
    brne _eu_ranged_facing_right
    subi r24, 2*EFFECT_SPRITE_WIDTH/3
_eu_ranged_facing_right:
    cpi r21, DIRECTION_RIGHT
    brne _eu_add_effect
    subi r24, -2*EFFECT_SPRITE_WIDTH/3
_eu_add_effect:
    call add_active_effect
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

; Update a corpse. All dead, only one thing to do.
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
    inc r24
    cpi r24, EFFECT_DAMAGE_DURATION
    brlo _cu_save
    std Y+NPC_EFFECT_OFFSET, r1
    rjmp _cu_later
_cu_save:
    andi r25, 0xf8
    or r25, r24
    std Y+NPC_EFFECT_OFFSET, r25
_cu_later:
    ret
