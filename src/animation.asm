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

; Calculate a pointer to a nonstatic item sprite. Sets RAMPZ. The behavior is
; undefined if the given action is not a valid action.
;
; Register Usage
;   r22         item index (param)
;   r23         direction (param)
;   r24         current action (param)
;   r25         character frame (param), temp register
;   Z (r30:r31) calculated sprite pointer
determine_overlay_sprite:
    dec r22
    brge _dos_determine_sprite
    ldi ZL, low(2*animated_item_sprite_table)
    ldi ZH, high(2*animated_item_sprite_table)
    ret
_dos_determine_sprite:
    mov ZL, r25
    clr ZH
_dos_test_idle_animation: ; IDLE and HURT actions share the same sprites
    cpi r24, ACTION_IDLE
    breq _dos_use_idle_animation
    cpi r24, ACTION_HURT
    brne _dos_test_walk_animation
_dos_use_idle_animation:
    subi ZL, -ITEM_ANIM_IDLE_OFFSET_FRAMES
    ldi r25, ITEM_ANIM_IDLE_FRAMES
_dos_test_walk_animation:
    cpi r24, ACTION_WALK
    brne _dos_test_attack1_animation
    subi ZL, -ITEM_ANIM_WALK_OFFSET_FRAMES
    ldi r25, ITEM_ANIM_WALK_FRAMES
_dos_test_attack1_animation:
    cpi r24, ACTION_ATTACK1
    brne _dos_test_attack2_animation
    subi ZL, -ITEM_ANIM_ATTACK_OFFSET_FRAMES
    ldi r25, ITEM_ANIM_ATTACK_FRAMES
_dos_test_attack2_animation:
    cpi r24, ACTION_ATTACK2
    brne _dos_test_attack3_animation
    subi ZL, -(ITEM_ANIM_ATTACK_OFFSET_FRAMES + ITEM_ANIM_ATTACK_TOTAL_FRAMES)
    ldi r25, ITEM_ANIM_ATTACK_FRAMES
_dos_test_attack3_animation:
    cpi r24, ACTION_ATTACK3
    brne _dos_determine_offsets
    subi ZL, -(ITEM_ANIM_ATTACK_OFFSET_FRAMES + 2*ITEM_ANIM_ATTACK_TOTAL_FRAMES)
    ldi r25, ITEM_ANIM_ATTACK_FRAMES
_dos_determine_offsets:
    mul r25, r23
    add ZL, r0
    ldi r25, ITEM_LUT_ENTRY_FRAME_MEMSIZE
    mul r25, ZL
    movw ZL, r0
    ldi r25, ITEM_LUT_ENTRY_MEMSIZE
    mul r25, r22
    add ZL, r0
    adc ZH, r1
    clr r1
    ldi r25, byte3(2*animated_item_sprite_lut)
    out RAMPZ, r25
    subi ZL, low(-2*animated_item_sprite_lut)
    sbci ZH, high(-2*animated_item_sprite_lut)
    elpm r24, Z+
    elpm r25, Z
    subi r24, low(-2*animated_item_sprite_table)
    sbci r25, high(-2*animated_item_sprite_table)
    movw ZL, r24
    ret
