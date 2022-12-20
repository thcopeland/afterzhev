conversation_update_game:
    rcall conversation_render_game
    rcall conversation_handle_controls

    lds r25, conversation_chars
    cpi r25, 0xff
    brsh _cug_end
    inc r25
    sts conversation_chars, r25
_cug_end:
    jmp _loop_reenter

; Handle controls in the conversation mode. If the current conversation frame is
; a "line", the first special button advances to the next frame. Otherwise, the
; directional buttons allow the player to select a response, and the first special
; button allows you to use it.
;
; Register Usage
;   r18-r19         controller values
;   r20-r25         calculations
;   Z (r30:r31)     memory lookups
conversation_handle_controls:
    lds r18, prev_controller_values
    lds r19, controller_values
    com r18
    and r18, r19
    breq _chc_no_recent_keydowns
    sts mode_clock, r1
    rjmp _chc_check_frame_type
_chc_no_recent_keydowns:
    lds r20, mode_clock
    inc r20
    sts mode_clock, r20
    andi r20, 15
    breq _chc_check_frame_type
    rjmp _chc_end
_chc_check_frame_type:
    ldi ZL, byte3(2*conversation_table)
    out RAMPZ, ZL
    lds ZL, conversation_frame
    lds ZH, conversation_frame+1
    elpm r20, Z
    cpi r20, CONVERSATION_BRANCH
    breq _chc_branch_button1
_chc_line_button1:
    sbrs r18, CONTROLS_SPECIAL1
    rjmp _chc_end
    adiw ZL, CONVERSATION_LINE_NEXT_OFFSET
    elpm r24, Z+
    elpm r25, Z+
    subi r24, low(-2*conversation_table)
    sbci r25, high(-2*conversation_table)
    call load_conversation
    rjmp _chc_end
_chc_branch_button1:
    sbrs r18, CONTROLS_SPECIAL1
    rjmp _chc_branch_down
    adiw ZL, CONVERSATION_BRANCH_CHOICE1_OFFSET+2
    lds r20, selected_choice
    ldi r21, CONVERSATION_BRANCH_CHOICE_MEMSIZE
    mul r20, r21
    add ZL, r0
    adc ZH, r1
    clr r1
    elpm r24, Z+
    elpm r25, Z+
    subi r24, low(-2*conversation_table)
    sbci r25, high(-2*conversation_table)
    ldi ZL, byte3(2*sector_table)
    out RAMPZ, ZL
    lds ZL, current_sector
    lds ZH, current_sector+1
    subi ZL, low(-SECTOR_ON_CHOICE_OFFSET)
    sbci ZH, high(-SECTOR_ON_CHOICE_OFFSET)
    elpm r20, Z+
    elpm r21, Z+
    cp r20, r1
    cpc r21, r1
    breq _chc_do_conversation
    movw ZL, r20
    movw r20, r24
    icall
    movw r24, r20
_chc_do_conversation:
    call load_conversation
    rjmp _chc_end
_chc_branch_down:
    sbrs r19, CONTROLS_DOWN
    rjmp _chc_branch_up
    lds r20, selected_choice
    inc r20
    adiw ZL, CONVERSATION_BRANCH_NUM_OFFSET
    elpm r21, Z
    cp r20, r21
    brsh _chc_end
    sts selected_choice, r20
_chc_branch_up:
    sbrs r19, CONTROLS_UP
    rjmp _chc_end
    lds r20, selected_choice
    dec r20
    brmi _chc_end
    sts selected_choice, r20
_chc_end:
    ret

; Load the given conversation. This is also used to advance the current
; conversation and return to explore mode.
;
; Register Usage
;   r20         calculations
;   r24:r25     conversation pointer (param)
load_conversation:
    cpiw r24, r25, 2*_conv_END_CONVERSATION, r20
    brne _lc_load_conversation
_lc_clear_conversation:
    ldi r20, MODE_EXPLORE
    sts game_mode, r20
    ret
_lc_load_conversation:
    sts conversation_frame, r24
    sts conversation_frame+1, r25
    sts selected_choice, r1
    sts conversation_chars, r1
    ldi r20, MODE_CONVERSATION
    sts game_mode, r20
    sts player_velocity_x, r1
    sts player_velocity_y, r1
    ret

.equ CONVERSATION_UI_BODY_COLOR = INVENTORY_UI_BODY_COLOR
.equ CONVERSATION_UI_HEADER_COLOR = INVENTORY_UI_HEADER_COLOR
.equ CONVERSATION_UI_HEADER_HEIGHT = 16
.equ CONVERSATION_UI_SPEAKER_MARGIN = 2*DISPLAY_WIDTH + 2
.equ CONVERSATION_UI_SPEAKER_LABEL_MARGIN = 6*DISPLAY_WIDTH + 18
.equ CONVERSATION_UI_MESSAGE_MARGIN = 20*DISPLAY_WIDTH + 3
.equ CONVERSATION_UI_CHOICE1_MARGIN = 20*DISPLAY_WIDTH + 8

; Render the current conversation line or branch.
;
; Register Usage
;   r14-r16     used to store values across subroutine calls
;   r18-r25     calculations
;   X, Y, Z     memory
conversation_render_game:
_crg_render_background:
    ldi XL, low(framebuffer)
    ldi XH, high(framebuffer)
    ldi r22, CONVERSATION_UI_HEADER_COLOR
    ldi r24, DISPLAY_WIDTH
    ldi r25, CONVERSATION_UI_HEADER_HEIGHT
    call render_rect
    ldi XL, low(framebuffer+DISPLAY_WIDTH*CONVERSATION_UI_HEADER_HEIGHT)
    ldi XH, high(framebuffer+DISPLAY_WIDTH*CONVERSATION_UI_HEADER_HEIGHT)
    ldi r22, CONVERSATION_UI_BODY_COLOR
    ldi r24, DISPLAY_WIDTH
    ldi r25, DISPLAY_HEIGHT-CONVERSATION_UI_HEADER_HEIGHT
    call render_rect
    ldi ZL, byte3(2*conversation_table)
    out RAMPZ, ZL
    lds ZL, conversation_frame
    lds ZH, conversation_frame+1
    movw r16, ZL
    elpm r20, Z
    cpi r20, CONVERSATION_LINE
    breq _crg_render_line
    rjmp _crg_render_branch
_crg_render_line:
    ldi XL, low(framebuffer+CONVERSATION_UI_SPEAKER_MARGIN)
    ldi XH, high(framebuffer+CONVERSATION_UI_SPEAKER_MARGIN)
    adiw ZL, CONVERSATION_LINE_NPC_OFFSET
    elpm r20, Z
    dec r20
    brmi _crg_render_player
_crg_render_npc:
    ldi ZL, low(2*npc_table+NPC_TABLE_CHARACTER_OFFSET)
    ldi ZH, high(2*npc_table+NPC_TABLE_CHARACTER_OFFSET)
    ldi r21, NPC_TABLE_ENTRY_MEMSIZE
    mul r20, r21
    add ZL, r0
    adc ZH, r1
    clr r1
    lpm r20, Z+
    cpi r20, 128
    brlo _crg_render_dynamic_npc
_crg_render_static_npc:
    andi r20, low(~128)
    ldi ZL, byte3(2*static_character_sprite_table)
    out RAMPZ, ZL
    ldi ZL, low(2*static_character_sprite_table)
    ldi ZH, high(2*static_character_sprite_table)
    ldi r21, CHARACTER_SPRITE_MEMSIZE
    mul r20, r21
    add ZL, r0
    adc ZH, r1
    clr r1
    ldi r21, CHARACTER_SPRITE_WIDTH
    clr r22
    ldi r23, CHARACTER_SPRITE_HEIGHT
    clr r24
    ldi r25, CHARACTER_SPRITE_WIDTH
    call write_sprite
    rjmp _crg_render_npc_name
_crg_render_dynamic_npc:
    sts character_render+CHARACTER_SPRITE_OFFSET, r20
    lpm r20, Z+
    sts character_render+CHARACTER_WEAPON_OFFSET, r20
    lpm r20, Z+
    sts character_render+CHARACTER_ARMOR_OFFSET, r20
    ldi YL, low(character_render)
    ldi YH, high(character_render)
    call render_character_icon
_crg_render_npc_name:
    ldi ZL, byte3(2*conversation_table)
    out RAMPZ, ZL
    movw ZL, r16
    adiw ZL, CONVERSATION_LINE_SPEAKER_OFFSET
    elpm r20, Z+
    elpm r21, Z+
    movw ZL, r20
    ldi YL, low(framebuffer+CONVERSATION_UI_SPEAKER_LABEL_MARGIN)
    ldi YH, high(framebuffer+CONVERSATION_UI_SPEAKER_LABEL_MARGIN)
    subi ZL, low(-2*conversation_string_table)
    sbci ZH, high(-2*conversation_string_table)
    ldi r21, 20
    clr r23
    call puts
    rjmp _crg_render_message
_crg_render_player:
    ldi YL, low(player_character)
    ldi YH, high(player_character)
    call render_character_icon
    ldi ZL, byte3(2*class_table)
    out RAMPZ, ZL
    ldi ZL, low(2*class_table+CLASS_NAME_OFFSET)
    ldi ZH, high(2*class_table+CLASS_NAME_OFFSET)
    lds r20, player_class
    andi r20, 0xf
    ldi r21, CLASS_MEMSIZE
    mul r20, r21
    add ZL, r0
    adc ZH, r1
    clr r1
    ldi YL, low(framebuffer+CONVERSATION_UI_SPEAKER_LABEL_MARGIN)
    ldi YH, high(framebuffer+CONVERSATION_UI_SPEAKER_LABEL_MARGIN)
    ldi r21, 20
    clr r23
    call puts
_crg_render_message:
    ldi ZL, byte3(2*conversation_table)
    out RAMPZ, ZL
    movw ZL, r16
    adiw ZL, CONVERSATION_LINE_STR_OFFSET
    elpm r20, Z+
    elpm r21, Z+
    movw ZL, r20
    ldi YL, low(framebuffer+CONVERSATION_UI_MESSAGE_MARGIN)
    ldi YH, high(framebuffer+CONVERSATION_UI_MESSAGE_MARGIN)
    subi ZL, low(-2*conversation_string_table)
    sbci ZH, high(-2*conversation_string_table)
    ldi r21, 28
    clr r23
    lds r24, conversation_chars
    call puts_n
    ret
_crg_render_branch:
    ldi XL, low(framebuffer+CONVERSATION_UI_SPEAKER_MARGIN)
    ldi XH, high(framebuffer+CONVERSATION_UI_SPEAKER_MARGIN)
    ldi YL, low(player_character)
    ldi YH, high(player_character)
    call render_character_icon
    ldi ZL, byte3(2*class_table)
    out RAMPZ, ZL
    ldi ZL, low(2*class_table+CLASS_NAME_OFFSET)
    ldi ZH, high(2*class_table+CLASS_NAME_OFFSET)
    lds r20, player_class
    andi r20, 0xf
    ldi r21, CLASS_MEMSIZE
    mul r20, r21
    add ZL, r0
    adc ZH, r1
    clr r1
    ldi YL, low(framebuffer+CONVERSATION_UI_SPEAKER_LABEL_MARGIN)
    ldi YH, high(framebuffer+CONVERSATION_UI_SPEAKER_LABEL_MARGIN)
    ldi r21, 20
    clr r23
    call puts
    ldi ZL, byte3(2*conversation_table)
    out RAMPZ, ZL
    movw ZL, r16
    adiw ZL, CONVERSATION_BRANCH_NUM_OFFSET
    elpm r14, Z+
    ldi YL, low(framebuffer+CONVERSATION_UI_CHOICE1_MARGIN)
    ldi YH, high(framebuffer+CONVERSATION_UI_CHOICE1_MARGIN)
    movw ZL, r16
    adiw ZL, CONVERSATION_BRANCH_CHOICE1_OFFSET
    movw r16, ZL
    lds r15, selected_choice
_crg_render_choices_iter:
    clr r23
    tst r15
    brne _crg_render_choice
    movw XL, YL
    subi XL, low(5*FONT_DISPLAY_WIDTH/3)
    sbci XH, high(5*FONT_DISPLAY_WIDTH/3)
    ldi r22, 128
    ldi r23, 0x04
    call putc
_crg_render_choice:
    movw ZL, r16
    elpm r20, Z+
    elpm r21, Z+
    movw ZL, r20
    subi ZL, low(-2*conversation_string_table)
    sbci ZH, high(-2*conversation_string_table)
    ldi r21, 27
    call puts
_crg_render_choice_next:
    subi YL, low(-3*FONT_DISPLAY_HEIGHT/2*DISPLAY_WIDTH)
    sbci YH, high(-3*FONT_DISPLAY_HEIGHT/2*DISPLAY_WIDTH)
    movw ZL, r16
    adiw ZL, CONVERSATION_BRANCH_CHOICE_MEMSIZE
    movw r16, ZL
    dec r15
    dec r14
    brne _crg_render_choices_iter
    ret
