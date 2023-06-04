; The complex game logic and interactions are governed by a pair of handler
; subroutines specific to each sector. The first subroutine is called once at the
; end of every frame and should update NPCs and whatnot. The second subroutine
; is called whenever an event occurs, such as a sector being loaded or the player
; making a conversation choice.
;
; The idea is that the majority of sectors will be fairly consistent: NPCs will
; patrol until the player gets close, conversations simply convey information
; without actually affecting game state, and so on. Some sectors will require
; more complex behavior, however, such as quests, talking to enemies, the final
; boss fight, etc. We can support all these features relatively simply by allowing
; each sector to determine its own logic. This is not the best way to achieve this,
; but it is probably one of the most flexible and should be all right for a small
; game.
;
; Register Usage (approximate, just what I've checked)
;   update subroutine: all registers are available
;   enter subroutine: r0, r18-r25, XL, XH, YL, YH, ZL, and ZH available
;   exit subroutine: r0, r24-r25, YL, YH, ZL, and ZH available
;   conversation subroutine: r0, r20-r25, ZL, and ZH available
;   choice subroutine: r0, r22-r25, ZL, and ZH available

.include "logic_shared.asm"

tutorial_update:
    lds r24, prev_controller_values
    lds r25, controller_values
    com r24
    and r25, r24
    sbrs r25, CONTROLS_SPECIAL1
    rjmp _tu_instructions
    player_distance_imm 205, 160
    cpi r25, 12
    brsh _tu_instructions
_tu_exit:
    call load_help
    ret
_tu_instructions:
    ldi r23, 0x00
    lds r24, player_position_x
    lds r25, player_position_y
    ldi ZL, byte3(2*ui_string_table)
    out RAMPZ, ZL
    cpi r24, 100
    brlo _tu_left
    rjmp _tu_right
_tu_left:
    ldi r21, 16
_tu_left_move:
    cpi r25, 140
    brlo _tu_left_pickup
    ldi YL, low(framebuffer+DISPLAY_WIDTH*16+50)
    ldi YH, high(framebuffer+DISPLAY_WIDTH*16+50)
    ldi ZL, low(2*tutorial_move_str)
    ldi ZH, high(2*tutorial_move_str)
    call puts
    ret
_tu_left_pickup:
    cpi r25, 120
    brlo _tu_left_shop
    ldi YL, low(framebuffer+DISPLAY_WIDTH*16+50)
    ldi YH, high(framebuffer+DISPLAY_WIDTH*16+50)
    ldi ZL, low(2*tutorial_pickup_str)
    ldi ZH, high(2*tutorial_pickup_str)
    call puts
    ret
_tu_left_shop:
    cpi r25, 80
    brlo _tu_left_inventory
    ldi YL, low(framebuffer+DISPLAY_WIDTH*6+50)
    ldi YH, high(framebuffer+DISPLAY_WIDTH*6+50)
    ldi ZL, low(2*tutorial_shop_str)
    ldi ZH, high(2*tutorial_shop_str)
    call puts
    ret
_tu_left_inventory:
    cpi r25, 50
    brlo _tu_left_next
    ldi YL, low(framebuffer+DISPLAY_WIDTH*4+50)
    ldi YH, high(framebuffer+DISPLAY_WIDTH*4+50)
    ldi ZL, low(2*tutorial_inventory_str)
    ldi ZH, high(2*tutorial_inventory_str)
    call puts
    ret
_tu_left_next:
    ldi YL, low(framebuffer+DISPLAY_WIDTH*24+55)
    ldi YH, high(framebuffer+DISPLAY_WIDTH*24+55)
    ldi ZL, low(2*tutorial_next_str)
    ldi ZH, high(2*tutorial_next_str)
    call puts
    ret
_tu_right:
    ldi r21, 14
_tu_right_talk:
    cpi r25, 70
    brsh _tu_right_fight
    ldi YL, low(framebuffer+DISPLAY_WIDTH*24+8)
    ldi YH, high(framebuffer+DISPLAY_WIDTH*24+8)
    ldi ZL, low(2*tutorial_talk_str)
    ldi ZH, high(2*tutorial_talk_str)
    call puts
    ret
_tu_right_fight:
    cpi r25, 96
    brsh _tu_right_save
    ldi YL, low(framebuffer+DISPLAY_WIDTH*12+5)
    ldi YH, high(framebuffer+DISPLAY_WIDTH*12+5)
    ldi ZL, low(2*tutorial_fight_str)
    ldi ZH, high(2*tutorial_fight_str)
    call puts
    ret
_tu_right_save:
    cpi r25, 140
    brlo _tu_right_end
    ldi YL, low(framebuffer+DISPLAY_WIDTH*20+4)
    ldi YH, high(framebuffer+DISPLAY_WIDTH*20+4)
    ldi ZL, low(2*tutorial_save_str)
    ldi ZH, high(2*tutorial_save_str)
    call puts
_tu_right_end:
    ret

sector_start_1_update:
    player_distance_imm 157, 93
    cpi r25, 12
    brlo _ss1u_end
    try_start_conversation what_happened
_ss1u_end:
    ret

sector_start_2_update:
    sts npc_move_flags2, r1
_ss2u_test_ruffian:
    lds r25, player_position_x
    cpi r25, 160
    brlo _ss2u_fight
    lds r25, player_position_y
    cpi r25, 60
    brsh _ss2u_fight
_ss2u_halfing:
    lds r25, player_character
    cpi r25, CHARACTER_HALFLING
    brne _ss2u_main
    try_start_conversation_intern battle_tutorial_halfling, battle_tutorial
    rjmp _ss2u_fight
_ss2u_main:
    try_start_conversation_intern battle_tutorial_generic, battle_tutorial
_ss2u_fight:
    check_conversation battle_tutorial
    brne _ss2u_end
    ldi r25, 1
    sts npc_move_flags2, r25
_ss2u_loot:
    lds r25, sector_npcs+NPC_IDX_OFFSET
    cpi r25, NPC_CORPSE
    brne _ss2u_end
    lds r25, sector_loose_items
    cpi r25, 0
    breq _ss2u_end
    lds r22, sector_npcs+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H
    lds r23, sector_npcs+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H
    player_distance r22, r23
    cpi r25, 16
    brlo _ss2u_end
    try_start_conversation loot_tutorial
_ss2u_end:
    ret

sector_start_fight_update:
    ldi r25, NPC_BANDIT_2
    call find_npc
    tst r20
    breq _ssfu_end
    ldd r25, Y+NPC_HEALTH_OFFSET
    cpi r25, 8
    brsh _ssfu_end
    try_start_conversation bandit_plead
_ssfu_end:
    ret

sector_start_fight_choice:
    push r20
    push r21
    lds r25, selected_choice
    cpi r25, 1
    brne _ssfc_end
    ldi r25, NPC_BANDIT_2
    call find_npc
    tst r20
    breq _ssfc_end
    ldi r25, NPC_BANDIT_2_REFORMED
    std Y+NPC_IDX_OFFSET, r25
    std Y+NPC_EFFECT_OFFSET, r1
    ldi r23, ITEM_bloody_sword
    ldd r24, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H
    subi r24, low(-2)
    ldd r25, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H
    subi r25, low(-10)
    call drop_item
    lds r25, npc_presence+((NPC_BANDIT_2-1)>>3)
    andi r25, low(~(1<<((NPC_BANDIT_2-1)&7)))
    sts npc_presence+((NPC_BANDIT_2-1)>>3), r25
    sts player_effect, r1
    ldi r25, ACTION_IDLE
    sts player_action, r25
    lds r24, player_xp
    lds r25, player_xp+1
    adiw r24, 10
    sts player_xp, r24
    sts player_xp+1, r25
_ssfc_end:
    pop r21
    pop r20
    ret

sector_town_entrance_1_update:
    lds r25, global_data + QUEST_KIDNAPPED
    cpi r25, 5
    brsh _ste1u_end
    ldi r25, NPC_KIDNAPPED_FOLLOWING
    call find_npc
    tst r20
    breq _ste1u_end
_ste1u_check_position:
    ldd r22, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H
    ldd r23, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H
    ldi r24, 81
    ldi r25, 133
    distance_between r24, r25, r22, r23
    cpi r25, 14
    brsh _ste1u_end
    ldi r25, NPC_KIDNAPPED
    std Y+NPC_IDX_OFFSET, r25
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DX, r1
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_DY, r1
    ldi r25, 5
    sts global_data + QUEST_KIDNAPPED, r25
    lds r25, npc_presence + ((NPC_KIDNAPPED-1)>>3)
    andi r25, ~(1<<((NPC_KIDNAPPED-1)&7))
    sts npc_presence + ((NPC_KIDNAPPED-1)>>3), r25
_ste1u_end:
    ret

sector_town_entrance_1_conversation:
    ldi r23, high(2*_conv_kidnapped)
    cpi r24, low(2*_conv_kidnapped)
    cpc r25, r23
    brne _ste1c_end
    lds r23, global_data+QUEST_KIDNAPPED
_st1ec_not_begun:
    andi r23, 0x07
    breq _ste1c_end
_st1ec_refused:
    cpi r23, 1
    brne _st1ec_accepted
    ldi r24, low(2*_conv_kidnapped9)
    ldi r25, high(2*_conv_kidnapped9)
    rjmp _ste1c_end
_st1ec_accepted:
    cpi r23, 2
    brne _st1ec_fighting
    ldi r24, low(2*_conv_kidnapped10)
    ldi r25, high(2*_conv_kidnapped10)
    rjmp _ste1c_end
_st1ec_fighting:
    cpi r23, 5
    brsh _st1ec_rescued
    ldi r24, low(2*_conv_kidnapped13)
    ldi r25, high(2*_conv_kidnapped13)
    rjmp _ste1c_end
_st1ec_rescued:
    cpi r23, 5
    brne _st1ec_completed
    lds r24, player_xp
    lds r25, player_xp+1
    subi r24, low(-QUEST_KIDNAPPED_XP)
    sbci r25, high(-QUEST_KIDNAPPED_XP)
    sts player_xp, r24
    sts player_xp+1, r25
    ldi r23, ITEM_health_potion
    ldi r24, 92
    ldi r25, 140
    call drop_item
    ldi r23, 6
    sts global_data + QUEST_KIDNAPPED, r23
    ldi r24, low(2*_conv_kidnapped11)
    ldi r25, high(2*_conv_kidnapped11)
    rjmp _ste1c_end
_st1ec_completed:
    ldi r24, low(2*_conv_kidnapped12)
    ldi r25, high(2*_conv_kidnapped12)
_ste1c_end:
    ret

sector_town_entrance_1_choice:
    lds r25, selected_choice
    tst r25
    breq _ste1ch_end
_ste1ch_refuse:
    cpi r25, 1
    brne _ste1ch_accept
    ldi r25, 2
    sts global_data + QUEST_KIDNAPPED, r25
    rjmp _ste1ch_end
_ste1ch_accept:
    ldi r25, 1
    sts global_data + QUEST_KIDNAPPED, r25
_ste1ch_end:
    ret

sector_town_wolves_update:
    lds r25, global_data + QUEST_KIDNAPPED
    cpi r25, 3
    brsh _stwu_end
_stwu_lurk:
    lds r25, player_position_x
    cpi r25, 80
    brsh _stwu_end
    ldi r25, 3
    sts global_data + QUEST_KIDNAPPED, r25
_stwu_end:
    ret

sector_start_post_fight_update:
    lds r25, global_data + QUEST_KIDNAPPED
    cpi r25, 4
    brne _sspfu_end
    ldi r25, NPC_KIDNAPPED
    call find_npc
    tst r20
    breq _sspfu_end
    ldi r25, NPC_KIDNAPPED_FOLLOWING
    std Y+NPC_IDX_OFFSET, r25
_sspfu_end:
    ret

sector_start_post_fight_conversation:
    push r24
    push r25
    ldi r20, 4
    sts global_data + QUEST_KIDNAPPED, r20
    ldi r25, NPC_KIDNAPPED
    call find_npc
    tst r20
    breq _sspfc_end
    ldi r20, NPC_KIDNAPPED_FOLLOWING
    std Y+NPC_IDX_OFFSET, r20
_sspfc_end:
    pop r25
    pop r24
    ret

sector_town_tavern_1_update:
    player_distance_imm 75, 116
    cpi r25, 16
    brsh _stt1u_end
    try_start_conversation bartender
_stt1u_end:
    ret

sector_town_tavern_2_update:
    ldi r25, NPC_ANNOYED_GUEST
    call find_npc
    tst r20
    breq _stt2u_end
    lds r25, sector_loose_items+SECTOR_ITEM_IDX_OFFSET
    cpi r25, 128|50
    breq _stt2u_end
    lds r25, npc_presence+((NPC_ROBBED_GUEST-1)>>3)
    andi r25, 1<<((NPC_ROBBED_GUEST-1)&7)
    brne _stt2u_add_robbed
    std Y+NPC_IDX_OFFSET, r1
    rjmp _stt2u_end
_stt2u_add_robbed:
    ldi r25, NPC_ROBBED_GUEST
    std Y+NPC_IDX_OFFSET, r25
    try_start_conversation robbed_guest
    rjmp _stt2u_end
_stt2u_end:
    ret

sector_town_tavern_2_conversation:
    ldi r20, high(2*_conv_guest_quest)
    cpi r24, low(2*_conv_guest_quest)
    cpc r25, r20
    brne _stt2c_end
    ldi ZL, low(player_inventory)
    ldi ZH, high(player_inventory)
    ldi r20, PLAYER_INVENTORY_SIZE
_stt2c_inventory_iter:
    ld r21, Z+
    cpi r21, ITEM_journal
    breq _stt2c_have_journal
_stt2c_next:
    dec r20
    brne _stt2c_inventory_iter
_stt2c_no_journal:
    lds r20, global_data+QUEST_JOURNAL
    andi r20, 0x03
    breq _stt2c_end
    cpi r20, 3
    breq _stt2c_completed
    ldi r24, low(2*_conv_guest_quest6)
    ldi r25, high(2*_conv_guest_quest6)
    rjmp _stt2c_end
_stt2c_have_journal:
    st -Z, r1
    lds r24, player_xp
    lds r25, player_xp+1
    subi r24, low(-QUEST_JOURNAL_XP)
    sbci r25, high(-QUEST_JOURNAL_XP)
    sts player_xp, r24
    sts player_xp+1, r25
    lds r20, global_data+QUEST_JOURNAL
    ldi r25, 3
    sts global_data+QUEST_JOURNAL, r25
    ldi r23, 128|5
    ldi r24, 52
    ldi r25, 41
    call drop_item
    andi r20, 0x03
    breq _stt2c_accepted
_stt2c_refused:
    cpi r20, 2
    brne _stt2c_test_accepted
    ldi r24, low(2*_conv_guest_quest7)
    ldi r25, high(2*_conv_guest_quest7)
    rjmp _stt2c_end
_stt2c_test_accepted:
    cpi r20, 1
    brne _stt2c_completed
_stt2c_accepted:
    ldi r24, low(2*_conv_guest_quest8)
    ldi r25, high(2*_conv_guest_quest8)
    rjmp _stt2c_end
_stt2c_completed:
    ldi r24, low(2*_conv_guest_quest9)
    ldi r25, high(2*_conv_guest_quest9)
_stt2c_end:
    ret

sector_town_tavern_2_choice:
    lds r25, selected_choice
    inc r25
    sts global_data+QUEST_JOURNAL, r25
    ret

sector_town_fields_init:
    sts npc_move_flags2, r1
    lds r25, global_data+QUEST_BANDITS
    andi r25, 0x3
_stfi_test_left_confrontation:
    cpi r25, 1
    brne _stfi_test_right_confrontation
    ldi r25, NPC_UNDERCOVER_BANDIT_UNMASKED
    call add_npc
    ldi r25, NPC_UNDERCOVER_GOON1
    call add_npc
    ldi r25, NPC_UNDERCOVER_GOON2
    call add_npc
    rjmp _stfi_end
_stfi_test_right_confrontation:
    cpi r25, 2
    brne _stfi_end
_stfi_add_unmasked:
    ldi r25, NPC_UNDERCOVER_BANDIT_UNMASKED
    call add_npc
    tst r25
    brne _stfi_add_goon_1
    ldi r24, 193
    ldi r25, 109
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H, r24
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H, r25
    ldi r25, DIRECTION_RIGHT
    std Y+NPC_ANIM_OFFSET, r25
_stfi_add_goon_1:
    ldi r25, NPC_UNDERCOVER_GOON1
    call add_npc
    tst r25
    brne _stfi_add_goon_2
    ldi r24, 183
    ldi r25, 118
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H, r24
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H, r25
    ldi r25, DIRECTION_RIGHT
    std Y+NPC_ANIM_OFFSET, r25
_stfi_add_goon_2:
    ldi r25, NPC_UNDERCOVER_GOON2
    call add_npc
    tst r25
    brne _stfi_end
    ldi r24, 185
    ldi r25, 100
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H, r24
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H, r25
    ldi r25, DIRECTION_RIGHT
    std Y+NPC_ANIM_OFFSET, r25
_stfi_end:
    ret

sector_town_fields_update:
    sts npc_move_flags2, r1
    ldi r25, 3
    call release_if_damaged
    lds r25, npc_move_flags2
    tst r25
    breq _stfu_main
    lds r25, conversation_over + ((CONVERSATION_bandit_reveal_ID-1)>>3)
    andi r25, low(~exp2((CONVERSATION_bandit_reveal_ID-1)&0x07))
    sts conversation_over + ((CONVERSATION_bandit_reveal_ID-1)>>3), r25
_stfu_main:
    lds r25, npc_presence+((NPC_UNDERCOVER_BANDIT_UNMASKED-1)>>3)
    andi r25, exp2((NPC_UNDERCOVER_BANDIT_UNMASKED-1)&0x07)
    brne _stfu_test_left_confrontation
    lds r25, global_data+QUEST_BANDITS
    ori r25, 3
    sts global_data+QUEST_BANDITS, r25
    rjmp _stfu_fight
_stfu_test_left_confrontation:
    lds r25, global_data+QUEST_BANDITS
    andi r25, 0x03
    cpi r25, 1
    brne _stfu_test_right_confrontation
    check_conversation bandit_reveal
    breq _stfu_fight
    lds r25, player_position_y
    cpi r25, 45
    brlo _stfu_end
    try_start_conversation_intern bandit_left_reveal1, bandit_reveal
    rjmp _stfu_end
_stfu_test_right_confrontation:
    cpi r25, 2
    brne _stfu_fight
    check_conversation bandit_reveal
    breq _stfu_fight
    lds r25, player_position_x
    cpi r25, 210
    brsh _stfu_end
    try_start_conversation_intern bandit_right_reveal, bandit_reveal
_stfu_fight:
    ldi r25, 1
    sts npc_move_flags2, r25
_stfu_end:
    ret

sector_town_forest_path_2_init:
    lds r25, global_data+QUEST_BANDITS
    mov r24, r25
    andi r24, 0x03
    cpi r24, 3
    brsh _stfp2_end
    andi r25, 0xfc
    ori r25, 1
    sts global_data+QUEST_BANDITS, r25
    ldi r25, NPC_CORPSE
    call add_npc
    ldi r24, 202
    ldi r25, 12
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H, r24
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H, r25
    ldi r25, NPC_CORPSE
    call add_npc
    ldi r24, 210
    ldi r25, 13
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H, r24
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H, r25
    ldi r25, NPC_CORPSE
    call add_npc
    ldi r24, 206
    ldi r25, 16
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H, r24
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H, r25
    lds r25, npc_presence+((NPC_UNDERCOVER_BANDIT-1)>>3)
    andi r25, low(~exp2((NPC_UNDERCOVER_BANDIT-1)&0x07))
    sts npc_presence+((NPC_UNDERCOVER_BANDIT-1)>>3), r25
_stfp2_end:
    ret

sector_town_forest_path_2_update:
    lds r24, prev_controller_values
    com r24
    lds r25, controller_values
    and r25, r24
    sbrs r25, CONTROLS_SPECIAL1
    rjmp _stfp2u_end
    player_distance_imm 215, 21
    cpi r25, 16
    brsh _stfp2u_end
    ldi r24, low(2*_conv_foxes_didnt_do_this)
    ldi r25, high(2*_conv_foxes_didnt_do_this)
    call load_conversation
_stfp2u_end:
    ret

sector_town_forest_path_4_update:
    ldi r25, 1
    sts npc_move_flags2, r25
    lds r25, player_position_y
    cpi r25, 120
    brlo _stfp4_end
    lds r25, player_position_x
    cpi r25, 100
    brsh _stfp4_end
    lds r25, global_data+QUEST_BANDITS
    sbrc r25, 3
    rjmp _stfp4_end
    ori r25, 8
    sts global_data+QUEST_BANDITS, r25
    ldi r25, NPC_AMBUSHER
    call add_npc
    ldi r25, NPC_AMBUSHER
    call add_npc
    tst r25
    brne _stfp4_end
    ldi r25, 59
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H, r25
_stfp4_end:
    ret

sector_town_forest_path_5_init:
    lds r25, global_data+QUEST_BANDITS
    mov r24, r25
    andi r24, 0x03
    cpi r24, 3
    brsh _stfp2_end
    andi r25, 0xfc
    ori r25, 2
    sts global_data+QUEST_BANDITS, r25
    lds r25, npc_presence+((NPC_UNDERCOVER_BANDIT-1)>>3)
    andi r25, low(~exp2((NPC_UNDERCOVER_BANDIT-1)&0x07))
    sts npc_presence+((NPC_UNDERCOVER_BANDIT-1)>>3), r25
_stfp5_end:
    ret

sector_town_den_2_init:
    try_start_conversation bandit_speech
    ret

sector_town_den_2_update:
    lds r24, prev_controller_values
    lds r25, controller_values
    com r24
    and r24, r25
    sbrs r24, CONTROLS_SPECIAL1
    rjmp _std2u_end
    lds r25, sector_loose_items+SECTOR_ITEM_IDX_OFFSET
    cpi r25, ITEM_pass
    breq _std2u_end
    try_start_conversation find_pass
_std2u_end:
    ret

; 0 - nothing
; 1 - warned
; 2 - attacking
; 3 - allowing to pass
sector_start_pretown_2_update:
    sts npc_move_flags2, r1
    ldi r25, 4
    call release_if_damaged
    lds r25, npc_presence+((NPC_HIGHWAY_GUARD_1-1)>>3)
    andi r25, exp2((NPC_HIGHWAY_GUARD_1-1)&0x07)
    breq _ssp2u_recognize
    lds r25, npc_presence+((NPC_HIGHWAY_GUARD_2-1)>>3)
    andi r25, exp2((NPC_HIGHWAY_GUARD_2-1)&0x07)
    breq _ssp2u_recognize
    lds r25, npc_presence+((NPC_HIGHWAY_GUARD_3-1)>>3)
    andi r25, exp2((NPC_HIGHWAY_GUARD_3-1)&0x07)
    breq _ssp2u_recognize
    lds r25, npc_presence+((NPC_HIGHWAY_GUARD_4-1)>>3)
    andi r25, exp2((NPC_HIGHWAY_GUARD_4-1)&0x07)
    breq _ssp2u_recognize
    rjmp _ssp2u_check
_ssp2u_recognize:
    ldi r25, 2
    sts sector_data, r25
_ssp2u_check:
    lds r25, sector_data
_ssp2u_warn:
    cpi r25, 0
    brne _ssp2u_attack
    lds r25, npc_move_flags2
    cpi r25, 0
    brne _ssp2u_attack
    lds r25, player_position_y
    cpi r25, 92
    brlo _ssp2u_attack
    cpi r25, 128
    brsh _ssp2u_attack
    ldi r25, 1
    sts sector_data, r25
    try_start_conversation highway_guard
    tst r25
    brne _ssp2u_end
    ldi r24, low(2*_conv_highway_guard2)
    ldi r25, high(2*_conv_highway_guard2)
    call load_conversation
    rjmp _ssp2u_end
_ssp2u_attack:
    cpi r25, 1
    brne _ssp2u_attacking
    lds r25, player_position_y
    cpi r25, 100
    brlo _ssp2u_test_reset
    cpi r25, 118
    brsh _ssp2u_test_reset
    ldi r25, 2
    sts sector_data, r25
    rjmp _ssp2u_end
_ssp2u_test_reset:
    lds r24, player_position_x
    cpi r24, 125
    brlo _ssp2u_reset
    cpi r25, 80
    brlo _ssp2u_reset
    cpi r25, 130
    brlo _ssp2u_attacking
_ssp2u_reset:
    sts sector_data, r1
    rjmp _ssp2u_end
_ssp2u_attacking:
    lds r25, sector_data
    cpi r25, 2
    brne _ssp2u_end
    ldi r25, 1
    sts npc_move_flags2, r25
_ssp2u_end:
    ret

sector_start_pretown_2_choice:
    sts player_action, r1
    lds r25, selected_choice
_ssp2c_pass:
    cpi r25, 2
    brne _ssp2c_sorry
    ldi ZL, low(player_inventory)
    ldi ZH, high(player_inventory)
    ldi r25, PLAYER_INVENTORY_SIZE
_ssp2c_inventory_loop:
    ld r24, Z+
    cpi r24, ITEM_pass
    breq _ssp2c_have_pass
    dec r25
    brne _ssp2c_inventory_loop
_ssp2c_no_pass:
    ldi r20, low(2*_conv_highway_guard17)
    ldi r21, high(2*_conv_highway_guard17)
    rjmp _ssp2c_end
_ssp2c_have_pass:
    ldi r25, 3
    sts sector_data, r25
    rjmp _ssp2c_end
_ssp2c_sorry:
    cpi r25, 3
    brne _ssp2c_end
    ldi r25, 1
    sts sector_data, r25
_ssp2c_end:
    ret

sector_river_hidden_house_choice:
    lds r25, selected_choice
    cpi r25, 1
    brne _srhhc_end
    ldi r25, NPC_ANGRY_POET
    sts sector_npcs+NPC_IDX_OFFSET, r25
_srhhc_end:
    ret

sector_deep_forest_update:
    ldi r22, 0x1f
    ldi r23, 10
    ldi r24, 0x03
    ldi r25, NPC_DEEP_FOREST_FOX
    call spawn_distant_npcs
    ret

sector_deep_forest_init:
    mov r25, r2
    andi r25, 0x03
    subi r25, low(-NPC_DEEP_FOREST_FOX)
    call add_distant_npc
    mov r25, r3
    andi r25, 0x03
    subi r25, low(-NPC_DEEP_FOREST_FOX)
    call add_distant_npc
_sdfi_end:
    ret

sector_underground_update:
    ldi r22, 0x1f
    ldi r23, 20
    ldi r24, 0x01
    ldi r25, NPC_GHOUL_1
    call spawn_distant_npcs
    ret

sector_skull_cult_1_enter:
    try_start_conversation cult_victim
    ldi r25, NPC_CULT_VICTIM
    call find_npc
    tst r20
    breq _ssc1e_end
    ldi r25, EFFECT_DAMAGE<<3
    std Y+NPC_EFFECT_OFFSET, r25
    ldi r25, NPC_CULTIST_6
    call find_npc
    tst r20
    breq _ssc1e_end
    ldi r25, ACTION_ATTACK<<5
    std Y+NPC_ANIM_OFFSET, r25
_ssc1e_end:
    ret

sector_skull_cult_1_update:
    ldi r25, NPC_CULT_VICTIM
    call find_npc
    tst r20
    breq _ssc1u_end
    ldd r25, Y+NPC_EFFECT_OFFSET
    tst r25
    brne _ssc1u_end
    ldi r25, EFFECT_DAMAGE<<3
    std Y+NPC_EFFECT_OFFSET, r25
    ldi ZL, byte3(2*npc_table)
    out RAMPZ, ZL
    ldi ZL, low(2*npc_table + (NPC_CULT_VICTIM-1)*NPC_MEMSIZE)
    ldi ZH, high(2*npc_table + (NPC_CULT_VICTIM-1)*NPC_MEMSIZE)
    call resolve_enemy_death
_ssc1u_end:
    ret

sector_fields_update:
    ldi r22, 0x1f
    ldi r23, 20
    ldi r24, 0x00
    ldi r25, NPC_FIELD_FOX
    call spawn_distant_npcs
    ret

sector_fields_init:
    ldi r25, NPC_FIELD_FOX
    call add_distant_npc
    ret

sector_final_2_update:
    lds r24, player_position_x
    lds r25, player_position_y
_sf2u_left_edge_check:
    cpi r24, 226
    brlo _sf2u_top_check
    subi r24, 10
    rjmp _sf2u_talk
_sf2u_top_check:
    cpi r25, 4
    brsh _sf2u_end
    subi r25, low(-10)
_sf2u_talk:
    sts player_velocity_x, r1
    sts player_velocity_y, r1
    sts player_position_x, r24
    sts player_position_y, r25
    ldi r24, low(2*_conv_cant_leave)
    ldi r25, high(2*_conv_cant_leave)
    call load_conversation
_sf2u_end:
    ret

sector_city_shop_1_choice:
    lds r25, selected_choice
    cpi r25, 0
    brne _scs1c_end
    lds r24, player_gold
    lds r25, player_gold+1
    sbiw r24, 10
    brsh _scs1c_save_gold
    clr r24
    clr r25
_scs1c_save_gold:
    sts player_gold, r24
    sts player_gold+1, r25
_scs1c_end:
    ret

sector_city_4_init:
    lds r25, global_data+QUEST_HALDIR
    andi r25, 0x0f
    cpi r25, QUEST_HALDIR_BANK_ATTACKED
    brne _sc4i_end
    ldi r25, NPC_BANK_QUESTGIVER
    call find_npc
    tst r20
    breq _sc4i_end
    ldi r25, NPC_BANK_QUESTGIVER_ANGRY
    std Y+NPC_IDX_OFFSET, r25
_sc4i_end:
    ret

sector_city_4_conversation:
    ldi r20, high(2*_conv_kill_thieves1)
    cpi r24, low(2*_conv_kill_thieves1)
    cpc r25, r20
    breq _sc4c_check_quest_status
_sc4c_end_fast:
    ret
_sc4c_check_quest_status:
    lds r20, global_data+QUEST_HALDIR
    andi r20, 0x0f
    breq _sc4c_end_fast
_sc4c_refused:
    cpi r20, QUEST_HALDIR_BANK_REFUSED
    brne _sc4c_accepted
    ldi r24, low(2*_conv_kill_thieves6)
    ldi r25, high(2*_conv_kill_thieves6)
    rjmp _sc4c_end
_sc4c_accepted:
    cpi r20, QUEST_HALDIR_BANK_ACCEPTED
    brne _sc4c_rewarded
    lds r25, npc_presence+((NPC_THIEF_BOSS-1)>>3)
    andi r25, exp2((NPC_THIEF_BOSS-1)&0x07)
    breq _sc4c_completed
    ldi r24, low(2*_conv_kill_thieves11)
    ldi r25, high(2*_conv_kill_thieves11)
    rjmp _sc4c_end
_sc4c_completed:
    ldi r23, ITEM_mithril_breastplate
    ldi r24, 126
    ldi r25, 100
    call drop_item
    lds r24, player_xp
    lds r25, player_xp+1
    subi r24, low(-QUEST_HALDIR_XP)
    subi r25, high(-QUEST_HALDIR_XP)
    sts player_xp, r24
    sts player_xp+1, r25
    lds r25, global_data+QUEST_HALDIR
    andi r25, 0xf0
    ori r25, QUEST_HALDIR_BANK_REWARDED
    sts global_data+QUEST_HALDIR, r25
    ldi r24, low(2*_conv_kill_thieves12)
    ldi r25, high(2*_conv_kill_thieves12)
    rjmp _sc4c_end
_sc4c_rewarded:
    cpi r20, QUEST_HALDIR_BANK_REWARDED
    brne _sc4c_other
    ldi r24, low(2*_conv_kill_thieves12)
    ldi r25, high(2*_conv_kill_thieves12)
    rjmp _sc4c_end
_sc4c_other:
    ldi r24, low(2*_conv_END_CONVERSATION)
    ldi r25, high(2*_conv_END_CONVERSATION)
_sc4c_end:
    ret

sector_city_4_choice:
    lds r24, global_data+QUEST_HALDIR
    andi r24, 0xf0
    lds r25, selected_choice
_sc4ch_accept:
    cpi r25, 1
    brne _sc4ch_refuse
    cpi r24, QUEST_HALDIR_THIEVES_NOT_BEGUN
    brne _sc4ch_acc_quest
    ori r24, QUEST_HALDIR_THIEVES_ATTACKING
_sc4ch_acc_quest:
    ori r24, QUEST_HALDIR_BANK_ACCEPTED
    sts global_data+QUEST_HALDIR, r24
_sc4ch_refuse:
    cpi r25, 2
    brne _sc4ch_end
    ori r24, QUEST_HALDIR_BANK_REFUSED
    sts global_data+QUEST_HALDIR, r24
_sc4ch_end:
    ret

sector_city_bank_1_update:
    sts npc_move_flags2, r1
    lds r25, global_data+QUEST_HALDIR
    andi r25, 0x0f
_scb1_check_attacked:
    cpi r25, QUEST_HALDIR_BANK_ATTACKED
    breq _scb1_attack
    ldi r25, 2
    call release_if_damaged
    lds r0, npc_move_flags2
    tst r0
    breq _scb1_warning
    lds r25, global_data+QUEST_HALDIR
    andi r25, 0xf0
    ori r25, QUEST_HALDIR_BANK_ATTACKED
    sts global_data+QUEST_HALDIR, r25
    rjmp _scb1_end
_scb1_attack:
    ldi r25, 1
    sts npc_move_flags2, r25
    rjmp _scb1_end
_scb1_warning:
    lds r25, player_position_y
    cpi r25, 60
    brsh _scb1_end
    lds r25, sector_data
    tst r25
    brne _scb1_end
    ldi r25, 1
    sts sector_data, r25
    ldi r24, low(2*_conv_bank_warning)
    ldi r25, high(2*_conv_bank_warning)
    call load_conversation
_scb1_end:
    ret

sector_city_bank_2_init:
    ldi r25, 1
    sts npc_move_flags2, r25
    lds r25, global_data+QUEST_HALDIR
    andi r25, 0xf0
    ori r25, QUEST_HALDIR_BANK_ATTACKED
    sts global_data+QUEST_HALDIR, r25
    ret

sector_city_bank_3_update:
    lds r25, global_data+QUEST_HALDIR
    andi r25, 0x0f
    cpi r25, QUEST_HALDIR_BANK_ATTACKED
    brne _scb3u_end
_scb3u_check_robbery:
    ldi YL, low(sector_loose_items)
    ldi YH, high(sector_loose_items)
    ldi r24, SECTOR_DYNAMIC_ITEM_COUNT
_scb3u_loop:
    ldd r25, Y+SECTOR_ITEM_IDX_OFFSET
    cpi r25, ITEM_small_chest
    breq _scb3u_end
_scb3u_next:
    adiw YL, SECTOR_DYNAMIC_ITEM_MEMSIZE
    dec r24
    brne _scb3u_loop
_scb3u_robbery:
    lds r25, global_data+QUEST_HALDIR
    andi r25, 0xf0
    ori r25, QUEST_HALDIR_BANK_ROBBED
    sts global_data+QUEST_HALDIR, r25
    ldi r25, NPC_GHOUL_1
    call add_npc_direct
    ldi r24, 93
    ldi r25, 24
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H, r24
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H, r25
    ldi r25, NPC_GHOUL_1
    call add_npc_direct
    ldi r24, 147
    ldi r25, 43
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H, r24
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H, r25
    ldi r25, NPC_GHOUL_1
    call add_npc_direct
    ldi r24, 120
    ldi r25, 53
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H, r24
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H, r25
_scb3u_end:
    ret

sector_city_bank_4_update:
    ldi r25, 2
    call release_if_damaged
    ret

sector_city_robbers_den_update:
    sts npc_move_flags2, r1
_scrdcu_check_quest:
    lds r25, global_data+QUEST_HALDIR
    andi r25, 0xf0
    cpi r25, QUEST_HALDIR_THIEVES_ATTACKING
    breq _scrdu_attack
_scrdu_check_player_attacking:
    ldi r25, 3
    call release_if_damaged
    lds r25, npc_move_flags2
    tst r25
    breq _scrdu_check_warn
    lds r25, global_data+QUEST_HALDIR
    andi r25, 0x0f
    ori r25, QUEST_HALDIR_THIEVES_ATTACKING
    sts global_data+QUEST_HALDIR, r25
_scrdu_attack:
    ldi r25, 1
    sts npc_move_flags2, r25
    ldi r25, NPC_THIEF_QUESTGIVER
    call find_npc
    tst r20
    breq _scrdu_end
    ldi r25, NPC_THIEF_QUESTGIVER_ANGRY
    cpse r25, r1
    std Y+NPC_IDX_OFFSET, r25
    lds r25, npc_presence+((NPC_THIEF_QUESTGIVER_TRICKY-1)>>3)
    andi r25, exp2((NPC_THIEF_QUESTGIVER_TRICKY-1)&0x07)
    brne _scrdu_end
    std Y+NPC_IDX_OFFSET, r1
    rjmp _scrdu_end
_scrdu_check_warn:
    lds r25, player_position_y
    cpi r25, 60
    brsh _scrdu_end
    lds r25, sector_data
    tst r25
    brne _scrdu_end
    ldi r25, 1
    sts sector_data, r25
    ldi r24, low(2*_conv_thieves_warning)
    ldi r25, high(2*_conv_thieves_warning)
    call load_conversation
_scrdu_end:
    ret

sector_city_robbers_den_conversation:
    lds r20, global_data+QUEST_HALDIR
    andi r20, 0xf0
    breq _scrdc_end
_scrdc_refused:
    cpi r20, QUEST_HALDIR_THIEVES_REFUSED
    brne _scrdc_accepted
    ldi r24, low(2*_conv_rob_bank5)
    ldi r25, high(2*_conv_rob_bank5)
    rjmp _scrdc_end
_scrdc_accepted:
    cpi r20, QUEST_HALDIR_THIEVES_ACCEPTED
    brne _scrdc_other
    ldi ZL, low(player_inventory)
    ldi ZH, high(player_inventory)
    ldi r24, PLAYER_INVENTORY_SIZE
_scrdc_loop:
    ld r25, Z+
    cpi r25, ITEM_small_chest
    brne _scrdc_next
_scrdc_completed:
    st -Z, r1
    lds r24, player_xp
    lds r25, player_xp+1
    subi r24, low(-QUEST_HALDIR_XP)
    subi r25, high(-QUEST_HALDIR_XP)
    sts player_xp, r24
    sts player_xp+1, r25
    ldi r25, NPC_THIEF_QUESTGIVER
    call find_npc
    ldi r25, NPC_THIEF_QUESTGIVER_TRICKY
    cpse r20, r1
    std Y+NPC_IDX_OFFSET, r25
    lds r25, global_data+QUEST_HALDIR
    andi r25, 0x0f
    ori r25, QUEST_HALDIR_THIEVES_ATTACKING
    sts global_data+QUEST_HALDIR, r25
    ldi r24, low(2*_conv_rob_bank9)
    ldi r25, high(2*_conv_rob_bank9)
    rjmp _scrdc_end
_scrdc_next:
    dec r24
    brne _scrdc_loop
    ldi r24, low(2*_conv_rob_bank8)
    ldi r25, high(2*_conv_rob_bank8)
    rjmp _scrdc_end
_scrdc_other:
    ldi r24, low(2*_conv_END_CONVERSATION)
    ldi r25, high(2*_conv_END_CONVERSATION)
_scrdc_end:
    ret

sector_city_robbers_den_choice:
    lds r24, global_data+QUEST_HALDIR
    andi r24, 0x0f
    lds r25, selected_choice
_scrdch_accept:
    cpi r25, 0
    brne _scrdch_refuse
    ori r24, QUEST_HALDIR_THIEVES_ACCEPTED
    sts global_data+QUEST_HALDIR, r24
_scrdch_refuse:
    cpi r25, 1
    brne _scrdch_end
    ori r24, QUEST_HALDIR_THIEVES_REFUSED
    sts global_data+QUEST_HALDIR, r24
_scrdch_end:
    ret

sector_city_robbers_den_2_init:
    ldi r25, 1
    sts npc_move_flags2, r25
    lds r25, global_data+QUEST_HALDIR
    andi r25, 0x0f
    ori r25, QUEST_HALDIR_THIEVES_ATTACKING
    sts global_data+QUEST_HALDIR, r25
    ret

sector_final_castle_init:
    ldi r25, 60
    sts camera_position_x, r25
    ret

sector_final_battle_init:
    ldi r24, low(2*_conv_final_boss1)
    ldi r25, high(2*_conv_final_boss1)
    call load_conversation
    sts sector_data, r1
    ret

sector_final_battle_update:
    lds r25, clock
    andi r25, 0x3f
    brne _sfbu_check
    ldi YL, low(sector_npcs)
    ldi YH, high(sector_npcs)
    ldi r25, 2
_sfbu_loop1:
    ldd r24, Y+NPC_HEALTH_OFFSET
    inc r24
    std Y+NPC_HEALTH_OFFSET, r24
    adiw YL, NPC_MEMSIZE
    dec r25
    brne _sfbu_loop1
_sfbu_check:
    ldi r25, NPC_ZHEV
    call find_npc
    tst r20
    breq _sfbu_test_zhev_defeated
_sfbu_check_second_phase:
    lds r25, sector_data
    tst r25
    brne _sfbu_end1
    ldd r25, Y+NPC_HEALTH_OFFSET
    cpi r25, 20
    brsh _sfbu_end1
    ldi r25, 1
    sts sector_data, r25
    ldi r25, 60
    std Y+NPC_HEALTH_OFFSET, r25
    ldi r25, EFFECT_POTION << 3
    std Y+NPC_EFFECT_OFFSET, r25
    movw ZL, YL
    adiw ZL, NPC_MEMSIZE
    ldi r25, NPC_ZHEV2
    std Z+NPC_IDX_OFFSET, r25
    ldd r25, Y+NPC_ANIM_OFFSET
    std Z+NPC_ANIM_OFFSET, r25
    ldd r25, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H
    std Z+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H, r25
    std Z+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_L, r1
    std Z+NPC_POSITION_OFFSET+CHARACTER_POSITION_DX, r1
    ldd r25, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H
    std Z+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H, r25
    std Z+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_L, r1
    std Z+NPC_POSITION_OFFSET+CHARACTER_POSITION_DY, r1
    ldd r25, Y+NPC_HEALTH_OFFSET
    std Z+NPC_HEALTH_OFFSET, r25
    ldd r25, Y+NPC_EFFECT_OFFSET
    std Z+NPC_EFFECT_OFFSET, r25
_sfbu_end1:
    ret
_sfbu_test_zhev_defeated:
    ldi r25, NPC_ZHEV
    call find_npc
    tst r20
    brne _sfbu_end2
    ldi r25, NPC_ZHEV2
    call find_npc
    tst r20
    breq _sfbu_test_letter_taken
    ldi r25, NPC_CORPSE
    std Y+NPC_IDX_OFFSET, r25
    ldi r25, EFFECT_DAMAGE << 3
    std Y+NPC_EFFECT_OFFSET, r25
_sfbu_test_letter_taken:
    ldi YL, low(player_inventory)
    ldi YH, high(player_inventory)
    ldi r24, PLAYER_INVENTORY_SIZE
_sfbu_loop:
    ld r25, Y+
    cpi r25, ITEM_letter
    brne _sfbu_next
    ldi r25, GAME_OVER_WIN
    call load_gameover
    ret
_sfbu_next:
    dec r24
    brne _sfbu_loop
_sfbu_end2:
    ret
