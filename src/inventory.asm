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
    andi r21, 3
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

.equ INVENTORY_UI_HEADER_HEIGHT = 9
.equ INVENTORY_UI_HEADER_COLOR = 0x1d
.equ INVENTORY_UI_SUBHEADER_HEIGHT = 7
.equ INVENTORY_UI_SUBHEADER_OFFSET = 33*DISPLAY_WIDTH
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
.equ INVENTORY_UI_ITEM_NAME_MARGIN = 34*DISPLAY_WIDTH+2
.equ INVENTORY_UI_ITEM_STATS_MARGIN = 41*DISPLAY_WIDTH+107
.equ INVENTORY_UI_NO_ITEM_SELECTED_MARGIN = 59*DISPLAY_WIDTH+28

; Render the player's inventory and equipment, along with the currently selected
; item and information about it.
;
; Register Usage
;   r14-r16         preserve values across calls
;   r18-r25         calculations
;   X, Y, Z         framebuffer and memory pointers
inventory_render_game:
    push r14
    push r15
    push r16
    push r17
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
_irg_render_item_name:
    lds r16, inventory_selection
    ldi ZL, low(player_inventory)
    ldi ZH, high(player_inventory)
    add ZL, r16
    adc ZH, r1
    ld r16, Z
    tst r16
    brne _irg_render_selected_item_name
    rjmp _irg_no_item_selected
_irg_render_selected_item_name:
    ldi XL, low(framebuffer+INVENTORY_UI_SUBHEADER_OFFSET)
    ldi XH, high(framebuffer+INVENTORY_UI_SUBHEADER_OFFSET)
    ldi r22, INVENTORY_UI_HEADER_COLOR
    ldi r24, DISPLAY_WIDTH
    ldi r25, INVENTORY_UI_SUBHEADER_HEIGHT
    call render_rect
    dec r16
    ldi YL, low(framebuffer+INVENTORY_UI_ITEM_NAME_MARGIN)
    ldi YH, high(framebuffer+INVENTORY_UI_ITEM_NAME_MARGIN)
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
    ldi r23, 0
    ldi r21, 29
    call puts
_irg_render_selected_item_description:
    ldi YL, low(framebuffer+INVENTORY_UI_ITEM_NAME_MARGIN+DISPLAY_WIDTH*(FONT_DISPLAY_HEIGHT+1))
    ldi YH, high(framebuffer+INVENTORY_UI_ITEM_NAME_MARGIN+DISPLAY_WIDTH*(FONT_DISPLAY_HEIGHT+1))
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
_irg_render_item_stats:
    ldi YL, low(framebuffer+INVENTORY_UI_ITEM_STATS_MARGIN)
    ldi YH, high(framebuffer+INVENTORY_UI_ITEM_STATS_MARGIN)
    ldi ZL, low(2*item_table+ITEM_STATS_OFFSET)
    ldi ZH, high(2*item_table+ITEM_STATS_OFFSET)
    ldi r19, ITEM_MEMSIZE
    mul r16, r19
    add ZL, r0
    adc ZH, r1
    clr r1
    elpm r14, Z+
    elpm r15, Z+
    elpm r16, Z+
    elpm r17, Z+
_irg_render_item_strength:
    tst r14
    breq _irg_render_item_vitality
    ldi ZL, byte3(2*ui_str_strength_abbr)
    out RAMPZ, ZL
    ldi ZL, low(2*ui_str_strength_abbr)
    ldi ZH, high(2*ui_str_strength_abbr)
    mov r25, r14
    rcall render_item_stat
    subi YL, low(-FONT_DISPLAY_HEIGHT*DISPLAY_WIDTH)
    sbci YH, high(-FONT_DISPLAY_HEIGHT*DISPLAY_WIDTH)
_irg_render_item_vitality:
    tst r15
    breq _irg_render_item_dexterity
    ldi ZL, low(2*ui_str_vitality_abbr)
    ldi ZH, high(2*ui_str_vitality_abbr)
    mov r25, r15
    rcall render_item_stat
    subi YL, low(-FONT_DISPLAY_HEIGHT*DISPLAY_WIDTH)
    sbci YH, high(-FONT_DISPLAY_HEIGHT*DISPLAY_WIDTH)
_irg_render_item_dexterity:
    tst r16
    breq _irg_render_item_charisma
    ldi ZL, low(2*ui_str_dexterity_abbr)
    ldi ZH, high(2*ui_str_dexterity_abbr)
    mov r25, r16
    rcall render_item_stat
    subi YL, low(-FONT_DISPLAY_HEIGHT*DISPLAY_WIDTH)
    sbci YH, high(-FONT_DISPLAY_HEIGHT*DISPLAY_WIDTH)
_irg_render_item_charisma:
    tst r17
    breq _irg_end
    ldi ZL, low(2*ui_str_charisma_abbr)
    ldi ZH, high(2*ui_str_charisma_abbr)
    mov r25, r17
    rcall render_item_stat
    rjmp _irg_end
_irg_no_item_selected:
    ldi YL, low(framebuffer+INVENTORY_UI_NO_ITEM_SELECTED_MARGIN)
    ldi YH, high(framebuffer+INVENTORY_UI_NO_ITEM_SELECTED_MARGIN)
    ldi ZL, low(2*ui_str_inventory_instructions)
    ldi ZH, high(2*ui_str_inventory_instructions)
    ldi r21, 29
    clr r23
    call puts
_irg_end:
    pop r17
    pop r16
    pop r15
    pop r14
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

; Render an item stat boost with color.
;
; Register Usage
;   r21-24          calculations
;   r25             stat boost value (param)
;   X (r26:r27)     working framebuffer pointer
;   Y (r28:r29)     framebuffer pointer (param)
;   Z (r30:r31)     stat abbreviation pointer (param)
render_item_stat:
    push r25
    ldi r21, 6
    clr r23
    call puts
    subi XL, low(4*FONT_DISPLAY_WIDTH+FONT_DISPLAY_WIDTH/3) ; puts changes X
    sbci XH, high(4*FONT_DISPLAY_WIDTH+FONT_DISPLAY_WIDTH/3)
    pop r21
    ldi r23, 0x18
    ldi r20, '+'
    cpi r21, 0
    brge _rit_write_stat
    ldi r23, 0x4
    ldi r20, '-'
    neg r21
_rit_write_stat:
    call put8u
    mov r22, r20
    call putc
    clr r23
    ret
