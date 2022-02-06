explore_update_game:
    rcall render_game
    rcall handle_controls
    rcall update_player
    call update_effects_progress
    rcall move_camera

    ldi ZL, byte3(2*sector_table)
    out RAMPZ, ZL
    lds ZL, current_sector
    lds ZH, current_sector+1
    subi ZL, low(-SECTOR_HANDLERS_OFFSET)
    sbci ZH, high(-SECTOR_HANDLERS_OFFSET)
    elpm r24, Z+
    tst r24
    breq _eup_end
    elpm r25, Z+
    tst r25
    breq _eup_end
    movw ZL, r24
    icall
_eup_end:
    jmp _loop_reenter

.equ EXPLORE_UI_EFFECTS_MARGIN = DISPLAY_WIDTH*(DISPLAY_HEIGHT-FOOTER_HEIGHT+1)-8
.equ EXPLORE_UI_EFFECTS_SEPARATION = 7
.equ EXPLORE_UI_XP_MARGIN = DISPLAY_WIDTH*(DISPLAY_HEIGHT-FOOTER_HEIGHT+1)+14
.equ EXPLORE_UI_XP_ICON_MARGIN = DISPLAY_WIDTH*(DISPLAY_HEIGHT-FOOTER_HEIGHT+1)+23
.equ EXPLORE_UI_GOLD_MARGIN = DISPLAY_WIDTH*(DISPLAY_HEIGHT-FOOTER_HEIGHT+1)+45
.equ EXPLORE_UI_GOLD_ICON_MARGIN = DISPLAY_WIDTH*(DISPLAY_HEIGHT-FOOTER_HEIGHT+1)+50
.equ EXPLORE_UI_HEALTH_MARGIN = DISPLAY_WIDTH*(DISPLAY_HEIGHT-FOOTER_HEIGHT+1)+77
.equ EXPLORE_UI_HEALTH_ICON_MARGIN = DISPLAY_WIDTH*(DISPLAY_HEIGHT-FOOTER_HEIGHT+1)+82

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
    clt
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
    clt
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
    lds r21, player_max_health
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
    rcall handle_attack_buttons
_hc_button3:
    sbrc r19, CONTROLS_SPECIAL3
    rcall handle_attack_buttons
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

; Begin an attack. Detects whether button 2 or 3 was pressed, and uses the correct
; attack params.
;
; Register Usage
;   r20-r21     calculations
handle_attack_buttons:
    lds r20, player_cooldown
    tst r20
    brne _hab_end
    lds r21, CONTROLLER_VALUES
    sbrc r21, CONTROLS_SPECIAL3
    rjmp _hab_attack2
_hab_attack1:
    ldi r20, ACTION_ATTACK1
    sts player_action, r20
    sts player_frame, r1
    ldi r20, ATTACK1_COOLDOWN
    sts player_cooldown, r20
    rjmp _hab_reduce_speed
_hab_attack2:
    ldi r20, ACTION_ATTACK2
    sts player_action, r20
    sts player_frame, r1
    ldi r20, ATTACK2_COOLDOWN
    sts player_cooldown, r20
_hab_reduce_speed:
    lds r20, player_velocity_x
    lds r21, player_velocity_y
    asr r20
    asr r21
    sts player_velocity_x, r20
    sts player_velocity_y, r21
_hab_end:
    ret

; Update the player's animation and general state.
;
; Register Usage
;   r22-r25         calculations
update_player:
    ser r26
    ldi YL, low(player_position_data)
    ldi YH, high(player_position_data)
    call move_character
    rcall check_sector_bounds
    lds r22, player_action
    lds r23, player_frame
    lds r24, player_velocity_x
    lds r25, player_velocity_y
    call update_character_animation
    sts player_action, r22
    sts player_frame, r23
    sts player_velocity_x, r24
    sts player_velocity_y, r25
    lds r22, player_cooldown
    dec r22
    sbrc r22, 7
    clr r22
    sts player_cooldown, r22
_up_npc_player_collision:
    ldi ZL, low(sector_npcs)
    ldi ZH, high(sector_npcs)
    ldi YL, low(player_position_data)
    ldi YH, high(player_position_data)
    ldi r26, SECTOR_DYNAMIC_NPC_COUNT
    call calculate_rebound_acc
    mov r23, r25
_up_npc_iter:
    ldd r20, Z+NPC_IDX_OFFSET
    tst r20
    breq _up_npc_next
    ldd r24, Z+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H
    ldd r25, Z+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H
    call collide_character
_up_npc_next:
    adiw ZL, NPC_MEMSIZE
    dec r26
    brne _up_npc_iter
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
    std Y+NPC_COOLDOWN_OFFSET, r1
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
