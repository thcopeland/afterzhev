; A conversation consists of a tree of lines and branches. A line is a screen o
; text spoken by a character leading to another line or a branch, and a branch
; presents the player with 1-4 choices, which lead to different lines.
;
; Line Layout (8 bytes)
;   line type - always CONVERSATION_LINE (1 byte)
;   NPC id - used for rendering, 0 indicates the player (1 byte)
;   speaker name ptr - (2 bytes)
;   line ptr - (2 bytes)
;   next frame ptr - or zero, for the end (2 bytes)

; Branch Layout (6 - 22 bytes)
;   type - always CONVERSATION_BRANCH (1 byte)
;   number of choices - shouldn't exceed 5 (1 byte)
;   choice 1 description ptr - (2 bytes)
;   choice 1 next frame ptr - (2 bytes)
;   choice 2 description ptr - (2 bytes)
;   choice 2 next frame ptr - (2 bytes)
;       .
;       .
;       .

.equ CONVERSATION_LINE = 0
.equ CONVERSATION_BRANCH = 1

.macro DECL_LINE ; npc, speaker, line, next
    .db CONVERSATION_LINE, @0
    .dw 2*(_conv_speaker_@1_str-conversation_string_table)
    .dw 2*(_conv_line_@2_str-conversation_string_table)
    .dw 2*(_conv_@3-conversation_table)
.endm

.macro DECL_BRANCH ; number
    .db CONVERSATION_BRANCH, @0
.endm

.macro DECL_CHOICE ; choice, consequent frame
    .dw 2*(_conv_@0_str-conversation_string_table)
    .dw 2*(_conv_@1-conversation_table)
.endm

conversation_table:
_conv_END_CONVERSATION:         .dw 0 ; placeholder
_conv_fisherman_greeting:       DECL_LINE 5, fisherman, fisherman_greeting, respond_to_greeting
_conv_fisherman_laugh:          DECL_LINE 5, fisherman, fisherman_laugh, END_CONVERSATION
_conv_respond_to_greeting:      DECL_BRANCH 3
                                DECL_CHOICE choose_polite_agreement, END_CONVERSATION
                                DECL_CHOICE choose_no_time, END_CONVERSATION
                                DECL_CHOICE choose_share, none_to_spare
_conv_none_to_spare:            DECL_LINE 5, fisherman, none_to_spare, END_CONVERSATION

conversation_string_table:
_conv_speaker_PLAYER_str:       ; placeholder
_conv_speaker_fisherman_str:        .db "Provincial Fisherman", 0, 0
_conv_line_fisherman_greeting_str:  .db "Nice day for fishing, ain", 39, "t it?", 0
_conv_line_fisherman_laugh_str:     .db "Huah hah!", 0
_conv_choose_polite_agreement_str:  .db "Indeed it is.", 0
_conv_choose_no_time_str:           .db "I", 39, "ve no time for fish... or stupid fishermen.", 0
_conv_choose_share_str:             .db "Yup... say, you wouldn", 39, "t happen to have any extra?", 0, 0
_conv_line_none_to_spare_str:       .db "No.", 0
