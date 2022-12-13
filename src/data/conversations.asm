; A conversation consists of a tree of lines and branches. A line is a screen o
; text spoken by a character leading to another line or a branch, and a branch
; presents the player with 1-4 choices, which lead to different lines.
;
; Conversations can be assigned an ID, which allows us to track whether it has
; occurred or not. However conversation IDs are not stored in the conversation
; table. Most are stored in the world data, and some are handled ad hoc in the
; game sector logic.
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

.set __CONVERSATION_IDX = 1
.macro DECL_CONVERSATION ; name
    .equ CONVERSATION_@0_ID = __CONVERSATION_IDX
    .set __CONVERSATION_IDX = __CONVERSATION_IDX+1
.endm

.macro DECL_LINE ; line, npc, speaker, next
    .db CONVERSATION_LINE, @1
    .dw 2*(_conv_speaker_@2_str-conversation_string_table)
    .dw 2*(_conv_@0_str-conversation_string_table)
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
DECL_CONVERSATION what_happened
_conv_what_happened:            DECL_LINE what_happened, 0, PLAYER, what_happened2
_conv_what_happened2:           DECL_LINE what_happened2, 0, PLAYER, what_happened3
_conv_what_happened3:           DECL_LINE what_happened3, 0, PLAYER, END_CONVERSATION
DECL_CONVERSATION pickup_tutorial
_conv_pickup_tutorial:          DECL_LINE pickup_tutorial, 0, PLAYER, pickup_tutorial2
_conv_pickup_tutorial2:         DECL_LINE pickup_tutorial2, 0, PLAYER, END_CONVERSATION
DECL_CONVERSATION battle_tutorial
_conv_battle_tutorial_halfling: DECL_LINE battle_tutorial_halfling, NPC_BATTLE_TUTORIAL, ruffian, battle_tutorial2
_conv_battle_tutorial_generic:  DECL_LINE battle_tutorial, NPC_BATTLE_TUTORIAL, ruffian, battle_tutorial2
_conv_battle_tutorial2:         DECL_BRANCH 3
                                DECL_CHOICE battle_tutorial_c1, battle_tutorial3
                                DECL_CHOICE battle_tutorial_c2, battle_tutorial4
                                DECL_CHOICE battle_tutorial_c3, battle_tutorial3
_conv_battle_tutorial3:         DECL_LINE battle_tutorial3, NPC_BATTLE_TUTORIAL, ruffian, battle_tutorial4
_conv_battle_tutorial4:         DECL_LINE battle_tutorial4, 0, PLAYER, END_CONVERSATION
DECL_CONVERSATION loot_tutorial
_conv_loot_tutorial:            DECL_LINE loot_tutorial, 0, PLAYER, loot_tutorial2
_conv_loot_tutorial2:           DECL_LINE loot_tutorial2, 0, PLAYER, END_CONVERSATION
DECL_CONVERSATION bandit_plead
_conv_bandit_plead:             DECL_LINE bandit_plead, NPC_BANDIT_3, bandit, bandit_plead2
_conv_bandit_plead2:            DECL_LINE bandit_plead2, 0, PLAYER, bandit_plead3
_conv_bandit_plead3:            DECL_LINE bandit_plead3, NPC_BANDIT_3, bandit, bandit_plead4
_conv_bandit_plead4:            DECL_LINE bandit_plead4, 0, PLAYER, bandit_plead5
_conv_bandit_plead5:            DECL_LINE bandit_plead5, NPC_BANDIT_3, bandit, bandit_plead_spare
_conv_bandit_plead_spare:       DECL_BRANCH 2
                                DECL_CHOICE bandit_plead_c1, END_CONVERSATION
                                DECL_CHOICE bandit_plead_c2, bandit_plead6
_conv_bandit_plead6:            DECL_LINE bandit_plead6, NPC_BANDIT_3, bandit, END_CONVERSATION

conversation_string_table:
_conv_speaker_PLAYER_str:       ; placeholder
_conv_speaker_ruffian_str:      .db "Ruffian", 0
_conv_speaker_bandit_str:       .db "Bandit", 0, 0
_conv_what_happened_str:        .db "Ugh...  what happened?", 10, 10, 10, 10, 10, 10, "          Press <A> to continue", 0
_conv_what_happened2_str:       .db "How long have I been asleep?", 10, 10, "By Jove! Where are my weapons?", 10, "Where", 39, "s the letter?" , 0, 0
_conv_what_happened3_str:       .db "It must have been stolen. I haveto get it back at any cost.", 0
_conv_pickup_tutorial_str:      .db "Press <select> to pick up items.", 0, 0
_conv_pickup_tutorial2_str:     .db "Press <start> to view inventory.", 0, 0
_conv_battle_tutorial_halfling_str:.db "Hey you! Yeah you, shorty! No", 10, "passing without paying!", 0
_conv_battle_tutorial_str:      .db "Hey you! Yeah you, ugly! No", 10, "passing without paying!", 0
_conv_battle_tutorial_c1_str:   .db "I swear, I don", 39, "t have anything.", 0
_conv_battle_tutorial_c2_str:   .db "I", 39, "m ready for you, villain!", 0
_conv_battle_tutorial_c3_str:   .db "Begone, scoundrel. I am an", 10, "envoy of the queen, dare not", 10, "hinder me.", 0, 0
_conv_battle_tutorial3_str:     .db "Heh, heh. I", 39, "m gonna enjoy this.", 0
_conv_battle_tutorial4_str:     .db 10, 10, 10, 10, 10, "  Press <A> to defend yourself", 10, "      and <B> to dash.", 0, 0
_conv_loot_tutorial_str:        .db "I think he got the point.", 0
_conv_loot_tutorial2_str:       .db 10, 10, 10, 10, 10, 10, "Press <select> to loot corpses.", 0
_conv_bandit_plead_str:         .db "I yield! Spare me, adventurer!", 0, 0
_conv_bandit_plead2_str:        .db "Then tell me quickly: did you", 10, "steal my letter?", 0, 0
_conv_bandit_plead3_str:        .db "Uh... it weren", 39, "t I, adventurer!", 10, "The others took it, but the big", 10, "boss", 39, "s men have it now.", 0
_conv_bandit_plead4_str:        .db "Big boss?", 0
_conv_bandit_plead5_str:        .db "His gang have a house in the woodwest of the town. Please,", 10, "adventure, we didn", 39, "t harm you!", 0
_conv_bandit_plead_c1_str:      .db "Ha! That letter means my life,", 10, "you will pay dearly!", 0
_conv_bandit_plead_c2_str:      .db "I spare you. But you must stop", 10, "robbing travelers.", 0
_conv_bandit_plead6_str:        .db "I swear it! I give you my sword asproof.", 0, 0
