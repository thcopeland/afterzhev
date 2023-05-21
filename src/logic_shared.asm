; Shared behavior for sector logic

; Clear the sector-specific data. Assumes four bytes, fails to assemble otherwise.
;
; Register Usage
;   r1          zero
clear_sector_data:
    sts sector_data, r1
.if SECTOR_DATA_MEMSIZE != 1
    .error "clear_sector_data clears only 1 bytes of sector data, adjust as necessary"
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
    add r25, r24
    brcc _pdi_3_%
    ser r25
_pdi_3_%:
.endm

; Calculate the distance from the player to the given coordinates.
;
; Register Usage
;   r24-r25     calculations
.macro player_distance ; x, y
    lds r24, player_position_x
    lds r25, player_position_y
    distance_between r24, r25, @0, @1
.endm

; Check whether a conversation has occurred or not. Z flag is cleared if it has.
;
; Register Usage
;   r24     update conversation mask
;   r25     previous conversation mask
.macro check_conversation ; conversation id
    lds r24, conversation_over + ((CONVERSATION_@0_ID-1)>>3)
    mov r25, r24
    andi r24, low(~(1<<((CONVERSATION_@0_ID-1)&7)))
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

; Add an NPC to the sector, if there's an available slot and the NPC has not been
; killed. r25 is cleared on success.
;
; Register Usage
;   r20-r21         calculations
;   r25             NPC id (param)
;   Y (r28:r29)     temp
add_npc:
    ldi YL, low(npc_presence)
    ldi YH, high(npc_presence)
    mov r20, r25
    dec r20
    brmi _an_end
    mov r21, r20
    lsr r20
    lsr r20
    lsr r20
    add YL, r20
    adc YH, r1
    ld r20, Y
    nbit r20, r21
    breq _an_end
    ldi YL, low(sector_npcs)
    ldi YH, high(sector_npcs)
    ldi r20, SECTOR_DYNAMIC_NPC_COUNT
_an_npc_iter:
    ld r21, Y
    tst r21
    breq _an_slot_found
    adiw YL, NPC_MEMSIZE
    dec r20
    brne _an_npc_iter
    rjmp _an_end
_an_slot_found:
    call load_npc
    clr r25
_an_end:
    ret

; Add an NPC to the sector, if there's an available slot.
;
; Register Usage
;   r20-r21         calculations
;   r25             NPC id (param)
;   Y (r28:r29)     temp
add_npc_direct:
    ldi YL, low(sector_npcs)
    ldi YH, high(sector_npcs)
    ldi r20, SECTOR_DYNAMIC_NPC_COUNT
_and_npc_iter:
    ld r21, Y
    tst r21
    breq _and_slot_found
    adiw YL, NPC_MEMSIZE
    dec r20
    brne _and_npc_iter
    rjmp _and_end
_and_slot_found:
    call load_npc
_and_end:
    ret

; Return a pointer to the given NPC. r20 will be cleared if not found.
;
; Register Usage
;   r20-r21         calculations
;   r25             NPC id (param)
;   Y (r28:r29)     temp
find_npc:
    ldi YL, low(sector_npcs)
    ldi YH, high(sector_npcs)
    ldi r20, SECTOR_DYNAMIC_NPC_COUNT
_fn_npc_iter:
    ld r21, Y
    cp r21, r25
    breq _fn_end
    adiw YL, NPC_MEMSIZE
    dec r20
    brne _fn_npc_iter
_fn_end:
    ret

; Release hold if any of the first N NPCs are damaged.
;
; Register Usage
;   r23-r24         calculations
;   r25             check first N NPCs (param)
;   Y (r28:r29)     npc pointer
;   Z (r30:r31)     flash pointer
release_if_damaged:
    ldi ZL, byte3(2*npc_table)
    out RAMPZ, ZL
    ldi YL, low(sector_npcs)
    ldi YH, high(sector_npcs)
    tst r25
    breq _rid_end
_rid_loop:
    ldd r23, Y+NPC_IDX_OFFSET
    subi r23, 1
    brlo _rid_next
    ldi ZL, low(2*npc_table+NPC_TABLE_HEALTH_OFFSET)
    ldi ZH, high(2*npc_table+NPC_TABLE_HEALTH_OFFSET)
    ldi r24, NPC_TABLE_ENTRY_MEMSIZE
    mul r23, r24
    add ZL, r0
    adc ZH, r1
    clr r1
    elpm r23, Z
    ldd r24, Y+NPC_HEALTH_OFFSET
    cp r24, r23
    brlo _rid_damaged
_rid_next:
    adiw YL, NPC_MEMSIZE
    dec r25
    brne _rid_loop
_rid_end:
    ret
_rid_damaged:
    ldi r25, 1
    sts npc_move_flags2, r25
    ret

; Occasionally, add NPCs at the sector avenger locations.
;
; Register Usage
;   r20-r21     calculations
;   r22         clock mask (param)
;   r23         random threshold (param)
;   r24         index offset mask (param)
;   r25         base NPC index (param)
;   Y (r28:r29) NPC pointer
spawn_distant_npcs:
    lds r20, clock
    and r20, r22
    brne _sdn_end
    cp r2, r23
    brsh _sdn_end
    ldi YL, low(sector_npcs)
    ldi YH, high(sector_npcs)
    clr r22
    ldi r23, SECTOR_DYNAMIC_NPC_COUNT
_sdn_loop:
    ldd r20, Y+NPC_IDX_OFFSET
    tst r20
    breq _sdn_next
    cpi r20, NPC_CORPSE
    breq _sdn_next
    inc r22
_sdn_next:
    adiw YL, NPC_MEMSIZE
    dec r23
    brne _sdn_loop
    cpi r22, 4
    brsh _sdn_end
    mov r20, r2
    and r20, r24
    add r25, r20
    call add_distant_npc
_sdn_end:
    ret

; Add an item at the given coordinates. If there's no empty slot, replaces the
; last item.
;
; Register Usage
;   r22             calculations
;   r23             item (param)
;   r24, r25        coordinates (param)
;   Z (r30:r31)     item pointer
drop_item:
    ldi ZL, low(sector_loose_items)
    ldi ZH, high(sector_loose_items)
    ldi r22, SECTOR_DYNAMIC_ITEM_COUNT
_di_loop:
    ldd r0, Z+SECTOR_ITEM_IDX_OFFSET
    tst r0
    breq _di_add_item
_di_next:
    adiw ZL, SECTOR_DYNAMIC_ITEM_MEMSIZE
    dec r22
    brne _di_loop
_di_no_slots:
    sbiw ZL, SECTOR_DYNAMIC_ITEM_MEMSIZE
_di_add_item:
    std Z+SECTOR_ITEM_IDX_OFFSET, r23
    std Z+SECTOR_ITEM_PREPLACED_IDX_OFFSET, r1
    std Z+SECTOR_ITEM_X_OFFSET, r24
    std Z+SECTOR_ITEM_Y_OFFSET, r25
_di_end:
    ret
