explore_update_game:
    rcall render_game
    rcall handle_controls
    call update_player_stat_effects
    rcall update_active_effects
    rcall update_player
    rcall move_camera

    ldi ZL, byte3(2*sector_table)
    out RAMPZ, ZL
    lds ZL, current_sector
    lds ZH, current_sector+1
    subi ZL, low(-SECTOR_HANDLERS_OFFSET)
    sbci ZH, high(-SECTOR_HANDLERS_OFFSET)
    elpm r24, Z+
    elpm r25, Z+
    tst r25
    breq _eup_end
    movw ZL, r24
    icall
_eup_end:
    jmp _loop_reenter

.equ EXPLORE_UI_EFFECTS_MARGIN = DISPLAY_WIDTH*(DISPLAY_HEIGHT-FOOTER_HEIGHT+1)-9
.equ EXPLORE_UI_EFFECTS_SEPARATION = 8
.equ EXPLORE_UI_XP_MARGIN = DISPLAY_WIDTH*(DISPLAY_HEIGHT-FOOTER_HEIGHT+1)+15
.equ EXPLORE_UI_XP_ICON_MARGIN = DISPLAY_WIDTH*(DISPLAY_HEIGHT-FOOTER_HEIGHT+1)+24
.equ EXPLORE_UI_GOLD_MARGIN = DISPLAY_WIDTH*(DISPLAY_HEIGHT-FOOTER_HEIGHT+1)+47
.equ EXPLORE_UI_GOLD_ICON_MARGIN = DISPLAY_WIDTH*(DISPLAY_HEIGHT-FOOTER_HEIGHT+1)+52
.equ EXPLORE_UI_HEALTH_MARGIN = DISPLAY_WIDTH*(DISPLAY_HEIGHT-FOOTER_HEIGHT+1)+78
.equ EXPLORE_UI_HEALTH_ICON_MARGIN = DISPLAY_WIDTH*(DISPLAY_HEIGHT-FOOTER_HEIGHT+1)+83
.equ EXPLORE_UI_COOLDOWN_BAR_LENGTH = 4
.equ EXPLORE_UI_ATTACK_COOLDOWN_MARGIN = DISPLAY_WIDTH*(DISPLAY_HEIGHT-FOOTER_HEIGHT+EXPLORE_UI_COOLDOWN_BAR_LENGTH)+90
.equ EXPLORE_UI_DASH_COOLDOWN_MARGIN = EXPLORE_UI_ATTACK_COOLDOWN_MARGIN+4


; Render the game while in the EXPLORE mode. The current sector, NPCs, items,
; the player must all be rendered.
;
; Register Usage
;   r14-17          storing values across calls, not preserved
;   r18-r25         calculations, params
;   Y (r28:r29)     memory pointer
;   Z (r30:r31)     memory pointer
render_game:
    lds r18, camera_position_x
    divmod12u r18, r21, r20
    lds r18, camera_position_y
    divmod12u r18, r23, r22
    lds r24, current_sector
    lds r25, current_sector+1
    call render_sector
_rg_render_loose_items:
    ldi YL, low(sector_loose_items)
    ldi YH, high(sector_loose_items)
    ldi r16, SECTOR_DYNAMIC_ITEM_COUNT
_rg_render_loose_items_iter:
    ldd r18, Y+SECTOR_ITEM_IDX_OFFSET
    tst r18
    breq _rg_render_loose_items_next
    ldi ZL, byte3(2*static_item_sprite_table)
    out RAMPZ, ZL
    cpi r18, 128
    brlo _rg_render_item
_rg_render_gold:
    ldi ZL, low(2*static_item_gold_sprite)
    ldi ZH, high(2*static_item_gold_sprite)
    rjmp _rg_render_item_sprite
_rg_render_item:
    dec r18
    ldi r19, STATIC_ITEM_MEMSIZE
    mul r18, r19
    movw ZL, r0
    clr r1
    subi ZL, low(-2*static_item_sprite_table)
    sbci ZH, high(-2*static_item_sprite_table)
_rg_render_item_sprite:
    ldi r22, STATIC_ITEM_WIDTH
    ldi r23, STATIC_ITEM_HEIGHT
    ldd r24, Y+SECTOR_ITEM_X_OFFSET
    ldd r25, Y+SECTOR_ITEM_Y_OFFSET
    call render_sprite
_rg_render_loose_items_next:
    adiw YL, SECTOR_DYNAMIC_ITEM_MEMSIZE
    dec r16
    brne _rg_render_loose_items_iter
_rg_render_npcs:
    ldi YL, low(sector_npcs)
    ldi YH, high(sector_npcs)
    ldi r16, SECTOR_DYNAMIC_NPC_COUNT
_rg_render_npcs_iter:
    ldd r17, Y+NPC_IDX_OFFSET
    dec r17
    brmi _rg_render_npcs_next
    ldi ZL, low(2*npc_table+NPC_TABLE_CHARACTER_OFFSET)
    ldi ZH, high(2*npc_table+NPC_TABLE_CHARACTER_OFFSET)
    ldi r18, NPC_TABLE_ENTRY_MEMSIZE
    mul r17, r18
    add ZL, r0
    adc ZH, r1
    clr r1
    lpm r18, Z+
_rg_render_static_npc:
    cpi r18, 128
    brlo _rg_render_dynamic_npc
    andi r18, low(~128)
    ldi ZL, byte3(2*static_character_sprite_table)
    out RAMPZ, ZL
    ldi ZL, low(2*static_character_sprite_table)
    ldi ZH, high(2*static_character_sprite_table)
    ldi r19, CHARACTER_SPRITE_MEMSIZE
    mul r18, r19
    add ZL, r0
    adc ZH, r1
    clr r1
    ldi r22, CHARACTER_SPRITE_WIDTH
    ldi r23, CHARACTER_SPRITE_HEIGHT
    ldd r24, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H
    ldd r25, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H
    call render_sprite
    ldd r22, Y+NPC_EFFECT_OFFSET
    ldd r24, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H
    ldd r25, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H
    call render_effect_animation
_rg_render_npcs_next:
    adiw YL, NPC_MEMSIZE
    dec r16
    brne _rg_render_npcs_iter
    rjmp _rg_render_player
_rg_render_dynamic_npc:
    sts character_render+CHARACTER_SPRITE_OFFSET, r18
    lpm r18, Z+
    sts character_render+CHARACTER_WEAPON_OFFSET, r18
    lpm r18, Z+
    sts character_render+CHARACTER_ARMOR_OFFSET, r18
    ldd r18, Y+NPC_ANIM_OFFSET
    mov r19, r18
    andi r19, 3
    sts character_render+CHARACTER_DIRECTION_OFFSET, r19
    lsr r18
    mov r19, r18
    lsr r19
    andi r19, 7
    sts character_render+CHARACTER_FRAME_OFFSET, r19
    swap r18
    andi r18, 7
    sts character_render+CHARACTER_ACTION_OFFSET, r18
    ldd r18, Y+NPC_EFFECT_OFFSET
    sts character_render+CHARACTER_EFFECT_OFFSET, r18
    ldd r24, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H
    ldd r25, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H
    movw r14, YL
    ldi YL, low(character_render)
    ldi YH, high(character_render)
    call render_character
    movw YL, r14
    rjmp _rg_render_npcs_next
_rg_render_player:
    lds r24, player_position_x
    lds r25, player_position_y
    ldi YL, low(player_character)
    ldi YH, high(player_character)
    call render_character
_rg_render_active_effects:
    ldi YL, low(active_effects)
    ldi YH, high(active_effects)
    ldi r16, ACTIVE_EFFECT_COUNT
_rg_active_effect_iter:
    ldd r23, Y+ACTIVE_EFFECT_DATA2_OFFSET
    andi r23, 0x0c
    brne _rg_active_effect_iter_next
    ldd r22, Y+ACTIVE_EFFECT_DATA_OFFSET
    ldd r24, Y+ACTIVE_EFFECT_X_OFFSET
    ldd r25, Y+ACTIVE_EFFECT_Y_OFFSET
    call render_effect_animation
_rg_active_effect_iter_next:
    adiw YL, ACTIVE_EFFECT_MEMSIZE
    dec r16
    brne _rg_active_effect_iter
_rg_footer_background:
    ldi XL, low(framebuffer+DISPLAY_WIDTH*(DISPLAY_HEIGHT-FOOTER_HEIGHT))
    ldi XH, high(framebuffer+DISPLAY_WIDTH*(DISPLAY_HEIGHT-FOOTER_HEIGHT))
    ldi r22, INVENTORY_UI_HEADER_COLOR
    ldi r24, DISPLAY_WIDTH
    ldi r25, FOOTER_HEIGHT
    call render_rect
_rg_player_health:
    ldi XL, low(framebuffer+EXPLORE_UI_HEALTH_ICON_MARGIN)
    ldi XH, high(framebuffer+EXPLORE_UI_HEALTH_ICON_MARGIN)
    ldi r24, 5
    ldi r25, 4
    ldi ZL, byte3(2*ui_small_heart_icon)
    out RAMPZ, ZL
    ldi ZL, low(2*ui_small_heart_icon)
    ldi ZH, high(2*ui_small_heart_icon)
    call render_element
    ldi XL, low(framebuffer+EXPLORE_UI_HEALTH_MARGIN)
    ldi XH, high(framebuffer+EXPLORE_UI_HEALTH_MARGIN)
    call calculate_max_health
    mov r21, r25
    call putb_small
    ldi r22, '/'
    call putc_small
    subi XL, low(FONT_DISPLAY_WIDTH)
    sbci XH, high(FONT_DISPLAY_WIDTH)
    lds r21, player_health
    call putb_small
_rg_player_gold:
    ldi XL, low(framebuffer+EXPLORE_UI_GOLD_ICON_MARGIN)
    ldi XH, high(framebuffer+EXPLORE_UI_GOLD_ICON_MARGIN)
    ldi r24, 3
    ldi r25, 4
    ldi ZL, byte3(2*ui_small_coin_icon)
    out RAMPZ, ZL
    ldi ZL, low(2*ui_small_coin_icon)
    ldi ZH, high(2*ui_small_coin_icon)
    call render_element
    ldi XL, low(framebuffer+EXPLORE_UI_GOLD_MARGIN)
    ldi XH, high(framebuffer+EXPLORE_UI_GOLD_MARGIN)
    lds r18, player_gold
    lds r19, player_gold+1
    call putw_small
_rg_player_xp:
    ldi XL, low(framebuffer+EXPLORE_UI_XP_ICON_MARGIN)
    ldi XH, high(framebuffer+EXPLORE_UI_XP_ICON_MARGIN)
    ldi r23, 0x82
    ldi r22, 'P'
    call putc_small
    sbiw XL, FONT_DISPLAY_WIDTH
    ldi r22, 'X'
    call putc_small
    ldi XL, low(framebuffer+EXPLORE_UI_XP_MARGIN)
    ldi XH, high(framebuffer+EXPLORE_UI_XP_MARGIN)
    lds r18, player_xp
    lds r19, player_xp+1
    clr r23
    call putw_small
_rg_calc_attack_cooldown:
    ldi ZL, byte3(2*item_table)
    out RAMPZ, ZL
    ldi ZL, low(2*item_table+ITEM_FLAGS_OFFSET)
    ldi ZH, high(2*item_table+ITEM_FLAGS_OFFSET)
    clr r24
    lds r20, player_weapon
    dec r20
    brmi _rg_render_attack_cooldown
    ldi r21, ITEM_MEMSIZE
    mul r20, r21
    add ZL, r0
    adc ZH, r1
    elpm r22, Z
    lsl r22
    andi r22, 0x70
    subi r22, -((ATTACK_FRAME_DURATION_MASK+1)*ITEM_ANIM_ATTACK_FRAMES)
    clr r23
    lds r24, player_attack_cooldown
    ldi r25, EXPLORE_UI_COOLDOWN_BAR_LENGTH
    mul r24, r25
    movw r24, r0
    call divmodw
    tst r22
    breq _rg_clamp_attack_cooldown
    inc r24
_rg_clamp_attack_cooldown:
    cpi r24, EXPLORE_UI_COOLDOWN_BAR_LENGTH
    brlo _rg_render_attack_cooldown
    ldi r24, EXPLORE_UI_COOLDOWN_BAR_LENGTH
_rg_render_attack_cooldown:
    ldi ZL, low(framebuffer+EXPLORE_UI_ATTACK_COOLDOWN_MARGIN)
    ldi ZH, high(framebuffer+EXPLORE_UI_ATTACK_COOLDOWN_MARGIN)
    ldi r20, 0b01001100
    ldi r21, 0b01001010
    ldi r25, EXPLORE_UI_COOLDOWN_BAR_LENGTH
_rg_attack_cooldown_iter1:
    st Z, r20
    std Z+1, r21
    subi ZL, low(DISPLAY_WIDTH)
    sbci ZH, high(DISPLAY_WIDTH)
    dec r25
    brne _rg_attack_cooldown_iter1
    tst r24
    breq _rg_calc_dash_cooldown
    ldi r20, 0xa4
    ldi r21, 0x5b
_rg_attack_cooldown_iter2:
    subi ZL, low(-DISPLAY_WIDTH)
    sbci ZH, high(-DISPLAY_WIDTH)
    st Z, r20
    std Z+1, r21
    dec r24
    brne _rg_attack_cooldown_iter2
_rg_calc_dash_cooldown:
    call calculate_dash_cooldown
    mov r22, r25
    clr r23
    ldi r24, EXPLORE_UI_COOLDOWN_BAR_LENGTH
    lds r25, player_dash_cooldown
    mul r24, r25
    movw r24, r0
    call divmodw
    tst r22
    breq _rg_clamp_dash_cooldown
    inc r24
_rg_clamp_dash_cooldown:
    cpi r24, EXPLORE_UI_COOLDOWN_BAR_LENGTH
    brlo _rg_render_dash_cooldown
    ldi r24, EXPLORE_UI_COOLDOWN_BAR_LENGTH
_rg_render_dash_cooldown:
    ldi ZL, low(framebuffer+EXPLORE_UI_DASH_COOLDOWN_MARGIN)
    ldi ZH, high(framebuffer+EXPLORE_UI_DASH_COOLDOWN_MARGIN)
    ldi r20, 0x1a
    ldi r21, 0x11
    ldi r25, EXPLORE_UI_COOLDOWN_BAR_LENGTH
_rg_dash_cooldown_iter1:
    st Z, r20
    std Z+1, r21
    subi ZL, low(DISPLAY_WIDTH)
    sbci ZH, high(DISPLAY_WIDTH)
    dec r25
    brne _rg_dash_cooldown_iter1
    tst r24
    breq _rg_effects
    ldi r20, 0xa4
    ldi r21, 0x5b
_rg_dash_cooldown_iter2:
    subi ZL, low(-DISPLAY_WIDTH)
    sbci ZH, high(-DISPLAY_WIDTH)
    st Z, r20
    std Z+1, r21
    dec r24
    brne _rg_dash_cooldown_iter2
_rg_effects:
    ldi XL, low(framebuffer+EXPLORE_UI_EFFECTS_MARGIN)
    ldi XH, high(framebuffer+EXPLORE_UI_EFFECTS_MARGIN)
    clr r20
_rg_effects_iter:
    mov r25, r20
    movw YL, XL
    rcall render_effect_progress
    movw XL, YL
    sbiw XL, EXPLORE_UI_EFFECTS_SEPARATION
    inc r20
    cpi r20, PLAYER_EFFECT_COUNT
    brne _rg_effects_iter
    ret

; Handle button presses.
;
; Register Usage
;   r18             previous button states
;   r19             current button state
;   r20-r21         miscellaneous
;   Z (r30:r31)     flash memory lookups
handle_controls:
    lds r18, prev_controller_values
    lds r19, controller_values
    call calculate_acceleration
_hc_up:
    sbrs r19, CONTROLS_UP
    rjmp _hc_down
    lds r21, player_velocity_y
    sbnv r21, r20
    sts player_velocity_y, r21
    ldi r21, DIRECTION_UP
    sts player_direction, r21
_hc_down:
    sbrs r19, CONTROLS_DOWN
    rjmp _hc_left
    lds r21, player_velocity_y
    adnv r21, r20
    sts player_velocity_y, r21
    ldi r21, DIRECTION_DOWN
    sts player_direction, r21
_hc_left:
    sbrs r19, CONTROLS_LEFT
    rjmp _hc_right
    lds r21, player_velocity_x
    sbnv r21, r20
    sts player_velocity_x, r21
    ldi r21, DIRECTION_LEFT
    sts player_direction, r21
_hc_right:
    sbrs r19, CONTROLS_RIGHT
    rjmp _hc_button1
    lds r21, player_velocity_x
    adnv r21, r20
    sts player_velocity_x, r21
    ldi r21, DIRECTION_RIGHT
    sts player_direction, r21
_hc_button1:
    sbrs r19, CONTROLS_SPECIAL1
    rjmp _hc_button2
    sbrc r18, CONTROLS_SPECIAL1
    rjmp _hc_button2
    rcall handle_main_button
    rjmp _hc_end
_hc_button2:
    sbrc r19, CONTROLS_SPECIAL2
    rcall player_attack
_hc_button3:
    sbrc r19, CONTROLS_SPECIAL3
    rcall player_dash
_hc_button4:
    sbrs r19, CONTROLS_SPECIAL4
    rjmp _hc_end
    sbrc r18, CONTROLS_SPECIAL4
    rjmp _hc_end
    call load_inventory
_hc_end:
    ret

; The main button allows interaction with the environment. If there are nearby
; items, one of them is added to the player's inventory.
;
; Register Usage
;   r18-r23         calculations
;   X (r26:r27)     memory pointer 2
;   Z (r30:r31)     memory pointer
handle_main_button:
    lds r18, player_position_x
    lds r19, player_position_y
    subi r18, -CHARACTER_SPRITE_WIDTH/2
    subi r19, -CHARACTER_SPRITE_HEIGHT/2
_hmb_pickup_items:
    ldi ZL, low(sector_loose_items)
    ldi ZH, high(sector_loose_items)
    ldi r22, SECTOR_DYNAMIC_ITEM_COUNT
_hmb_loose_item_iter:
    ldd r23, Z+SECTOR_ITEM_IDX_OFFSET
    tst r23
    breq _hmb_loose_item_next
    ldd r20, Z+SECTOR_ITEM_X_OFFSET
    ldd r21, Z+SECTOR_ITEM_Y_OFFSET
    subi r20, -STATIC_ITEM_WIDTH/2
    subi r21, -STATIC_ITEM_HEIGHT/2
    sub r20, r18
    sbrc r20, 7
    neg r20
    sub r21, r19
    sbrc r21, 7
    neg r21
    cpi r20, 2*TILE_WIDTH/3
    brsh _hmb_loose_item_next
    cpi r21, 3*TILE_HEIGHT/4
    brlo _hmb_nearby_item_found
_hmb_loose_item_next:
    adiw ZL, SECTOR_DYNAMIC_ITEM_MEMSIZE
    dec r22
    brne _hmb_loose_item_iter
    rjmp _hmb_npc_interactions
_hmb_nearby_item_found:
    ldi XL, low(player_inventory)
    ldi XH, high(player_inventory)
    cpi r23, 128
    brlo _hmb_pickup_item
_hmb_pickup_gold:
    lds r21, player_gold
    lds r22, player_gold+1
    subi r23, 128
    add r21, r23
    adc r22, r1
    sts player_gold, r21
    sts player_gold+1, r22
    rjmp _hmb_remove_item
_hmb_pickup_item:
    ldi r22, PLAYER_INVENTORY_SIZE
_hmb_inventory_iter:
    ld r21, X+
    tst r21
    breq _hmb_empty_inventory_slot_found
_hmb_inventory_next:
    dec r22
    brne _hmb_inventory_iter
    rjmp _hmb_npc_interactions
_hmb_empty_inventory_slot_found:
    st -X, r23   ; fill the empty slot
_hmb_remove_item:
    std Z+SECTOR_ITEM_IDX_OFFSET, r1
    ldd r20, Z+SECTOR_ITEM_PREPLACED_IDX_OFFSET
    tst r20
    breq _hmb_npc_interactions
    mov r21, r20    ; if a preplaced item, mark as unavailable
    lsr r20
    lsr r20
    lsr r20
    ldi XL, low(preplaced_item_presence)
    ldi XH, high(preplaced_item_presence)
    add XL, r20
    adc XH, r1
    ld r20, X
    ldi r22, 1
    mpow2 r22, r21
    com r22
    and r20, r22
    st X, r20
    rjmp _hmb_end
_hmb_npc_interactions:
    ldi YL, low(sector_npcs)
    ldi YH, high(sector_npcs)
    ldi r22, SECTOR_NPC_COUNT
_hmb_npc_iter:
    ldd r23, Y+NPC_IDX_OFFSET
    dec r23
    brmi _hmb_npc_next
    ldd r20, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H
    ldd r21, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H
    subi r20, -CHARACTER_SPRITE_WIDTH/2
    subi r21, -CHARACTER_SPRITE_HEIGHT/2
    sub r20, r18
    sbrc r20, 7
    neg r20
    sub r21, r19
    sbrc r21, 7
    neg r21
    add r20, r21
    cpi r20, 3*(TILE_WIDTH+TILE_HEIGHT)/4
    brsh _hmb_npc_next
    ldi ZL, low(2*npc_table)
    ldi ZH, high(2*npc_table)
    ldi r20, NPC_TABLE_ENTRY_MEMSIZE
    mul r20, r23
    add ZL, r0
    adc ZH, r1
    clr r1
    lpm r20, Z
    cpi r20, NPC_SHOPKEEPER
    breq _hmb_nearby_shopkeeper
    cpi r20, NPC_TALKER
    breq _hmb_nearby_talker
_hmb_npc_next:
    adiw YL, NPC_MEMSIZE
    dec r22
    brne _hmb_npc_iter
    rjmp _hmb_end
_hmb_nearby_shopkeeper:
    adiw ZL, NPC_TABLE_SHOP_IDX_OFFSET
    lpm r25, Z
    call load_shop
    rjmp _hmb_end
_hmb_nearby_talker:
    adiw ZL, NPC_TABLE_TALKER_CONV1_OFFSET
    ldi r20, NPC_TABLE_TALKER_CONV_COUNT
_hmb_conversation_iter:
    lpm r20, Z+
    lpm r24, Z+
    lpm r25, Z+
    dec r20
    brmi _hmb_available_conversation
    mov r22, r20
    mov r21, r20
    lsr r22
    lsr r22
    lsr r22
    ldi XL, low(conversation_over)
    ldi XH, high(conversation_over)
    add XL, r22
    adc XH, r1
    ld r23, X
    mov r18, r23
    nbit r18, r21
    breq _hmb_conversation_next
    ldi r22, 1
    mpow2 r22, r20
    com r22
    and r23, r22
    st X, r23
_hmb_available_conversation:
    subi r24, low(-2*conversation_table)
    sbci r25, high(-2*conversation_table)
    call load_conversation
    rjmp _hmb_end
_hmb_conversation_next:
    dec r20
    brne _hmb_conversation_iter
_hmb_end:
    ret

; Begin to dash in the facing direction.
;
; Register Usage
;   r20         calculations
player_dash:
    lds r20, player_dash_cooldown
    tst r20
    brne _pd_end
    ldi r20, ACTION_DASH
    sts player_action, r20
    sts player_frame, r1
    call calculate_dash_cooldown ; TODO: inline?
    sts player_dash_cooldown, r25
    lds r20, player_direction
    sts player_dash_direction, r20
_pd_end:
    ret

; Begin an attack.
;   cooldown = 2*weapon_cooldown + (ATTACK_FRAME_DURATION_MASK+1)*ITEM_ANIM_ATTACK_FRAMES
;
; Register Usage
;   r20-r25         calculations
;   Z (r30:r31)     flash pointer
player_attack:
    lds r20, player_attack_cooldown
    tst r20
    brne _pa_end
    lds r20, player_weapon
    dec r20
    brmi _pa_end
    ldi ZL, byte3(2*item_table)
    out RAMPZ, ZL
    ldi ZL, low(2*item_table+ITEM_FLAGS_OFFSET)
    ldi ZH, high(2*item_table+ITEM_FLAGS_OFFSET)
    ldi r21, ITEM_MEMSIZE
    mul r20, r21
    add ZL, r0
    adc ZH, r1
    clr r1
    elpm r20, Z
_pa_test_high_level_intellect:
    mov r21, r20
    andi r21, 0x3
    cpi r21, ITEM_RANGED
    brne _pa_attack
    sbrs r20, 2
    rjmp _pa_attack
    lds r21, player_augmented_stats+STATS_INTELLECT_OFFSET
    cpi r21, ITEM_HIGH_LEVEL_INTELLECT
    brlo _pa_end
_pa_attack:
    mov r21, r20
    lsl r21
    andi r21, 0x70
    subi r21, -((ATTACK_FRAME_DURATION_MASK+1)*ITEM_ANIM_ATTACK_FRAMES)
    sts player_attack_cooldown, r21
    ldi r21, ACTION_ATTACK
    sts player_action, r21
    sts player_frame, r1
    mov r21, r20
    andi r21, 0x3
_pa_end:
    ret

; Update the active effects, such as spells or features of the sector. Active
; effects should have the following layout
;
; Active Effect Layout:
;   data [direction:2][effect:3][frame:3]
;   data2 [unused:2][speed:2][delay:2][role:2]
;   x coordinate
;   y coordinate
;
; Register Usage
;   r20-r25         calculations
;   Z (r30:r31)     memory pointer
update_active_effects:
    ldi ZL, low(active_effects)
    ldi ZH, high(active_effects)
    ldi r20, ACTIVE_EFFECT_COUNT
_uae_active_effect_iter:
    ldd r21, Z+ACTIVE_EFFECT_DATA_OFFSET
    mov r22, r21
    andi r22, 0x38  ; effect
    breq _uae_active_effect_next
    ldd r23, Z+ACTIVE_EFFECT_DATA2_OFFSET
    mov r24, r23
    andi r24, 0x0c ; delay
    breq _uae_update_effect_position
_uae_update_effect_delay:
    lds r25, clock
    andi r25, EFFECT_DELAY_FRAME_DURATION_MASK
    brne _uae_active_effect_next
    subi r24, 1<<2
    andi r23, 0xf3
    or r23, r24
    std Z+ACTIVE_EFFECT_DATA2_OFFSET, r23
    rjmp _uae_active_effect_next
_uae_update_effect_position:
    swap r23
    andi r23, 0x03  ; speed
    breq _uae_update_effect_frame
    lds r24, clock
    andi r24, 0x01
    sbrc r23, 1
    inc r24
    mov r23, r21
    andi r23, 0xc0  ; direction
    sbrc r23, 7
    neg r24
    mov r25, r24
    sbrc r23, 6
    clr r25
    sbrs r23, 6
    clr r24
    ldd r23, Z+ACTIVE_EFFECT_X_OFFSET
    add r23, r24
    std Z+ACTIVE_EFFECT_X_OFFSET, r23
    ldd r23, Z+ACTIVE_EFFECT_Y_OFFSET
    add r23, r25
    std Z+ACTIVE_EFFECT_Y_OFFSET, r23
_uae_update_effect_frame:
    mov r23, r21
    andi r21, 0x07  ; frame
    andi r23, 0xc0  ; direction
_uae_attack_fire:
    cpi r22, EFFECT_ATTACK_FIRE<<3
    brne _uae_active_effect_next
    lds r24, clock
    andi r24, EFFECT_ATTACK_FIRE_FRAME_DURATION_MASK
    brne _uae_active_effect_next
    inc r21
    cpi r21, EFFECT_ATTACK_FIRE_DURATION
    brlo _uau_save_effect
    clr r22
_uau_save_effect:
    or r21, r22
    or r21, r23
    std Z+ACTIVE_EFFECT_DATA_OFFSET, r21
_uae_active_effect_next:
    adiw ZL, ACTIVE_EFFECT_MEMSIZE
    dec r20
    brne _uae_active_effect_iter
    ret

; Add an effect to the list. If there are no empty slots, replace a random one.
;
; Register Usage
;   r20-r21         calculations
;   r22             effect data 1 (param)
;   r23             effect data 2 (param)
;   r24, r25        position (param)
;   Z (r30:r31)     memory pointer
add_active_effect:
    ldi ZL, low(active_effects)
    ldi ZH, high(active_effects)
    ldi r20, ACTIVE_EFFECT_COUNT
_aae_iter:
    ldd r21, Z+ACTIVE_EFFECT_DATA_OFFSET
    andi r21, 0x38
    brne _aae_next
    std Z+ACTIVE_EFFECT_DATA_OFFSET, r22
    std Z+ACTIVE_EFFECT_DATA2_OFFSET, r23
    std Z+ACTIVE_EFFECT_X_OFFSET, r24
    std Z+ACTIVE_EFFECT_Y_OFFSET, r25
    ret
_aae_next:
    adiw ZL, ACTIVE_EFFECT_MEMSIZE
    dec r20
    brne _aae_iter
    lds r21, clock
    ; restrict to [0, ACTIVE_EFFECT_COUNT-1]
    andi r21, (ACTIVE_EFFECT_COUNT|(ACTIVE_EFFECT_COUNT>>1)|(ACTIVE_EFFECT_COUNT>>2)|(ACTIVE_EFFECT_COUNT>>3)) ; 4 bit next power of 2 minus 1
    cpi r21, ACTIVE_EFFECT_COUNT
    brlo _aae_replace
    subi r21, ACTIVE_EFFECT_COUNT
_aae_replace:
    ldi ZL, low(active_effects)
    ldi ZH, high(active_effects)
    ldi r20, ACTIVE_EFFECT_MEMSIZE
    mul r21, r20
    add ZL, r0
    adc ZH, r1
    clr r1
    std Z+ACTIVE_EFFECT_DATA_OFFSET, r22
    std Z+ACTIVE_EFFECT_DATA2_OFFSET, r23
    std Z+ACTIVE_EFFECT_X_OFFSET, r24
    std Z+ACTIVE_EFFECT_Y_OFFSET, r25
    ret

; Update the player's animation and general state.
;
; Register Usage
;   r20-r26         calculations
update_player:
    ser r26
    ldi YL, low(player_position_data)
    ldi YH, high(player_position_data)
    call move_character
    rcall check_sector_bounds
_up_dash:
    lds r20, player_action
    cpi r20, ACTION_DASH
    brne _up_ranged_attack
    lds r20, player_dash_direction
_up_dash_up:
    cpi r20, DIRECTION_UP
    brne _up_dash_down
    ldi r20, -128
    sts player_velocity_y, r20
_up_dash_down:
    cpi r20, DIRECTION_DOWN
    brne _up_dash_left
    ldi r20, 127
    sts player_velocity_y, r20
_up_dash_left:
    cpi r20, DIRECTION_LEFT
    brne _up_dash_right
    ldi r20, -128
    sts player_velocity_x, r20
_up_dash_right:
    cpi r20, DIRECTION_RIGHT
    brne _up_dash_move_again1
    ldi r20, 127
    sts player_velocity_x, r20
_up_dash_move_again1:
    lds r20, player_frame
    cpi r20, DASH_DURATION/4
    brsh _up_dash_move_again2
    call move_character
_up_dash_move_again2:
    call move_character
_up_ranged_attack:
    lds r20, player_action
    cpi r20, ACTION_ATTACK
    brne _up_animation
    lds r20, clock
    andi r20, ATTACK_FRAME_DURATION_MASK
    brne _up_animation
    lds r20, player_frame
    cpi r20, RANGED_LAUNCH_FRAME
    brne _up_animation
    lds r20, player_weapon
    dec r20
    brmi _up_animation ; unlikely but technically possible
    ldi ZL, byte3(2*item_table)
    out RAMPZ, ZL
    ldi ZL, low(2*item_table+ITEM_FLAGS_OFFSET)
    ldi ZH, high(2*item_table+ITEM_FLAGS_OFFSET)
    ldi r21, ITEM_MEMSIZE
    mul r20, r21
    add ZL, r0
    adc ZH, r1
    clr r1
    elpm r20, Z
_up_check_ranged:
    mov r21, r20
    andi r21, 0x03
    cpi r21, ITEM_RANGED
    brne _up_animation
    lds r22, player_direction
    lds r24, player_position_x
    lds r25, player_position_y
_up_facing_up:
    cpi r22, DIRECTION_UP
    brne _up_facing_down
    subi r25, EFFECT_SPRITE_HEIGHT
_up_facing_down:
    cpi r22, DIRECTION_DOWN
    brne _up_facing_left
    subi r25, -EFFECT_SPRITE_HEIGHT
_up_facing_left:
    cpi r22, DIRECTION_LEFT
    brne _up_facing_right
    subi r24, EFFECT_SPRITE_WIDTH
_up_facing_right:
    cpi r22, DIRECTION_RIGHT
    brne _up_add_effect
    subi r24, -EFFECT_SPRITE_WIDTH
_up_add_effect:
    adiw ZL, ITEM_EXTRA_OFFSET-ITEM_FLAGS_OFFSET
    elpm r23, Z
    andi r23, 0x07
    lsl r23
    swap r22
    or r22, r23
    lsl r22
    lsl r22
    andi r20, 0xc0
    lsr r20
    lsr r20
    ldi r23, EFFECT_ROLE_DAMAGE_NPCS
    or r23, r20
    rcall add_active_effect
_up_animation:
    lds r21, player_effect
    lds r22, player_action
    lds r23, player_frame
    lds r24, player_velocity_x
    lds r25, player_velocity_y
    call update_character_animation
    sts player_effect, r21
    sts player_action, r22
    sts player_frame, r23
    sts player_velocity_x, r24
    sts player_velocity_y, r25
    call update_player_health
_up_attack_cooldown:
    lds r20, player_attack_cooldown
    subi r20, 1
    brlo _up_dash_cooldown
    sts player_attack_cooldown, r20
_up_dash_cooldown:
    lds r20, player_dash_cooldown
    subi r20, 1
    brlo _up_end
    sts player_dash_cooldown, r20
_up_end:
    ret

; If the player is outside the sector bounds, load the appropriate adjacent
; sector.
;
; Register Usage
;   r24, r25        player position, calculations
;   Z (r30:r31)     pointer to the adjacent sector
check_sector_bounds:
    lds r24, player_position_x
    lds r25, player_position_y
    lds ZL, current_sector
    lds ZH, current_sector+1
    subi ZL, low(-SECTOR_AJD_OFFSET)
    sbci ZH, high(-SECTOR_AJD_OFFSET)
_csb_check_sector_left:
    cpi r24, 255
    brlo _csb_check_sector_right
    adiw ZL, 3
    ldi r24, SECTOR_WIDTH*TILE_WIDTH-CHARACTER_SPRITE_WIDTH
    sts player_position_x, r24
    subi r24, DISPLAY_WIDTH
    sts camera_position_x, r24
    rjmp _csb_switch_sector
_csb_check_sector_right:
    cpi r24, SECTOR_WIDTH*TILE_WIDTH-CHARACTER_SPRITE_WIDTH+1
    brlo _csb_check_sector_top
    adiw ZL, 1
    sts player_position_x, r1
    sts camera_position_x, r1
    rjmp _csb_switch_sector
_csb_check_sector_top:
    cpi r25, 255
    brlo _csb_check_sector_bottom
    adiw ZL, 2
    ldi r24, SECTOR_HEIGHT*TILE_HEIGHT-CHARACTER_SPRITE_HEIGHT
    sts player_position_y, r24
    subi r24, DISPLAY_HEIGHT-FOOTER_HEIGHT
    sts camera_position_y, r24
    rjmp _csb_switch_sector
_csb_check_sector_bottom:
    cpi r25, SECTOR_HEIGHT*TILE_HEIGHT-CHARACTER_SPRITE_HEIGHT+1
    brlo _csb_end
    sts player_position_y, r1
    sts camera_position_y, r1
_csb_switch_sector:
    call load_upgrade_if_necessary
    lpm r24, Z
    ldi r25, SECTOR_MEMSIZE/2
    mul r24, r25
    lsl r0
    rol r1
    ldi ZL, byte3(2*sector_table)
    out RAMPZ, ZL
    ldi ZL, low(2*sector_table)
    ldi ZH, high(2*sector_table)
    add ZL, r0
    adc ZH, r1
    clr r1
    rcall load_sector
_csb_end:
    ret

; Change sectors. Every sector has its own set of items and NPCs, these must be
; loaded as necessary.
;
; Register Usage
;   r18-r24         calculations
;   X (r26:r27)     data pointer
;   Y (r28:r29)     second data pointer
;   Z (r30:r31)     pointer to the new sector (param)
load_sector:
    push YL
    push YH
    sts current_sector, ZL
    sts current_sector+1, ZH
_ls_clear_loose_items:
    ldi YL, low(sector_loose_items)
    ldi YH, high(sector_loose_items)
    ldi r18, SECTOR_DYNAMIC_ITEM_COUNT
_ls_clear_loose_items_iter:
    st Y+, r1
    st Y+, r1
    st Y+, r1
    st Y+, r1
    dec r18
    brne _ls_clear_loose_items_iter
_ls_load_preplaced_items:
    subi ZL, low(-SECTOR_ITEMS_OFFSET)
    sbci ZH, high(-SECTOR_ITEMS_OFFSET)
    ldi YL, low(sector_loose_items)
    ldi YH, high(sector_loose_items)
    ldi r18, SECTOR_PREPLACED_ITEM_COUNT
_ls_load_preplaced_items_iter:
    elpm r19, Z+
    elpm r20, Z+
    elpm r21, Z+
    elpm r22, Z+
    ldi XL, low(preplaced_item_presence)
    ldi XH, high(preplaced_item_presence)
    mov r23, r20
    mov r24, r20
    lsr r23
    lsr r23
    lsr r23
    add XL, r23
    adc XH, r1
    ld r23, X
    nbit r23, r24 ; check that the item is still available
    breq _ls_load_preplaced_items_next
    st Y, r19
    std Y+1, r20
    std Y+2, r21
    std Y+3, r22
_ls_load_preplaced_items_next:
    adiw YL, SECTOR_PREPLACED_ITEM_MEMSIZE
    dec r18
    brne _ls_load_preplaced_items_iter
_ls_clear_npcs:
    ldi YL, low(sector_npcs)
    ldi YH, high(sector_npcs)
    ldi r18, SECTOR_DYNAMIC_NPC_COUNT
_ls_clear_npcs_iter:
    st Y, r1
    adiw YL, NPC_MEMSIZE
    dec r18
    brne _ls_clear_npcs_iter
_ls_load_npcs:
    ldi YL, low(sector_npcs)
    ldi YH, high(sector_npcs)
    lds XL, current_sector
    lds XH, current_sector+1
    subi XL, low(-SECTOR_NPC_OFFSET)
    sbci XH, high(-SECTOR_NPC_OFFSET)
    ldi ZL, byte3(2*sector_table)
    out RAMPZ, ZL
    ldi r18, SECTOR_NPC_COUNT
_ls_load_npcs_iter:
    movw ZL, XL
    elpm r19, Z+
    mov r20, r19
    movw XL, ZL
    dec r20
    brmi _ls_run_handler
    mov r21, r20
    mov r22, r20
    lsr r22
    lsr r22
    lsr r22
    ldi ZL, low(npc_presence)
    ldi ZH, high(npc_presence)
    add ZL, r22
    adc ZH, r1
    ld r23, Z
    nbit r23, r21
    breq _ls_load_npcs_next
    std Y+NPC_IDX_OFFSET, r19
    ldi ZL, low(2*npc_table+NPC_TABLE_DIRECTION_OFFSET)
    ldi ZH, high(2*npc_table+NPC_TABLE_DIRECTION_OFFSET)
    ldi r21, NPC_TABLE_ENTRY_MEMSIZE
    mul r20, r21
    add ZL, r0
    adc ZH, r1
    clr r1
    lpm r19, Z+    ; direction
    std Y+NPC_ANIM_OFFSET, r19
    lpm r19, Z+    ; x pos
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_L, r1
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H, r19
    lpm r19, Z+    ; y pos
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_L, r1
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H, r19
    lpm r19, Z+    ; initial x velocity
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DX, r19
    lpm r19, Z+    ; initial y velocity
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DY, r19
    adiw ZL, 1
    lpm r19, Z      ; initial health
    std Y+NPC_HEALTH_OFFSET, r19
    std Y+NPC_EFFECT_OFFSET, r1
_ls_load_npcs_next:
    adiw YL, NPC_MEMSIZE
    dec r18
    brne _ls_load_npcs_iter
_ls_run_handler:
    ldi ZL, byte3(2*sector_table)
    out RAMPZ, ZL
    lds ZL, current_sector
    lds ZH, current_sector+1
    subi ZL, low(-(SECTOR_HANDLERS_OFFSET+2))
    sbci ZH, high(-(SECTOR_HANDLERS_OFFSET+2))
    elpm r24, Z+
    tst r24
    breq _ls_end
    elpm r25, Z+
    tst r25
    breq _ls_end
    movw ZL, r24
    ldi r25, EVENT_ENTER
    icall
_ls_end:
    pop YH
    pop YL
    ret

; Move the "camera" so that the player is within the camera view plus some margin.
; The camera is constrained to the sector bounds, however.
;
; Register Usage
;   r18, r19        player position
;   r20, r21        camera position
;   r22, r23        player-camera position
move_camera:
    lds r22, player_position_x
    lds r23, camera_position_x
    mov r24, r22
    sub r24, r23
_mc_pad_left:
    cpi r24, CAMERA_HORIZONTAL_PADDING
    brsh _mc_pad_right
    mov r23, r22
    subi r23, CAMERA_HORIZONTAL_PADDING
    brsh _mc_save_horizontal
    clr r23
    rjmp _mc_save_horizontal
_mc_pad_right:
    cpi r24, DISPLAY_WIDTH-CAMERA_HORIZONTAL_PADDING-CHARACTER_SPRITE_WIDTH
    brlo _mc_save_horizontal
    mov r23, r22
    subi r23, DISPLAY_WIDTH-CAMERA_HORIZONTAL_PADDING-CHARACTER_SPRITE_WIDTH
    cpi r23, TILE_WIDTH*SECTOR_WIDTH-DISPLAY_WIDTH
    brlo _mc_save_horizontal
    ldi r23, TILE_WIDTH*SECTOR_WIDTH-DISPLAY_WIDTH
_mc_save_horizontal:
    sts camera_position_x, r23
_mc_pad_vertical:
    lds r22, player_position_y
    lds r23, camera_position_y
    mov r24, r22
    sub r24, r23
_mc_pad_top:
    cpi r24, CAMERA_VERTICAL_PADDING
    brsh _mc_pad_bottom
    mov r23, r22
    subi r23, CAMERA_VERTICAL_PADDING
    brsh _mc_save_vertical
    clr r23
    rjmp _mc_save_vertical
_mc_pad_bottom:
    cpi r24, (DISPLAY_HEIGHT-FOOTER_HEIGHT)-CAMERA_VERTICAL_PADDING-CHARACTER_SPRITE_HEIGHT
    brlo _mc_save_vertical
    mov r23, r22
    subi r23, (DISPLAY_HEIGHT-FOOTER_HEIGHT)-CAMERA_VERTICAL_PADDING-CHARACTER_SPRITE_HEIGHT
    cpi r23, TILE_HEIGHT*SECTOR_HEIGHT-(DISPLAY_HEIGHT-FOOTER_HEIGHT)
    brlo _mc_save_vertical
    ldi r23, TILE_HEIGHT*SECTOR_HEIGHT-(DISPLAY_HEIGHT-FOOTER_HEIGHT)
_mc_save_vertical:
    sts camera_position_y, r23
    ret
