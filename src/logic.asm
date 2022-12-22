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
    lds r25, sector_npcs+(NPC_MEMSIZE*2)+NPC_HEALTH_OFFSET ; health of BANDIT_3
    cpi r25, 10
    brsh _ssfu_fight
_ssfu_plead:
    try_start_conversation bandit_plead
    tst r25
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
    lds r25, sector_data
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

sector_start_fight_choice:
    lds r25, selected_choice
    inc r25
    sts sector_data, r25
    ret

sector_start_pretown_1_update:
    call update_standard
    player_distance_imm 170, 32
    cpi r25, 12
    brsh _ssp1u_end
    try_start_conversation interact_tutorial
_ssp1u_end:
    ret

sector_town_entrance_1_update:
    call kidnapped_quest_update
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
    cpi r25, NPC_KIDNAPPED
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
    brsh _stwu_attack
_stwu_lurk:
    lds r25, player_position_x
    cpi r25, 80
    brsh _stwu_end
    ldi r25, 3
    sts global_data + QUEST_KIDNAPPED, r25
_stwu_attack:
    call kidnapped_quest_update
_stwu_end:
    ret

sector_start_post_fight_update:
    lds r25, global_data + QUEST_KIDNAPPED
    cpi r25, 4
    brsh _sspfu_update_npcs
    player_distance_imm 134, 31
    cpi r25, 16
    brsh _sspfu_update_npcs
    ldi r24, low(2*_conv_kidnapped10)
    ldi r25, high(2*_conv_kidnapped10)
    call load_conversation
    ldi r25, 4
    sts global_data + QUEST_KIDNAPPED, r25
    rjmp _sspfu_end
_sspfu_update_npcs:
    call kidnapped_quest_update
_sspfu_end:
    ret

kidnapped_quest_update:
    call player_resolve_melee_damage
    call player_resolve_effect_damage
    ldi YL, low(sector_npcs)
    ldi YH, high(sector_npcs)
    ldi r16, SECTOR_DYNAMIC_NPC_COUNT
_kdqu_npc_iter:
    ldd r25, Y+NPC_IDX_OFFSET
    cpi r25, NPC_CORPSE
    brne _kdqu_not_corpse
    call corpse_update
    rjmp _kdqu_next_npc
_kdqu_not_corpse:
    subi r25, 1
    brlo _kdqu_next_npc
    ldi ZL, byte3(2*npc_table)
    out RAMPZ, ZL
    ldi ZL, low(2*npc_table)
    ldi ZH, high(2*npc_table)
    ldi r24, NPC_TABLE_ENTRY_MEMSIZE
    mul r24, r25
    add ZL, r0
    adc ZH, r1
    clr r1
    elpm r25, Z
    cpi r25, NPC_ENEMY
    brne _kdqu_next_npc
    push ZL
    push ZH
    ldi r25, NPC_MOVE_FRICTION|NPC_MOVE_GOTO|NPC_MOVE_ATTACK|NPC_MOVE_LOOKAT|NPC_MOVE_FALLOFF
    sts npc_move_flags, r25
    ldd r25, Y+NPC_IDX_OFFSET
    cpi r25, NPC_KIDNAPPED
    brne _kdqu_move
    lds r25, global_data + QUEST_KIDNAPPED
    cpi r25, 4
    breq _kdqu_move
_kdqu_no_move:
    ldi r25, NPC_MOVE_FRICTION
    sts npc_move_flags, r25
_kdqu_move:
    call npc_move
    call npc_update
    pop ZH
    pop ZL
    ldd r25, Y+NPC_IDX_OFFSET
    cpi r25, NPC_KIDNAPPED
    breq _kdqu_next_npc
    call npc_resolve_ranged_damage
    call npc_resolve_melee_damage
_kdqu_next_npc:
    adiw YL, NPC_MEMSIZE
    dec r16
    brne _kdqu_npc_iter
_kdqu_end:
    ret

sector_town_tavern_1_update:
    ldi r25, NPC_MOVE_FRICTION|NPC_MOVE_GOTO|NPC_MOVE_ATTACK|NPC_MOVE_LOOKAT
    sts npc_move_flags, r25
    call update_standard
_sst1u_store_tutorial:
    player_distance_imm 75, 116
    cpi r25, 16
    brsh _stt1u_end
    try_start_conversation bartender
_stt1u_end:
    ret

sector_town_tavern_2_update:
    ldi r25, NPC_MOVE_FRICTION|NPC_MOVE_GOTO|NPC_MOVE_ATTACK|NPC_MOVE_LOOKAT
    sts npc_move_flags, r25
    call update_standard
_stt2u_robbery:
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
    ldi r25, ITEM_wooden_bow
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
