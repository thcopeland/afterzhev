shop_update_game:
    rcall shop_render_game
    rcall shop_handle_controls
    jmp _loop_reenter

; Populate shop_inventory with the items for the given shop and switch the game
; mode. If the shop was the most recent one open, the inventory is not cleared.
;
; Register Usage
;   r20-r21         calculations
;   r25             shop NPC idx (param)
;   X (r26:r27)     memory pointer
;   Z (r30:r31)     flash pointer
load_shop:
    lds r20, current_shop_index
    cp r20, r25
    breq _ls_change_mode
    sts current_shop_index, r25
    sts shop_selection, r1
    ldi XL, low(shop_inventory)
    ldi XH, high(shop_inventory)
    ldi r20, SHOP_INVENTORY_SIZE
_ls_clear_inventory_iter:
    st X+, r1
_ls_clear_inventory_next:
    dec r20
    brne _ls_clear_inventory_iter
    ldi ZL, low(2*shop_table+SHOP_ITEMS_OFFSET)
    ldi ZH, high(2*shop_table+SHOP_ITEMS_OFFSET)
    ldi r20, SHOP_MEMSIZE
    mul r25, r20
    add ZL, r0
    adc ZH, r1
    clr r1
    ldi XL, low(shop_inventory)
    ldi XH, high(shop_inventory)
    ldi r20, SHOP_INITIAL_INVENTORY_SIZE
_ls_load_inventory_iter:
    lpm r21, Z+
    st X+, r21
_ls_load_inventory_next:
    dec r20
    brne _ls_load_inventory_iter
_ls_change_mode:
    ldi r20, MODE_SHOPPING
    sts game_mode, r20
    sts player_velocity_x, r1
    sts player_velocity_y, r1
    ret

; Handle all player input. The directional keys control selection, button 2 is
; buy, button 3 is sell, and button 4 is exit. Button 1 does nothing.
;
; Register Usage
;   r18-r19         controller values
;   r20-r22         calculations
shop_handle_controls:
    lds r18, prev_controller_values
    lds r19, controller_values
    com r18
    and r18, r19
    breq _shc_handle_buttons
    sts mode_clock, r1
    rjmp _shc_down
_shc_handle_buttons:
    lds r21, mode_clock
    inc r21
    sts mode_clock, r21
    andi r21, 15
    brne _shc_end
_shc_down:
    sbrs r19, CONTROLS_DOWN
    rjmp _shc_right
    lds r22, shop_selection
    cpi r22, (SHOP_INVENTORY_SIZE+PLAYER_INVENTORY_SIZE)/2
    brpl _shc_right
    subi r22, -(SHOP_INVENTORY_SIZE+PLAYER_INVENTORY_SIZE)/2
    sts shop_selection, r22
_shc_right:
    sbrs r19, CONTROLS_RIGHT
    rjmp _shc_up
    lds r22, shop_selection
    inc r22
    cpi r22, SHOP_INVENTORY_SIZE+PLAYER_INVENTORY_SIZE
    brsh _shc_up
    sts shop_selection, r22
_shc_up:
    sbrs r19, CONTROLS_UP
    rjmp _shc_left
    lds r22, shop_selection
    subi r22, (SHOP_INVENTORY_SIZE+PLAYER_INVENTORY_SIZE)/2
    brmi _shc_left
    sts shop_selection, r22
_shc_left:
    sbrs r19, CONTROLS_LEFT
    rjmp _shc_button1
    lds r22, shop_selection
    dec r22
    brmi _shc_end
    sts shop_selection, r22
_shc_button1:
_shc_button2:
    sbrc r19, CONTROLS_SPECIAL2
    rcall shop_buy_selected
_shc_button3:
    sbrc r19, CONTROLS_SPECIAL3
    rcall shop_sell_selected
_shc_button4:
    sbrs r18, CONTROLS_SPECIAL4
    rjmp _shc_end
    ldi r22, MODE_EXPLORE
    sts game_mode, r22
_shc_end:
    ret

; Remove an item from the shop's inventory and place it in the player's. The
; purchase will fail if the player has insufficient funds or no empty slots.
;
; Register Usage
;   r20-r21,r24-r25 calculations
;   r22-r23         player's gold
;   X (r26:r27)     shop inventory pointer
;   Y (r28:r29)     player inventory pointer
shop_buy_selected:
    rcall shop_determine_selection
    tst r25
    brne _sbs_end
    ld r25, X
    dec r25
    brmi _sbs_end
    rcall calculate_buy_price
    lds r22, player_gold
    lds r23, player_gold+1
    sub r22, r24
    sbc r23, r25
    brmi _sbs_end
    ldi YL, low(player_inventory)
    ldi YH, high(player_inventory)
    ldi r20, PLAYER_INVENTORY_SIZE
_sbs_player_inventory_iter:
    ld r21, Y+
    tst r21
    breq _sbs_player_inventory_empty_slot_found
_sbs_player_inventory_next:
    dec r20
    brne _sbs_player_inventory_iter
    rjmp _sbs_end
_sbs_player_inventory_empty_slot_found:
    sts player_gold, r22
    sts player_gold+1, r23
    ld r20, X
    st X, r1
    st -Y, r20
_sbs_end:
    ret

; Move the selected item from the player's inventory to the shop's, if there
; is an empty slot. If not, the last item is replaced.
;
; Register Usage
;   r20-r21,r24-r25 calculations
;   r22-r23         player's gold
;   X (r26:r27)     player inventory pointer
;   Y (r28:r29)     shop inventory pointer
shop_sell_selected:
    rcall shop_determine_selection
    tst r25
    breq _sss_end
    ld r25, X
    dec r25
    brmi _sss_end
    ldi YL, low(shop_inventory)
    ldi YH, high(shop_inventory)
    ldi r20, SHOP_INVENTORY_SIZE
_sss_shop_inventory_iter:
    ld r21, Y+
    tst r21
    breq _sss_shop_inventory_empty_slot_found
_sss_shop_inventory_next:
    dec r20
    brne _sss_shop_inventory_iter
_sss_shop_inventory_empty_slot_found:
    rcall calculate_sell_price
    lds r22, player_gold
    lds r23, player_gold+1
    add r22, r24
    adc r23, r25
    sts player_gold, r22
    sts player_gold+1, r23
    ld r20, X
    st X, r1
    st -Y, r20
_sss_end:
    ret

.equ SHOP_UI_HEADER_COLOR = INVENTORY_UI_HEADER_COLOR
.equ SHOP_UI_HEADER_HEIGHT = INVENTORY_UI_HEADER_HEIGHT
.equ SHOP_UI_SUBHEADER_MARGIN = INVENTORY_UI_SUBHEADER_MARGIN
.equ SHOP_UI_SUBHEADER_HEIGHT = INVENTORY_UI_SUBHEADER_HEIGHT
.equ SHOP_UI_SHOP_NAME_MARGIN = 2*DISPLAY_WIDTH+2
.equ SHOP_UI_PLAYER_CLASS_MARGIN = 2*DISPLAY_WIDTH+85
.equ SHOP_UI_BODY_COLOR = INVENTORY_UI_BODY_COLOR
.equ SHOP_UI_SHOP_INVENTORY_ROW1_MARGIN = 11*DISPLAY_WIDTH+4
.equ SHOP_UI_SHOP_INVENTORY_ROW2_MARGIN = 20*DISPLAY_WIDTH+4
.equ SHOP_UI_PLAYER_INVENTORY_ROW1_MARGIN = 11*DISPLAY_WIDTH+65
.equ SHOP_UI_PLAYER_INVENTORY_ROW2_MARGIN = 20*DISPLAY_WIDTH+65
.equ SHOP_UI_ITEM_NAME_MARGIN = INVENTORY_UI_ITEM_NAME_MARGIN
.equ SHOP_UI_GOLD_MARGIN = 31*DISPLAY_WIDTH+75
.equ SHOP_UI_GOLD_ICON_MARGIN = 30*DISPLAY_WIDTH+80
.equ SHOP_UI_HEALTH_MARGIN = 31*DISPLAY_WIDTH+105
.equ SHOP_UI_HEALTH_ICON_MARGIN = 30*DISPLAY_WIDTH+110
.equ SHOP_UI_PRICE_LABEL_MARGIN = 47*DISPLAY_WIDTH+100
.equ SHOP_UI_PRICE_MARGIN = 58*DISPLAY_WIDTH+111

; Render the shop and player inventories, as well as the selected item information.
;
; Register Usage
;   r16-r17     saving across calls
;   r18-r25     calculations
;   X, Y, Z     framebuffer and data pointers
shop_render_game:
_srg_render_background:
    ldi XL, low(framebuffer)
    ldi XH, high(framebuffer)
    ldi r22, SHOP_UI_HEADER_COLOR
    ldi r24, DISPLAY_WIDTH
    ldi r25, SHOP_UI_HEADER_HEIGHT
    call render_rect
    ldi XL, low(framebuffer+SHOP_UI_HEADER_HEIGHT*DISPLAY_WIDTH)
    ldi XH, high(framebuffer+SHOP_UI_HEADER_HEIGHT*DISPLAY_WIDTH)
    ldi r22, SHOP_UI_BODY_COLOR
    ldi r24, DISPLAY_WIDTH
    ldi r25, DISPLAY_HEIGHT-SHOP_UI_HEADER_HEIGHT
    call render_rect
_srg_render_header_text:
    ldi ZL, low(2*shop_table+SHOP_NAME_PTR_OFFSET)
    ldi ZH, high(2*shop_table+SHOP_NAME_PTR_OFFSET)
    ldi r20, SHOP_MEMSIZE
    lds r21, current_shop_index
    mul r20, r21
    add ZL, r0
    adc ZH, r1
    clr r1
    lpm r20, Z+
    lpm r21, Z+
    ldi ZL, byte3(2*shop_string_table)
    out RAMPZ, ZL
    ldi ZL, low(2*shop_string_table)
    ldi ZH, high(2*shop_string_table)
    add ZL, r20
    adc ZH, r21
    ldi YL, low(framebuffer+SHOP_UI_SHOP_NAME_MARGIN)
    ldi YH, high(framebuffer+SHOP_UI_SHOP_NAME_MARGIN)
    ldi r21, 29
    clr r23
    call puts
    ldi YL, low(framebuffer+SHOP_UI_PLAYER_CLASS_MARGIN)
    ldi YH, high(framebuffer+SHOP_UI_PLAYER_CLASS_MARGIN)
    ldi ZL, byte3(2*class_table+CLASS_NAME_OFFSET)
    out RAMPZ, ZL
    ldi ZL, low(2*class_table+CLASS_NAME_OFFSET)
    ldi ZH, high(2*class_table+CLASS_NAME_OFFSET)
    ldi r20, CLASS_MEMSIZE
    lds r21, player_class
    andi r21, 0xf
    mul r20, r21
    add ZL, r0
    adc ZH, r1
    clr r1
    ldi r21, 10
    call puts
_srg_shop_inventory:
    ldi XL, low(framebuffer+SHOP_UI_SHOP_INVENTORY_ROW1_MARGIN)
    ldi XH, high(framebuffer+SHOP_UI_SHOP_INVENTORY_ROW1_MARGIN)
    clr r20
_srg_shop_inventory_iter:
    ldi ZL, low(shop_inventory)
    ldi ZH, high(shop_inventory)
    add ZL, r20
    adc ZH, r1
    ld r25, Z
    movw YL, XL
    call render_item_with_underbar
    movw XL, YL
    adiw XL, INVENTORY_UI_COL_WIDTH
    inc r20
    cpi r20, SHOP_INVENTORY_SIZE/2
    brne _srg_shop_inventory_next
    ldi XL, low(framebuffer+SHOP_UI_SHOP_INVENTORY_ROW2_MARGIN)
    ldi XH, high(framebuffer+SHOP_UI_SHOP_INVENTORY_ROW2_MARGIN)
_srg_shop_inventory_next:
    cpi r20, SHOP_INVENTORY_SIZE
    brlo _srg_shop_inventory_iter
_srg_player_inventory:
    ldi XL, low(framebuffer+SHOP_UI_PLAYER_INVENTORY_ROW1_MARGIN)
    ldi XH, high(framebuffer+SHOP_UI_PLAYER_INVENTORY_ROW1_MARGIN)
    clr r20
_srg_player_inventory_iter:
    ldi ZL, low(player_inventory)
    ldi ZH, high(player_inventory)
    add ZL, r20
    adc ZH, r1
    ld r25, Z
    movw YL, XL
    call render_item_with_underbar
    movw XL, YL
    adiw XL, INVENTORY_UI_COL_WIDTH
    inc r20
    cpi r20, PLAYER_INVENTORY_SIZE/2
    brne _srg_player_inventory_next
    ldi XL, low(framebuffer+SHOP_UI_PLAYER_INVENTORY_ROW2_MARGIN)
    ldi XH, high(framebuffer+SHOP_UI_PLAYER_INVENTORY_ROW2_MARGIN)
_srg_player_inventory_next:
    cpi r20, PLAYER_INVENTORY_SIZE
    brlo _srg_player_inventory_iter
_srg_render_health:
    ldi XL, low(framebuffer+SHOP_UI_HEALTH_ICON_MARGIN)
    ldi XH, high(framebuffer+SHOP_UI_HEALTH_ICON_MARGIN)
    ldi r24, 7
    ldi r25, 7
    ldi ZL, byte3(2*ui_heart_icon)
    out RAMPZ, ZL
    ldi ZL, low(2*ui_heart_icon)
    ldi ZH, high(2*ui_heart_icon)
    call render_element
    ldi XL, low(framebuffer+SHOP_UI_HEALTH_MARGIN)
    ldi XH, high(framebuffer+SHOP_UI_HEALTH_MARGIN)
    call calculate_max_health
    mov r21, r25
    call putb
    ldi r22, '/'
    call putc
    subi XL, low(FONT_DISPLAY_WIDTH)
    sbci XH, high(FONT_DISPLAY_WIDTH)
    lds r21, player_health
    call putb
_srg_render_gold:
    ldi XL, low(framebuffer+SHOP_UI_GOLD_ICON_MARGIN)
    ldi XH, high(framebuffer+SHOP_UI_GOLD_ICON_MARGIN)
    ldi r24, 4
    ldi r25, 7
    ldi ZL, byte3(2*ui_coin_icon)
    out RAMPZ, ZL
    ldi ZL, low(2*ui_coin_icon)
    ldi ZH, high(2*ui_coin_icon)
    call render_element
    ldi XL, low(framebuffer+SHOP_UI_GOLD_MARGIN)
    ldi XH, high(framebuffer+SHOP_UI_GOLD_MARGIN)
    lds r18, player_gold
    lds r19, player_gold+1
    call putw
_srg_selection_cursor:
    lds r20, shop_selection
    ldi XL, low(framebuffer+SHOP_UI_SHOP_INVENTORY_ROW1_MARGIN-DISPLAY_WIDTH-1)
    ldi XH, high(framebuffer+SHOP_UI_SHOP_INVENTORY_ROW1_MARGIN-DISPLAY_WIDTH-1)
    cpi r20, (PLAYER_INVENTORY_SIZE+SHOP_INVENTORY_SIZE)/2
    brlo _srg_cursor_horizontal_offset
    subi XL, low(SHOP_UI_SHOP_INVENTORY_ROW1_MARGIN-SHOP_UI_SHOP_INVENTORY_ROW2_MARGIN)
    sbci XH, high(SHOP_UI_SHOP_INVENTORY_ROW1_MARGIN-SHOP_UI_SHOP_INVENTORY_ROW2_MARGIN)
    subi r20, (PLAYER_INVENTORY_SIZE+SHOP_INVENTORY_SIZE)/2
_srg_cursor_horizontal_offset:
    ldi r21, INVENTORY_UI_COL_WIDTH
    mul r20, r21
    add XL, r0
    adc XH, r1
    clr r1
    cpi r20, SHOP_INVENTORY_SIZE/2
    brlo _srg_render_cursor
    subi XL, low(-7)
    sbci XH, high(-7)
_srg_render_cursor:
    ldi r24, 8
    ldi r25, 8
    ldi ZL, byte3(2*ui_item_selection_cursor)
    out RAMPZ, ZL
    ldi ZL, low(2*ui_item_selection_cursor)
    ldi ZH, high(2*ui_item_selection_cursor)
    call render_element
    rcall shop_determine_selection
    ld r16, X
    mov r17, r25
    dec r16
    brpl _srg_selection_name
    rjmp _srg_no_selection
_srg_selection_name:
    ldi XL, low(framebuffer+SHOP_UI_SUBHEADER_MARGIN)
    ldi XH, high(framebuffer+SHOP_UI_SUBHEADER_MARGIN)
    ldi r22, SHOP_UI_HEADER_COLOR
    ldi r24, DISPLAY_WIDTH
    ldi r25, SHOP_UI_SUBHEADER_HEIGHT
    call render_rect
    ldi YL, low(framebuffer+SHOP_UI_ITEM_NAME_MARGIN)
    ldi YH, high(framebuffer+SHOP_UI_ITEM_NAME_MARGIN)
    ldi ZL, byte3(2*item_table)
    out RAMPZ, ZL
    ldi ZL, low(2*item_table+ITEM_NAME_PTR_OFFSET)
    ldi ZH, high(2*item_table+ITEM_NAME_PTR_OFFSET)
    ldi r19, ITEM_MEMSIZE
    mul r16, r19
    add ZL, r0
    adc ZH, r1
    clr r1
    elpm r24, Z+
    elpm r25, Z+
    movw ZL, r24
    subi ZL, low(-2*item_string_table)
    sbci ZH, high(-2*item_string_table)
    clr r23
    ldi r21, 29
    call puts
_srg_selection_description:
    ldi YL, low(framebuffer+SHOP_UI_ITEM_NAME_MARGIN+DISPLAY_WIDTH*(FONT_DISPLAY_HEIGHT+1))
    ldi YH, high(framebuffer+SHOP_UI_ITEM_NAME_MARGIN+DISPLAY_WIDTH*(FONT_DISPLAY_HEIGHT+1))
    ldi ZL, low(2*item_table+ITEM_DESC_PTR_OFFSET)
    ldi ZH, high(2*item_table+ITEM_DESC_PTR_OFFSET)
    ldi r19, ITEM_MEMSIZE
    mul r16, r19
    add ZL, r0
    adc ZH, r1
    clr r1
    elpm r24, Z+
    elpm r25, Z+
    movw ZL, r24
    subi ZL, low(-2*item_string_table)
    sbci ZH, high(-2*item_string_table)
    ldi r23, 0
    ldi r21, 22
    call puts
_srg_selection_buy_price:
    ldi YL, low(framebuffer+SHOP_UI_PRICE_LABEL_MARGIN)
    ldi YH, high(framebuffer+SHOP_UI_PRICE_LABEL_MARGIN)
    ldi r21, 29
    tst r17
    brne _srg_selection_sell_price
    ldi ZL, low(2*ui_str_buy_label)
    ldi ZH, high(2*ui_str_buy_label)
    call puts
    mov r25, r16
    rcall calculate_buy_price
    movw r18, r24
    ldi XL, low(framebuffer+DISPLAY_WIDTH+SHOP_UI_PRICE_MARGIN-FONT_DISPLAY_WIDTH)
    ldi XH, high(framebuffer+DISPLAY_WIDTH+SHOP_UI_PRICE_MARGIN-FONT_DISPLAY_WIDTH)
    ldi r23, 0x04
    call putw
    rjmp _srg_coin_icon
_srg_selection_sell_price:
    ldi ZL, low(2*ui_str_sell_label)
    ldi ZH, high(2*ui_str_sell_label)
    call puts
    mov r25, r16
    rcall calculate_sell_price
    movw r18, r24
    ldi XL, low(framebuffer+DISPLAY_WIDTH+SHOP_UI_PRICE_MARGIN-FONT_DISPLAY_WIDTH)
    ldi XH, high(framebuffer+DISPLAY_WIDTH+SHOP_UI_PRICE_MARGIN-FONT_DISPLAY_WIDTH)
    ldi r23, 0x18
    call putw
_srg_coin_icon:
    ldi XL, low(framebuffer+SHOP_UI_PRICE_MARGIN)
    ldi XH, high(framebuffer+SHOP_UI_PRICE_MARGIN)
    ldi r24, 4
    ldi r25, 7
    ldi ZL, byte3(2*ui_coin_icon)
    out RAMPZ, ZL
    ldi ZL, low(2*ui_coin_icon)
    ldi ZH, high(2*ui_coin_icon)
    call render_element
    rjmp _srg_end
_srg_no_selection:
    ldi YL, low(framebuffer+INVENTORY_UI_NO_ITEM_SELECTED_MARGIN)
    ldi YH, high(framebuffer+INVENTORY_UI_NO_ITEM_SELECTED_MARGIN)
    ldi ZL, low(2*ui_str_inventory_instructions)
    ldi ZH, high(2*ui_str_inventory_instructions)
    ldi r21, 29
    clr r23
    call puts
_srg_end:
    ret

; Calculate a pointer to the selected item, in the player's or shop's inventory.
;
; Register Usage
;   r25             nonzero if in the player's inventory, zero if in the shop's
;   X (r30:r31)     pointer to the selected item
shop_determine_selection:
    lds r24, shop_selection
    ldi r25, 1
_sds_shop1:
    cpi r24, SHOP_INVENTORY_SIZE/2
    brsh _sds_player1
    ldi XL, low(shop_inventory)
    ldi XH, high(shop_inventory)
    add XL, r24
    adc XH, r1
    clr r25
    ret
_sds_player1:
    subi r24, SHOP_INVENTORY_SIZE/2
    cpi r24, PLAYER_INVENTORY_SIZE/2
    brsh _sds_shop2
    ldi XL, low(player_inventory)
    ldi XH, high(player_inventory)
    add XL, r24
    adc XH, r1
    ret
_sds_shop2:
    subi r24, PLAYER_INVENTORY_SIZE/2
    cpi r24, SHOP_INVENTORY_SIZE/2
    brsh _sts_player2
    ldi XL, low(shop_inventory+SHOP_INVENTORY_SIZE/2)
    ldi XH, high(shop_inventory+SHOP_INVENTORY_SIZE/2)
    add XL, r24
    adc XH, r1
    clr r25
    ret
_sts_player2:
    subi r24, SHOP_INVENTORY_SIZE/2
    cpi r24, PLAYER_INVENTORY_SIZE/2
    brsh _sts_end
    ldi XL, low(player_inventory+PLAYER_INVENTORY_SIZE/2)
    ldi XH, high(player_inventory+PLAYER_INVENTORY_SIZE/2)
    add XL, r24
    adc XH, r1
_sts_end:
    ret

; Calculate the price at which the player can buy the given item.
;
; Register Usage
;   r24:r25         calculated price
;   r25             item index (param)
;   Z (r30:r31)     flash pointer
calculate_buy_price:
    ldi ZL, byte3(2*item_table)
    out RAMPZ, ZL
    ldi ZL, low(2*item_table+ITEM_COST_OFFSET)
    ldi ZH, high(2*item_table+ITEM_COST_OFFSET)
    ldi r24, ITEM_MEMSIZE
    mul r24, r25
    add ZL, r0
    adc ZH, r1
    elpm r20, Z+
    elpm r21, Z+
    ldi ZL, byte3(2*shop_table)
    out RAMPZ, ZL
    ldi ZL, low(2*shop_table+SHOP_PRICE_CONST_OFFSET)
    ldi ZH, high(2*shop_table+SHOP_PRICE_CONST_OFFSET)
    ldi r22, SHOP_MEMSIZE
    lds r23, current_shop_index
    mul r22, r23
    add ZL, r0
    adc ZH, r1
    clr r1
    elpm r22, Z+
    elpm r23, Z+
    mul r20, r23
    lsr r1
    ror r0
    lsr r1
    ror r0
    lsr r1
    ror r0
    lsr r1
    ror r0
    lsr r1
    ror r0
    movw r24, r0
    mul r21, r23
    lsl r0
    rol r1
    lsl r0
    rol r1
    lsl r0
    rol r1
    add r24, r0
    adc r25, r1
    clr r1
    add r24, r22
    adc r25, r1
    ret

; Calculate the price at which the player can sell the given item.
;
; Register Usage
;   r24:r25         calculated price
;   r25             item index (param)
;   Z (r30:r31)     flash pointer
calculate_sell_price:
    ldi ZL, byte3(2*item_table)
    out RAMPZ, ZL
    ldi ZL, low(2*item_table+ITEM_COST_OFFSET)
    ldi ZH, high(2*item_table+ITEM_COST_OFFSET)
    ldi r24, ITEM_MEMSIZE
    mul r24, r25
    add ZL, r0
    adc ZH, r1
    elpm r24, Z+
    elpm r25, Z+
    ret
