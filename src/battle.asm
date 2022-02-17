; Check for and resolve all player-enemy combat.
;
; Register Usage
;   r20-r26         calculations
;   Y (r28:r29)     enemy pointer
;   Z (r30:r31)     flash lookups
resolve_attacks:
    lds r25, clock
    andi r25, ATTACK_FRAME_DURATION_MASK
    brne _ra_end
    ldi YL, low(sector_npcs)
    ldi YH, high(sector_npcs)
    ldi r20, SECTOR_DYNAMIC_NPC_COUNT
_ra_enemy_iter:
    ldd r25, Y+NPC_IDX_OFFSET
    tst r25
    breq _ra_enemy_next
    ldi ZL, byte3(2*npc_table)
    out RAMPZ, ZL
    ldi ZL, low(2*npc_table)
    ldi ZH, high(2*npc_table)
    elpm r25, Z
    cpi r25, NPC_ENEMY
    brne _ra_enemy_next
_ra_check_enemy_attack:
    ldd r25, Y+NPC_ANIM_OFFSET
    mov r26, r25
    lsr r25
    mov r24, r25
    lsr r24
    andi r24, 0x7
    cpi r24, ATTACK_DAMAGE_FRAME
    brne _ra_check_player_attack
    swap r25
    andi r25, 0x7
    cpi r25, ACTION_ATTACK1
    brlo _ra_check_player_attack
    ldd r22, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H
    ldd r23, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H
    lds r24, player_position_x
    lds r25, player_position_y
    andi r26, 0x3
    call biased_character_distance
    cpi r25, STRIKING_DISTANCE
    brsh _ra_check_player_attack
    rcall resolve_enemy_attack
_ra_check_player_attack:
    lds r25, player_action
    cpi r25, ACTION_ATTACK1
    brlo _ra_enemy_next
    lds r25, player_frame
    cpi r25, ATTACK_DAMAGE_FRAME
    brlo _ra_enemy_next
    lds r22, player_position_x
    lds r23, player_position_y
    ldd r24, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H
    ldd r25, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H
    lds r26, player_direction
    call biased_character_distance
    cpi r25, STRIKING_DISTANCE
    brsh _ra_enemy_next
    rcall resolve_player_attack
_ra_enemy_next:
    adiw YL, NPC_MEMSIZE
    dec r20
    brne _ra_enemy_iter
_ra_end:
    ret

; Apply damage to the player and force the player away from the enemy. The pushing
; acceleration is damage << 1.
;
; Register Usage
;   r22-r25         calculations
;   Y (r28:r29)     enemy pointer (param)
;   Z (r30:r31)     npc table pointer (param)
resolve_enemy_attack:
    adiw ZL, NPC_TABLE_ENEMY_STRENGTH_OFFSET
    elpm r23, Z+
    elpm r24, Z+
    sbiw ZL, NPC_TABLE_ENEMY_STRENGTH_OFFSET+2
    lds r25, player_augmented_stats+STATS_DEXTERITY_OFFSET
    call calculate_damage
    lds r24, player_health
    sub r24, r23
    sts player_health, r24
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
    ret

; Apply damage to the given enemy and push it away from the player. The pushing
; acceleration is damage << 1.
;
; Register Usage
;   r22-r25         calculations
;   Y (r28:r29)     enemy pointer (param)
;   Z (r30:r31)     npc table pointer (param)
resolve_player_attack:
    lds r23, player_augmented_stats+STATS_STRENGTH_OFFSET
    lds r24, player_augmented_stats+STATS_DEXTERITY_OFFSET
    adiw ZL, NPC_TABLE_ENEMY_DEXTERITY_OFFSET
    elpm r25, Z
    sbiw ZL, NPC_TABLE_ENEMY_DEXTERITY_OFFSET
    call calculate_damage
    ldd r24, Y+NPC_HEALTH_OFFSET
    sub r24, r23
    std Y+NPC_HEALTH_OFFSET, r24
    lsl r23
    mov r22, r23
    lds r24, player_position_x
    ldd r25, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H
    cp r24, r25
    brlo _rpa_push_x
    neg r22
_rpa_push_x:
    ldd r25, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DX
    adnv r25, r22
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DX, r25
    lds r24, player_position_y
    ldd r25, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H
    cp r24, r25
    brlo _rpa_push_y
    neg r23
_rpa_push_y:
    ldd r25, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DY
    adnv r25, r23
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DY, r25
    ret
