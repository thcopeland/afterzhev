; Various UI elements.
ui_item_selection_cursor:
    .db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; ----------------
    .db 0x00, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x00	; --            --
    .db 0x00, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x00	; --            --
    .db 0x00, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x00	; --            --
    .db 0x00, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x00	; --            --
    .db 0x00, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x00	; --            --
    .db 0x00, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x00	; --            --
    .db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; ----------------
ui_heart_icon:
    .db 0x57, 0x57, 0x0d, 0xc7, 0x57, 0x0d, 0x0d, 0x57 ; ~~~~XX  ~~XXXX
    .db 0x0d, 0x0d, 0x57, 0x0d, 0x0d, 0x03, 0x0d, 0x0d ; ~~XXXX~~XXXXWW
    .db 0x0d, 0x0d, 0x0d, 0x03, 0x03, 0x0d, 0x0d, 0x0d ; XXXXXXXXXXWWWW
    .db 0x0d, 0x0d, 0x03, 0x03, 0xc7, 0x0d, 0x0d, 0x0d ; XXXXXXXXXXWWWW
    .db 0x03, 0x03, 0xc7, 0xc7, 0xc7, 0x0d, 0x03, 0x03 ;  XXXXXXWWWW
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x03, 0xc7, 0xc7 ;    XXWWWW
    .db 0xc7, 0x00                                     ;      WW
ui_small_heart_icon:
    .db 0x5f, 0x0d, 0xc7, 0x5f, 0x0d, 0x5f	; --XX  --XX
    .db 0x0d, 0x0d, 0x0d, 0x03, 0xc7, 0x0d	; --XXXXXXWW
    .db 0x0d, 0x03, 0xc7, 0xc7, 0xc7, 0x03	;   XXXXWW
    .db 0xc7, 0xc7	                        ;     WW
ui_coin_icon:
    .db 0xc7, 0x77, 0x2f, 0xc7	;   ,,--
    .db 0x77, 0x2f, 0x2f, 0x1f	; ,,----~~
    .db 0x77, 0x2f, 0x2f, 0x1f	; ,,----~~
    .db 0x77, 0x2f, 0x2f, 0x1f	; ,,----~~
    .db 0x77, 0x2f, 0x2f, 0x1f	; ,,----~~
    .db 0x77, 0x2f, 0x2f, 0x1f	; ,,----~~
    .db 0xc7, 0x2f, 0x1f, 0xc7	;   --~~
ui_small_coin_icon:
    .db 0xc7, 0x77, 0xc7, 0x77	;   ..
    .db 0x2f, 0x1f, 0x77, 0x2f	; ..,,--
    .db 0x1f, 0xc7, 0x1f, 0xc7	; ..,,--
                                ;   --

ui_str_inventory_instructions:  .db "No item selected", 0, 0
ui_str_level_up:    .db "Level Up!", 0
ui_str_points_remaining:    .db "   ability points remaining", 0
ui_str_strength:    .db "Strength", 0, 0
ui_str_vitality:    .db "Vitality", 0, 0
ui_str_dexterity:   .db "Dexterity", 0
ui_str_intellect:    .db "Intellect", 0
ui_str_strength_abbr:  .db "Str", 0
ui_str_vitality_abbr:  .db "Vit ", 0, 0 ; the trailing space is a hack to ensure all abbreviations have the same width
ui_str_dexterity_abbr: .db "Dex", 0
ui_str_intellect_abbr:  .db "Int", 0
ui_str_buy_label:   .db "Buy", 10, "for", 0
ui_str_sell_label:  .db "Sell", 10, " for", 0
