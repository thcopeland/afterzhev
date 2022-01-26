; The complex game mechanics and interactions are governed by a pair of handler
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
; each sector to determine its mechanics. This is not the best way to achieve this,
; but it is probably one of the most flexible and should be all right for a small
; game.

sector_0_update:
    lds r23, sector_npcs+NPC_ANIM_OFFSET
    ldi YL, low(sector_npcs+NPC_POSITION_OFFSET)
    ldi YH, high(sector_npcs+NPC_POSITION_OFFSET)
    call enemy_patrol
    ret

sector_0_event:
    ret
