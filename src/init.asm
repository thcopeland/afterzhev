init:
    clr r1
_clear_memory:
    ldi XL, low(framebuffer + DISPLAY_WIDTH*DISPLAY_HEIGHT)
    ldi XH, high(framebuffer + DISPLAY_WIDTH*DISPLAY_HEIGHT)
    ldi r24, low(RAMEND - (framebuffer + DISPLAY_WIDTH*DISPLAY_HEIGHT))
    ldi r25, high(RAMEND - (framebuffer + DISPLAY_WIDTH*DISPLAY_HEIGHT))
_clear_memory_loop:
    st X+, r1
    sbiw r24, 1
    brne _clear_memory_loop
    ldi r24, low(framebuffer)
    ldi r25, high(framebuffer)
    out GPIOR0, r24 ; stores the video framebuffer offset (low)
    out GPIOR1, r25 ; stores the video framebuffer offset (high)
    out GPIOR2, r1  ; video frame status
    ldi r25, 1
    sts seed, r25
    sts seed+1, r1
    sts start_selection, r1
    call restart_game

    ; call init_game_state
    ; ldi r25, MODE_EXPLORE
    ; sts game_mode, r25
    ;
    ; ldi r25, ITEM_wood_staff
    ; sts player_weapon, r25
    ;
    ; ldi r25, ITEM_glass_staff
    ; sts player_inventory, r25
    ;
    ; ldi r25, 60
    ; sts player_stats+STATS_VITALITY_OFFSET, r25
    ;
    ; ldi r25, ITEM_leather_armor
    ; sts player_armor, r25
    ;
    ; ldi r25, 80
    ; sts player_position_x, r25
    ; ldi r25, 90
    ; sts player_position_y, r25
    ; call reset_camera
    ;
    ; ldi ZL, byte3(2*sector_table)
    ; out RAMPZ, ZL
    ; .equ SECTOR = SECTOR_TOWN_DEN
    ; ldi ZL, low(2*sector_table + SECTOR*SECTOR_MEMSIZE)
    ; ldi ZH, high(2*sector_table + SECTOR*SECTOR_MEMSIZE)
    ; call load_sector

    rjmp main
