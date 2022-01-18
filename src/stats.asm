; Determine the player's current stats, taking base stats, equipped items, and
; effects into account.
;
; Register Usage
;   r18-r21             stats
;   r22-r24             calculations
;   X (r26:r27)         memory pointer
;   Z (r30:r31)         flash pointer
calculate_player_stats:
    lds r18, player_stats+STATS_STRENGTH_OFFSET
    lds r19, player_stats+STATS_VITALITY_OFFSET
    lds r20, player_stats+STATS_DEXTERITY_OFFSET
    lds r21, player_stats+STATS_CHARISMA_OFFSET
    ldi ZL, byte3(2*item_table)
    out RAMPZ, ZL
_cps_weapon_boost:
    lds r22, player_weapon
    tst r22
    breq _cps_armor_boost
    dec r22
    ldi ZL, low(2*item_table+ITEM_STATS_OFFSET)
    ldi ZH, high(2*item_table+ITEM_STATS_OFFSET)
    ldi r23, ITEM_MEMSIZE
    mul r22, r23
    add ZL, r0
    adc ZH, r1
    clr r1
    elpm r23, Z+
    adnv r18, r23
    elpm r23, Z+
    adnv r19, r23
    elpm r23, Z+
    adnv r20, r23
    elpm r23, Z+
    adnv r21, r23
_cps_armor_boost:
    lds r22, player_armor
    tst r22
    breq _cps_effect_boosts
    dec r22
    ldi ZL, low(2*item_table+ITEM_STATS_OFFSET)
    ldi ZH, high(2*item_table+ITEM_STATS_OFFSET)
    ldi r23, ITEM_MEMSIZE
    mul r22, r23
    add ZL, r0
    adc ZH, r1
    clr r1
    elpm r23, Z+
    adnv r18, r23
    elpm r23, Z+
    adnv r19, r23
    elpm r23, Z+
    adnv r20, r23
    elpm r23, Z+
    adnv r21, r23
_cps_effect_boosts:
    ldi r22, PLAYER_EFFECT_COUNT
    ldi XL, low(player_effects)
    ldi XH, high(player_effects)
_cps_effect_iter:
    ld r23, X
    tst r23
    breq _cps_effect_next
    dec r23
    ldi ZL, low(2*item_table+ITEM_STATS_OFFSET)
    ldi ZH, high(2*item_table+ITEM_STATS_OFFSET)
    ldi r24, ITEM_MEMSIZE
    mul r23, r24
    add ZL, r0
    adc ZH, r1
    clr r1
    elpm r24, Z+
    adnv r18, r24
    elpm r24, Z+
    adnv r19, r24
    elpm r24, Z+
    adnv r20, r24
    elpm r24, Z+
    adnv r21, r24
_cps_effect_next:
    adiw XL, PLAYER_EFFECT_MEMSIZE
    dec r22
    brne _cps_effect_iter
    clampi r18, -STATS_RANGE, STATS_RANGE
    clampi r19, -STATS_RANGE, STATS_RANGE
    clampi r20, -STATS_RANGE, STATS_RANGE
    clampi r21, -STATS_RANGE, STATS_RANGE
    sts player_augmented_stats+STATS_STRENGTH_OFFSET, r18
    sts player_augmented_stats+STATS_VITALITY_OFFSET, r19
    sts player_augmented_stats+STATS_DEXTERITY_OFFSET, r20
    sts player_augmented_stats+STATS_CHARISMA_OFFSET, r21
    ret

; Update the progress of each effect, clearing if necessary. At the end, calls
; calculate_player_stats.
;
; Register Usage
;   r20-r23         calculations
;   r24:r25         pointer storage
;   Y (r28:r29)     memory pointer
;   Z (r30:r31)     flash and memory pointer
update_effects_progress:
    movw r24, YL
    ldi r20, PLAYER_EFFECT_COUNT
    ldi YL, low(player_effects)
    ldi YH, high(player_effects)
    ldi ZL, byte3(2*item_table)
    out RAMPZ, ZL
_uep_effect_iter:
    ldd r21, Y+PLAYER_EFFECT_IDX_OFFSET
    tst r21
    breq _uep_effect_next
    dec r21
    ldi ZL, low(2*item_table+ITEM_FLAGS_OFFSET)
    ldi ZH, high(2*item_table+ITEM_FLAGs_OFFSET)
    ldi r23, ITEM_MEMSIZE
    mul r21, r23
    add ZL, r0
    adc ZH, r1
    clr r1
    ldd r21, Y+PLAYER_EFFECT_TIME_OFFSET
    elpm r22, Z
    lsr r22
    lsr r22
    lds r23, clock
    and r22, r23
    brne _uep_effect_next
    dec r21
    breq _uep_clear_effect
    std Y+PLAYER_EFFECT_TIME_OFFSET, r21
    rjmp _uep_effect_next
_uep_clear_effect:
    std Y+PLAYER_EFFECT_IDX_OFFSET, r1
_uep_effect_next:
    adiw YL, PLAYER_EFFECT_MEMSIZE
    dec r20
    brne _uep_effect_iter
_uep_shift1:
    ldi YL, low(player_effects)
    ldi YH, high(player_effects)
    ldi ZL, low(player_effects+PLAYER_EFFECT_MEMSIZE)
    ldi ZH, high(player_effects+PLAYER_EFFECT_MEMSIZE)
    ld r20, Y
    tst r20
    brne _uep_shift2
    ld r20, Z+
    ld r21, Z+
    st -Z, r1
    st -Z, r1
    st Y+, r20
    st Y+, r21
_uep_shift2:
    ldi YL, low(player_effects+PLAYER_EFFECT_MEMSIZE)
    ldi YH, high(player_effects+PLAYER_EFFECT_MEMSIZE)
    ldi ZL, low(player_effects+2*PLAYER_EFFECT_MEMSIZE)
    ldi ZH, high(player_effects+2*PLAYER_EFFECT_MEMSIZE)
    ld r20, Y
    tst r20
    brne _uep_end
    ld r20, Z+
    ld r21, Z+
    st -Z, r1
    st -Z, r1
    st Y+, r20
    st Y+, r21
_uep_shift3:
    ldi YL, low(player_effects+2*PLAYER_EFFECT_MEMSIZE)
    ldi YH, high(player_effects+2*PLAYER_EFFECT_MEMSIZE)
    ldi ZL, low(player_effects+3*PLAYER_EFFECT_MEMSIZE)
    ldi ZH, high(player_effects+3*PLAYER_EFFECT_MEMSIZE)
    ld r20, Y
    tst r20
    brne _uep_end
    ld r20, Z+
    ld r21, Z+
    st -Z, r1
    st -Z, r1
    st Y+, r20
    st Y+, r21
_uep_end:
    movw YL, r24
    rcall calculate_player_stats
    ret
