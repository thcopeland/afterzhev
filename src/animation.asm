; Calculate a pointer to a nonstatic character sprite. Sets RAMPZ.
;
; Register Usage
;   r22         character index (param)
;   r23         direction (param)
;   r24         current action (param)
;   r25         character frame (param), temp register
;   Z (r30:r31) calculated sprite pointer
determine_character_sprite:
    mov ZL, r25
    clr ZH
    cpi r24, ACTION_WALK
    breq _dcs_use_walk_animation
_dcs_use_idle_animation:
    subi ZL, -CHARACTER_ANIM_IDLE_FRAMES_OFFSET
    ldi r25, CHARACTER_ANIM_IDLE_FRAMES
    rjmp _dcs_determine_offsets
_dcs_use_walk_animation:
    subi ZL, -CHARACTER_ANIM_WALK_FRAMES_OFFSET
    ldi r25, CHARACTER_ANIM_WALK_FRAMES
_dcs_determine_offsets:
    mul r25, r23
    add ZL, r0
    ldi r25, CHARACTER_ANIM_TOTAL_FRAMES
    mul r22, r25
    add ZL, r0
    ldi r25, CHARACTER_SPRITE_MEMSIZE
    mul ZL, r25
    movw ZL, r0
    clr r1
    ldi r25, byte3(2*character_sprite_table)
    out RAMPZ, r25
    subi ZL, low(-2*character_sprite_table)
    sbci ZH, high(-2*character_sprite_table)
_dcs_foyle:
    ret

determine_weapon_sprite:
