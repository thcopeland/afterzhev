load_character_selection:
    ldi r25, MODE_CHARACTER
    sts game_mode, r25
    sts sector_data, r1
    sts mode_clock, r1
    sts player_class, r1
    sts player_character, r1
    ret

character_selection_update:
    rcall character_selection_render
    rcall character_selection_controls
    jmp _loop_reenter

character_selection_controls:
    lds r20, prev_controller_values
    lds r21, controller_values
    com r20
    and r20, r21
    lds r25, sector_data
    tst r25
    brne _csc_character
_csc_class:
    lds r25, player_class
    sbrc r20, CONTROLS_LEFT
    dec r25
    sbrc r20, CONTROLS_RIGHT
    inc r25
    cpi r25, 3
    brsh _csc_finalize_class
    sts player_class, r25
_csc_finalize_class:
    andi r20, exp2(CONTROLS_SPECIAL1)|exp2(CONTROLS_SPECIAL2)|exp2(CONTROLS_SPECIAL3)|exp2(CONTROLS_SPECIAL4)
    breq _csc_class_end
    ldi r25, 1
    sts sector_data, r25
_csc_class_end:
    ret
_csc_character:
    lds r25, player_character
    sbrc r20, CONTROLS_LEFT
    dec r25
    sbrc r20, CONTROLS_RIGHT
    inc r25
    cpi r25, 3
    brsh _csc_finalize_character
    sts player_character, r25
_csc_finalize_character:
    andi r20, exp2(CONTROLS_SPECIAL1)|exp2(CONTROLS_SPECIAL2)|exp2(CONTROLS_SPECIAL3)|exp2(CONTROLS_SPECIAL4)
    breq _csc_class_end
    call load_intro
_csc_character_end:
    ret

.equ CHARACTER_HEADER_MARGIN = 8 + DISPLAY_WIDTH*6
.equ CHARACTER_CURSOR_MARGIN = 20 + DISPLAY_WIDTH*25
.equ CHARACTER_OPTION_1_MARGIN = 24 + DISPLAY_WIDTH*20
.equ CHARACTER_OPTION_2_MARGIN = 54 + DISPLAY_WIDTH*20
.equ CHARACTER_OPTION_3_MARGIN = 84 + DISPLAY_WIDTH*20
.equ CHARACTER_SHADOW_OFFSET = 3 + DISPLAY_WIDTH*10
.equ CHARACTER_DESCRIPTION_MARGIN = 6 + DISPLAY_WIDTH*40
.equ CHARACTER_NAME_OFFSET = DISPLAY_WIDTH*18

character_selection_render:
    ldi ZL, byte3(2*parchment_screen)
    out RAMPZ, ZL
    ldi ZL, low(2*parchment_screen)
    ldi ZH, high(2*parchment_screen)
    call render_full_screen
_csr_shadows:
    ldi r21, 12
    ldi r22, 0
    ldi r23, 3
    ldi r24, 0
    ldi r25, 12
    ldi XL, low(framebuffer+CHARACTER_OPTION_1_MARGIN+CHARACTER_SHADOW_OFFSET)
    ldi XH, high(framebuffer+CHARACTER_OPTION_1_MARGIN+CHARACTER_SHADOW_OFFSET)
    ldi ZL, byte3(2*character_icon_shadow)
    out RAMPZ, ZL
    ldi ZL, low(2*character_icon_shadow)
    ldi ZH, high(2*character_icon_shadow)
    call write_sprite
    ldi r21, 12
    ldi r22, 0
    ldi r23, 3
    ldi r24, 0
    ldi r25, 12
    ldi XL, low(framebuffer+CHARACTER_OPTION_2_MARGIN+CHARACTER_SHADOW_OFFSET)
    ldi XH, high(framebuffer+CHARACTER_OPTION_2_MARGIN+CHARACTER_SHADOW_OFFSET)
    ldi ZL, low(2*character_icon_shadow)
    ldi ZH, high(2*character_icon_shadow)
    call write_sprite
    ldi r21, 12
    ldi r22, 0
    ldi r23, 3
    ldi r24, 0
    ldi r25, 12
    ldi XL, low(framebuffer+CHARACTER_OPTION_3_MARGIN+CHARACTER_SHADOW_OFFSET)
    ldi XH, high(framebuffer+CHARACTER_OPTION_3_MARGIN+CHARACTER_SHADOW_OFFSET)
    ldi ZL, low(2*character_icon_shadow)
    ldi ZH, high(2*character_icon_shadow)
    call write_sprite
_csr_selected:
    ldi XL, low(framebuffer+CHARACTER_CURSOR_MARGIN)
    ldi XH, high(framebuffer+CHARACTER_CURSOR_MARGIN)
    ldi r20, 30
    lds r21, player_class
    lds r25, sector_data
    tst r25
    breq _csr_selected_offset
    lds r21, player_character
_csr_selected_offset:
    mul r20, r21
    add XL, r0
    adc XH, r1
    clr r1
    ldi r22, 128
    clr r23
    call putc
_csr_mode:
    lds r25, sector_data
    tst r25
    breq _csr_class
    rjmp _csr_character
_csr_class:
    ldi r21, 30
    ldi r23, 0
    ldi YL, low(framebuffer+CHARACTER_HEADER_MARGIN)
    ldi YH, high(framebuffer+CHARACTER_HEADER_MARGIN)
    ldi ZL, byte3(2*ui_str_choose_class)
    out RAMPZ, ZL
    ldi ZL, low(2*ui_str_choose_class)
    ldi ZH, high(2*ui_str_choose_class)
    call puts
    ldi r23, 128|CHOOSE_PALADIN_SPRITE
    ldi r24, ITEM_blessed_sword
    ldi r25, ITEM_iron_helmet
    sts character_render, r23
    sts character_render+1, r24
    sts character_render+2, r25
    sts character_render+3, r1
    sts character_render+4, r1
    sts character_render+5, r1
    sts character_render+6, r1
    ldi XL, low(framebuffer+CHARACTER_OPTION_1_MARGIN)
    ldi XH, high(framebuffer+CHARACTER_OPTION_1_MARGIN)
    ldi YL, low(character_render)
    ldi YH, high(character_render)
    call render_character_icon
    ldi r23, 128|CHOOSE_ROGUE_SPRITE
    ldi r24, ITEM_glass_dagger
    ldi r25, ITEM_green_hood
    sts character_render, r23
    sts character_render+1, r24
    sts character_render+2, r25
    ldi XL, low(framebuffer+CHARACTER_OPTION_2_MARGIN)
    ldi XH, high(framebuffer+CHARACTER_OPTION_2_MARGIN)
    call render_character_icon
    ldi r23, 128|CHOOSE_MAGE_SPRITE
    ldi r24, ITEM_wood_staff
    sts character_render, r23
    sts character_render+1, r24
    sts character_render+2, r1
    ldi XL, low(framebuffer+CHARACTER_OPTION_3_MARGIN)
    ldi XH, high(framebuffer+CHARACTER_OPTION_3_MARGIN)
    call render_character_icon
    ldi YL, low(framebuffer+CHARACTER_DESCRIPTION_MARGIN)
    ldi YH, high(framebuffer+CHARACTER_DESCRIPTION_MARGIN)
    ldi ZL, byte3(2*class_table+CLASS_DESC_OFFSET)
    out RAMPZ, ZL
    ldi ZL, low(2*class_table+CLASS_DESC_OFFSET)
    ldi ZH, high(2*class_table+CLASS_DESC_OFFSET)
    lds r24, player_class
    ldi r25, CLASS_MEMSIZE
    mul r24, r25
    add ZL, r0
    adc ZH, r1
    clr r1
    ldi r21, 29
    clr r23
    call puts
    ret
_csr_character:
    ldi r21, 30
    ldi r23, 0
    ldi YL, low(framebuffer+CHARACTER_HEADER_MARGIN)
    ldi YH, high(framebuffer+CHARACTER_HEADER_MARGIN)
    ldi ZL, byte3(2*ui_str_choose_character)
    out RAMPZ, ZL
    ldi ZL, low(2*ui_str_choose_character)
    ldi ZH, high(2*ui_str_choose_character)
    call puts
    ldi YL, low(framebuffer+CHARACTER_OPTION_1_MARGIN+CHARACTER_NAME_OFFSET)
    ldi YH, high(framebuffer+CHARACTER_OPTION_1_MARGIN+CHARACTER_NAME_OFFSET)
    ldi ZL, low(2*ui_str_man)
    ldi ZH, high(2*ui_str_man)
    call puts
    ldi YL, low(framebuffer+CHARACTER_OPTION_2_MARGIN+CHARACTER_NAME_OFFSET-8)
    ldi YH, high(framebuffer+CHARACTER_OPTION_2_MARGIN+CHARACTER_NAME_OFFSET-8)
    ldi ZL, low(2*ui_str_halfling)
    ldi ZH, high(2*ui_str_halfling)
    call puts
    ldi YL, low(framebuffer+CHARACTER_OPTION_3_MARGIN+CHARACTER_NAME_OFFSET-2)
    ldi YH, high(framebuffer+CHARACTER_OPTION_3_MARGIN+CHARACTER_NAME_OFFSET-2)
    ldi ZL, low(2*ui_str_woman)
    ldi ZH, high(2*ui_str_woman)
    call puts
_csr_determine_gear:
    lds r25, player_class
_csr_paladin_gear:
    cpi r25, CLASS_PALADIN
    brne _csr_rogue_gear
    ldi r20, ITEM_blessed_sword
    ldi r21, NO_ITEM
_csr_rogue_gear:
    cpi r25, CLASS_ROGUE
    brne _csr_mage_gear
    ldi r20, ITEM_glass_dagger
    ldi r21, ITEM_green_cloak
_csr_mage_gear:
    cpi r25, CLASS_MAGE
    brne _csr_render_man
    ldi r20, ITEM_wood_staff
    ldi r21, NO_ITEM
_csr_render_man:
    ldi r23, CHARACTER_MAN
    sts character_render, r23
    sts character_render+1, r20
    sts character_render+2, r21
    sts character_render+3, r1
    sts character_render+4, r1
    sts character_render+5, r1
    sts character_render+6, r1
    ldi XL, low(framebuffer+CHARACTER_OPTION_1_MARGIN)
    ldi XH, high(framebuffer+CHARACTER_OPTION_1_MARGIN)
    ldi YL, low(character_render)
    ldi YH, high(character_render)
    call render_character_icon
    ldi r23, CHARACTER_HALFLING
    sts character_render, r23
    lds r21, character_render+2
    cpi r21, ITEM_green_cloak
    brne _csr_do_render_halfling
    ldi r21, ITEM_green_cloak_small
    sts character_render+2, r21
_csr_do_render_halfling:
    ldi XL, low(framebuffer+CHARACTER_OPTION_2_MARGIN+DISPLAY_WIDTH)
    ldi XH, high(framebuffer+CHARACTER_OPTION_2_MARGIN+DISPLAY_WIDTH)
    ldi YL, low(character_render)
    ldi YH, high(character_render)
    call render_character_icon
    ldi r23, CHARACTER_WOMAN
    sts character_render, r23
    ldi XL, low(framebuffer+CHARACTER_OPTION_3_MARGIN)
    ldi XH, high(framebuffer+CHARACTER_OPTION_3_MARGIN)
    ldi YL, low(character_render)
    ldi YH, high(character_render)
    call render_character_icon
    ret
