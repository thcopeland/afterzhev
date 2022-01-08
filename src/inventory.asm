inventory_update_game:
    rcall inventory_render_game
    rcall inventory_handle_controls
    ret

inventory_handle_controls:
    lds r18, prev_controller_values
    lds r19, controller_values
    mov r20, r18
    com r20
    and r20, r19
    breq _ihc_handle_buttons
    sts mode_clock, r1
_ihc_handle_buttons:
    lds r21, mode_clock
    andi r21, 0; 3
    brne _ihc_end
_ihc_down:
    sbrs r19, CONTROLS_DOWN
    rjmp _ihc_right
    lds r22, inventory_selection
    cpi r22, PLAYER_INVENTORY_SIZE/2
    brpl _ihc_right
    subi r22, -PLAYER_INVENTORY_SIZE/2
    sts inventory_selection, r22
_ihc_right:
    sbrs r19, CONTROLS_RIGHT
    rjmp _ihc_up
    lds r22, inventory_selection
    inc r22
    cpi r22, PLAYER_INVENTORY_SIZE
    brsh _ihc_up
    sts inventory_selection, r22
_ihc_up:
    sbrs r19, CONTROLS_UP
    rjmp _ihc_left
    lds r22, inventory_selection
    subi r22, PLAYER_INVENTORY_SIZE/2
    brlo _ihc_left
    sts inventory_selection, r22
_ihc_left:
    sbrs r19, CONTROLS_LEFT
    rjmp _ihc_end
    lds r22, inventory_selection
    dec r22
    brmi _ihc_end
    sts inventory_selection, r22
_ihc_end:
    inc r21
    sts mode_clock, r21
    ret

_placeholder_item_description: .db "ANCIENT GLASS SWORD     300O", 10, "A favorite of thives and assassins, but prone to chipping.", 0
_placeholder_item_stats: .db " -3 Str +0 Vit +1 Dex +1 Cng", 0, 0

.equ INVENTORY_UI_HEADER_HEIGHT = 9
.equ INVENTORY_UI_HEADER_COLOR = 0x1d
.equ INVENTORY_UI_BODY_COLOR = 0x6e
.equ INVENTORY_UI_CLASS_MARGIN = 2*DISPLAY_WIDTH+2
.equ INVENTORY_UI_STATS_MARGIN = 2*DISPLAY_WIDTH+60
.equ INVENTORY_UI_ROW1_MARGIN = DISPLAY_WIDTH*11+33
.equ INVENTORY_UI_ROW2_MARGIN = DISPLAY_WIDTH*20+33
.equ INVENTORY_UI_COL_WIDTH = STATIC_ITEM_WIDTH+3
.equ INVENTORY_UI_CHARACTER_MARGIN = DISPLAY_WIDTH*14+3
.equ INVENTORY_UI_WEAPON_MARGIN = INVENTORY_UI_CHARACTER_MARGIN-DISPLAY_WIDTH*3+16
.equ INVENTORY_UI_ARMOR_MARGIN = INVENTORY_UI_CHARACTER_MARGIN+DISPLAY_WIDTH*6+16
.equ INVENTORY_UI_HEALTH_ICON_MARGIN = DISPLAY_WIDTH*12+110
.equ INVENTORY_UI_HEALTH_MARGIN = 13*DISPLAY_WIDTH+106
.equ INVENTORY_UI_GOLD_ICON_MARGIN = DISPLAY_WIDTH*21+112
.equ INVENTORY_UI_GOLD_MARGIN = 22*DISPLAY_WIDTH+106

inventory_render_game:
_irg_render_background:
    ldi XL, low(framebuffer)
    ldi XH, high(framebuffer)
    ldi r22, INVENTORY_UI_HEADER_COLOR
    ldi r24, DISPLAY_WIDTH
    ldi r25, INVENTORY_UI_HEADER_HEIGHT
    call render_rect
    ldi XL, low(framebuffer+INVENTORY_UI_HEADER_HEIGHT*DISPLAY_WIDTH)
    ldi XH, high(framebuffer+INVENTORY_UI_HEADER_HEIGHT*DISPLAY_WIDTH)
    ldi r22, INVENTORY_UI_BODY_COLOR
    ldi r24, DISPLAY_WIDTH
    ldi r25, DISPLAY_HEIGHT-INVENTORY_UI_HEADER_HEIGHT
    call render_rect
_irg_render_class:
    ldi YL, low(framebuffer+INVENTORY_UI_CLASS_MARGIN)
    ldi YH, high(framebuffer+INVENTORY_UI_CLASS_MARGIN)
    ldi ZL, byte3(2*class_table+CLASS_NAME_OFFSET)
    out RAMPZ, ZL
    ldi ZL, low(2*class_table+CLASS_NAME_OFFSET)
    ldi ZH, high(2*class_table+CLASS_NAME_OFFSET)
    ldi r20, CLASS_MEMSIZE
    lds r21, player_class
    mul r20, r21
    add ZL, r0
    adc ZH, r1
    clr r1
    ldi r23, 0
    ldi r21, 10
    call puts
_irg_render_stats:
    ldi XL, low(framebuffer+INVENTORY_UI_STATS_MARGIN)
    ldi XH, high(framebuffer+INVENTORY_UI_STATS_MARGIN)
    ldi YL, low(player_stats)
    ldi YH, high(player_stats)
    ldi r20, STATS_COUNT
_irg_render_stats_iter:
    ld r21, Y+
    call put8u
    subi XL, low(-22)
    sbci XH, high(-22)
_irg_render_stats_check:
    dec r20
    brne _irg_render_stats_iter
_irg_render_health:
    ldi XL, low(framebuffer+INVENTORY_UI_HEALTH_ICON_MARGIN)
    ldi XH, high(framebuffer+INVENTORY_UI_HEALTH_ICON_MARGIN)
    ldi r24, 7
    ldi r25, 7
    ldi ZL, byte3(2*ui_heart_icon)
    out RAMPZ, ZL
    ldi ZL, low(2*ui_heart_icon)
    ldi ZH, high(2*ui_heart_icon)
    call render_element
    ldi XL, low(framebuffer+INVENTORY_UI_HEALTH_MARGIN)
    ldi XH, high(framebuffer+INVENTORY_UI_HEALTH_MARGIN)
    lds r21, player_max_health
    call put8u
    ldi r22, '/'
    call putc
    subi XL, low(FONT_DISPLAY_WIDTH)
    sbci XH, high(FONT_DISPLAY_WIDTH)
    lds r21, player_health
    call put8u
_irg_render_gold:
    ldi XL, low(framebuffer+INVENTORY_UI_GOLD_ICON_MARGIN)
    ldi XH, high(framebuffer+INVENTORY_UI_GOLD_ICON_MARGIN)
    ldi r24, 4
    ldi r25, 7
    ldi ZL, byte3(2*ui_coin_icon)
    out RAMPZ, ZL
    ldi ZL, low(2*ui_coin_icon)
    ldi ZH, high(2*ui_coin_icon)
    call render_element
    ldi XL, low(framebuffer+INVENTORY_UI_GOLD_MARGIN)
    ldi XH, high(framebuffer+INVENTORY_UI_GOLD_MARGIN)
    lds r21, player_gold
    call put8u
_irg_render_character:
    ldi XL, low(framebuffer+INVENTORY_UI_WEAPON_MARGIN)
    ldi XH, high(framebuffer+INVENTORY_UI_WEAPON_MARGIN)
    lds r25, player_armor
    ldi r25, 1
    rcall render_item_with_underbar
    ldi XL, low(framebuffer+INVENTORY_UI_CHARACTER_MARGIN)
    ldi XH, high(framebuffer+INVENTORY_UI_CHARACTER_MARGIN)
    ldi YL, low(player_character)
    ldi YH, high(player_character)
    call render_character_icon
    ldi XL, low(framebuffer+INVENTORY_UI_ARMOR_MARGIN)
    ldi XH, high(framebuffer+INVENTORY_UI_ARMOR_MARGIN)
    lds r25, player_weapon
    rcall render_item_with_underbar
_irg_render_inventory:
    ldi XL, low(framebuffer+INVENTORY_UI_ROW1_MARGIN)
    ldi XH, high(framebuffer+INVENTORY_UI_ROW1_MARGIN)
    clr r20
_irg_display_inventory_iter:
    ldi ZL, low(player_inventory)
    ldi ZH, high(player_inventory)
    add ZL, r20
    adc ZH, r1
    ld r25, Z
    movw YL, XL
    rcall render_item_with_underbar
    movw XL, YL
    adiw XL, INVENTORY_UI_COL_WIDTH
    inc r20
    cpi r20, PLAYER_INVENTORY_SIZE/2
    brne _irg_display_inventory_iter_next
    ldi XL, low(framebuffer+INVENTORY_UI_ROW2_MARGIN)
    ldi XH, high(framebuffer+INVENTORY_UI_ROW2_MARGIN)
_irg_display_inventory_iter_next:
    cpi r20, PLAYER_INVENTORY_SIZE
    brlo _irg_display_inventory_iter
_irg_render_selection:
    lds r18, inventory_selection
    ldi ZL, low(player_inventory)
    ldi ZH, high(player_inventory)
    add ZL, r18
    adc ZH, r1
    ld r19, Z
    ldi XL, low(framebuffer+INVENTORY_UI_ROW1_MARGIN-DISPLAY_WIDTH-1)
    ldi XH, high(framebuffer+INVENTORY_UI_ROW1_MARGIN-DISPLAY_WIDTH-1)
    cpi r18, PLAYER_INVENTORY_SIZE/2
    brlo _irg_calc_selection_offset
    ldi XL, low(framebuffer+INVENTORY_UI_ROW2_MARGIN-DISPLAY_WIDTH-1)
    ldi XH, high(framebuffer+INVENTORY_UI_ROW2_MARGIN-DISPLAY_WIDTH-1)
    subi r18, PLAYER_INVENTORY_SIZE/2
_irg_calc_selection_offset:
    ldi r20, INVENTORY_UI_COL_WIDTH
    mul r18, r20
    add XL, r0
    adc XH, r1
    clr r1
_irg_render_selection_cursor:
    ldi r24, 8
    ldi r25, 8
    ldi ZL, byte3(2*ui_item_selection_cursor)
    out RAMPZ, ZL
    ldi ZL, low(2*ui_item_selection_cursor)
    ldi ZH, high(2*ui_item_selection_cursor)
    call render_element
_irg_render_item_description:
    ldi YL, low(framebuffer+40*DISPLAY_WIDTH+2)
    ldi YH, high(framebuffer+40*DISPLAY_WIDTH+2)
    ldi ZL, byte3(2*_placeholder_item_description)
    out RAMPZ, ZL
    ldi ZL, low(2*_placeholder_item_description)
    ldi ZH, high(2*_placeholder_item_description)
    ldi r23, 0
    ldi r21, 29
    call puts
_irg_render_item_stats:
    ldi YL, low(framebuffer+59*DISPLAY_WIDTH+2)
    ldi YH, high(framebuffer+59*DISPLAY_WIDTH+2)
    ldi ZL, byte3(2*_placeholder_item_stats)
    out RAMPZ, ZL
    ldi ZL, low(2*_placeholder_item_stats)
    ldi ZH, high(2*_placeholder_item_stats)
    ldi r23, 0
    ldi r21, 29
    call puts
_irg_end:
    ret

; Render an item icon with a nice-looking underbar. The underbar is rendered
; whether or not the item is present.
;
; Register Usage
;   r22-r24         internal
;   r25             item (param)
;   X (r26:r37)     framebuffer pointer (param)
render_item_with_underbar:
    call render_item_icon
    subi XL, low(-(STATIC_ITEM_HEIGHT*DISPLAY_WIDTH-1))
    sbci XH, high(-(STATIC_ITEM_HEIGHT*DISPLAY_WIDTH-1))
    ldi r22, 0x0
    ldi r24, INVENTORY_UI_COL_WIDTH-1
    ldi r25, 1
    call render_rect
    ret
