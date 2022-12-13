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
;   event subroutines: r0, r24, r25, ZL, and ZH available

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
    brne _ssfu_end
_ssfu_fight:
    lds r20, player_position_x
    lds r21, player_position_y
    sts npc_move_data, r20
    sts npc_move_data+1, r21
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
_ssfu_last_bandit_update:
    call update_single_npc
    call player_resolve_melee_damage
    call player_resolve_effect_damage
_ssfu_end:
    ret
