; Apply damage to the player and force the player away from the enemy. The pushing
; acceleration is damage << 1.
;
; Register Usage
;   r22-r25         calculations
;   Y (r28:r29)     enemy pointer (param)
;   Z (r30:r31)     npc table pointer (param)
resolve_enemy_attack:
    lds r25, clock
    andi r25, ATTACK_FRAME_DURATION_MASK
    brne  _rea_end_trampoline
_rea_check_action:
    ldd r25, Y+NPC_ANIM_OFFSET
    mov r26, r25
    lsr r25
    mov r24, r25
    lsr r24
    andi r24, 0x7
    cpi r24, ATTACK_DAMAGE_FRAME
    brne _rea_end_trampoline
    swap r25
    andi r25, 0x7
    cpi r25, ACTION_ATTACK
    breq _rea_check_distance
_rea_end_trampoline:
    rjmp _rea_end
_rea_check_distance:
    ldd r22, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H
    ldd r23, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H
    lds r24, player_position_x
    lds r25, player_position_y
    andi r26, 0x3
    call biased_character_distance
    mov r26, r25
    movw r22, ZL ; save regs
    adiw ZL, NPC_TABLE_WEAPON_OFFSET
    elpm r25, Z
    call character_striking_distance
    movw ZL, r22
    cp r26, r0
    brsh _rea_end
_rea_damage_effect:
    lds r22, player_effect
    andi r22, 0x38
    brne _rea_damage
    ldi r22, EFFECT_DAMAGE<<3
    sts player_effect, r22
_rea_damage:
    adiw ZL, NPC_TABLE_ENEMY_STRENGTH_OFFSET
    elpm r23, Z+
    elpm r24, Z+
    sbiw ZL, NPC_TABLE_ENEMY_STRENGTH_OFFSET+2
    lds r25, player_augmented_stats+STATS_DEXTERITY_OFFSET
    call calculate_damage
    lds r24, player_health
    sub r24, r23
    sts player_health, r24
    brsh _rea_push
    sts player_health, r1
    ldi r25, GAME_OVER_DEAD
    call load_gameover
    rjmp _rea_end
_rea_push:
    lsl r23
    mov r22, r23
    ldd r24, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H
    lds r25, player_position_x
    cp r24, r25
    brlo _rea_push_x
    neg r22
_rea_push_x:
    lds r25, player_velocity_x
    adnv r25, r22
    sts player_velocity_x, r25
    ldd r24, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H
    lds r25, player_position_y
    cp r24, r25
    brlo _rea_push_y
    neg r23
_rea_push_y:
    lds r25, player_velocity_y
    adnv r25, r23
    sts player_velocity_y, r25
_rea_end:
    ret

; Apply damage to the given enemy and push it away from the player. The pushing
; acceleration is damage << 1.
;
; Register Usage
;   r22-r25         calculations
;   Y (r28:r29)     enemy pointer (param)
;   Z (r30:r31)     npc table pointer (param)
npc_resolve_melee_damage:
    ldd r25, Y+NPC_IDX_OFFSET
    tst r25
    breq _nrmd_end_trampoline
    lds r25, clock
    andi r25, ATTACK_FRAME_DURATION_MASK
    brne  _nrmd_end_trampoline
_nrmd_check_action:
    lds r25, player_action
    cpi r25, ACTION_ATTACK
    brne _nrmd_end_trampoline
    lds r25, player_frame
    cpi r25, ATTACK_DAMAGE_FRAME
    breq _nrmd_check_weapon
_nrmd_end_trampoline:
    rjmp _nrmd_end
_nrmd_check_weapon:
    lds r25, player_weapon
    dec r25
    brmi _nrmd_end_trampoline
    movw r22, ZL
    ldi ZL, byte3(2*item_table)
    out RAMPZ, ZL
    ldi ZL, low(2*item_table+ITEM_FLAGS_OFFSET)
    ldi ZH, high(2*item_table+ITEM_FLAGS_OFFSET)
    ldi r24, ITEM_MEMSIZE
    mul r24, r25
    add ZL, r0
    adc ZH, r1
    clr r1
    elpm r25, Z
    ldi ZL, byte3(2*npc_table)
    out RAMPZ, ZL
    movw ZL, r22
    andi r25, 0x03
    cpi r25, ITEM_RANGED
    breq _nrmd_end_trampoline
_nrmd_check_distance:
    lds r22, player_position_x
    lds r23, player_position_y
    ldd r24, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H
    ldd r25, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H
    lds r26, player_direction
    call biased_character_distance
    mov r26, r25
    movw r22, ZL ; save regs
    lds r25, player_weapon
    call character_striking_distance
    movw ZL, r22 ; restore regs
    cp r26, r0
    brsh _nrmd_end
_nrmd_damage_effect:
    ldd r22, Y+NPC_EFFECT_OFFSET
    andi r22, 0x38
    brne _nrmd_damage
    ldi r22, EFFECT_DAMAGE<<3
    std Y+NPC_EFFECT_OFFSET, r22
_nrmd_damage:
    lds r23, player_augmented_stats+STATS_STRENGTH_OFFSET
    lds r24, player_augmented_stats+STATS_DEXTERITY_OFFSET
    adiw ZL, NPC_TABLE_ENEMY_DEXTERITY_OFFSET
    elpm r25, Z
    sbiw ZL, NPC_TABLE_ENEMY_DEXTERITY_OFFSET
    call calculate_damage
    ldd r24, Y+NPC_HEALTH_OFFSET
    sub r24, r23
    std Y+NPC_HEALTH_OFFSET, r24
    brsh _nrmd_push
_nrmd_kill_enemy:
    rcall resolve_enemy_death
    rjmp _nrmd_end
_nrmd_push:
    lsl r23
    mov r22, r23
    lds r24, player_position_x
    ldd r25, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H
    cp r24, r25
    brlo _nrmd_push_x
    neg r22
_nrmd_push_x:
    ldd r25, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DX
    adnv r25, r22
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DX, r25
    lds r24, player_position_y
    ldd r25, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H
    cp r24, r25
    brlo _nrmd_push_y
    neg r23
_nrmd_push_y:
    ldd r25, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DY
    adnv r25, r23
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DY, r25
_nrmd_end:
    ret

; Apply any damage to the given NPC from ranged attacks.
;
; Register Usage
;   r22-r25         calculations
;   X (r26:r27)     memory pointer, calculations
;   Y (r28:r29)     enemy pointer (param)
;   Z (r30:r31)     npc table pointer (param)
npc_resolve_ranged_damage:
    ldd r25, Y+NPC_IDX_OFFSET
    tst r25
    breq _nrrd_end
    ldd r25, Y+NPC_EFFECT_OFFSET
    mov r24, r25
    andi r24, 0x7
    andi r25, 0x38
    cpi r25, EFFECT_DAMAGE<<3
    brne _nrrd_resolve_effects
    cpi r24, 4
    brsh _nrrd_end
_nrrd_resolve_effects:
    ldi XL, low(active_effects)
    ldi XH, high(active_effects)
    ldi r22, ACTIVE_EFFECT_COUNT
_nrrd_effect_iter:
    ld r24, X+ ; ACTIVE_EFFECT_DATA_OFFSET
    andi r24, 0x38
    breq _nrrd_effect_next
    ld r24, X+ ; ACTIVE_EFFECT_DATA2_OFFSET
    andi r24, 0x01
    breq _nrrd_effect_next
    ld r24, X+ ; ACTIVE_EFFECT_X_OFFSET
    ldd r25, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H
    subi r24, -(EFFECT_SPRITE_WIDTH-EFFECT_DAMAGE_DISTANCE)/2
    sub r24, r25
    sbrc r24, 7
    neg r24
    cpi r24, EFFECT_DAMAGE_DISTANCE
    brsh _nrrd_effect_next
    ld r24, X ; ACTIVE_EFFECT_Y_OFFSET
    ldd r25, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H
    subi r24, -(EFFECT_SPRITE_HEIGHT-EFFECT_DAMAGE_DISTANCE)/2
    sub r24, r25
    sbrc r24, 7
    neg r24
    cpi r24, EFFECT_DAMAGE_DISTANCE
    brsh _nrrd_effect_next
    sbiw XL, ACTIVE_EFFECT_Y_OFFSET
    call calculate_effect_npc_damage
_nrrd_damage_effect:
    ldd r23, Y+NPC_EFFECT_OFFSET
    andi r23, 0x38
    brne _nrrd_damage
    ldi r23, EFFECT_DAMAGE<<3
    or r23, r24
    std Y+NPC_EFFECT_OFFSET, r23
_nrrd_damage:
    ldd r24, Y+NPC_HEALTH_OFFSET
    sub r24, r25
    std Y+NPC_HEALTH_OFFSET, r24
    brsh _nrrd_effect_next
    rcall resolve_enemy_death
    rjmp _nrrd_end
_nrrd_effect_next:
    adiw XL, ACTIVE_EFFECT_MEMSIZE
    dec r22
    brne _nrrd_effect_iter
_nrrd_end:
    ret

; Record an enemy's death, add a corpse, and handle drops.
;
; Register Usage
;   r22-r25         calculations
;   Y (r28:r29)     enemy pointer, preserved (param)
;   Z (r30:r31)     enemy data pointer, preserved (param)
resolve_enemy_death:
    movw r22, ZL
    adiw ZL, NPC_TABLE_ENEMY_DROPS_OFFSET
    call rand
    mov r25, r1
    clr r1
    andi r25, 0x3
    cpi r25, NPC_TABLE_ENEMY_DROPS_COUNT
    brlo _red_determine_drop
    clr r25
_red_determine_drop:
    add ZL, r25
    adc ZH, r1
    elpm r25, Z
    tst r25
    breq _red_record_death
    ldi ZL, low(sector_loose_items)
    ldi ZH, high(sector_loose_items)
    ldi r24, SECTOR_DYNAMIC_ITEM_COUNT
_red_loose_items_iter:
    ld r0, Z
    tst r0
    brne _red_loose_items_next
    std Z+SECTOR_ITEM_IDX_OFFSET, r25
    std Z+SECTOR_ITEM_PREPLACED_IDX_OFFSET, r1
    ldd r25, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H
    subi r25, -(CHARACTER_SPRITE_WIDTH-STATIC_ITEM_WIDTH)/2
    std Z+SECTOR_ITEM_X_OFFSET, r25
    ldd r25, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H
    subi r25, -(CHARACTER_SPRITE_HEIGHT-STATIC_ITEM_HEIGHT+4)/2
    std Z+SECTOR_ITEM_Y_OFFSET, r25
    rjmp _red_record_death
_red_loose_items_next:
    adiw ZL, SECTOR_DYNAMIC_ITEM_MEMSIZE
    dec r24
    brne _red_loose_items_iter
_red_record_death:
    ldd r25, Y+NPC_IDX_OFFSET
    dec r25
    mov r24, r25
    lsr r25
    lsr r25
    lsr r25
    ldi ZL, low(npc_presence)
    ldi ZH, high(npc_presence)
    add ZL, r25
    adc ZH, r1
    ld r0, Z
    ldi r25, 1
    mpow2 r25, r24
    eor r0, r25
    st Z, r0
    movw ZL, r22
    ldi r25, CORPSE_NPC
    std Y+NPC_IDX_OFFSET, r25
_red_player_xp:
    adiw ZL, NPC_TABLE_ENEMY_ACC_OFFSET
    elpm r22, Z+ ; acceleration
    lsl r22
    elpm r25, Z+ ; health
    add r22, r25
    clr r23
    adc r23, r1
    elpm r25, Z+ ; strength
    lsl r25
    add r22, r25
    adc r23, r1
    elpm r25, Z+ ; dexterity
    add r22, r25
    adc r23, r1
    sbiw ZL, NPC_TABLE_ENEMY_ACC_OFFSET+4
    lds r24, player_xp
    lds r25, player_xp+1
    add r24, r22
    adc r25, r23
    sts player_xp, r24
    sts player_xp+1, r25
    ret
