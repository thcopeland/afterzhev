init:
    clr r1

    ; clear all RAM beyond the framebuffer
_init_zero:
    ldi XL, low(framebuffer + DISPLAY_WIDTH*DISPLAY_HEIGHT)
    ldi XH, high(framebuffer + DISPLAY_WIDTH*DISPLAY_HEIGHT)
    ldi r24, low(RAMEND)
    ldi r25, high(RAMEND)
    sub r24, XL
    sbc r25, XH
_init_zero_iter:
    st X+, r1
    sbiw r24, 1
    brne _init_zero_iter

    ldi r16, low(framebuffer)
    ldi r17, high(framebuffer)
    out GPIOR0, r16 ; stores the video framebuffer offset (low)
    out GPIOR1, r17 ; stores the video framebuffer offset (high)
    out GPIOR2, r1  ; video frame status
    sti player_position_x, 156
    sti player_position_y, 35
    call reset_camera
    sti player_velocity_x, 0
    sti player_velocity_y, 0
    sti player_class, CLASS_ROGUE
    sti player_character, CHARACTER_HALFLING
    sti player_weapon, ITEM_iron_staff ;ITEM_steel_sword
    sti player_armor, ITEM_iron_breastplate; ITEM_leather_armor
    sti player_inventory, ITEM_health_potion
    sti player_inventory+1, ITEM_whiskey
    sti player_inventory+2, ITEM_pass
    sti player_inventory+3, ITEM_journal
    sti player_inventory+4, ITEM_glass_staff
    sti player_inventory+5, ITEM_large_health_potion
    sti player_inventory+6, ITEM_mint_tonic
    sti player_inventory+7, ITEM_mint_leaves
    sti player_inventory+8, ITEM_bismuth_subsalicylate
    sti player_inventory+9, ITEM_strength_potion
    sti player_action, ACTION_WALK
    sti player_direction, DIRECTION_LEFT
    sti player_frame, 0
    sti player_effect, 0
    sti player_stats, 4
    sti player_stats+1, 8
    sti player_stats+2, 60
    sti player_stats+3, 10
    call calculate_player_stats
    stiw player_gold, 0
    sti player_health, 64
    stiw player_xp, 0
    sti game_mode, MODE_EXPLORE
    sti inventory_selection, 0
    stiw preplaced_item_presence, 0xffff
    stiw npc_presence, 0xffff
    stiw npc_presence+2, 0xffff
    stiw npc_presence+4, 0xffff
    stiw npc_presence+6, 0xffff
    stiw npc_presence+8, 0xffff
    stiw npc_presence+10, 0xffff
    sti clock, 0
    sti mode_clock, 0
    sti current_shop_index, NO_SHOP
    stiw conversation_over, 0xffff
    sti conversation_over+2, 0xff
    sti savepoint_used, 0x00
    stiw seed, 1
    sti gameover_state, 0xc0

    ldi ZL, byte3(2*sector_table)
    out RAMPZ, ZL
    sti player_position_x, 12
    sti player_position_y, 98
    call reset_camera
    .equ INITIAL_SECTOR = SECTOR_CITY_1
    ldi ZL, low(2*sector_table+INITIAL_SECTOR*SECTOR_MEMSIZE)
    ldi ZH, high(2*sector_table+INITIAL_SECTOR*SECTOR_MEMSIZE)
    call load_sector

    rjmp main
