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
;   event subroutines: r0, r24, r25, ZL, and ZL available

sector_0_update:
    ldi YL, low(sector_npcs)
    ldi YH, high(sector_npcs)
_s0u_npc_iter:
    ldd r25, Y+NPC_IDX_OFFSET
    dec r25
    brmi _s0u_npc_next
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
    brne _s0u_not_enemy
    movw r16, ZL
    lds r20, player_position_x
    lds r21, player_position_y
    sts npc_move_data, r20
    sts npc_move_data+1, r21
    ldi r20, NPC_MOVE_FRICTION|NPC_MOVE_GOTO|NPC_MOVE_ATTACK|NPC_MOVE_LOOKAT|NPC_MOVE_FALLOFF|NPC_MOVE_POLTROON|NPC_MOVE_RETURN
    sts npc_move_flags, r20
    call npc_move
    call npc_update
    movw ZL, r16
    call npc_resolve_ranged_damage
    call npc_resolve_melee_damage
    rjmp _s0u_npc_next
_s0u_not_enemy:
    ldd r25, Y+NPC_IDX_OFFSET
    cpi r25, CORPSE_NPC
    brne _s0u_other
_s0u_corpse:
    call corpse_update
    rjmp _s0u_npc_next
_s0u_other:
    movw r16, ZL
    call npc_update
    ldi r20, NPC_MOVE_FRICTION
    sts npc_move_flags, r20
    call npc_move
    movw ZL, r16
    call npc_resolve_ranged_damage
    call npc_resolve_melee_damage
_s0u_npc_next:
    adiw YL, NPC_MEMSIZE
    cpiw YL, YH, sector_npcs+NPC_MEMSIZE*SECTOR_DYNAMIC_NPC_COUNT, r25
    ; brlo _s0u_npc_iter
    brsh _s0u_work_done
    rjmp _s0u_npc_iter
_s0u_work_done:
    call reorder_npcs
    call player_resolve_melee_damage
    call player_resolve_effect_damage
    ret

sector_0_on_entry:
    ret

sector_0_on_pickup:
    sts framebuffer, r1
    ret

sector_0_on_conversation:
    sts framebuffer, r1
    ret

sector_0_on_choice:
    sts framebuffer, r1
    ret