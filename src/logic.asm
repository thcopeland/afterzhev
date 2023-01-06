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
;   exit subroutine: r0, r24-r25, YL, YH, ZL, and ZH available
;   conversation subroutine: r0, r20-r25, ZL, and ZH available
;   choice subroutine: r0, r22-r25, ZL, and ZH available
;   other event subroutines: r0, r24, r25, ZL, and ZH available

.include "logic_shared.asm"

sector_start_1_update:
    player_distance_imm 164, 40
    cpi r25, 12
    brlo _ss1u_end
    try_start_conversation what_happened
_ss1u_end:
    ret

sector_start_2_update:
    sts npc_move_flags2, r1
    player_distance_imm 134, 128
    cpi r25, 18
    brsh _ss2u_test_ruffian
    try_start_conversation pickup_tutorial
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
    lds r25, sector_npcs+NPC_MEMSIZE+NPC_HEALTH_OFFSET
    cpi r25, 5
    brsh _ssfu_end
    try_start_conversation bandit_plead
_ssfu_end:
    ret

sector_start_fight_choice:
    lds r25, selected_choice
    cpi r25, 1
    brne _ssfc_end
    ldi r25, NPC_BANDIT_2_REFORMED
    sts sector_npcs+NPC_MEMSIZE+NPC_IDX_OFFSET, r25
    ldi r25, ITEM_bloody_sword
    sts sector_loose_items+SECTOR_DYNAMIC_ITEM_MEMSIZE*5+0, r25
    sts sector_loose_items+SECTOR_DYNAMIC_ITEM_MEMSIZE*5+1, r1
    lds r25, sector_npcs+NPC_MEMSIZE+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H
    subi r25, low(-2)
    sts sector_loose_items+SECTOR_DYNAMIC_ITEM_MEMSIZE*5+2, r25
    lds r25, sector_npcs+NPC_MEMSIZE+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H
    subi r25, low(-10)
    sts sector_loose_items+SECTOR_DYNAMIC_ITEM_MEMSIZE*5+3, r25
    lds r25, npc_presence+((NPC_BANDIT_2-1)>>3)
    andi r25, ~(1<<((NPC_BANDIT_2-1)&7))
    sts npc_presence+((NPC_BANDIT_2-1)>>3), r25
    sts player_effect, r1
    sts sector_npcs+NPC_MEMSIZE+NPC_EFFECT_OFFSET, r1
    ldi r25, ACTION_IDLE
    sts player_action, r25
    lds r24, player_xp
    lds r25, player_xp+1
    adiw r24, 10
    sts player_xp, r24
    sts player_xp+1, r25
_ssfc_end:
    ret

sector_start_pretown_1_update:
    player_distance_imm 170, 32
    cpi r25, 12
    brsh _ssp1u_end
    try_start_conversation interact_tutorial
_ssp1u_end:
    ret

sector_town_entrance_1_update:
    player_distance_imm 184, 130
    cpi r25, 16
    brsh _ste1u_interact
    try_start_conversation save_tutorial
    rjmp  _ste1u_check_quest
_ste1u_interact:
    player_distance_imm 86, 134
    cpi r25, 16
    brsh _ste1u_check_quest
    try_start_conversation interact_tutorial
_ste1u_check_quest:
    lds r25, global_data + QUEST_KIDNAPPED
    cpi r25, 4
    brne _ste1u_end
    ldi YL, low(sector_npcs)
    ldi YH, high(sector_npcs)
    ldi r24, SECTOR_DYNAMIC_NPC_COUNT
_ste1u_npc_iter:
    ldd r25, Y+NPC_IDX_OFFSET
    cpi r25, NPC_KIDNAPPED_FOLLOWING
    breq _ste1u_check_position
    adiw YL, NPC_MEMSIZE
    dec r24
    brne _ste1u_npc_iter
    rjmp _ste1u_end
_ste1u_check_position:
    ldd r22, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H
    ldd r23, Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H
    ldi r24, 86
    ldi r25, 134
    distance_between r24, r25, r22, r23
    cpi r25, 20
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
    ldi r24, low(2*_conv_kidnapped5)
    ldi r25, high(2*_conv_kidnapped5)
    rjmp _ste1c_end
_st1ec_accepted:
    cpi r23, 2
    brne _st1ec_fighting
    ldi r24, low(2*_conv_kidnapped6)
    ldi r25, high(2*_conv_kidnapped6)
    rjmp _ste1c_end
_st1ec_fighting:
    cpi r23, 5
    brsh _st1ec_rescued
    ldi r24, low(2*_conv_kidnapped9)
    ldi r25, high(2*_conv_kidnapped9)
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
    ldi r25, ITEM_health_potion
    sts sector_loose_items+SECTOR_DYNAMIC_ITEM_MEMSIZE*5+0, r25
    sts sector_loose_items+SECTOR_DYNAMIC_ITEM_MEMSIZE*5+1, r1
    ldi r25, 92
    sts sector_loose_items+SECTOR_DYNAMIC_ITEM_MEMSIZE*5+2, r25
    ldi r25, 140
    sts sector_loose_items+SECTOR_DYNAMIC_ITEM_MEMSIZE*5+3, r25
    ldi r23, 6
    sts global_data + QUEST_KIDNAPPED, r23
    ldi r24, low(2*_conv_kidnapped7)
    ldi r25, high(2*_conv_kidnapped7)
    rjmp _ste1c_end
_st1ec_completed:
    ldi r24, low(2*_conv_kidnapped8)
    ldi r25, high(2*_conv_kidnapped8)
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
    ldi r20, 4
    sts global_data + QUEST_KIDNAPPED, r20
    ldi r20, NPC_KIDNAPPED_FOLLOWING
    sts sector_npcs+NPC_IDX_OFFSET, r20
    ret

sector_town_tavern_1_update:
    player_distance_imm 75, 116
    cpi r25, 16
    brsh _stt1u_end
    try_start_conversation bartender
_stt1u_end:
    ret

sector_town_tavern_2_update:
    lds r25, sector_npcs+NPC_IDX_OFFSET
    cpi r25, NPC_ANNOYED_GUEST
    brne _stt2u_end
    lds r25, sector_loose_items+SECTOR_ITEM_IDX_OFFSET
    cpi r25, 128|50
    breq _stt2u_end
    lds r25, npc_presence+((NPC_ROBBED_GUEST-1)>>3)
    andi r25, 1<<((NPC_ROBBED_GUEST-1)&7)
    brne _stt2u_add_robbed
    sts sector_npcs+NPC_IDX_OFFSET, r1
    rjmp _stt2u_end
_stt2u_add_robbed:
    ldi r25, NPC_ROBBED_GUEST
    sts sector_npcs+NPC_IDX_OFFSET, r25
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
    ldi r25, 128|5
    sts sector_loose_items+SECTOR_DYNAMIC_ITEM_MEMSIZE*5+0, r25
    sts sector_loose_items+SECTOR_DYNAMIC_ITEM_MEMSIZE*5+1, r1
    ldi r25, 52
    sts sector_loose_items+SECTOR_DYNAMIC_ITEM_MEMSIZE*5+2, r25
    ldi r25, 41
    sts sector_loose_items+SECTOR_DYNAMIC_ITEM_MEMSIZE*5+3, r25
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
    ldi r25, NPC_UNDERCOVER_BANDIT_UNMASKED
    call add_npc
    ldi r24, 193
    ldi r25, 109
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H, r24
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H, r25
    ldi r25, DIRECTION_RIGHT
    std Y+NPC_ANIM_OFFSET, r25
    ldi r25, NPC_UNDERCOVER_GOON1
    call add_npc
    ldi r24, 183
    ldi r25, 118
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H, r24
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H, r25
    ldi r25, DIRECTION_RIGHT
    std Y+NPC_ANIM_OFFSET, r25
    ldi r25, NPC_UNDERCOVER_GOON2
    call add_npc
    ldi r24, 185
    ldi r25, 100
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H, r24
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H, r25
    ldi r25, DIRECTION_RIGHT
    std Y+NPC_ANIM_OFFSET, r25
    rjmp _stfi_end
_stfi_end:
    ret

sector_town_fields_update:
    sts npc_move_flags2, r1
    ldi r25, 3
    call release_if_damaged
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
    lds r25, npc_presence+((NPC_UNDERCOVER_BANDIT-1)>>3)
    andi r25, ~exp2((NPC_UNDERCOVER_BANDIT-1)&0x07)
    sts npc_presence+((NPC_UNDERCOVER_BANDIT-1)>>3), r25
_stfp2_end:
    ret

sector_town_forest_path_4_update:
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
    andi r25, ~exp2((NPC_UNDERCOVER_BANDIT-1)&0x07)
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

sector_start_pretown_2_update:
    sts npc_move_flags2, r1
    ldi r25, 4
    call release_if_damaged
    lds r25, sector_data
    ; 0 - nothing
    ; 1 - warned
    ; 2 - attacking
    ; 3 - allowing to pass
_ssp2u_warn:
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
    ldi r20, low(2*_conv_highway_guard9)
    ldi r21, high(2*_conv_highway_guard9)
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
