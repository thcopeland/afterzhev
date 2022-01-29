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
    brsh _ec_facing_down
    ldi r25, DIRECTION_RIGHT
    rjmp _ec_facing_down
_ec_orient_vertical:
    ldi r25, DIRECTION_UP
    cp r21, r19
    brsh _ec_facing_down
    ldi r25, DIRECTION_DOWN
_ec_facing_down:
    movw r22, r20
    cpi r25, DIRECTION_DOWN
    brne _ec_facing_right
    subi r23, -DIRECTION_BIAS
_ec_facing_right:
    cpi r25, DIRECTION_RIGHT
    brne _ec_facing_up
    subi r22, -DIRECTION_BIAS
_ec_facing_up:
    cpi r25, DIRECTION_UP
    brne _ec_facing_left
    subi r23, DIRECTION_BIAS
_ec_facing_left:
    cpi r25, DIRECTION_LEFT
    brne _ec_write_facing
    subi r22, DIRECTION_BIAS
_ec_write_facing:
    ldd r24, Y+NPC_ANIM_OFFSET
    andi r24, 0xfc
    or r24, r25
    std Y+NPC_ANIM_OFFSET, r24
_ec_calculate_distance:
    sub r22, r18
    sbrc r22, 7
    neg r22
    sub r23, r19
    sbrc r23, 7
    neg r23
    cpi r22, STRIKING_DISTANCE-1 ; approach a little closer than strictly necessary
    brsh _ec_approach_player
    cpi r23, STRIKING_DISTANCE-1
    brsh _ec_approach_player
_ec_attack_player:
    ret
_ec_approach_player:
    ldi ZL, byte3(2*npc_table)
    out RAMPZ, ZL
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
    cpi r22, 2*STRIKING_DISTANCE
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
    cpi r23, 2*STRIKING_DISTANCE
    brsh _ec_vertical_direction
    lsr r27
    cpi r23, STRIKING_DISTANCE/2
    brlo _ec_save_velocity
_ec_vertical_direction:
    cp r19, r21
    brsh _ec_acc_y
    neg r27
_ec_acc_y:
    adnv r25, r27
_ec_save_velocity:
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DX, r24
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DY, r25
    ret
