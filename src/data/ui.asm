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

ui_string_table:
ui_str_inventory_instructions:  .db "No item selected", 0, 0
ui_str_level_up:    .db "Level Up!", 0
ui_str_points_remaining:    .db "   ability points remaining", 0
ui_str_strength:    .db "Strength", 0, 0
ui_str_vitality:    .db "Vitality", 0, 0
ui_str_dexterity:   .db "Dexterity", 0
ui_str_intellect:   .db "Intellect", 0
ui_str_damage_abbr:     .db "Dmg", 0
ui_str_defense_abbr:    .db "Def", 0
ui_str_strength_abbr:   .db "Str", 0
ui_str_vitality_abbr:   .db "Vit ", 0, 0 ; the trailing space ensures all abbreviations have the same width
ui_str_dexterity_abbr:  .db "Dex", 0
ui_str_intellect_abbr:  .db "Int", 0
ui_str_buy_label:   .db "Buy", 10, "for", 0
ui_str_sell_label:  .db "Sell", 10, " for", 0
ui_str_you_died:    .db "A noble effort.", 0
.if TARGETING_MCU
ui_str_death_retry: .db "Press <A> to try again", 0, 0
ui_str_death_restart:.db " or <B> to start over.", 0, 0
.else
ui_str_death_retry: .db "Press <A> to try again", 0, 0
ui_str_death_restart:.db " or <S> to start over.", 0, 0
.endif
ui_credits_congrats:.db "Nobly fought, envoy.", 0, 0
ui_credits_1:       .db "Game by", 0
ui_credits_2:       .db "Tom Copeland", 0, 0
ui_credits_3:       .db "Art by", 0, 0
ui_credits_4:       .db "Tom Copeland", 0, 0
ui_credits_5:       .db "Font by", 0
ui_credits_6:       .db "Brian Swetland", 0, 0
ui_credits_7:       .db "Robey Pointer", 0
ui_credits_8:       .db "Tiny font by", 0, 0
ui_credits_9:       .db "Matthew Welch", 0,
ui_credits_10:      .db "Thanks for playing!", 0
ui_str_start:       .db "Start", 0
ui_str_resume:      .db "Resume", 0, 0
ui_str_help:        .db "Controls", 0, 0
ui_str_about:       .db "About", 0
ui_str_choose_class:.db "Choose your class:", 0, 0
ui_str_choose_character:.db "Choose your character:", 0, 0
ui_str_man:         .db "Man", 0
ui_str_woman:       .db "Woman", 0
ui_str_halfling:    .db "Halfling", 0, 0
ui_str_no_save:     .db "No saved game found in EEPROM.", 10, "Press any button to exit.", 0, 0
intro_str_1:        .db "The queen", 39, "s envoys are a", 10, "particularly glorious corps.", 0
intro_str_2:        .db "Famously, they have never", 10, "failed to deliver a letter.", 0
intro_str_3:        .db "A few weeks ago, two envoys", 10, "departed with a special letter.", 0
intro_str_4:        .db "One an experienced envoy, the", 10, "other an apprentice named Zhev.", 0
intro_str_5:        .db "They traveled far and fast,", 10, "stopping only to eat and rest.", 0, 0
about_str:          .db "AfterZhev is a small, retro-", 10, "inspired RPG written entirely", 10, "in AVR assembly. It runs on a", 10, "single ATmega2560 chip.", 10, 10, "Visit thcopeland.com for the", 10, "full story and source code.", 10, 10, "AfterZhev is released under", 10, "the MIT license (2023).", 0
.if TARGETING_MCU
tutorial_move_str:  .db "  Move with the D-pad.", 0, 0
tutorial_inventory_str:.db "  Press select for inventory.", 0
tutorial_fight_str: .db "  Press <B> to attack.", 0, 0
controls_line1_str: .db 129, 130, 131, "    Move character", 0
controls_line2_str: .db "sel    Toggle inventory", 0
controls_line3_str: .db "srt    Dash, drop item, sell", 0, 0
controls_line4_str: .db "  B      Attack, use potion, buy", 0, 0
controls_line5_str: .db "  A      Interact, equip/unequip", 0, 0
.else
tutorial_move_str:  .db "  Move with the arrows keys.", 0, 0
tutorial_inventory_str:.db "  Press <F> for inventory.", 0, 0
tutorial_fight_str: .db "  Press <S> to attack.", 0, 0
controls_line1_str: .db "  A      Interact, equip/unequip", 0, 0
controls_line2_str: .db "  S      Attack, use potion, buy", 0, 0
controls_line3_str: .db "  D      Dash, drop item, sell", 0, 0
controls_line4_str: .db "  F      Toggle inventory", 0
controls_line5_str: .db 129, 130, 131, "    Move character", 0
.endif
tutorial_pickup_str:.db "  Press <A> to pick up.", 0
tutorial_talk_str:  .db "  Press <A> to interact.", 0, 0
tutorial_next_str:  .db "  Press <A> to enter.", 0
tutorial_save_str:  .db "  Press <A> to save game.", 0
