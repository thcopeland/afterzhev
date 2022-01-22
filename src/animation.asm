; Calculate a pointer to a nonstatic character sprite. Sets RAMPZ.
;
; Register Usage
;   r21         calculations
;   r22         character index (param)
;   r23         direction (param)
;   r24         current action (param)
;   r25         character frame (param), calculations
;   Z (r30:r31) calculated sprite pointer
determine_character_sprite:
    cpi r24, ACTION_WALK
    breq _dcs_use_walk_animation
_dcs_use_idle_animation:
    ldi r25, CHARACTER_ANIM_IDLE_FRAMES_OFFSET
    ldi r21, CHARACTER_ANIM_IDLE_FRAMES
    rjmp _dcs_determine_offsets
_dcs_use_walk_animation:
    subi r25, -CHARACTER_ANIM_WALK_FRAMES_OFFSET
    ldi r21, CHARACTER_ANIM_WALK_FRAMES
_dcs_determine_offsets:
    mul r21, r23
    add r25, r0
    ldi r21, CHARACTER_ANIM_TOTAL_FRAMES
    mul r22, r21
    add r25, r0
    ldi r21, CHARACTER_SPRITE_MEMSIZE
    mul r25, r21
    movw ZL, r0
    clr r1
    ldi r21, byte3(2*character_sprite_table)
    out RAMPZ, r21
    subi ZL, low(-2*character_sprite_table)
    sbci ZH, high(-2*character_sprite_table)
_dcs_foyle:
    ret

; Calculate a pointer to a weapon sprite. Weapons reuse the DOWN and RIGHT sprites
; as UP and LEFT, but have sprites for attacks. Sets RAMPZ. The behavior is
; undefined if the given action is not a valid action.
;
; Register Usage
;   r21         calculations
;   r22         item index (param)
;   r23         direction (param)
;   r24         current action (param)
;   r25         character frame (param), temp register
;   Z (r30:r31) calculated sprite pointer
determine_weapon_sprite:
    dec r22
    brpl _dws_test_idle_animation
    ret
_dws_test_idle_animation:
    cpi r24, ACTION_IDLE
    breq _dws_use_idle_animation
    cpi r24, ACTION_HURT
    brne _dws_test_walk_animation
_dws_use_idle_animation:
    subi r25, -ITEM_ANIM_IDLE_OFFSET_FRAMES
    ldi r21, ITEM_ANIM_IDLE_FRAMES
_dws_test_walk_animation:
    cpi r24, ACTION_WALK
    brne _dws_test_attack1_animation
    subi r25, -ITEM_ANIM_WALK_OFFSET_FRAMES
    ldi r21, ITEM_ANIM_WALK_FRAMES
_dws_test_attack1_animation:
    cpi r24, ACTION_ATTACK1
    brne _dws_test_attack2_animation
    subi r25, -ITEM_ANIM_ATTACK_OFFSET_FRAMES
    ldi r21, ITEM_ANIM_ATTACK_FRAMES
_dws_test_attack2_animation:
    cpi r24, ACTION_ATTACK2
    brne _dws_determine_offsets
    subi r25, -(ITEM_ANIM_ATTACK_OFFSET_FRAMES + ITEM_ANIM_ATTACK_TOTAL_FRAMES)
    ldi r21, ITEM_ANIM_ATTACK_FRAMES
_dws_determine_offsets:
    sbrc r23, 0
    add r25, r21
    ldi r21, ITEM_LUT_ENTRY_FRAME_MEMSIZE
    mul r21, r25
    movw ZL, r0
    ldi r21, ITEM_LUT_ENTRY_MEMSIZE
    mul r21, r22
    add ZL, r0
    adc ZH, r1
    clr r1
    ldi r21, byte3(2*animated_item_sprite_lut)
    out RAMPZ, r21
    subi ZL, low(-2*animated_item_sprite_lut)
    sbci ZH, high(-2*animated_item_sprite_lut)
    elpm r24, Z+
    elpm r25, Z
    subi r24, low(-2*animated_item_sprite_table)
    sbci r25, high(-2*animated_item_sprite_table)
    movw ZL, r24
    ret

; Calculate a pointer to an armor sprite. Armor sprites have distinct sprites
; for all directions while walking and idle, but reuse idle sprites when attacking
; and hurt. Sets RAMPZ.
;
; Register Usage
;   r21         calculations
;   r22         item index (param)
;   r23         direction (param)
;   r24         current action (param)
;   r25         character frame (param), temp register
;   Z (r30:r31) calculated sprite pointer
determine_armor_sprite:
    dec r22
    brpl _das_test_action
    ret
_das_test_action:
    cpi r24, ACTION_WALK
    breq _das_walk_animation
_das_idle_animation:
    subi r25, -ITEM_ANIM_IDLE_OFFSET_FRAMES
    ldi r21, ITEM_ANIM_IDLE_FRAMES
    rjmp _das_determine_offsets
_das_walk_animation:
    subi r25, -ITEM_ANIM_WALK_OFFSET_FRAMES
    ldi r21, ITEM_ANIM_WALK_FRAMES
_das_determine_offsets:
    mul r23, r21
    add r25, r0
    ldi r21, ITEM_LUT_ENTRY_FRAME_MEMSIZE
    mul r21, r25
    movw ZL, r0
    ldi r21, ITEM_LUT_ENTRY_MEMSIZE
    mul r21, r22
    add ZL, r0
    adc ZH, r1
    clr r1
    ldi r21, byte3(2*animated_item_sprite_lut)
    out RAMPZ, r21
    subi ZL, low(-2*animated_item_sprite_lut)
    sbci ZH, high(-2*animated_item_sprite_lut)
    elpm r24, Z+
    elpm r25, Z
    subi r24, low(-2*animated_item_sprite_table)
    sbci r25, high(-2*animated_item_sprite_table)
    movw ZL, r24
    ret
