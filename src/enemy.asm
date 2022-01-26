; Move around at a constant speed, negating x velocity when colliding with a
; horizontal barrier, and negating y velocity when colliding with a vertical
; barrier.
;
; Register Usage
;   r16-r17         call-saved values
;   r23             facing direction (param)
;   r24-r25         calculations
;   Y (r28:r29)     position data pointer (param)
enemy_patrol:
    push r16
    push r17
    ldd r16, Y+CHARACTER_POSITION_DX
    ldd r17, Y+CHARACTER_POSITION_DY
    clr r26
    call move_character
_ep_test_reverse_x:
    ldd r24, Y+CHARACTER_POSITION_DX
    cp r16, r24
    brne _ep_reverse_x
    ldd r24, Y+CHARACTER_POSITION_X_H
    cpi r24, 1
    brlo _ep_reverse_x
    cpi r24, TILE_WIDTH*SECTOR_WIDTH - CHARACTER_SPRITE_WIDTH
    brlo _ep_test_reverse_y
_ep_reverse_x:
    ldd r24, Y+CHARACTER_POSITION_X_H
    neg r16
    std Y+CHARACTER_POSITION_DX, r16
    ldi r24, 1
    eor r23, r24
_ep_test_reverse_y:
    ldd r25, Y+CHARACTER_POSITION_DY
    cp r17, r25
    brne _ep_reverse_y
    ldd r25, Y+CHARACTER_POSITION_Y_H
    cpi r25, 1
    brlo _ep_reverse_y
    cpi r25, TILE_HEIGHT*SECTOR_HEIGHT - CHARACTER_SPRITE_HEIGHT
    brlo _ep_end
_ep_reverse_y:
    neg r17
    std Y+CHARACTER_POSITION_DY, r17
    ldi r24, 2
    eor r23, r24
_ep_end:
    pop r17
    pop r16
    ret
