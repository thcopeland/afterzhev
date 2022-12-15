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
; Register Usage
;   update subroutine: all registers are available
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
    player_distance_imm 134, 128
    cpi r25, 18
    brsh _ss2u_test_ruffian
    try_start_conversation pickup_tutorial
_ss2u_test_ruffian:
    lds r25, player_position_x
    cpi r25, 160
    brlo _ss2u_move_enemies
    lds r25, player_position_y
    cpi r25, 60
    brsh _ss2u_move_enemies
_ss2u_halfing:
    lds r25, player_character
    cpi r25, CHARACTER_HALFLING
    brne _ss2u_main
    try_start_conversation_intern battle_tutorial_halfling, battle_tutorial
    rjmp _ss2u_move_enemies
_ss2u_main:
    try_start_conversation_intern battle_tutorial_generic, battle_tutorial
_ss2u_move_enemies:
    check_conversation battle_tutorial
    brne _ss2u_end
    ldi r25, NPC_MOVE_FRICTION|NPC_MOVE_GOTO|NPC_MOVE_ATTACK|NPC_MOVE_LOOKAT|NPC_MOVE_RETURN
    sts npc_move_flags, r25
    call update_standard
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
    ; in general, NPCs may be reordered, so this is a bit of a hack
    ; it works because (1) no reordering here and (2) it's the last NPC
    lds r25, sector_npcs+(NPC_MEMSIZE*2)+NPC_HEALTH_OFFSET ; health of BANDIT_3
    cpi r25, 10
    brsh _ssfu_fight
_ssfu_plead:
    try_start_conversation bandit_plead
    tst r25
    ; brne _ssfu_end
    breq _ssfu_fight
    ret
_ssfu_fight:
    ldi YL, low(sector_npcs)
    ldi YH, high(sector_npcs)
    ldi r25, NPC_MOVE_FRICTION|NPC_MOVE_GOTO|NPC_MOVE_ATTACK|NPC_MOVE_LOOKAT|NPC_MOVE_RETURN
    sts npc_move_flags, r25
    ldi r25, 2
    call update_multiple_npcs
    ldi r25, NPC_MOVE_FRICTION|NPC_MOVE_LOOKAT|NPC_MOVE_FALLOFF
    sts npc_move_flags, r25
    ldd r25, Y+NPC_IDX_OFFSET
    cpi r25, NPC_BANDIT_3
    brne _ssfu_last_bandit_update
_ssfu_last_bandit_stand:
    lds r25, last_choice
    cpi r25, 0
    brne _ssfu_last_bandit_attack
    ldi r25, NPC_MOVE_FRICTION|NPC_MOVE_ATTACK|NPC_MOVE_LOOKAT|NPC_MOVE_FALLOFF
    sts npc_move_flags, r25
    rjmp _ssfu_last_bandit_update
_ssfu_last_bandit_attack:
    cpi r25, 1
    brne _ssfu_reform_bandit
    ldi r25, NPC_MOVE_FRICTION|NPC_MOVE_ATTACK|NPC_MOVE_GOTO|NPC_MOVE_LOOKAT
    sts npc_move_flags, r25
    rjmp _ssfu_last_bandit_update
_ssfu_reform_bandit:
    ldi r25, NPC_BANDIT_3_REFORMED
    std Y+NPC_IDX_OFFSET, r25
    ldi r25, ITEM_bloody_sword
    sts sector_loose_items+SECTOR_DYNAMIC_ITEM_MEMSIZE*5+0, r25
    sts sector_loose_items+SECTOR_DYNAMIC_ITEM_MEMSIZE*5+1, r1
    ldi r25, 118
    sts sector_loose_items+SECTOR_DYNAMIC_ITEM_MEMSIZE*5+2, r25
    ldi r25, 150
    sts sector_loose_items+SECTOR_DYNAMIC_ITEM_MEMSIZE*5+3, r25
    lds r25, npc_presence+((NPC_BANDIT_3-1)>>3)
    andi r25, ~(1<<((NPC_BANDIT_3-1)&7))
    sts npc_presence+((NPC_BANDIT_3-1)>>3), r25
    sts player_effect, r1
    std Y+NPC_EFFECT_OFFSET, r1
    ldi r25, ACTION_IDLE
    sts player_action, r25
_ssfu_last_bandit_update:
    call update_single_npc
    call player_resolve_melee_damage
    call player_resolve_effect_damage
_ssfu_end:
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
    rjmp  _ste1u_end
_ste1u_interact:
    player_distance_imm 86, 134
    cpi r25, 16
    brsh _ste1u_end
    try_start_conversation interact_tutorial
_ste1u_end:
    ret

sector_town_entrance_1_conversation:
    ldi r23, high(2*_conv_kidnapped_daughter)
    cpi r24, low(2*_conv_kidnapped_daughter)
    cpc r25, r23
    brne _ste1c_end
    lds r23, global_data+QUEST_KIDNAPPED_DAUGHTER
_st1ec_not_begun:
    andi r23, 0x07
    breq _ste1c_end
_st1ec_refused:
    cpi r23, 1
    brne _st1ec_accepted
    ldi r24, low(2*_conv_kidnapped_daughter5)
    ldi r25, high(2*_conv_kidnapped_daughter5)
    rjmp _ste1c_end
_st1ec_accepted:
    cpi r23, 2
    brne _st1ec_fighting
    ldi r24, low(2*_conv_kidnapped_daughter6)
    ldi r25, high(2*_conv_kidnapped_daughter6)
    rjmp _ste1c_end
_st1ec_fighting:
    cpi r23, 5
    brsh _st1ec_rescued
    ldi r24, low(2*_conv_kidnapped_daughter9)
    ldi r25, high(2*_conv_kidnapped_daughter9)
    rjmp _ste1c_end
_st1ec_rescued:
    cpi r23, 5
    brne _st1ec_completed
    ; todo: drop potion
    ldi r23, 6
    sts global_data + QUEST_KIDNAPPED_DAUGHTER, r23
    ldi r24, low(2*_conv_kidnapped_daughter7)
    ldi r25, high(2*_conv_kidnapped_daughter7)
    rjmp _ste1c_end
_st1ec_completed:
    ldi r24, low(2*_conv_kidnapped_daughter8)
    ldi r25, high(2*_conv_kidnapped_daughter8)
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
    sts global_data + QUEST_KIDNAPPED_DAUGHTER, r25
    rjmp _ste1ch_end
_ste1ch_accept:
    ldi r25, 1
    sts global_data + QUEST_KIDNAPPED_DAUGHTER, r25
_ste1ch_end:
    ret

sector_town_wolves_update:
    lds r25, global_data + QUEST_KIDNAPPED_DAUGHTER
    cpi r25, 3
    brsh _stwu_attack
_stwu_lurk:
    lds r25, player_position_y
    cpi r25, 96
    brlo _stwu_end
    ldi r25, 3
    sts global_data + QUEST_KIDNAPPED_DAUGHTER, r25
    rjmp _stwu_end
_stwu_attack:
    ldi r25, NPC_MOVE_FRICTION|NPC_MOVE_GOTO|NPC_MOVE_ATTACK|NPC_MOVE_LOOKAT|NPC_MOVE_FALLOFF
    sts npc_move_flags, r25
    call update_standard
_stwu_end:
    ret

sector_start_post_fight_update:
    lds r25, global_data + QUEST_KIDNAPPED_DAUGHTER
    cpi r25, 4
    brsh _sspfu_follow
    player_distance_imm 134, 31
    cpi r25, 16
    brsh _sspfu_end
    ldi r24, low(2*_conv_kidnapped_daughter10)
    ldi r25, high(2*_conv_kidnapped_daughter10)
    call load_conversation
    ldi r25, 4
    sts global_data + QUEST_KIDNAPPED_DAUGHTER, r25
    rjmp _sspfu_end
_sspfu_follow:
    ldi YL, low(sector_npcs)
    ldi YH, high(sector_npcs)
    lds r25, sector_npcs+NPC_IDX_OFFSET
    tst r25
    breq _sspfu_check_add_follower
    ldi r25, NPC_MOVE_FRICTION|NPC_MOVE_GOTO|NPC_MOVE_LOOKAT
    sts npc_move_flags, r25
    call update_single_npc
    rjmp _sspfu_end
_sspfu_check_add_follower:
    lds r25, sector_data
    cpi r25, 20
    brsh _sspfu_add_follow
    inc r25
    sts sector_data, r25
    rjmp _sspfu_end
_sspfu_add_follow:
    ldi r25, NPC_KIDNAPPED_DAUGHTER
    call load_npc
    ldi r25, 168
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_X_H, r25
    std Y+NPC_POSITION_OFFSET+CHARACTER_POSITION_Y_H, r1
    ldi r25, DIRECTION_DOWN
    std Y+NPC_ANIM_OFFSET, r25
_sspfu_end:
    ret

sector_start_post_fight_init:
    lds r25, global_data + QUEST_KIDNAPPED_DAUGHTER
    cpi r25, 4
    brlo _sspfi_end
    sts sector_data, r1
    sts sector_npcs+NPC_IDX_OFFSET, r1
_sspfi_end:
    ret
