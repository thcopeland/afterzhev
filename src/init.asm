init:
    clr r1
    stiw vid_fbuff_offset, framebuffer
    sti vid_row_repeat, 0
    sti vid_work_complete, 0
    stiw current_sector, 2*sector_table
    sti camera_position_x, 00
    sti camera_position_y, 12
    sti player_position_x, 10
    sti player_position_y, 40
    sti player_velocity_x, 0
    sti player_velocity_y, 0
    sti player_class, CLASS_HALFLING
    sti player_character, 0
    sti player_weapon, 1
    sti player_armor, 0
    sti player_action, ACTION_WALK
    sti player_direction, DIRECTION_DOWN
    sti player_frame, 0
    sti player_effect, 0
    ldi XL, low(player_inventory)
    ldi XH, high(player_inventory)
    ldi r18, PLAYER_INVENTORY_SIZE
_init_clear_inventory_iter:
    st X+, r1
    dec r18
    brne _init_clear_inventory_iter
    ldi XL, low(player_effects)
    ldi XH, high(player_effects)
    ldi r18, PLAYER_EFFECT_COUNT
_init_clear_effects_iter:
    st X+, r1
    st X+, r1
    dec r18
    brne _init_clear_effects_iter
    sti player_inventory, 2
    sti player_inventory+2, 4
    sti player_inventory+10, 5
    sti player_inventory+1, 6
    sti player_stats, 10
    sti player_stats+1, 10
    sti player_stats+2, 20
    sti player_stats+3, 10
    call calculate_player_stats
    stiw player_gold, 1600
    sti player_health, 40
    stiw player_xp, 300
    sti game_mode, MODE_EXPLORE
    sti inventory_selection, 0
    stiw preplaced_item_presence, 0xffff
    stiw npc_presence, 0xffff
    sti clock, 0
    sti mode_clock, 0
    sti current_shop_index, 0xff
    stiw conversation_over, 0xffff
    stiw seed, 1
    sti gameover_state, 0xc0

    sti active_effects, 0b00010000
    sti active_effects+1, 30
    sti active_effects+2, 40

    ldi ZL, byte3(2*sector_table)
    out RAMPZ, ZL
    ldi ZL, low(2*sector_table)
    ldi ZH, high(2*sector_table)
    call load_sector

    rjmp main
