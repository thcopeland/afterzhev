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
ui_str_you_died:    .db "YOU  DIED", 0
.if TARGETING_MCU
ui_str_death_retry: .db "Press <A> to try again", 0, 0
ui_str_death_restart:.db " or <B> to start over.", 0, 0
.else
ui_str_death_retry: .db "Press <A> to try again", 0, 0
ui_str_death_restart:.db " or <S> to start over.", 0, 0
.endif
ui_str_press_any_button:.db "Press any button", 0, 0
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
about_str:          .db "AfterZhev is a game by Tom", 10, "Copeland, made from late", 10, "2021 to early 2023.", 10, 10, "Visit thcopeland.com for the", 10, "full story.", 10, 10, "Released under", 10, "the MIT license.", 0, 0
.if TARGETING_MCU
tutorial_move_str:  .db "Use the D-pad to", 10, "move around. To", 10, "dash, press start.", 0
tutorial_pickup_str:.db "Press <A> to pick", 10, "up items.", 10, 10, "They will aid you inyour travels.", 0, 0
tutorial_shop_str:  .db "Press <A> to visit", 10, "a shop.", 10, 10, "Press <B> to buy", 10, "and start to sell.", 10, 10, "Then press select to leave.", 0, 0
tutorial_inventory_str: .db "Press select to", 10, "see the inventory.", 10, 10, "Press <A> to equip,<B> to consume,", 10, "and start to drop.", 10, 10, "Then press select", 10, "to exit.", 0
tutorial_fight_str: .db "After equipping", 10, "a weapon, press <B> to attack.", 10, 10, "Use start to", 10, "dash forward.", 0, 0
.else
tutorial_move_str:  .db "Use the arrow keysto move around.", 10, 10, "Press <D> to dash.", 0
tutorial_pickup_str:.db "Press <A> to pick", 10, "up items.", 10, 10, "They will aid you inyour travels.", 0, 0
tutorial_shop_str:  .db "Press <A> to visit", 10, "a shop.", 10, 10, "Press <S> to buy", 10, "and <D> to sell.", 10, 10, "Then press <F> to", 10, "leave.", 0
tutorial_inventory_str: .db "Press <F> to open", 10, "your inventory.", 10, 10, "Press <A> to equip,<S> to consume,", 10, "and <D> to drop.", 10, 10, "Then press <F> to", 10, "exit.", 0
tutorial_fight_str: .db "After equipping", 10, "a weapon, press <S> to attack.", 10, 10, "Use <D> to dash.", 0, 0
.endif
tutorial_talk_str:  .db "Press <A> to", 10, "interact.", 0, 0
tutorial_next_str:  .db "Press <A> to", 10, "continue through", 10, "the open door.", 0, 0
tutorial_save_str:  .db "Press <A>", 10, "to save", 10, "your", 10, "progress.", 0, 0
