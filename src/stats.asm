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
    lds r21, player_stats+STATS_INTELLECT_OFFSET
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
    sts player_augmented_stats+STATS_INTELLECT_OFFSET, r21
    rcall calculate_max_health
    lds r24, player_health
    cp r25, r24
    brsh _cps_end
    sts player_health, r25
_cps_end:
    ret

; Update the progress of each effect, clearing if necessary. At the end, calls
; calculate_player_stats.
;
; Register Usage
;   r20-r23         calculations
;   r24:r25         pointer storage
;   Y (r28:r29)     memory pointer
;   Z (r30:r31)     flash and memory pointer
update_player_stat_effects:
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
    ror r22
    brcs _uep_effect_next
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

; Update the player's health. Once every few frames, health is incremented.
;   update interval = max(40-vitality, 0)+10
;
; Register Usage
;   r22-r25     calculations
update_player_health:
    lds r23, player_augmented_stats + STATS_VITALITY_OFFSET
    ldi r22, 40
    sub r22, r23
    brsh _uph_div
    clr r22
_uph_div:
    subi r22, low(-10)
    clr r23
    lds r24, clock
    lds r25, clock+1
    call divmodw
    cp r22, r1
    cpc r23, r1
    brne _uph_end
_uph_heal:
    lds r22, player_health
    tst r22
    breq _uph_end
    inc r22
    call calculate_max_health
    cp r25, r22
    brlo _uph_end
    sts player_health, r22
_uph_end:
    ret

; Calculate the player's maximum health.
;   health = 10+(strength + dexterity + intellect)/2 + 2*vitality + armor boost
;
; Register Usage
;   r24     calculations
;   r25     health
calculate_max_health:
    lds r25, player_armor
    dec r25
    brpl _cmh_armor
    clr r25
    rjmp _cmh_stat
_cmh_armor:
    ldi ZL, byte3(2*item_table)
    out RAMPZ, ZL
    ldi ZL, low(2*item_table+ITEM_FLAGS_OFFSET)
    ldi ZH, high(2*item_table+ITEM_FLAGS_OFFSET)
    ldi r24, ITEM_MEMSIZE
    mul r25, r24
    add ZL, r0
    adc ZH, r1
    clr r1
    elpm r25, Z
    asr r25
_cmh_stat:
    lds r24, player_stats + STATS_STRENGTH_OFFSET
    add r25, r24
    lds r24, player_stats + STATS_DEXTERITY_OFFSET
    add r25, r24
    lds r24, player_stats + STATS_INTELLECT_OFFSET
    add r25, r24
    lsr r25
    lds r24, player_stats + STATS_VITALITY_OFFSET
    add r25, r24
    add r25, r24
    subi r25, low(-10)
    ret

; Calculate the player's acceleration.
;   acceleration = 3 + max(dexterity*0.375, 0)
;
; Register Usage
;   r20             acceleration
;   r21             calculations
calculate_acceleration:
    lds r20, player_augmented_stats+STATS_DEXTERITY_OFFSET
    asr r20
    mov r21, r20
    asr r21
    asr r21
    sub r20, r21
    sbrc r20, 7
    clr r20
    subi r20, low(-3)
    ret

; Calculate the acceration applied to an enemy when colliding with the player.
;   acceleration = 2 + strength/8
;
; Register Usage
;   r25     acceleration
calculate_push_acceleration:
    lds r25, player_augmented_stats+STATS_STRENGTH_OFFSET
    lsr r25
    lsr r25
    lsr r25
    subi r25, -2
    ret

; Calculate the resistance factor applied to the player when running through enemies.
;   resistance = (float) (190 + dexterity/2 + strength) / 0xff
;
; Register Usage
;   r22     resistance
;   r23     calculations
calculate_push_resistance:
    lds r22, player_augmented_stats+STATS_DEXTERITY_OFFSET
    lsr r22
    lds r23, player_augmented_stats+STATS_STRENGTH_OFFSET
    add r22, r23
    subi r22, low(-190)
    brmi _cpr_end
    ldi r22, 0xff
_cpr_end:
    ret

; Calculate the dash cooldown time.
;   cooldown = 6*max(38-dex, 3)
;
; Register Usage
;   r25     cooldown time
calculate_dash_cooldown:
    lds r25, player_augmented_stats+STATS_DEXTERITY_OFFSET
    subi r25, 38
    brlo _cdc_main
    clr r25
_cdc_main:
    neg r25
    sbrc r25, 7
    ldi r25, 3
    lsl r25
    mov r0, r25
    lsl r25
    add r25, r0
    ret

; Reset the player's stats based on the player's class.
;
; Register Usage
;   r22-r25     calculations
;   Y (r28:r29) memory pointer
init_player_stats:
    sts player_augmented_stats+STATS_STRENGTH_OFFSET, r1
    sts player_augmented_stats+STATS_VITALITY_OFFSET, r1
    sts player_augmented_stats+STATS_DEXTERITY_OFFSET, r1
    sts player_augmented_stats+STATS_INTELLECT_OFFSET, r1
    ldi YL, low(player_effects)
    ldi YH, high(player_effects)
    ldi r24, PLAYER_EFFECT_COUNT
_ips_loop:
    std Y+PLAYER_EFFECT_IDX_OFFSET, r1
    adiw YL, PLAYER_EFFECT_COUNT
    dec r24
    brne _ips_loop
_ips_check_class:
    lds r25, player_class
_ips_paladin:
    cpi r25, CLASS_PALADIN
    brne _ips_rogue
    ldi r22, 10
    ldi r23, 10
    ldi r24, 5
    ldi r25, 3
_ips_rogue:
    cpi r25, CLASS_ROGUE
    brne _ips_mage
    ldi r22, 6
    ldi r23, 6
    ldi r24, 12
    ldi r25, 8
_ips_mage:
    cpi r25, CLASS_MAGE
    brne _ips_save_stats
    ldi r22, 4
    ldi r23, 6
    ldi r24, 7
    ldi r25, 13
_ips_save_stats:
    sts player_stats + STATS_STRENGTH_OFFSET, r22
    sts player_stats + STATS_VITALITY_OFFSET, r23
    sts player_stats + STATS_DEXTERITY_OFFSET, r24
    sts player_stats + STATS_INTELLECT_OFFSET, r25
    rcall update_player_stat_effects
    rcall calculate_max_health
    sts player_health, r25
    ret
