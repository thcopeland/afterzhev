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
    stiw current_sector, 2*sector_table
    sti camera_position_x, 00
    sti camera_position_y, 12
    sti player_position_x, 70
    sti player_position_y, 50
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
    sti player_inventory, 2
    sti player_inventory+2, 4
    sti player_inventory+10, 5
    sti player_inventory+1, 6
    sti player_stats, 10
    sti player_stats+1, 10
    sti player_stats+2, 10
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
    sti current_shop_index, NO_SHOP
    stiw conversation_over, 0xffff
    sti savepoint_used, 0x00
    stiw seed, 1
    sti gameover_state, 0xc0

    ldi ZL, byte3(2*sector_table)
    out RAMPZ, ZL
    ldi ZL, low(2*sector_table)
    ldi ZH, high(2*sector_table)
    call load_sector

    rjmp main
