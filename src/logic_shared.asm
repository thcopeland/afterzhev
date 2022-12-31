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
; killed.
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
_an_end:
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
