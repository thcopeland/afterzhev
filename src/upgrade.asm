upgrade_update_game:
    rcall upgrade_render_game
    rcall upgrade_handle_controls
    jmp _loop_reenter

; Switch to the level up game mode if the player has gained enough XP to advance.
; If not, this does nothing.
;
; Register Usage
;   r22-r25     calculations
load_upgrade_if_necessary:
    lds r23, player_class
    swap r23
    andi r23, 0xf
    lds r24, player_xp
    lds r25, player_xp+1
_luin_level_0:
    cpi r23, 0
    brne _luin_level_1
    cpiw r24, r25, LEVEL_1_XP, r22
    brlo _luin_end
    ldi r25, UPGRADE_1_POINTS
    sts upgrade_points, r25
    rjmp _luin_level_up
_luin_level_1:
    cpi r23, 1
    brne _luin_level_2
    cpiw r24, r25, LEVEL_2_XP, r22
    brlo _luin_end
    ldi r25, UPGRADE_2_POINTS
    sts upgrade_points, r25
    rjmp _luin_level_up
_luin_level_2:
    cpi r23, 2
    brne _luin_end
    cpiw r24, r25, LEVEL_3_XP, r22
    brlo _luin_end
    ldi r25, UPGRADE_3_POINTS
    sts upgrade_points, r25
_luin_level_up:
    inc r23
    swap r23
    lds r24, player_class
    andi r24, 0xf
    or r23, r24
    sts player_class, r23
    sts upgrade_selection, r1
    sts player_augmented_stats+STATS_STRENGTH_OFFSET, r1
    sts player_augmented_stats+STATS_DEXTERITY_OFFSET, r1
    sts player_augmented_stats+STATS_VITALITY_OFFSET, r1
    sts player_augmented_stats+STATS_INTELLECT_OFFSET, r1
    ldi r25, MODE_UPGRADE
    sts game_mode, r25
_luin_end:
    ret

; Handle all player input. UP and DOWN are used to select the statistics, LEFT
; and RIGHT are used to decrement/increment the statistic, and the four special
; buttons are used to exit, if there are no ability points left.
;
; Register Usage
;   r18-r19         controller
;   r21-r21         calculations
upgrade_handle_controls:
    lds r18, prev_controller_values
    lds r19, controller_values
    com r18
    and r18, r19
    breq _uhc_no_recent_keydowns
    sts mode_clock, r1
    rjmp _uhc_check_keys
_uhc_no_recent_keydowns:
    lds r20, mode_clock
    inc r20
    sts mode_clock, r20
    andi r20, 15
    breq _uhc_check_keys
    ret
_uhc_check_keys:
_uhc_up:
    sbrs r19, CONTROLS_UP
    rjmp _uhc_down
    lds r20, upgrade_selection
    dec r20
    brmi _uhc_down
    sts upgrade_selection, r20
_uhc_down:
    sbrs r19, CONTROLS_DOWN
    rjmp _uhc_left
    lds r20, upgrade_selection
    cpi r20, 3
    brsh _uhc_left
    inc r20
    sts upgrade_selection, r20
_uhc_left:
    sbrs r19, CONTROLS_LEFT
    rjmp _uhc_right
    lds r20, upgrade_selection
    ldi ZL, low(player_augmented_stats)
    ldi ZH, high(player_augmented_stats)
    add ZL, r20
    adc ZH, r1
    ld r20, Z
    dec r20
    brmi _uhc_right
    st Z, r20
    lds r20, upgrade_points
    inc r20
    sts upgrade_points, r20
_uhc_right:
    sbrs r19, CONTROLS_RIGHT
    rjmp _uhc_other
    lds r20, upgrade_points
    dec r20
    brmi _uhc_other
    sts upgrade_points, r20
    lds r20, upgrade_selection
    ldi ZL, low(player_augmented_stats)
    ldi ZH, high(player_augmented_stats)
    add ZL, r20
    adc ZH, r1
    ld r20, Z
    inc r20
    st Z, r20
_uhc_other:
    andi r18, (1<<CONTROLS_SPECIAL1)|(1<<CONTROLS_SPECIAL2)|(1<<CONTROLS_SPECIAL3)|(1<<CONTROLS_SPECIAL4)
    breq _uhc_end
    lds r20, upgrade_points
    tst r20
    brne _uhc_end
    lds r20, player_augmented_stats+STATS_STRENGTH_OFFSET
    lds r21, player_stats+STATS_STRENGTH_OFFSET
    add r20, r21
    sts player_stats+STATS_STRENGTH_OFFSET, r20
    lds r20, player_augmented_stats+STATS_VITALITY_OFFSET
    lds r21, player_stats+STATS_VITALITY_OFFSET
    add r20, r21
    sts player_stats+STATS_VITALITY_OFFSET, r20
    lds r20, player_augmented_stats+STATS_DEXTERITY_OFFSET
    lds r21, player_stats+STATS_DEXTERITY_OFFSET
    add r20, r21
    sts player_stats+STATS_DEXTERITY_OFFSET, r20
    lds r20, player_augmented_stats+STATS_INTELLECT_OFFSET
    lds r21, player_stats+STATS_INTELLECT_OFFSET
    add r20, r21
    sts player_stats+STATS_INTELLECT_OFFSET, r20
    ldi r20, MODE_EXPLORE
    sts game_mode, r20
    call calculate_player_stats
    call calculate_max_health
    sts player_health, r25
_uhc_end:
    ret

.equ UPGRADE_UI_HEADER_HEIGHT = INVENTORY_UI_HEADER_HEIGHT
.equ UPGRADE_UI_HEADER_COLOR = INVENTORY_UI_HEADER_COLOR
.equ UPGRADE_UI_HEADER_TEXT_MARGIN = DISPLAY_WIDTH*2+44
.equ UPGRADE_UI_BODY_COLOR = INVENTORY_UI_BODY_COLOR
.equ UPGRADE_UI_REMAINING_MARGIN = DISPLAY_WIDTH*59+16
.equ UPGRADE_UI_STATS_MARGIN = DISPLAY_WIDTH*13+6
.equ UPGRADE_UI_STAT_BAR_MARGIN = UPGRADE_UI_STATS_MARGIN+DISPLAY_WIDTH*2+38
.equ UPGRADE_UI_STAT_SPACING = DISPLAY_WIDTH*11

; Render the upgrade screen.
;
; Register Usage
;   r20-r25         calculations
;   X (r26:r27)     framebuffer pointer
;   Y (r28:r29)     another framebuffer pointer
;   Z (r30:r31)     framebuffer pointer, memory pointer
upgrade_render_game:
_urg_background:
    ldi XL, low(framebuffer)
    ldi XH, high(framebuffer)
    ldi r22, UPGRADE_UI_HEADER_COLOR
    ldi r24, DISPLAY_WIDTH
    ldi r25, UPGRADE_UI_HEADER_HEIGHT
    call render_rect
    ldi XL, low(framebuffer+INVENTORY_UI_HEADER_HEIGHT*DISPLAY_WIDTH)
    ldi XH, high(framebuffer+INVENTORY_UI_HEADER_HEIGHT*DISPLAY_WIDTH)
    ldi r22, UPGRADE_UI_BODY_COLOR
    ldi r24, DISPLAY_WIDTH
    ldi r25, DISPLAY_HEIGHT-UPGRADE_UI_HEADER_HEIGHT
    call render_rect
_urg_render_header_text:
    ldi YL, low(framebuffer+UPGRADE_UI_HEADER_TEXT_MARGIN)
    ldi YH, high(framebuffer+UPGRADE_UI_HEADER_TEXT_MARGIN)
    ldi ZL, byte3(2*ui_str_level_up)
    out RAMPZ, ZL
    ldi ZL, low(2*ui_str_level_up)
    ldi ZH, high(2*ui_str_level_up)
    ldi r21, 10
    clr r23
    call puts
_urg_render_strength:
    ldi YL, low(framebuffer+UPGRADE_UI_STATS_MARGIN)
    ldi YH, high(framebuffer+UPGRADE_UI_STATS_MARGIN)
    movw XL, YL
    ldi r25, STATS_STRENGTH_OFFSET
    rcall render_stat_selector
    ldi ZL, low(2*ui_str_strength)
    ldi ZH, high(2*ui_str_strength)
    ldi r21, 10
    call puts
    ldi XL, low(framebuffer+UPGRADE_UI_STAT_BAR_MARGIN)
    ldi XH, high(framebuffer+UPGRADE_UI_STAT_BAR_MARGIN)
    ldi r24, STATS_STRENGTH_COLOR
    ldi r25, STATS_STRENGTH_OFFSET
    rcall render_stat_progress
_urg_render_vitality:
    ldi YL, low(framebuffer+UPGRADE_UI_STATS_MARGIN+UPGRADE_UI_STAT_SPACING)
    ldi YH, high(framebuffer+UPGRADE_UI_STATS_MARGIN+UPGRADE_UI_STAT_SPACING)
    movw XL, YL
    ldi r25, STATS_VITALITY_OFFSET
    rcall render_stat_selector
    ldi ZL, low(2*ui_str_vitality)
    ldi ZH, high(2*ui_str_vitality)
    ldi r21, 10
    call puts
    ldi XL, low(framebuffer+UPGRADE_UI_STAT_BAR_MARGIN+UPGRADE_UI_STAT_SPACING)
    ldi XH, high(framebuffer+UPGRADE_UI_STAT_BAR_MARGIN+UPGRADE_UI_STAT_SPACING)
    ldi r24, STATS_VITALITY_COLOR
    ldi r25, STATS_VITALITY_OFFSET
    rcall render_stat_progress
_urg_render_dexterity:
    ldi YL, low(framebuffer+UPGRADE_UI_STATS_MARGIN+2*UPGRADE_UI_STAT_SPACING)
    ldi YH, high(framebuffer+UPGRADE_UI_STATS_MARGIN+2*UPGRADE_UI_STAT_SPACING)
    movw XL, YL
    ldi r25, STATS_DEXTERITY_OFFSET
    rcall render_stat_selector
    ldi ZL, low(2*ui_str_dexterity)
    ldi ZH, high(2*ui_str_dexterity)
    ldi r21, 10
    call puts
    ldi XL, low(framebuffer+UPGRADE_UI_STAT_BAR_MARGIN+2*UPGRADE_UI_STAT_SPACING)
    ldi XH, high(framebuffer+UPGRADE_UI_STAT_BAR_MARGIN+2*UPGRADE_UI_STAT_SPACING)
    ldi r24, STATS_DEXTERITY_COLOR
    ldi r25, STATS_DEXTERITY_OFFSET
    rcall render_stat_progress
_urg_render_intellect:
    ldi YL, low(framebuffer+UPGRADE_UI_STATS_MARGIN+3*UPGRADE_UI_STAT_SPACING)
    ldi YH, high(framebuffer+UPGRADE_UI_STATS_MARGIN+3*UPGRADE_UI_STAT_SPACING)
    movw XL, YL
    ldi r25, STATS_INTELLECT_OFFSET
    rcall render_stat_selector
    ldi ZL, low(2*ui_str_intellect)
    ldi ZH, high(2*ui_str_intellect)
    ldi r21, 10
    call puts
    ldi XL, low(framebuffer+UPGRADE_UI_STAT_BAR_MARGIN+3*UPGRADE_UI_STAT_SPACING)
    ldi XH, high(framebuffer+UPGRADE_UI_STAT_BAR_MARGIN+3*UPGRADE_UI_STAT_SPACING)
    ldi r24, STATS_INTELLECT_COLOR
    ldi r25, STATS_INTELLECT_OFFSET
    rcall render_stat_progress
_urg_render_remaining_points:
    ldi YL, low(framebuffer+UPGRADE_UI_REMAINING_MARGIN)
    ldi YH, high(framebuffer+UPGRADE_UI_REMAINING_MARGIN)
    ldi ZL, low(2*ui_str_points_remaining)
    ldi ZH, high(2*ui_str_points_remaining)
    ldi r21, 22
    clr r23
    call puts
    ldi XL, low(framebuffer+UPGRADE_UI_REMAINING_MARGIN)
    ldi XH, high(framebuffer+UPGRADE_UI_REMAINING_MARGIN)
    lds r21, upgrade_points
    call putb
    ret

; Render an indicator to show whether a stat is selected.
;
; Register Usage
;   r25             current stat num (param)
;   X (r26:r30)     framebuffer pointer (param)
render_stat_selector:
    lds r20, upgrade_selection
    cp r20, r25
    breq _rss_selected
    clr r23
    ret
_rss_selected:
    subi XL, low(5*FONT_DISPLAY_WIDTH/3-1)
    sbci XH, high(5*FONT_DISPLAY_WIDTH/3-1)
    ldi r22, 128
    ldi r23, 0x04
    call putc
    ret

; Render a stat progressbar, showing the base stat and the upgrade.
;
; Register Usage
;   r20-r23         calculations
;   r24             color (param)
;   r25             stat number (param)
;   X (r26:r27)     framebuffer pointer (param)
;   Z (r30:r31)     second framebuffer pointer
render_stat_progress:
    ldi ZL, low(player_stats)
    ldi ZH, high(player_stats)
    add ZL, r25
    adc ZH, r1
    ld r20, Z
    subi ZL, low(player_stats-player_augmented_stats)
    sbci ZH, high(player_stats-player_augmented_stats)
    ld r21, Z
    movw ZL, XL
    subi ZL, low(-DISPLAY_WIDTH)
    sbci ZH, high(-DISPLAY_WIDTH)
    mov r25, r24
    andi r25, 0xb6
    lsr r25
    ldi r22, 150
    mul r20, r22
    lsl r0
    rol r1
    lsl r0
    rol r1
_rsp_base_iter:
    st X+, r24
    st Z+, r25
    dec r1
    brne _rsp_base_iter
    tst r21
    breq _rsp_total
    mov r25, r24
    ori r24, 0x49
    mul r21, r22
    lsl r0
    rol r1
    lsl r0
    rol r1
_rsp_aug_iter:
    st X+, r24
    st Z+, r25
    dec r1
    brne _rsp_aug_iter
_rsp_total:
    subi XL, low(DISPLAY_WIDTH-6)
    sbci XH, high(DISPLAY_WIDTH-6)
    add r21, r20
    call putb_small
    ret
