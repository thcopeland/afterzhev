; Apply damage to the player and force the player away from the enemy. The pushing
; acceleration is damage << 1.
;
; Register Usage
;   r20-r27         calculations
;   Y (r28:r29)     enemy pointer
;   Z (r30:r31)     npc table pointer
player_resolve_melee_damage:
    lds r25, clock
    andi r25, ATTACK_FRAME_DURATION_MASK
    breq _prmd_iter_setup
    rjmp _prmd_end
_prmd_iter_setup:
    ldi YL, low(sector_npcs)
    ldi YH, high(sector_npcs)
    ldi r27, SECTOR_NPC_COUNT
_prmd_npc_iter:
    ldd r25, Y+NPC_IDX_OFFSET
    dec r25
    brmi _prmd_next_npc_trampoline
_prmd_flash_ptr:
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
    brne _prmd_next_npc_trampoline
    ldd r25, Y+NPC_ANIM_OFFSET
    lsr r25
    swap r25
    andi r25, 0x7
    cpi r25, ACTION_ATTACK
    brne _prmd_next_npc_trampoline
_prmd_check_weapon:
    movw r24, ZL
    adiw ZL, NPC_TABLE_WEAPON_OFFSET
    elpm r22, Z
    dec r22
    brmi _prmd_next_npc_trampoline
    ldi ZL, byte3(2*item_table+ITEM_FLAGS_OFFSET)
    out RAMPZ, ZL
    ldi ZL, low(2*item_table+ITEM_FLAGS_OFFSET)
    ldi ZH, high(2*item_table+ITEM_FLAGS_OFFSET)
    ldi r23, ITEM_MEMSIZE
    mul r22, r23
    add ZL, r0
    adc ZH, r1
    clr r1
    elpm r20, Z
    adiw ZL, ITEM_EXTRA_OFFSET-ITEM_FLAGS_OFFSET
    elpm r21, Z
    ldi ZL, byte3(2*npc_table)
    out RAMPZ, ZL
    movw ZL, r24
    mov r24, r20
    andi r24, 3
    cpi r24, ITEM_RANGED
    brne _prmd_check_melee_frame
_prmd_check_ranged_frame:
    ldd r24, Y+NPC_ANIM_OFFSET
    andi r24, 0x1c
    cpi r24, RANGED_LAUNCH_FRAME << 2
    breq _prmd_add_ranged_effect
_prmd_next_npc_trampoline:
    rjmp _prmd_next_npc
_prmd_add_ranged_effect:
    ldd r22, Y+NPC_ANIM_OFFSET
    swap r22
    lsl r22
    lsl r22
    andi r22, 0xc0
    mov r25, r21
    lsl r25
    lsl r25
    lsl r25
    andi r25, 0x38
    or r22, r25
    ldi r23, EFFECT_ROLE_DAMAGE_PLAYER
    swap r20
    andi r20, 0x0c
    or r23, r20
    ldd r24, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H
    ldd r25, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H
    ldd r20, Y+NPC_ANIM_OFFSET
    andi r20, 0x03
_prmd_ranged_facing_up:
    cpi r20, DIRECTION_UP
    brne _prmd_ranged_facing_down
    subi r25, 2*EFFECT_SPRITE_HEIGHT/3
_prmd_ranged_facing_down:
    cpi r20, DIRECTION_DOWN
    brne _prmd_ranged_facing_left
    subi r25, -2*EFFECT_SPRITE_HEIGHT/3
_prmd_ranged_facing_left:
    cpi r20, DIRECTION_LEFT
    brne _prmd_ranged_facing_right
    subi r24, 2*EFFECT_SPRITE_WIDTH/3
_prmd_ranged_facing_right:
    cpi r20, DIRECTION_RIGHT
    brne _prmd_add_effect
    subi r24, -2*EFFECT_SPRITE_WIDTH/3
_prmd_add_effect:
    push ZL
    push ZH
    call add_active_effect
    pop ZH
    pop ZL
    rjmp _prmd_end
_prmd_check_melee_frame:
    ldd r24, Y+NPC_ANIM_OFFSET
    mov r26, r24
    lsr r24
    lsr r24
    andi r24, 0x7
    cpi r24, ATTACK_DAMAGE_FRAME
    brne _prmd_next_npc_trampoline
_prmd_check_distance:
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
    brsh _prmd_end
_prmd_damage_effect:
    lds r22, player_effect
    andi r22, 0x38
    brne _prmd_damage
    ldi r22, EFFECT_DAMAGE<<3
    sts player_effect, r22
_prmd_damage:
    adiw ZL, NPC_TABLE_ENEMY_STRENGTH_OFFSET
    elpm r23, Z+
    elpm r24, Z+
    sbiw ZL, NPC_TABLE_ENEMY_STRENGTH_OFFSET+2
    lds r25, player_augmented_stats+STATS_DEXTERITY_OFFSET
    call calculate_damage
    lds r24, player_health
    sub r24, r23
    sts player_health, r24
    brsh _prmd_push
    sts player_health, r1
    ldi r25, GAME_OVER_DEAD
    call load_gameover
    rjmp _prmd_end
_prmd_push:
    lsl r23
    mov r22, r23
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
    neg r23
_prmd_push_y:
    lds r25, player_velocity_y
    adnv r25, r23
    sts player_velocity_y, r25
_prmd_next_npc:
    adiw YL, NPC_MEMSIZE
    dec r27
    breq _prmd_end
    rjmp _prmd_npc_iter
_prmd_end:
    ret

; Apply damage to the player from effects, including ranged attacks.
;
; Register Usage
;   r22-r25         calculations
;   Y (r28:r29)     effect pointer
player_resolve_effect_damage:
    lds r25, player_effect
    andi r25, 0x38
    cpi r25, EFFECT_DAMAGE << 3
    breq _pred_end
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
    brsh _pred_effect_next
    lds r24, player_augmented_stats+STATS_DEXTERITY_OFFSET
    ldd r25, Y+ACTIVE_EFFECT_DATA2_OFFSET
    call calculate_effect_damage
_pred_damage_effect:
    lds r24, player_effect
    andi r24, 0x38
    brne _pred_damage
    ldi r24, EFFECT_DAMAGE<<3
    sts player_effect, r24
_pred_damage:
    lds r24, player_health
    sub r24, r25
    sts player_health, r24
    brsh _pred_effect_next
    sts player_health, r1
    ldi r25, GAME_OVER_DEAD
    call load_gameover
    rjmp _pred_end
_pred_effect_next:
    adiw YL, ACTIVE_EFFECT_MEMSIZE
    dec r22
    brne  _pred_effect_iter
_pred_end:
    ret

; If an enemy, apply damage to the given enemy and push it away from the player. The pushing
; acceleration is damage << 1. If a shopkeeper or talker, try to replace it with another
; NPC (probably an enemy).
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
    brsh _nrmd_end_trampoline
_nrmd_damage_effect:
    ldd r22, Y+NPC_EFFECT_OFFSET
    andi r22, 0x38
    brne _nrmd_calc_damage
    ldi r22, EFFECT_DAMAGE<<3
    std Y+NPC_EFFECT_OFFSET, r22
_nrmd_calc_damage:
    lds r23, player_augmented_stats+STATS_STRENGTH_OFFSET
    lds r24, player_augmented_stats+STATS_DEXTERITY_OFFSET
    elpm r25, Z
    cpi r25, NPC_ENEMY
    brne _nrmd_use_default_dexterity
_nrmd_read_enemy_dexterity:
    adiw ZL, NPC_TABLE_ENEMY_DEXTERITY_OFFSET
    elpm r25, Z
    sbiw ZL, NPC_TABLE_ENEMY_DEXTERITY_OFFSET
    rjmp _nrmd_apply_damage
_nrmd_use_default_dexterity:
    ldi r25, NPC_DEFAULT_DEXTERITY
_nrmd_apply_damage:
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
;   X (r26:r27)     temp registers, calculations
;   Y (r28:r29)     enemy pointer (param)
;   Z (r30:r31)     memory pointer, npc table pointer (param)
npc_resolve_ranged_damage:
    ldd r25, Y+NPC_IDX_OFFSET
    tst r25
    breq _nrrd_hard_end
    ldd r25, Y+NPC_EFFECT_OFFSET
    andi r25, 0x38
    cpi r25, EFFECT_DAMAGE<<3
    breq _nrrd_hard_end
_nrrd_resolve_effects:
    movw XL, ZL
    ldi ZL, low(active_effects)
    ldi ZH, high(active_effects)
    ldi r22, ACTIVE_EFFECT_COUNT
_nrrd_effect_iter:
    ldd r24, Z+ACTIVE_EFFECT_DATA_OFFSET
    andi r24, 0x38
    breq _nrrd_effect_next
    ldd r24, Z+ACTIVE_EFFECT_DATA2_OFFSET
    andi r24, 0x01
    breq _nrrd_effect_next
    ldd r24, Z+ACTIVE_EFFECT_X_OFFSET
    ldd r25, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H
    sub r24, r25
    sbrc r24, 7
    neg r24
    cpi r24, EFFECT_DAMAGE_DISTANCE
    brsh _nrrd_effect_next
    ldd r24, Z+ACTIVE_EFFECT_Y_OFFSET
    ldd r25, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H
    sub r24, r25
    sbrc r24, 7
    neg r24
    cpi r24, EFFECT_DAMAGE_DISTANCE
    brsh _nrrd_effect_next
    mov r0, ZL
    mov r23, ZH
    movw ZL, XL
    adiw ZL, NPC_TABLE_ENEMY_DEXTERITY_OFFSET
    elpm r24, Z
    mov ZL, r0
    mov ZH, r23
    ldd r25, Z+ACTIVE_EFFECT_DATA2_OFFSET
    call calculate_effect_damage
_nrrd_damage_effect:
    ldd r23, Y+NPC_EFFECT_OFFSET
    andi r23, 0x38
    brne _nrrd_damage
    ldi r23, EFFECT_DAMAGE<<3
    std Y+NPC_EFFECT_OFFSET, r23
_nrrd_damage:
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
    brne _nrrd_effect_iter
_nrrd_end:
    movw ZL, XL
_nrrd_hard_end:
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
    subi r25, -(CHARACTER_SPRITE_HEIGHT-STATIC_ITEM_HEIGHT+4)/2
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
    elpm r25, Z+ ; strength
    lsl r25
    add r22, r25
    adc r23, r1
    elpm r25, Z+ ; dexterity
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
    rcall add_npc
_red_add_corpse:
    ldi ZL, byte3(2*npc_table)
    out RAMPZ, ZL
    movw ZL, r22
    ldi r25, CORPSE_NPC
    std Y+NPC_IDX_OFFSET, r25
    ret

; Try to add an NPC as far as possible from the player. This is done by
; casting four axis-aligned rays from the player's position, ensuring that
; the position is reachable and valid. Ideally the NPC would be outside
; the camera view, but that's difficult to guarantee.
;
; Temporary
;   0-1             player tile-aligned location
;   2-3             store Z pointer for internal reuse
;
; Register Usage
;   r20-21, r24     calculations
;   r25             NPC id (param)
;   X (r26:r27)     memory pointer
;   Z (r30:r31)     flash pointer
add_npc:
    movw XL, YL
    ldi YL, low(sector_npcs)
    ldi YH, high(sector_npcs)
    ldi r20, SECTOR_DYNAMIC_NPC_COUNT
_an_npc_iter:
    ld r21, Y
    tst r21
    breq _an_slot_found
    adiw YL, NPC_MEMSIZE
    dec r20
    brne _an_npc_iter
    rjmp _an_end
_an_slot_found:
    call load_npc
_an_reposition:
    lds r24, player_position_x
    lds r25, player_position_y
    subi r24, low(-CHARACTER_SPRITE_WIDTH/2)
    subi r25, low(-CHARACTER_SPRITE_HEIGHT/2)
    div12u r24, r20
    div12u r25, r21
    ldi r24, 12
    ldi r25, SECTOR_WIDTH
    mul r20, r24
    sts subroutine_tmp, r0
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H, r0
    mul r21, r24
    sts subroutine_tmp+1, r0
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H, r0
    ldi ZL, byte3(2*sector_table)
    out RAMPZ, ZL
    lds ZL, current_sector
    lds ZH, current_sector+1
    mul r21, r25
    add ZL, r0
    adc ZH, r1
    clr r1
    add ZL, r20
    adc ZH, r1
    sts subroutine_tmp+2, ZL
    sts subroutine_tmp+3, ZH
_an_raycast_up:
    clr r25
    lds r20, subroutine_tmp+1
    rjmp _an_up_check
_an_up_iter:
    sbiw ZL, SECTOR_WIDTH
    elpm r24, Z
    cpi r24, MIN_BLOCKING_TILE_IDX
    brsh _an_up_save
    inc r25
    subi r20, TILE_HEIGHT
    cpi r25, ADD_NPC_MAX_Y_DISTANCE
    brsh _an_up_save
_an_up_check:
    cpi r20, TILE_HEIGHT
    brsh _an_up_iter
_an_up_save:
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H, r20
_an_raycast_down:
    lds ZL, subroutine_tmp+2
    lds ZH, subroutine_tmp+3
    clr r21
    lds r20, subroutine_tmp+1
    rjmp _an_down_check
_an_down_iter:
    adiw ZL, SECTOR_WIDTH
    elpm r24, Z
    cpi r24, MIN_BLOCKING_TILE_IDX
    brsh _an_down_save
    inc r21
    subi r20, low(-TILE_HEIGHT)
    cpi r21, ADD_NPC_MAX_Y_DISTANCE
    brsh _an_down_save
_an_down_check:
    cpi r20, (SECTOR_HEIGHT-1)*TILE_HEIGHT
    brlo _an_down_iter
_an_down_save:
    cp r25, r21
    brsh _an_raycast_left
    mov r25, r21
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H, r20
_an_raycast_left:
    lds ZL, subroutine_tmp+2
    lds ZH, subroutine_tmp+3
    clr r21
    lds r20, subroutine_tmp
    rjmp _an_left_check
_an_left_iter:
    sbiw ZL, 1
    elpm r24, Z
    cpi r24, MIN_BLOCKING_TILE_IDX
    brsh _an_left_save
    inc r21
    subi r20, TILE_WIDTH
    cpi r21, ADD_NPC_MAX_X_DISTANCE
    brsh _an_left_save
_an_left_check:
    cpi r20, TILE_WIDTH
    brsh _an_left_iter
_an_left_save:
    cp r25, r21
    brsh _an_raycast_right
    mov r25, r21
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H, r20
    lds r20, subroutine_tmp+1
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H, r20
_an_raycast_right:
    lds ZL, subroutine_tmp+2
    lds ZH, subroutine_tmp+3
    clr r21
    lds r20, subroutine_tmp
    rjmp _an_right_check
_an_right_iter:
    adiw ZL, 1
    elpm r24, Z
    cpi r24, MIN_BLOCKING_TILE_IDX
    brsh _an_right_save
    inc r21
    subi r20, low(-TILE_WIDTH)
    cpi r21, ADD_NPC_MAX_X_DISTANCE
    brsh _an_right_save
_an_right_check:
    cpi r20, (SECTOR_WIDTH-1)*TILE_WIDTH
    brlo _an_right_iter
_an_right_save:
    cp r25, r21
    brsh _an_end
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H, r20
    lds r20, subroutine_tmp+1
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H, r20
_an_end:
    movw YL, XL
    ret