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
    call enemy_charge
    call enemy_update
    call enemy_sector_bounds
    movw ZL, r16
    call resolve_enemy_attack
    call resolve_player_attack
    rjmp _s0u_npc_next
_s0u_not_enemy:
    ldd r25, Y+NPC_IDX_OFFSET
    cpi r25, CORPSE_NPC
    brne _s0u_npc_next
    call corpse_update
_s0u_npc_next:
    adiw YL, NPC_MEMSIZE
    cpiw YL, YH, sector_npcs+NPC_MEMSIZE*SECTOR_DYNAMIC_NPC_COUNT, r25
    brlo _s0u_npc_iter
    ret

sector_0_event:
    ret
