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

; Calculate a pointer to a weapon sprite animation entry. Weapons reuse the DOWN
; and RIGHT sprites as UP and LEFT, but have sprites for attacks. Sets RAMPZ.
; The behavior is undefined if the given action is not a valid action.
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
    brmi _dws_end
_dws_test_walk_animation:
    cpi r24, ACTION_WALK
    brne _dws_test_attack_animation
    subi r25, -WEAPON_WALK_OFFSET_FRAMES
    ldi r21, WEAPON_WALK_FRAMES
    rjmp _dws_determine_offsets
_dws_test_attack_animation:
    cpi r24, ACTION_ATTACK
    brne _dws_test_idle_animation
    subi r25, -WEAPON_ATTACK_OFFSET_FRAMES
    ldi r21, WEAPON_ATTACK_FRAMES
    rjmp _dws_determine_offsets
_dws_test_idle_animation:
    ldi r25, WEAPON_IDLE_OFFSET_FRAMES
    ldi r21, WEAPON_IDLE_FRAMES
_dws_determine_offsets:
    sbrc r23, 0
    add r25, r21
    ldi r21, ANIMATED_ITEM_ENTRY_MEMSIZE
    mul r21, r22
    movw ZL, r0
    clr r1
    lsl r25
    lsl r25
    add ZL, r25
    adc ZH, r1
    ldi r21, byte3(2*animated_item_table)
    out RAMPZ, r21
    subi ZL, low(-2*animated_item_table)
    sbci ZH, high(-2*animated_item_table)
_dws_end:
    ret

; Calculate a pointer to an armor sprite animation entry. Armor sprites have
; distinct sprites for all directions while walking and idle, but reuse idle
; sprites when attacking and hurt. Sets RAMPZ.
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
    ldi r25, WEARABLE_IDLE_OFFSET_FRAMES
    ldi r21, WEARABLE_IDLE_FRAMES
    rjmp _das_determine_offsets
_das_walk_animation:
    subi r25, -WEARABLE_WALK_OFFSET_FRAMES
    ldi r21, WEARABLE_WALK_FRAMES
_das_determine_offsets:
    mul r23, r21
    add r25, r0
    lsl r25
    lsl r25
    ldi r21, ANIMATED_ITEM_ENTRY_MEMSIZE
    mul r21, r22
    movw ZL, r0
    clr r1
    add ZL, r25
    adc ZH, r1
    ldi r21, byte3(2*animated_item_table)
    out RAMPZ, r21
    subi ZL, low(-2*animated_item_table)
    sbci ZH, high(-2*animated_item_table)
    ret
