.include "device.asm"
.include "vga.asm"
.include "utils.asm"
.include "layout.asm"
.include "gamedefs.asm"

.cseg
    .org 0x0000
    jmp init
    .org OC1Aaddr
    jmp isr_loop

.include "init.asm"

main:
    ldi r18, 0xFF
    ldi r19, 0x00
    out DDRA, r18   ; VGA image output
    out DDRB, r18   ; PB6 is VGA HSYNC
    out DDRE, r18   ; PE4 is VGA VSYNC
    out DDRC, r19   ; controls
    out PORTC, r18  ; pull-up

    ; init timers
    ; halt all timers
    ldi r18, (1 << TSM) | (1 << PSRASY) | (1 << PSRSYNC)
    out GTCCR, r18

    ; HSYNC
    ; initialize timer 1 to fast PWM (pin PB6)
    sti TCCR1A, (1 << WGM10) | (1 << WGM11) | (1 << COM1B1) | (1 << COM1B0)
    sti TCCR1B, (1 << WGM12) | (1 << WGM13) | (1 << CS10)
    stiw OCR1AL, (HSYNC_PERIOD - 1)
    stiw OCR1BL, (HSYNC_PERIOD - HSYNC_SYNC_WIDTH - 1)
    sti TIMSK1, (1 << OCIE1A)

    ; VSYNC
    ; initialize timer 3 to fast PWM (pin PE4)
    sti TCCR3A, (1 << WGM30) | (1 << WGM31) | (1 << COM3B1) | (1 << COM3B0)
    sti TCCR3B, (1 << WGM32) | (1 << WGM33) | (1 << CS32)
    stiw OCR3AL, (VSYNC_PERIOD - 1)
    stiw OCR3BL, (VSYNC_PERIOD - VSYNC_SYNC_WIDTH - 1)

    ; synchronize timers
    stiw TCNT1L, (HSYNC_PERIOD - 1)
    stiw TCNT3L, (VSYNC_PERIOD - VSYNC_SYNC_WIDTH - 1 - 20*VIRT_ADJUST)

    ; release timers
    out GTCCR, r1
    sei

    ; enable IDLE sleep mode for reliable interrupt timing
    ldi r18, (1 << SE)
    out SMCR, r18
_main_stall:
    sleep
    rjmp _main_stall

isr_loop:
    ; drop stack frame to save a few bytes
    pop r18
    pop r18
    .if PC_SIZE == 3
    pop r18
    .endif

    ; normally, ISRs should be as short as possible and preserve CPU state. Since
    ; everything is done within this ISR, however, that's unnecessary.
    lds r18, TCNT3L
    lds r19, TCNT3H
    cpiw r18, r19, DISPLAY_CLK_TOP, r20
    brpl _loop_active_test2
    rjmp _loop_work
_loop_active_test2:
    cpiw r18, r19, DISPLAY_CLK_BOTTOM, r20
    brlo _loop_active_screen
    rjmp _loop_work
_loop_active_screen:
    ; output a single row from the framebuffer as quickly as reasonably possible.
    in XL, GPIOR0
    in XH, GPIOR1
    in r16, GPIOR2
    andi r16, 0x7f
    write_12_pixels PORTA, X
    write_12_pixels PORTA, X
    write_12_pixels PORTA, X
    write_12_pixels PORTA, X
    write_12_pixels PORTA, X
    write_12_pixels PORTA, X
    write_12_pixels PORTA, X
    write_12_pixels PORTA, X
    write_12_pixels PORTA, X
    write_12_pixels PORTA, X
    nop
    dec r16
    out PORTA, r1
    brpl _loop_quick_work
    out GPIOR0, XL
    out GPIOR1, XH
    ldi r16, DISPLAY_VERTICAL_STRETCH-1
_loop_quick_work:
    out GPIOR2, r16
    ; After writing a row to the screen, there's a brief period (~75 cycles) where
    ; we can do other work (this corresponds to the VGA front porch and sync pulse).
    rjmp _loop_end
_loop_work:
    in r16, GPIOR2
    sbrc r16, 7
    rjmp _loop_reset_render_state
    ori r16, 0x80
    out GPIOR2, r16
    ; At this point, we've rendered a complete image to the screen, and there's a
    ; fairly long gap (~99,300 cycles) where we fill the framebuffer and update
    ; the game. This corresponds to the VGA vertical front porch and sync pulse,
    ; in addition to the time we save with any blank rows (the latter is the most
    ; significant).
    ; heartbeat, used for syncing with the emulator
    in r0, PORTB
    ldi r16, 0x80
    eor r0, r16
    out PORTB, r0

    call rand
    clr r1

    lds r24, clock
    lds r25, clock+1
    adiw r24, 1
    sts clock, r24
    sts clock+1, r25

    call read_controls

    lds r18, game_mode
_loop_explore:
    cpi r18, MODE_EXPLORE
    brne _loop_inventory
    jmp explore_update_game
_loop_inventory:
    cpi r18, MODE_INVENTORY
    brne _loop_shop
    jmp inventory_update_game
_loop_shop:
    cpi r18, MODE_SHOPPING
    brne _loop_conversation
    jmp shop_update_game
_loop_conversation:
    cpi r18, MODE_CONVERSATION
    brne _loop_upgrade
    jmp conversation_update_game
_loop_upgrade:
    cpi r18, MODE_UPGRADE
    brne _loop_gameover
    jmp upgrade_update_game
_loop_gameover:
    cpi r18, MODE_GAMEOVER
    brne _loop_start
    jmp gameover_update_game
_loop_start:
    cpi r18, MODE_START
    brne _loop_character_selection
    jmp start_update_game
_loop_character_selection:
    cpi r18, MODE_CHARACTER
    brne _loop_intro
    jmp character_selection_update
_loop_intro:
    cpi r18, MODE_INTRO
    brne _loop_resume
    jmp intro_update_game
_loop_resume:
    cpi r18, MODE_RESUME
    brne _loop_about
    jmp resume_update_game
_loop_about:
    cpi r18, MODE_ABOUT
    brne _loop_help
    jmp about_update
_loop_help:
    cpi r18, MODE_HELP
    brne _loop_credits
    jmp help_update
_loop_credits:
    cpi r18, MODE_CREDITS
    brne _loop_reenter
    jmp credits_update

_loop_reenter:

_loop_reset_render_state:
    in r16, GPIOR2
    andi r16, 0x80
    ori r16, DISPLAY_VERTICAL_STRETCH
    out GPIOR2, r16
    ldi r16, low(framebuffer)
    ldi r17, high(framebuffer)
    out GPIOR0, r16
    out GPIOR1, r17
    sbi TIFR1, OCF1A ; clear any pending interrupts
_loop_end:
    ; exit from interrupt
    sei
    rjmp _main_stall

.include "math.asm"
.include "controls.asm"
.include "animation.asm"
.include "character.asm"
.include "battle.asm"
.include "render.asm"
.include "stats.asm"
.include "npc.asm"
.include "explore.asm"
.include "inventory.asm"
.include "shop.asm"
.include "conversation.asm"
.include "upgrade.asm"
.include "gameover.asm"
.include "credits.asm"
.include "start.asm"
.include "character_selection.asm"
.include "intro.asm"
.include "resume.asm"
.include "about.asm"
.include "tutorial.asm"
.include "logic.asm"
.include "rodata.asm"
.include "data.asm"

;
; .message "shop_update_game", shop_update_game*2
; .message "load_shop", load_shop*2
; .message "shop_handle_controls", shop_handle_controls*2
; .message "shop_buy_selected", shop_buy_selected*2
; .message "shop_sell_selected", shop_sell_selected*2
; .message "shop_render_game", shop_render_game*2
; .message "shop_determine_selection", shop_determine_selection*2
; .message "calculate_buy_price", calculate_buy_price*2
; .message "calculate_sell_price", calculate_sell_price*2
; .message "shop_most_valuable", shop_most_valuable*2
; .message "upgrade_update_game", upgrade_update_game*2
; .message "load_upgrade_if_necessary", load_upgrade_if_necessary*2
; .message "upgrade_handle_controls", upgrade_handle_controls*2
; .message "upgrade_render_game", upgrade_render_game*2
; .message "render_stat_selector", render_stat_selector*2
; .message "render_stat_progress", render_stat_progress*2
; .message "credits_update", credits_update*2
; .message "load_credits", load_credits*2
; .message "credits_handle_controls", credits_handle_controls*2
; .message "credits_render", credits_render*2
; .message "scrolling_text", scrolling_text*2
; .message "puts_outlined", puts_outlined*2
; .message "rand", rand*2
; .message "divmodb", divmodb*2
; .message "divmodw", divmodw*2
; .message "init", init*2
; .message "load_character_selection", load_character_selection*2
; .message "character_selection_update", character_selection_update*2
; .message "character_selection_controls", character_selection_controls*2
; .message "character_selection_render", character_selection_render*2
; .message "player_resolve_melee_damage", player_resolve_melee_damage*2
; .message "player_resolve_effect_damage", player_resolve_effect_damage*2
; .message "npc_resolve_melee_damage", npc_resolve_melee_damage*2
; .message "npc_resolve_ranged_damage", npc_resolve_ranged_damage*2
; .message "resolve_enemy_death", resolve_enemy_death*2
; .message "add_distant_npc", add_distant_npc*2
; .message "load_resume", load_resume*2
; .message "resume_update_game", resume_update_game*2
; .message "resume_try_load_save", resume_try_load_save*2
; .message "resume_handle_controls", resume_handle_controls*2
; .message "resume_render", resume_render*2
; .message "restart_game", restart_game*2
; .message "start_update_game", start_update_game*2
; .message "start_render_screen", start_render_screen*2
; .message "screen_fade_out", screen_fade_out*2
; .message "start_handle_controls", start_handle_controls*2
; .message "start_change", start_change*2
; .message "load_about", load_about*2
; .message "about_update", about_update*2
; .message "about_handle_controls", about_handle_controls*2
; .message "about_render", about_render*2
; .message "render_logo", render_logo*2
; .message "item_table", item_table*2
; .message "item_string_table", item_string_table*2
; .message "sector_table", sector_table*2
; .message "ui_item_selection_cursor", ui_item_selection_cursor*2
; .message "ui_heart_icon", ui_heart_icon*2
; .message "ui_small_heart_icon", ui_small_heart_icon*2
; .message "ui_coin_icon", ui_coin_icon*2
; .message "ui_small_coin_icon", ui_small_coin_icon*2
; .message "ui_string_table", ui_string_table*2
; .message "ui_str_inventory_instructions", ui_str_inventory_instructions*2
; .message "ui_str_level_up", ui_str_level_up*2
; .message "ui_str_points_remaining", ui_str_points_remaining*2
; .message "ui_str_strength", ui_str_strength*2
; .message "ui_str_vitality", ui_str_vitality*2
; .message "ui_str_dexterity", ui_str_dexterity*2
; .message "ui_str_intellect", ui_str_intellect*2
; .message "ui_str_damage_abbr", ui_str_damage_abbr*2
; .message "ui_str_defense_abbr", ui_str_defense_abbr*2
; .message "ui_str_strength_abbr", ui_str_strength_abbr*2
; .message "ui_str_vitality_abbr", ui_str_vitality_abbr*2
; .message "ui_str_dexterity_abbr", ui_str_dexterity_abbr*2
; .message "ui_str_intellect_abbr", ui_str_intellect_abbr*2
; .message "ui_str_buy_label", ui_str_buy_label*2
; .message "ui_str_sell_label", ui_str_sell_label*2
; .message "ui_str_you_died", ui_str_you_died*2
; .message "ui_str_death_retry", ui_str_death_retry*2
; .message "ui_str_death_restart", ui_str_death_restart*2
; .message "ui_str_death_retry", ui_str_death_retry*2
; .message "ui_str_death_restart", ui_str_death_restart*2
; .message "ui_credits_congrats", ui_credits_congrats*2
; .message "ui_credits_1", ui_credits_1*2
; .message "ui_credits_2", ui_credits_2*2
; .message "ui_credits_3", ui_credits_3*2
; .message "ui_credits_4", ui_credits_4*2
; .message "ui_credits_5", ui_credits_5*2
; .message "ui_credits_6", ui_credits_6*2
; .message "ui_credits_7", ui_credits_7*2
; .message "ui_credits_8", ui_credits_8*2
; .message "ui_credits_9", ui_credits_9*2
; .message "ui_credits_10", ui_credits_10*2
; .message "ui_str_start", ui_str_start*2
; .message "ui_str_resume", ui_str_resume*2
; .message "ui_str_help", ui_str_help*2
; .message "ui_str_about", ui_str_about*2
; .message "ui_str_choose_class", ui_str_choose_class*2
; .message "ui_str_choose_character", ui_str_choose_character*2
; .message "ui_str_man", ui_str_man*2
; .message "ui_str_woman", ui_str_woman*2
; .message "ui_str_halfling", ui_str_halfling*2
; .message "ui_str_no_save", ui_str_no_save*2
; .message "intro_str_1", intro_str_1*2
; .message "intro_str_2", intro_str_2*2
; .message "intro_str_3", intro_str_3*2
; .message "intro_str_4", intro_str_4*2
; .message "intro_str_5", intro_str_5*2
; .message "about_str", about_str*2
; .message "tutorial_move_str", tutorial_move_str*2
; .message "tutorial_pickup_str", tutorial_pickup_str*2
; .message "tutorial_shop_str", tutorial_shop_str*2
; .message "tutorial_inventory_str", tutorial_inventory_str*2
; .message "tutorial_fight_str", tutorial_fight_str*2
; .message "tutorial_move_str", tutorial_move_str*2
; .message "tutorial_pickup_str", tutorial_pickup_str*2
; .message "tutorial_shop_str", tutorial_shop_str*2
; .message "tutorial_inventory_str", tutorial_inventory_str*2
; .message "tutorial_fight_str", tutorial_fight_str*2
; .message "tutorial_talk_str", tutorial_talk_str*2
; .message "tutorial_next_str", tutorial_next_str*2
; .message "tutorial_save_str", tutorial_save_str*2
; .message "framebuffer", framebuffer*2
; .message "prev_controller_values", prev_controller_values*2
; .message "controller_values", controller_values*2
; .message "savedmem_start", savedmem_start*2
; .message "clock", clock*2
; .message "mode_clock", mode_clock*2
; .message "seed", seed*2
; .message "game_mode", game_mode*2
; .message "current_sector", current_sector*2
; .message "camera_position_x", camera_position_x*2
; .message "camera_position_y", camera_position_y*2
; .message "player_class", player_class*2
; .message "player_position_data", player_position_data*2
; .message "player_position_x", player_position_x*2
; .message "player_subpixel_x", player_subpixel_x*2
; .message "player_velocity_x", player_velocity_x*2
; .message "player_position_y", player_position_y*2
; .message "player_subpixel_y", player_subpixel_y*2
; .message "player_velocity_y", player_velocity_y*2
; .message "player_attack_cooldown", player_attack_cooldown*2
; .message "player_dash_cooldown", player_dash_cooldown*2
; .message "player_dash_direction", player_dash_direction*2
; .message "player_character", player_character*2
; .message "player_weapon", player_weapon*2
; .message "player_armor", player_armor*2
; .message "player_direction", player_direction*2
; .message "player_action", player_action*2
; .message "player_frame", player_frame*2
; .message "player_effect", player_effect*2
; .message "player_stats", player_stats*2
; .message "player_augmented_stats", player_augmented_stats*2
; .message "player_health", player_health*2
; .message "player_gold", player_gold*2
; .message "player_xp", player_xp*2
; .message "player_effects", player_effects*2
; .message "player_inventory", player_inventory*2
; .message "sector_data", sector_data*2
; .message "global_data", global_data*2
; .message "preplaced_item_presence", preplaced_item_presence*2
; .message "npc_presence", npc_presence*2
; .message "conversation_over", conversation_over*2
; .message "savedmem_end", savedmem_end*2
; .message "sector_npcs", sector_npcs*2
; .message "following_spawn_x", following_spawn_x*2
; .message "following_spawn_y", following_spawn_y*2
; .message "following_timer", following_timer*2
; .message "following_npcs", following_npcs*2
; .message "savepoint_used", savepoint_used*2
; .message "savepoint_data", savepoint_data*2
; .message "savepoint_progress", savepoint_progress*2
; .message "sector_loose_items", sector_loose_items*2
; .message "active_effects", active_effects*2
; .message "current_shop_index", current_shop_index*2
; .message "shop_inventory", shop_inventory*2
; .message "start_selection", start_selection*2
; .message "inventory_selection", inventory_selection*2
; .message "shop_selection", shop_selection*2
; .message "selected_choice", selected_choice*2
; .message "upgrade_selection", upgrade_selection*2
; .message "npc_move_flags", npc_move_flags*2
; .message "gameover_state", gameover_state*2
; .message "npc_move_flags2", npc_move_flags2*2
; .message "lightning_clock", lightning_clock*2
; .message "conversation_frame", conversation_frame*2
; .message "conversation_chars", conversation_chars*2
; .message "upgrade_points", upgrade_points*2
; .message "character_render", character_render*2
; .message "subroutine_tmp", subroutine_tmp*2
; .message "end_game_allocs", end_game_allocs*2
; .message "animated_item_table", animated_item_table*2
; .message "animated_item_sprite_table", animated_item_sprite_table*2
; .message "static_item_sprite_table", static_item_sprite_table*2
; .message "static_item_gold_sprite", static_item_gold_sprite*2
; .message "tile_table", tile_table*2
; .message "shop_table", shop_table*2
; .message "shop_string_table", shop_string_table*2
; .message "effect_damage_sprites", effect_damage_sprites*2
; .message "effect_healing_sprites", effect_healing_sprites*2
; .message "effect_potion_sprites", effect_potion_sprites*2
; .message "effect_upgrade_sprites", effect_upgrade_sprites*2
; .message "effect_arrow_sprites", effect_arrow_sprites*2
; .message "effect_fireball_sprites", effect_fireball_sprites*2
; .message "effect_missile_sprites", effect_missile_sprites*2
; .message "savepoint_sprites", savepoint_sprites*2
; .message "character_icon_shadow", character_icon_shadow*2
; .message "fade_table", fade_table*2
; .message "feature_sprites", feature_sprites*2
; .message "win_screen", win_screen*2
; .message "title_screen", title_screen*2
; .message "parchment_screen", parchment_screen*2
; .message "intro_screen", intro_screen*2
; .message "logo_image", logo_image*2
; .message "conversation_table", conversation_table*2
; .message "conversation_string_table", conversation_string_table*2
; .message "font_character_table", font_character_table*2
; .message "small_font_character_table", small_font_character_table*2
; .message "class_table", class_table*2
; .message "character_sprite_table", character_sprite_table*2
; .message "static_character_sprite_table", static_character_sprite_table*2
; .message "npc_table", npc_table*2
; .message "read_controls", read_controls*2
; .message "estimated_effect_ranges", estimated_effect_ranges*2
; .message "npc_move", npc_move*2
; .message "npc_update", npc_update*2
; .message "enemy_sector_bounds", enemy_sector_bounds*2
; .message "enemy_personal_space", enemy_personal_space*2
; .message "enemy_fighting_space", enemy_fighting_space*2
; .message "corpse_update", corpse_update*2
; .message "inventory_update_game", inventory_update_game*2
; .message "load_inventory", load_inventory*2
; .message "inventory_handle_controls", inventory_handle_controls*2
; .message "inventory_equip_item", inventory_equip_item*2
; .message "inventory_use_item", inventory_use_item*2
; .message "inventory_drop_item", inventory_drop_item*2
; .message "inventory_render_game", inventory_render_game*2
; .message "render_item_stat", render_item_stat*2
; .message "conversation_update_game", conversation_update_game*2
; .message "conversation_handle_controls", conversation_handle_controls*2
; .message "load_conversation", load_conversation*2
; .message "conversation_render_game", conversation_render_game*2
; .message "clear_sector_data", clear_sector_data*2
; .message "add_npc", add_npc*2
; .message "add_npc_direct", add_npc_direct*2
; .message "find_npc", find_npc*2
; .message "release_if_damaged", release_if_damaged*2
; .message "spawn_distant_npcs", spawn_distant_npcs*2
; .message "drop_item", drop_item*2
; .message "calculate_player_stats", calculate_player_stats*2
; .message "update_player_stat_effects", update_player_stat_effects*2
; .message "update_player_health", update_player_health*2
; .message "calculate_max_health", calculate_max_health*2
; .message "calculate_acceleration", calculate_acceleration*2
; .message "calculate_push_acceleration", calculate_push_acceleration*2
; .message "calculate_push_resistance", calculate_push_resistance*2
; .message "calculate_dash_cooldown", calculate_dash_cooldown*2
; .message "init_player_stats", init_player_stats*2
; .message "load_help", load_help*2
; .message "load_tutorial", load_tutorial*2
; .message "help_update", help_update*2
; .message "determine_character_sprite", determine_character_sprite*2
; .message "determine_weapon_sprite", determine_weapon_sprite*2
; .message "determine_armor_sprite", determine_armor_sprite*2
; .message "write_entire_tile", write_entire_tile*2
; .message "write_partial_tile", write_partial_tile*2
; .message "write_12x12_sprite", write_12x12_sprite*2
; .message "write_sprite", write_sprite*2
; .message "write_sprite_flip_x", write_sprite_flip_x*2
; .message "write_sprite_flip_y", write_sprite_flip_y*2
; .message "write_sprite_flip_xy", write_sprite_flip_xy*2
; .message "render_sector", render_sector*2
; .message "render_sprite", render_sprite*2
; .message "render_character", render_character*2
; .message "render_character_icon", render_character_icon*2
; .message "render_effect_animation", render_effect_animation*2
; .message "render_item_icon", render_item_icon*2
; .message "putc", putc*2
; .message "putc_small", putc_small*2
; .message "putb", putb*2
; .message "putb_small", putb_small*2
; .message "putw", putw*2
; .message "putw_small", putw_small*2
; .message "puts", puts*2
; .message "puts_n", puts_n*2
; .message "render_element", render_element*2
; .message "render_rect", render_rect*2
; .message "render_effect_progress", render_effect_progress*2
; .message "render_item_with_underbar", render_item_with_underbar*2
; .message "render_full_screen", render_full_screen*2
; .message "render_partial_screen", render_partial_screen*2
; .message "fade_text", fade_text*2
; .message "fade_text_inverse", fade_text_inverse*2
; .message "load_intro", load_intro*2
; .message "intro_update_game", intro_update_game*2
; .message "intro_handle_controls", intro_handle_controls*2
; .message "intro_render", intro_render*2
; .message "main", main*2
; .message "isr_loop", isr_loop*2
; .message "tutorial_update", tutorial_update*2
; .message "sector_start_1_update", sector_start_1_update*2
; .message "sector_start_2_update", sector_start_2_update*2
; .message "sector_start_fight_update", sector_start_fight_update*2
; .message "sector_start_fight_choice", sector_start_fight_choice*2
; .message "sector_town_entrance_1_update", sector_town_entrance_1_update*2
; .message "sector_town_entrance_1_conversation", sector_town_entrance_1_conversation*2
; .message "sector_town_entrance_1_choice", sector_town_entrance_1_choice*2
; .message "sector_town_wolves_update", sector_town_wolves_update*2
; .message "sector_start_post_fight_update", sector_start_post_fight_update*2
; .message "sector_start_post_fight_conversation", sector_start_post_fight_conversation*2
; .message "sector_town_tavern_1_update", sector_town_tavern_1_update*2
; .message "sector_town_tavern_2_update", sector_town_tavern_2_update*2
; .message "sector_town_tavern_2_conversation", sector_town_tavern_2_conversation*2
; .message "sector_town_tavern_2_choice", sector_town_tavern_2_choice*2
; .message "sector_town_fields_init", sector_town_fields_init*2
; .message "sector_town_fields_update", sector_town_fields_update*2
; .message "sector_town_forest_path_2_init", sector_town_forest_path_2_init*2
; .message "sector_town_forest_path_2_update", sector_town_forest_path_2_update*2
; .message "sector_town_forest_path_4_update", sector_town_forest_path_4_update*2
; .message "sector_town_forest_path_5_init", sector_town_forest_path_5_init*2
; .message "sector_town_den_2_init", sector_town_den_2_init*2
; .message "sector_town_den_2_update", sector_town_den_2_update*2
; .message "sector_start_pretown_2_update", sector_start_pretown_2_update*2
; .message "sector_start_pretown_2_choice", sector_start_pretown_2_choice*2
; .message "sector_river_hidden_house_choice", sector_river_hidden_house_choice*2
; .message "sector_deep_forest_update", sector_deep_forest_update*2
; .message "sector_deep_forest_init", sector_deep_forest_init*2
; .message "sector_underground_update", sector_underground_update*2
; .message "sector_fields_update", sector_fields_update*2
; .message "sector_fields_init", sector_fields_init*2
; .message "sector_final_2_update", sector_final_2_update*2
; .message "sector_city_shop_1_choice", sector_city_shop_1_choice*2
; .message "sector_city_4_init", sector_city_4_init*2
; .message "sector_city_4_conversation", sector_city_4_conversation*2
; .message "sector_city_4_choice", sector_city_4_choice*2
; .message "sector_city_bank_1_update", sector_city_bank_1_update*2
; .message "sector_city_bank_2_init", sector_city_bank_2_init*2
; .message "sector_city_bank_3_update", sector_city_bank_3_update*2
; .message "sector_city_bank_4_update", sector_city_bank_4_update*2
; .message "sector_city_robbers_den_update", sector_city_robbers_den_update*2
; .message "sector_city_robbers_den_conversation", sector_city_robbers_den_conversation*2
; .message "sector_city_robbers_den_choice", sector_city_robbers_den_choice*2
; .message "sector_city_robbers_den_2_init", sector_city_robbers_den_2_init*2
; .message "sector_final_castle_init", sector_final_castle_init*2
; .message "sector_final_battle_init", sector_final_battle_init*2
; .message "sector_final_battle_update", sector_final_battle_update*2
; .message "gameover_update_game", gameover_update_game*2
; .message "load_gameover", load_gameover*2
; .message "gameover_handle_controls", gameover_handle_controls*2
; .message "gameover_render_game", gameover_render_game*2
; .message "gameover_render_dead", gameover_render_dead*2
; .message "gameover_render_win", gameover_render_win*2
; .message "gameover_text", gameover_text*2
; .message "gfs_lightning", gfs_lightning*2
; .message "gameover_lightning", gameover_lightning*2
; .message "move_character", move_character*2
; .message "update_character_animation", update_character_animation*2
; .message "biased_character_distance", biased_character_distance*2
; .message "character_striking_distance", character_striking_distance*2
; .message "init_game_state", init_game_state*2
; .message "explore_update_game", explore_update_game*2
; .message "render_game", render_game*2
; .message "render_npc_health_bar", render_npc_health_bar*2
; .message "handle_controls", handle_controls*2
; .message "handle_main_button", handle_main_button*2
; .message "reset_camera", reset_camera*2
; .message "player_dash", player_dash*2
; .message "player_attack", player_attack*2
; .message "update_active_effects", update_active_effects*2
; .message "update_savepoint_animation", update_savepoint_animation*2
; .message "update_savepoint", update_savepoint*2
; .message "restore_from_savepoint", restore_from_savepoint*2
; .message "add_active_effect", add_active_effect*2
; .message "update_player", update_player*2
; .message "check_sector_bounds", check_sector_bounds*2
; .message "load_sector", load_sector*2
; .message "load_npc", load_npc*2
; .message "move_camera", move_camera*2
; .message "update_followers", update_followers*2
; .message "update_npcs", update_npcs*2
; .message "sort_npcs", sort_npcs*2
; .message "add_nearby_followers", add_nearby_followers*2
