; Apply damage to the player and force the player away from the enemy. The pushing
; acceleration is damage << 1.
;
; Register Usage
;   r20-r27         calculations
;   Y (r28:r29)     enemy pointer
;   Z (r30:r31)     npc table pointer
player_resolve_melee_damage:
    lds r25, clock
    inc r25 ; offset by one frame to avoid doing everything on one frame
    andi r25, ATTACK_FRAME_DURATION_MASK
    breq _prmd_main
    ret
_prmd_main:
    ldi YL, low(sector_npcs)
    ldi YH, high(sector_npcs)
    ldi r27, SECTOR_NPC_COUNT
_prmd_iter:
    ldd r25, Y+NPC_IDX_OFFSET
    cpi r25, NPC_CORPSE
    breq _prmd_next_trampoline
    dec r25
    brmi _prmd_next_trampoline
    ldd r24, Y+NPC_ANIM_OFFSET
    mov r23, r24
    andi r24, 0xe0
    cpi r24, ACTION_ATTACK<<5
    brne _prmd_next_trampoline
    andi r23, 0x1c
    cpi r23, ATTACK_DAMAGE_FRAME<<2
    brne _prmd_next_trampoline
    ldi ZL, byte3(2*npc_table)
    out RAMPZ, ZL
    ldi ZL, low(2*npc_table)
    ldi ZH, high(2*npc_table)
    ldi r24, NPC_TABLE_ENTRY_MEMSIZE
    mul r24, r25
    add ZL, r0
    adc ZH, r1
    clr r1
    elpm r25, Z
    cpi r25, NPC_ENEMY
    brne _prmd_next_trampoline
_prmd_check_weapon:
    movw r24, ZL
    adiw ZL, NPC_TABLE_WEAPON_OFFSET
    elpm r22, Z
    dec r22
    brmi _prmd_next_trampoline
    ldi ZL, byte3(2*item_table+ITEM_FLAGS_OFFSET)
    out RAMPZ, ZL
    ldi ZL, low(2*item_table+ITEM_FLAGS_OFFSET)
    ldi ZH, high(2*item_table+ITEM_FLAGS_OFFSET)
    ldi r23, ITEM_MEMSIZE
    mul r22, r23
    add ZL, r0
    adc ZH, r1
    clr r1
    elpm r23, Z
    andi r23, 0x03
    cpi r23, ITEM_WIELDABLE
    breq _prmd_more_checks
_prmd_next_trampoline:
    rjmp _prmd_next
_prmd_more_checks:
    ldi ZL, byte3(2*npc_table)
    out RAMPZ, ZL
    movw ZL, r24
_prmd_check_distance:
    ldd r22, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H
    ldd r23, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H
    lds r24, player_position_x
    lds r25, player_position_y
    ldd r26, Y+NPC_ANIM_OFFSET
    andi r26, 0x3
    call biased_character_distance
    mov r26, r25
    movw r22, ZL ; save regs
    adiw ZL, NPC_TABLE_WEAPON_OFFSET
    elpm r25, Z
    call character_striking_distance
    movw ZL, r22
    cp r26, r0
    brsh _prmd_next_trampoline
_prmd_damage_effect:
    lds r22, player_effect
    andi r22, 0x38
    brne _prmd_damage
    ldi r22, EFFECT_DAMAGE<<3
    sts player_effect, r22
_prmd_damage:
    adiw ZL, NPC_TABLE_ENEMY_ATTACK_OFFSET
    elpm r26, Z
    sbiw ZL, NPC_TABLE_ENEMY_ATTACK_OFFSET
    ldi r24, 0x0f
_prmd_attack_roll1:
    call rand
    and r0, r24
    cp r0, r26
    brlo _prmd_calculate_defense
_prmd_attack_roll2:
    mov r0, r1
    and r0, r24
    cp r0, r26
    brlo _prmd_calculate_defense
_prmd_fallback:
    mov r0, r26
    lsr r0
_prmd_calculate_defense:
    clr r1
    add r26, r0
    lds r22, player_armor
    dec r22
    brmi _prmd_apply_damage
    ldi ZL, byte3(2*item_table+ITEM_EXTRA_OFFSET)
    out RAMPZ, ZL
    ldi ZL, low(2*item_table+ITEM_EXTRA_OFFSET)
    ldi ZH, high(2*item_table+ITEM_EXTRA_OFFSET)
    ldi r23, ITEM_MEMSIZE
    mul r22, r23
    add ZL, r0
    adc ZH, r1
    clr r1
    elpm r25, Z
    andi r25, 0x0f
    sub r26, r25
    brsh _prmd_apply_damage
    ldi r26, 1
_prmd_apply_damage:
    inc r26
    lds r24, player_health
    sub r24, r26
    sts player_health, r24
    brsh _prmd_push
    sts player_health, r1
    ldi r25, GAME_OVER_DEAD
    call load_gameover
    rjmp _prmd_end
_prmd_push:
    mov r22, r26
    ldd r24, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H
    lds r25, player_position_x
    cp r24, r25
    brlo _prmd_push_x
    neg r22
_prmd_push_x:
    lds r25, player_velocity_x
    adnv r25, r22
    sts player_velocity_x, r25
    ldd r24, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H
    lds r25, player_position_y
    cp r24, r25
    brlo _prmd_push_y
    neg r26
_prmd_push_y:
    lds r25, player_velocity_y
    adnv r25, r26
    sts player_velocity_y, r25
_prmd_next:
    adiw YL, NPC_MEMSIZE
    dec r27
    breq _prmd_end
    rjmp _prmd_iter
_prmd_end:
    ret

; Apply damage to the player from effects, including ranged attacks.
;
; Register Usage
;   r22-r25         calculations
;   Y (r28:r29)     effect pointer
;   Z (r30:r31)     item pointer
player_resolve_effect_damage:
    lds r25, player_effect
    andi r25, 0x38
    cpi r25, EFFECT_DAMAGE << 3
    brne _pred_main
    ret
_pred_main:
    ldi YL, low(active_effects)
    ldi YH, high(active_effects)
    ldi r22, ACTIVE_EFFECT_COUNT
_pred_effect_iter:
    ldd r24, Y+ACTIVE_EFFECT_DATA_OFFSET
    andi r24, 0x38
    breq _pred_effect_next
    ldd r24, Y+ACTIVE_EFFECT_DATA2_OFFSET
    andi r24, 0x02
    breq _pred_effect_next
    ldd r24, Y+ACTIVE_EFFECT_X_OFFSET
    lds r25, player_position_x
    sub r24, r25
    sbrc r24, 7
    neg r24
    cpi r24, EFFECT_DAMAGE_DISTANCE
    brsh _pred_effect_next
    ldd r24, Y+ACTIVE_EFFECT_Y_OFFSET
    lds r25, player_position_y
    sub r24, r25
    sbrc r24, 7
    neg r24
    cpi r24, EFFECT_DAMAGE_DISTANCE
    brlo _pred_damage_effect
_pred_effect_next:
    adiw YL, ACTIVE_EFFECT_MEMSIZE
    dec r22
    brne  _pred_effect_iter
    ret
_pred_damage_effect:
    lds r24, player_effect
    andi r24, 0x38
    brne _pred_calculate_damage
    ldi r24, EFFECT_DAMAGE<<3
    sts player_effect, r24
_pred_calculate_damage:
    ldd r25, Y+ACTIVE_EFFECT_DATA2_OFFSET
    swap r25
    andi r25, 0x0f
    ldi r24, 0x0f
_pred_attack_roll1:
    call rand
    and r0, r24
    cp r0, r25
    brlo _pred_calculate_defense
_pred_attack_roll2:
    mov r0, r1
    and r0, r24
    cp r0, r25
    brlo _pred_calculate_defense
_pred_fallback:
    mov r0, r25
    lsr r0
_pred_calculate_defense:
    clr r1
    add r25, r0
    lds r23, player_armor
    dec r23
    brmi _pred_damage
    ldi ZL, byte3(2*item_table)
    out RAMPZ, ZL
    ldi ZL, low(2*item_table+ITEM_EXTRA_OFFSET)
    ldi ZH, high(2*item_table+ITEM_EXTRA_OFFSET)
    ldi r24, ITEM_MEMSIZE
    mul r23, r24
    add ZL, r0
    adc ZH, r1
    clr r1
    elpm r24, Z
    andi r24, 0x0f
    sub r25, r24
    brsh _pred_damage
    ldi r25, 1
_pred_damage:
    inc r25
    lds r24, player_health
    sub r24, r25
    sts player_health, r24
    brsh _pred_effect_next
    sts player_health, r1
    ldi r25, GAME_OVER_DEAD
    call load_gameover
    ret

; If an enemy, apply damage to the given enemy and push it away from the player. The pushing
; acceleration is damage << 1. If a shopkeeper or talker, try to replace it with another
; NPC (probably an enemy).
;
; Register Usage
;   r22-r26         calculations
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
    brne _nrmd_end_trampoline
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
    brsh _nrmd_end_trampoline
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
    adiw ZL, ITEM_EXTRA_OFFSET-ITEM_FLAGS_OFFSET
    elpm r24, Z
    ldi ZL, byte3(2*npc_table)
    out RAMPZ, ZL
    movw ZL, r22
    andi r25, 0x03
    cpi r25, ITEM_WIELDABLE
    breq _nrmd_damage_effect
_nrmd_end_trampoline:
    rjmp _nrmd_end
_nrmd_damage_effect:
    ldd r22, Y+NPC_EFFECT_OFFSET
    andi r22, 0x38
    brne _nrmd_calc_damage
    ldi r22, EFFECT_DAMAGE<<3
    std Y+NPC_EFFECT_OFFSET, r22
_nrmd_check_replacement:
    elpm r22, Z
    cpi r22, NPC_TALKER
    brne _nrmd_calc_damage
    adiw ZL, NPC_TABLE_TALKER_REPLACEMENT_OFFSET
    elpm r22, Z
    sbiw ZL, NPC_TABLE_TALKER_REPLACEMENT_OFFSET
    tst r22
    breq _nrmd_calc_damage
    std Y+NPC_IDX_OFFSET, r22
    rjmp _nrmd_end
_nrmd_calc_damage:
    mov r25, r24
    swap r25
    andi r25, 0x0f
    ldi r24, 0x0f
_nrmd_attack_roll1:
    call rand
    and r0, r24
    cp r0, r25
    brlo _nrmd_strength_damage
_nrmd_attack_roll2:
    mov r0, r1
    and r0, r24
    cp r0, r25
    brlo _nrmd_strength_damage
_nrmd_fallback:
    mov r0, r25
    lsr r0
_nrmd_strength_damage:
    clr r1
    add r25, r0
    lds r24, player_augmented_stats+STATS_STRENGTH_OFFSET
    asr r24
    add r25, r24
    elpm r24, Z
    cpi r24, NPC_ENEMY
    breq _nrmd_enemy_defense
    ldi r24, NPC_DEFAULT_DEFENSE
    rjmp _nrmd_apply_defense
_nrmd_enemy_defense:
    adiw ZL, NPC_TABLE_ENEMY_DEFENSE_OFFSET
    elpm r24, Z
    sbiw ZL, NPC_TABLE_ENEMY_DEFENSE_OFFSET
_nrmd_apply_defense:
    sub r25, r24
    brsh _nrmd_apply_damage
    ldi r25, 1
_nrmd_apply_damage:
    inc r25
    ldd r24, Y+NPC_HEALTH_OFFSET
    sub r24, r25
    std Y+NPC_HEALTH_OFFSET, r24
    brsh _nrmd_push
    rcall resolve_enemy_death
    rjmp _nrmd_end
_nrmd_push:
    mov r23, r25
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
;   X (r26:r27)     temp registers, calculations
;   Y (r28:r29)     enemy pointer (param)
;   Z (r30:r31)     memory pointer, npc table pointer (param)
npc_resolve_ranged_damage:
    ldd r25, Y+NPC_IDX_OFFSET
    tst r25
    breq _nrrd_early_exit
    cpi r25, NPC_CORPSE
    breq _nrrd_early_exit
_nrrd_main:
    ldd r25, Y+NPC_EFFECT_OFFSET
    andi r25, 0x38
    cpi r25, EFFECT_DAMAGE<<3
    brne _nrrd_resolve_effects
_nrrd_early_exit:
    ret
_nrrd_resolve_effects:
    movw XL, ZL
    ldi ZL, low(active_effects)
    ldi ZH, high(active_effects)
    ldi r22, ACTIVE_EFFECT_COUNT
_nrrd_effect_iter:
    ldd r24, Z+ACTIVE_EFFECT_DATA_OFFSET
    andi r24, 0x38
    breq _nrrd_next_trampoline
    ldd r24, Z+ACTIVE_EFFECT_DATA2_OFFSET
    andi r24, 0x01
    breq _nrrd_next_trampoline
    ldd r24, Z+ACTIVE_EFFECT_X_OFFSET
    ldd r25, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H
    sub r24, r25
    sbrc r24, 7
    neg r24
    cpi r24, EFFECT_DAMAGE_DISTANCE
    brsh _nrrd_next_trampoline
    ldd r24, Z+ACTIVE_EFFECT_Y_OFFSET
    ldd r25, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H
    sub r24, r25
    sbrc r24, 7
    neg r24
    cpi r24, EFFECT_DAMAGE_DISTANCE
    brlo _nrrd_damage_effect
_nrrd_next_trampoline:
    rjmp _nrrd_effect_next
_nrrd_damage_effect:
    ldd r23, Y+NPC_EFFECT_OFFSET
    andi r23, 0x38
    brne _nrrd_check_replacement
    ldi r23, EFFECT_DAMAGE<<3
    std Y+NPC_EFFECT_OFFSET, r23
_nrrd_check_replacement:
    movw r24, ZL
    movw ZL, XL
    elpm r23, Z
    adiw ZL, NPC_TABLE_TALKER_REPLACEMENT_OFFSET
    elpm r0, Z
    movw ZL, r24
    cpi r23, NPC_TALKER
    brne _nrrd_calculate_damage
    tst r0
    breq _nrrd_calculate_damage
    std Y+NPC_IDX_OFFSET, r0
    rjmp _nrrd_end
_nrrd_calculate_damage:
    ldd r25, Z+ACTIVE_EFFECT_DATA2_OFFSET
    mov r24, r25
    swap r25
    andi r25, 0x0f
    andi r24, 0x2
    brne _nrrd_calculate_defense
    ldi r24, 0x0f
_nrrd_attack_roll1:
    call rand
    and r0, r24
    cp r0, r25
    brlo _nrrd_additional_damage
_nrrd_attack_roll2:
    mov r0, r1
    and r0, r24
    cp r0, r25
    brlo _nrrd_additional_damage
_nrrd_fallback:
    mov r0, r25
    lsr r0
_nrrd_additional_damage:
    clr r1
    add r25, r0
_nrrd_check_weapon:
    lds r22, player_weapon
    dec r22
    brmi _nrrd_calculate_defense
    push ZL
    push ZH
    ldi ZL, byte3(2*item_table)
    out RAMPZ, ZL
    ldi ZL, low(2*item_table+ITEM_FLAGS_OFFSET)
    ldi ZH, high(2*item_table+ITEM_FLAGS_OFFSET)
    ldi r24, ITEM_MEMSIZE
    mul r22, r24
    add ZL, r0
    adc ZH, r1
    clr r1
    elpm r22, Z
    adiw ZL, ITEM_EXTRA_OFFSET-ITEM_FLAGS_OFFSET
    elpm r23, Z
    pop ZH
    pop ZL
    andi r22, 0x03
    cpi r22, ITEM_RANGED
    brne _nrrd_calculate_defense
    lds r24, player_augmented_stats+STATS_INTELLECT_OFFSET
    lsr r24
    andi r23, RANGED_MAGICAL
    brne _nrrd_apply_additional
_nrrd_non_magical_ranged:
    lds r23, player_augmented_stats+STATS_STRENGTH_OFFSET
    lsr r23
    add r24, r23
    lsr r24
_nrrd_apply_additional:
    add r25, r24
_nrrd_calculate_defense:
    mov r0, ZL
    mov r23, ZH
    ldi ZL, byte3(2*npc_table)
    out RAMPZ, ZL
    movw ZL, XL
    elpm r24, Z
    cpi r24, NPC_ENEMY
    breq _nrrd_enemy_defense
    ldi r24, NPC_DEFAULT_DEFENSE
    rjmp _nrrd_apply_defense
_nrrd_enemy_defense:
    adiw ZL, NPC_TABLE_ENEMY_DEFENSE_OFFSET
    elpm r24, Z
_nrrd_apply_defense:
    mov ZL, r0
    mov ZH, r23
    sub r25, r24
    brsh _nrrd_apply_damage
    ldi r25, 1
_nrrd_apply_damage:
    inc r25
    ldd r24, Y+NPC_HEALTH_OFFSET
    sub r24, r25
    std Y+NPC_HEALTH_OFFSET, r24
    brsh _nrrd_effect_next
    movw ZL, XL
    rcall resolve_enemy_death
    rjmp _nrrd_end
_nrrd_effect_next:
    adiw ZL, ACTIVE_EFFECT_MEMSIZE
    dec r22
    breq _nrrd_end
    rjmp _nrrd_effect_iter
_nrrd_end:
    movw ZL, XL
    ret

; Record an NPC's death and replace it with a corpse. If an enemy, also
; rewards the player with some XP. If an enemy or a shopkeeper, handles
; drops.
;
; Register Usage
;   r20-r25         calculations
;   Y (r28:r29)     enemy pointer, preserved (param)
;   Z (r30:r31)     enemy data pointer, preserved (param)
resolve_enemy_death:
    movw r22, ZL
    elpm r25, Z
    cpi r25, NPC_SHOPKEEPER
    breq _red_resolve_shop_drops
    cpi r25, NPC_ENEMY
    breq _red_resolve_enemy_drops
    rjmp _red_record_death
_red_resolve_enemy_drops:
    adiw ZL, NPC_TABLE_ENEMY_DROPS_OFFSET
    call rand
    mov r25, r1
    clr r1
    andi r25, 0x3
    cpi r25, NPC_TABLE_ENEMY_DROPS_COUNT
    brlo _red_determine_enemy_drop
    clr r25
_red_determine_enemy_drop:
    add ZL, r25
    adc ZH, r1
    elpm r25, Z
    tst r25
    brne _red_init_loose_items_iter
    rjmp _red_player_xp
_red_resolve_shop_drops:
    adiw ZL, NPC_TABLE_SHOP_IDX_OFFSET
    elpm r25, Z
    push r22
    push r23
    call shop_most_valuable
    pop r23
    pop r22
_red_init_loose_items_iter:
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
    subi r25, -(CHARACTER_SPRITE_HEIGHT-STATIC_ITEM_HEIGHT+10)/2
    std Z+SECTOR_ITEM_Y_OFFSET, r25
    rjmp _red_player_xp
_red_loose_items_next:
    adiw ZL, SECTOR_DYNAMIC_ITEM_MEMSIZE
    dec r24
    brne _red_loose_items_iter
_red_player_xp:
    movw ZL, r22
    clr r23
    adiw ZL, NPC_TABLE_HEALTH_OFFSET
    elpm r25, Z ; health
    adiw ZL, NPC_TABLE_ENEMY_ACC_OFFSET-NPC_TABLE_HEALTH_OFFSET
    elpm r22, Z+ ; acceleration
    lsr r22
    add r22, r25
    adc r23, r1
    elpm r25, Z+ ; attack
    lsl r25
    add r22, r25
    adc r23, r1
    elpm r25, Z+ ; defense
    lsl r25
    add r22, r25
    adc r23, r1
    sbiw ZL, NPC_TABLE_ENEMY_ACC_OFFSET+3
    lds r24, player_xp
    lds r25, player_xp+1
    add r24, r22
    adc r25, r23
    sts player_xp, r24
    sts player_xp+1, r25
    movw r22, ZL
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
_red_resolve_avenger:
    movw ZL, r22
    elpm r25, Z
    cpi r25, NPC_SHOPKEEPER
    breq _red_add_avenger
    cpi r25, NPC_TALKER
    breq _red_add_avenger
    rjmp _red_add_corpse
_red_add_avenger:
    adiw ZL, NPC_TABLE_AVENGER_OFFSET
    elpm r25, Z
    sbiw ZL, NPC_TABLE_AVENGER_OFFSET
    tst r25
    breq _red_add_corpse
    rcall add_distant_npc
_red_add_corpse:
    ldi ZL, byte3(2*npc_table)
    out RAMPZ, ZL
    movw ZL, r22
    ldi r25, NPC_CORPSE
    std Y+NPC_IDX_OFFSET, r25
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DX, r1
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DY, r1
    ret

; Try to add an NPC as far as possible from the camera view. This is done by
; choosing the farthest of the two avenger places for the sector. Ideally the NPC
; would be outside the camera view, but that's difficult to guarantee.
;
; Register Usage
;   r20-21, r24     calculations
;   r25             NPC id (param)
;   X (r26:r27)     memory pointer
;   Z (r30:r31)     flash pointer
add_distant_npc:
    movw XL, YL
    ldi YL, low(sector_npcs)
    ldi YH, high(sector_npcs)
    ldi r20, SECTOR_DYNAMIC_NPC_COUNT
_adn_npc_iter:
    ld r21, Y
    tst r21
    breq _adn_slot_found
    adiw YL, NPC_MEMSIZE
    dec r20
    brne _adn_npc_iter
    rjmp _adn_end
_adn_slot_found:
    call load_npc
    ldi ZL, byte3(2*sector_table)
    out RAMPZ, ZL
    lds ZL, current_sector
    lds ZH, current_sector+1
    subi ZL, low(-SECTOR_AVENGER_PLACES_OFFSET)
    sbci ZH, high(-SECTOR_AVENGER_PLACES_OFFSET)
    lds r24, camera_position_x
    subi r24, low(-DISPLAY_WIDTH/2)
    lds r25, camera_position_y
    subi r25, low(-DISPLAY_HEIGHT/2)
    elpm r20, Z+
    elpm r21, Z+
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H, r20
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H, r21
    distance_between r20, r21, r24, r25
    mov r0, r21
    elpm r20, Z+
    elpm r21, Z+
    distance_between r24, r25, r20, r21
    cp r0, r25
    brsh _adn_end
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H, r20
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H, r21
_adn_end:
    movw YL, XL
    ret
