; Shared behavior for sector logic

; Clear the sector-specific data. Assumes four bytes, fails to assemble otherwise.
;
; Register Usage
;   r1          zero
clear_sector_data:
    sts sector_data+1, r1
    sts sector_data+1, r1
    sts sector_data+1, r1
    sts sector_data+1, r1
.if SECTOR_DATA_MEMSIZE != 4
    .error "clear_sector_data clears only 4 bytes of sector, adjust as necessary"
.endif
    ret

; Calculate the distance from the player to the immediate coordinates.
;
; Register Usage
;   r24-r25     calculations
.macro player_distance_imm ; x, y
    lds r24, player_position_x
    lds r25, player_position_y
    subi r24, @0-CHARACTER_SPRITE_WIDTH/2
    brsh _pdi_1_%
    neg r24
_pdi_1_%:
    subi r25, @1-CHARACTER_SPRITE_HEIGHT/2
    brsh _pdi_2_%
    neg r25
_pdi_2_%:
    adnv r25, r24
.endm

; Calculate the distance from the player to the given coordinates.
;
; Register Usage
;   r24-r25     calculations
.macro player_distance ; x, y
    lds r24, player_position_x
    lds r25, player_position_y
    sub r24, @0
    brsh _pd_1_%
    neg r24
_pd_1_%:
    sub r25, @1
    brsh _pd_2_%
    neg r25
_pd_2_%:
    adnv r25, r24
.endm

; Check whether a conversation has occurred or not. Z flag is cleared if it has.
;
; Register Usage
;   r24     update conversation mask
;   r25     previous conversation mask
.macro check_conversation ; conversation id
    lds r24, conversation_over + ((CONVERSATION_@0_ID-1)>>3)
    mov r25, r24
    andi r24, ~(1<<((CONVERSATION_@0_ID-1)&7))
    cp r25, r24
.endm

; Start a conversation unless it has already been started. r25 is cleared if the
; conversation fails, set to a nonzero value otherwise.
;
; Register Usage
;   r24, r25    calculations
.macro try_start_conversation_intern ; conversation name, conversation id
    check_conversation @1
    ldi r25, 0
    breq _tsc_end_%
    sts conversation_over + ((CONVERSATION_@1_ID-1)>>3), r24
    ldi r24, low(2*_conv_@0)
    ldi r25, high(2*_conv_@0)
    call load_conversation
_tsc_end_%:
.endm

; Start a conversation unless it has already been started.
;
; Register Usage
;   r24, r25    calculations
.macro try_start_conversation ; conversation name
    try_start_conversation_intern @0, @0
.endm

; Standard NPC update routine.
;
; Register Usage
;   r0, r16-r27 calculations
;   r20-r27     NPC move flags for each enemy (param)
update_sector_npcs:
.if PC_SIZE == 3
    pop r0  ; save one byte of stack
.endif
    ; this uses a lot of SRAM, but the call tree at this point should be only
    ; one or two frames deep (assuming it's called from game logic), compared
    ; to five or six elsewhere, so it's fine.
    push r27
    push r26
    push r25
    push r24
    push r23
    push r22
    push r21
    push r20
    lds r20, player_position_x
    lds r21, player_position_y
    sts npc_move_data, r20
    sts npc_move_data+1, r21
    ldi YL, low(sector_npcs)
    ldi YH, high(sector_npcs)
_usn_loop:
    pop r24
    sts npc_move_flags, r24
    ldd r25, Y+NPC_IDX_OFFSET
    subi r25, 1
    brlo _usn_next
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
    brne _usn_check_corpse
    movw r16, ZL
    call npc_move
    call npc_update
    movw ZL, r16
    call npc_resolve_ranged_damage
    call npc_resolve_melee_damage
    rjmp _usn_next
_usn_check_corpse:
    ldd r25, Y+NPC_IDX_OFFSET
    cpi r25, NPC_CORPSE
    brne _usn_next
    call corpse_update
    rjmp _usn_next
_usn_next:
    adiw YL, NPC_MEMSIZE
    cpiw YL, YH, sector_npcs+NPC_MEMSIZE*SECTOR_DYNAMIC_NPC_COUNT, r25
    brlo _usn_loop
_usn_cleanup:
    call reorder_npcs
    ; TODO these should arguably be done elsewhere, might change if helpful
    call player_resolve_melee_damage
    call player_resolve_effect_damage
.if PC_SIZE == 3
    push r1
.endif
    ret
