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

    .if __CONVERSATION_IDX == TOTAL_CONVERSATION_COUNT
        .error "Too many conversations"
    .endif
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
                                DECL_CHOICE plead, battle_tutorial3
                                DECL_CHOICE threaten, battle_tutorial4
                                DECL_CHOICE bluff, battle_tutorial5
_conv_battle_tutorial3:         DECL_LINE battle_tutorial3, 0, PLAYER, battle_tutorial6
_conv_battle_tutorial4:         DECL_LINE battle_tutorial4, 0, PLAYER, battle_tutorial6
_conv_battle_tutorial5:         DECL_LINE battle_tutorial5, 0, PLAYER, battle_tutorial6
_conv_battle_tutorial6:         DECL_LINE battle_tutorial6, NPC_BATTLE_TUTORIAL, ruffian, battle_tutorial7
_conv_battle_tutorial7:         DECL_LINE battle_tutorial7, 0, PLAYER, END_CONVERSATION
DECL_CONVERSATION loot_tutorial
_conv_loot_tutorial:            DECL_LINE loot_tutorial, 0, PLAYER, loot_tutorial2
_conv_loot_tutorial2:           DECL_LINE loot_tutorial2, 0, PLAYER, END_CONVERSATION
DECL_CONVERSATION bandit_plead
_conv_bandit_plead:             DECL_LINE bandit_plead, NPC_BANDIT_2, bandit, bandit_plead2
_conv_bandit_plead2:            DECL_LINE bandit_plead2, 0, PLAYER, bandit_plead3
_conv_bandit_plead3:            DECL_LINE bandit_plead3, NPC_BANDIT_2, bandit, bandit_plead4
_conv_bandit_plead4:            DECL_LINE bandit_plead4, 0, PLAYER, bandit_plead5
_conv_bandit_plead5:            DECL_LINE bandit_plead5, NPC_BANDIT_2, bandit, bandit_plead6
_conv_bandit_plead6:            DECL_BRANCH 2
                                DECL_CHOICE punish, bandit_plead7
                                DECL_CHOICE spare, bandit_plead8
_conv_bandit_plead7:            DECL_LINE bandit_plead7, 0, PLAYER, END_CONVERSATION
_conv_bandit_plead8:            DECL_LINE bandit_plead8, 0, PLAYER, bandit_plead9
_conv_bandit_plead9:            DECL_LINE bandit_plead9, NPC_BANDIT_2, bandit, END_CONVERSATION
DECL_CONVERSATION interact_tutorial
_conv_interact_tutorial:        DECL_LINE interact_tutorial, 0, PLAYER, END_CONVERSATION
DECL_CONVERSATION drunks_warning
_conv_drunks_warning:           DECL_LINE drunks_warning, NPC_DRUNK, drunk, drunks_warning2
_conv_drunks_warning2:          DECL_LINE drunks_warning2, NPC_DRUNK, drunk, END_CONVERSATION
DECL_CONVERSATION save_tutorial
_conv_save_tutorial:            DECL_LINE save_tutorial, 0, PLAYER, END_CONVERSATION
_conv_kidnapped:                DECL_LINE kidnapped, NPC_GRIEVING_FATHER, grieving_father, kidnapped2
_conv_kidnapped2:               DECL_BRANCH 3
                                DECL_CHOICE kidnapped3, kidnapped4
                                DECL_CHOICE accept, kidnapped5
                                DECL_CHOICE refuse, kidnapped6
_conv_kidnapped4:               DECL_LINE kidnapped4, 0, PLAYER, kidnapped7
_conv_kidnapped5:               DECL_LINE kidnapped5, 0, PLAYER, kidnapped8
_conv_kidnapped6:               DECL_LINE kidnapped6, 0, PLAYER, END_CONVERSATION
_conv_kidnapped7:               DECL_LINE kidnapped7, NPC_GRIEVING_FATHER, grieving_father, kidnapped2
_conv_kidnapped8:               DECL_LINE kidnapped8, NPC_GRIEVING_FATHER, grieving_father, END_CONVERSATION
_conv_kidnapped9:               DECL_LINE kidnapped9, NPC_GRIEVING_FATHER, grieving_father, END_CONVERSATION
_conv_kidnapped10:              DECL_LINE kidnapped10, NPC_GRIEVING_FATHER, grieving_father, END_CONVERSATION
_conv_kidnapped11:              DECL_LINE kidnapped11, NPC_GRIEVING_FATHER, grieving_father, END_CONVERSATION
_conv_kidnapped12:              DECL_LINE my_thanks, NPC_GRIEVING_FATHER, grieving_father, END_CONVERSATION
_conv_kidnapped13:              DECL_LINE kidnapped13, NPC_GRIEVING_FATHER, grieving_father, END_CONVERSATION
DECL_CONVERSATION rescue_kidnapped
_conv_rescue_kidnapped:         DECL_LINE rescue_kidnapped, 0, PLAYER, END_CONVERSATION
DECL_CONVERSATION nice_day
_conv_nice_day:                 DECL_LINE nice_day, NPC_FISHERMAN, fisherman, nice_day2
_conv_nice_day2:                DECL_BRANCH 2
                                DECL_CHOICE yes, nice_day3
                                DECL_CHOICE no, nice_day3
_conv_nice_day3:                DECL_LINE nice_day3, NPC_FISHERMAN, fisherman, END_CONVERSATION
DECL_CONVERSATION welcome
_conv_welcome:                  DECL_LINE welcome, NPC_WELCOME, farmer, welcome2
_conv_welcome2:                 DECL_LINE welcome2, NPC_WELCOME, farmer, welcome3
_conv_welcome3:                 DECL_BRANCH 3
                                DECL_CHOICE welcome4, welcome7
                                DECL_CHOICE welcome5, welcome8
                                DECL_CHOICE welcome6, END_CONVERSATION
_conv_welcome7:                 DECL_LINE welcome7, 0, PLAYER, welcome9
_conv_welcome8:                 DECL_LINE welcome8, 0, PLAYER, welcome11
_conv_welcome9:                 DECL_LINE welcome9, NPC_WELCOME, farmer, welcome10
_conv_welcome10:                DECL_LINE welcome10, NPC_WELCOME, farmer, welcome3
_conv_welcome11:                DECL_LINE welcome11, NPC_WELCOME, farmer, welcome12
_conv_welcome12:                DECL_LINE welcome12, NPC_WELCOME, farmer, welcome13
_conv_welcome13:                DECL_LINE welcome13, 0, PLAYER, welcome14
_conv_welcome14:                DECL_LINE welcome14, NPC_WELCOME, farmer, welcome3
_conv_tavern_sign:              DECL_LINE tavern_sign, NPC_TAVERN_SIGN, empty, END_CONVERSATION
DECL_CONVERSATION bartender
_conv_bartender:                DECL_LINE bartender, NPC_BARTENDER, bartender, bartender2
_conv_bartender2:               DECL_LINE bartender2, 0, PLAYER, END_CONVERSATION
DECL_CONVERSATION drunk_hiccup
_conv_drunk_hiccup:             DECL_LINE drunk_hiccup, NPC_DRUNK2, drunk, drunk_hiccup2
_conv_drunk_hiccup2:            DECL_LINE drunk_hiccup2, NPC_DRUNK2, drunk, drunk_hiccup3
_conv_drunk_hiccup3:            DECL_LINE drunk_hiccup3, NPC_DRUNK2, drunk, drunk_hiccup4
_conv_drunk_hiccup4:            DECL_LINE drunk_hiccup4, NPC_BARTENDER, bartender, drunk_hiccup5
_conv_drunk_hiccup5:            DECL_LINE drunk_hiccup5, NPC_DRUNK2, drunk, END_CONVERSATION
_conv_whit_ye_daen:             DECL_LINE whit_ye_daen, NPC_ANNOYED_GUEST, inn_guest, END_CONVERSATION
DECL_CONVERSATION robbed_guest
_conv_robbed_guest:             DECL_LINE robbed_guest, NPC_ROBBED_GUEST, inn_guest, END_CONVERSATION
_conv_guest_quest:              DECL_LINE guest_quest, NPC_GUEST_QUEST, inn_guest, guest_quest2
_conv_guest_quest2:             DECL_LINE guest_quest2, NPC_GUEST_QUEST, inn_guest, guest_quest3
_conv_guest_quest3:             DECL_BRANCH 2
                                DECL_CHOICE accept, guest_quest4
                                DECL_CHOICE refuse, guest_quest5
_conv_guest_quest4:             DECL_LINE guest_quest4, NPC_GUEST_QUEST, inn_guest, END_CONVERSATION
_conv_guest_quest5:             DECL_LINE guest_quest5, NPC_GUEST_QUEST, inn_guest, END_CONVERSATION
_conv_guest_quest6:             DECL_LINE guest_quest6, NPC_GUEST_QUEST, inn_guest, END_CONVERSATION
_conv_guest_quest7:             DECL_LINE guest_quest7, NPC_GUEST_QUEST, inn_guest, guest_quest8
_conv_guest_quest8:             DECL_LINE guest_quest8, NPC_GUEST_QUEST, inn_guest, END_CONVERSATION
_conv_guest_quest9:             DECL_LINE guest_quest9, NPC_GUEST_QUEST, inn_guest, END_CONVERSATION
_conv_just_beat_it:             DECL_LINE just_beat_it, NPC_GRUFF_BOUNCER, bouncer, END_CONVERSATION
DECL_CONVERSATION bandit_lies
_conv_bandit_lies1:             DECL_LINE bandit_lies1, NPC_UNDERCOVER_BANDIT, undercover, bandit_lies2
_conv_bandit_lies2:             DECL_LINE bandit_lies2, 0, PLAYER, bandit_lies3
_conv_bandit_lies3:             DECL_LINE bandit_lies3, NPC_UNDERCOVER_BANDIT, undercover, bandit_lies4
_conv_bandit_lies4:             DECL_LINE bandit_lies4, NPC_UNDERCOVER_BANDIT, undercover, bandit_good_luck
_conv_bandit_good_luck:         DECL_LINE bandit_good_luck, NPC_UNDERCOVER_BANDIT, undercover, END_CONVERSATION
DECL_CONVERSATION bandit_reveal
_conv_bandit_left_reveal1:      DECL_LINE bandit_left_reveal1, NPC_UNDERCOVER_BANDIT_UNMASKED, bandit_agent, bandit_left_reveal2
_conv_bandit_left_reveal2:      DECL_LINE bandit_left_reveal2, 0, PLAYER, bandit_left_reveal3
_conv_bandit_left_reveal3:      DECL_LINE bandit_left_reveal3, NPC_UNDERCOVER_BANDIT_UNMASKED, bandit_agent, END_CONVERSATION
_conv_bandit_right_reveal:      DECL_LINE bandit_right_reveal, NPC_UNDERCOVER_BANDIT_UNMASKED, bandit_agent, END_CONVERSATION
_conv_foxes_didnt_do_this:      DECL_LINE foxes_didnt_do_this, 0, PLAYER, END_CONVERSATION
DECL_CONVERSATION bandit_speech
_conv_bandit_speech:            DECL_LINE bandit_speech, NPC_DEN_BANDIT_CHIEF, bandit_chief, bandit_speech2
_conv_bandit_speech2:           DECL_LINE bandit_speech2, 0, PLAYER, bandit_speech3
_conv_bandit_speech3:           DECL_LINE bandit_speech3, NPC_DEN_BANDIT_CHIEF, bandit_chief, END_CONVERSATION
DECL_CONVERSATION find_pass
_conv_find_pass:                DECL_LINE find_pass, 0, PLAYER, find_pass2
_conv_find_pass2:               DECL_LINE find_pass2, 0, PLAYER, find_pass3
_conv_find_pass3:               DECL_LINE find_pass3, 0, PLAYER, END_CONVERSATION
DECL_CONVERSATION highway_guard
_conv_highway_guard:            DECL_LINE highway_guard, NPC_HIGHWAY_GUARD_1, highway_guard, highway_guard3
_conv_highway_guard2:           DECL_LINE highway_guard2, NPC_HIGHWAY_GUARD_1, highway_guard, highway_guard3
_conv_highway_guard3:           DECL_BRANCH 4
                                DECL_CHOICE highway_guard4, highway_guard8
                                DECL_CHOICE highway_guard5, highway_guard9
                                DECL_CHOICE highway_guard6, highway_guard10
                                DECL_CHOICE highway_guard7, highway_guard11
_conv_highway_guard8:           DECL_LINE highway_guard8, 0, PLAYER, highway_guard12
_conv_highway_guard9:           DECL_LINE highway_guard9, 0, PLAYER, highway_guard15
_conv_highway_guard10:          DECL_LINE highway_guard10, 0, PLAYER, highway_guard16
_conv_highway_guard11:          DECL_LINE highway_guard11, 0, PLAYER, END_CONVERSATION
_conv_highway_guard12:          DECL_LINE highway_guard12, NPC_HIGHWAY_GUARD_1, highway_guard, highway_guard13
_conv_highway_guard13:          DECL_LINE highway_guard13, 0, PLAYER, highway_guard14
_conv_highway_guard14:          DECL_LINE highway_guard14, NPC_HIGHWAY_GUARD_1, highway_guard, highway_guard3
_conv_highway_guard15:          DECL_LINE highway_guard15, NPC_HIGHWAY_GUARD_1, highway_guard, END_CONVERSATION
_conv_highway_guard16:          DECL_LINE highway_guard16, NPC_HIGHWAY_GUARD_1, highway_guard, END_CONVERSATION
_conv_highway_guard17:          DECL_LINE highway_guard10, 0, PLAYER, highway_guard18
_conv_highway_guard18:          DECL_LINE highway_guard18, NPC_HIGHWAY_GUARD_1, highway_guard, END_CONVERSATION
DECL_CONVERSATION cold_feet
_conv_cold_feet:               DECL_LINE cold_feet, NPC_COLD_FEET, scared_bandit, cold_feet2
_conv_cold_feet2:              DECL_LINE cold_feet2, NPC_COLD_FEET, scared_bandit, cold_feet3
_conv_cold_feet3:              DECL_LINE cold_feet3, NPC_COLD_FEET, scared_bandit, END_CONVERSATION
DECL_CONVERSATION lonely_poet
_conv_poet1:                    DECL_LINE poet1, NPC_LONELY_POET, poet, poet2
_conv_poet2:                    DECL_BRANCH 2
                                DECL_CHOICE poet2_c1, poet3
                                DECL_CHOICE poet2_c2, poet5
_conv_poet3:                    DECL_LINE poet3, 0, PLAYER, poet4
_conv_poet4:                    DECL_LINE poet4, NPC_LONELY_POET, poet, END_CONVERSATION
_conv_poet5:                    DECL_LINE poet5, 0, PLAYER, poet6
_conv_poet6:                    DECL_LINE poet6, NPC_LONELY_POET, poet, END_CONVERSATION
_conv_poet7:                    DECL_LINE poet7, NPC_LONELY_POET, poet, END_CONVERSATION
DECL_CONVERSATION welcome_to_haldir
_conv_haldir1:                  DECL_LINE haldir1, NPC_HALDIR_GUARD, haldir_guard, haldir2
_conv_haldir2:                  DECL_BRANCH 4
                                DECL_CHOICE haldir2_c1, haldir3
                                DECL_CHOICE haldir2_c2, haldir5
                                DECL_CHOICE haldir2_c3, haldir7
                                DECL_CHOICE haldir2_c4, END_CONVERSATION
_conv_haldir3:                  DECL_LINE haldir3, 0, PLAYER, haldir4
_conv_haldir4:                  DECL_LINE haldir4, NPC_HALDIR_GUARD, haldir_guard, haldir4_2
_conv_haldir4_2:                DECL_LINE haldir4_2, NPC_HALDIR_GUARD, haldir_guard, haldir2
_conv_haldir5:                  DECL_LINE haldir5, 0, PLAYER, haldir6
_conv_haldir6:                  DECL_LINE haldir6, NPC_HALDIR_GUARD, haldir_guard, haldir2
_conv_haldir7:                  DECL_LINE haldir7, 0, PLAYER, haldir8
_conv_haldir8:                  DECL_LINE haldir8, NPC_HALDIR_GUARD, haldir_guard, haldir2
_conv_bard1:                    DECL_LINE bard1, NPC_BARD, bard, bard2
_conv_bard2:                    DECL_BRANCH 2
                                DECL_CHOICE accept, bard3
                                DECL_CHOICE refuse, END_CONVERSATION
_conv_bard3:                    DECL_LINE bard3, NPC_BARD, bard, bard4
_conv_bard4:                    DECL_LINE bard4, NPC_BARD, bard, bard5
_conv_bard5:                    DECL_LINE bard5, NPC_BARD, bard, bard6
_conv_bard6:                    DECL_LINE bard6, NPC_BARD, bard, bard2
_conv_no_message:               DECL_LINE no_message, NPC_HALDIR_GUARD_2, haldir_guard, END_CONVERSATION
_conv_somethings_wrong:         DECL_LINE somethings_wrong, NPC_CITIZEN_1, citizen, END_CONVERSATION
_conv_might_leave:              DECL_LINE might_leave, NPC_CITIZEN_2, citizen, END_CONVERSATION
_conv_leaving:                  DECL_LINE leaving, NPC_CITIZEN_3, citizen, leaving2
_conv_leaving2:                 DECL_LINE leaving2, NPC_CITIZEN_3, citizen, END_CONVERSATION
_conv_field_foxes:              DECL_LINE field_foxes, NPC_FIELD_QUESTGIVER, citizen, field_foxes2
_conv_field_foxes2:             DECL_LINE field_foxes2, NPC_FIELD_QUESTGIVER, citizen, END_CONVERSATION
_conv_cant_leave:               DECL_LINE cant_leave, 0, PLAYER, END_CONVERSATION
_conv_kill_thieves1:            DECL_LINE kill_thieves1, NPC_BANK_QUESTGIVER, bank_guard, kill_thieves2
_conv_kill_thieves2:            DECL_LINE kill_thieves2, NPC_BANK_QUESTGIVER, bank_guard, kill_thieves3
_conv_kill_thieves3:            DECL_LINE kill_thieves3, NPC_BANK_QUESTGIVER, bank_guard, kill_thieves4
_conv_kill_thieves4:            DECL_BRANCH 3
                                DECL_CHOICE kill_thieves7, kill_thieves8
                                DECL_CHOICE accept, kill_thieves10
                                DECL_CHOICE refuse, kill_thieves5
_conv_kill_thieves5:            DECL_LINE kill_thieves5, NPC_BANK_QUESTGIVER, bank_guard, END_CONVERSATION
_conv_kill_thieves6:            DECL_LINE kill_thieves6, NPC_BANK_QUESTGIVER, bank_guard, kill_thieves4
_conv_kill_thieves8:            DECL_LINE kill_thieves8, 0, PLAYER, kill_thieves9
_conv_kill_thieves9:            DECL_LINE kill_thieves9, NPC_BANK_QUESTGIVER, bank_guard, kill_thieves4
_conv_kill_thieves10:           DECL_LINE kill_thieves10, NPC_BANK_QUESTGIVER, bank_guard, END_CONVERSATION
_conv_kill_thieves11:           DECL_LINE kill_thieves11, NPC_BANK_QUESTGIVER, bank_guard, END_CONVERSATION
_conv_kill_thieves12:           DECL_LINE kill_thieves12, NPC_BANK_QUESTGIVER, bank_guard, END_CONVERSATION
_conv_bank_warning:             DECL_LINE bank_warning, NPC_BANK_GUARD_1, bank_guard, END_CONVERSATION
_conv_rob_bank1:                DECL_LINE rob_bank1, NPC_THIEF_QUESTGIVER, dodgy_fellow, rob_bank2
_conv_rob_bank2:                DECL_LINE rob_bank2, 0, PLAYER, rob_bank3
_conv_rob_bank3:                DECL_LINE rob_bank3, NPC_THIEF_QUESTGIVER, dodgy_fellow, rob_bank4
_conv_rob_bank4:                DECL_BRANCH 2
                                DECL_CHOICE accept, rob_bank7
                                DECL_CHOICE refuse, rob_bank6
_conv_rob_bank5:                DECL_LINE rob_bank5, NPC_THIEF_QUESTGIVER, dodgy_fellow, rob_bank4
_conv_rob_bank6:                DECL_LINE rob_bank6, NPC_THIEF_QUESTGIVER, dodgy_fellow, END_CONVERSATION
_conv_rob_bank7:                DECL_LINE rob_bank7, NPC_THIEF_QUESTGIVER, dodgy_fellow, END_CONVERSATION
_conv_rob_bank8:                DECL_LINE rob_bank8, NPC_THIEF_QUESTGIVER, dodgy_fellow, END_CONVERSATION
_conv_rob_bank9:                DECL_LINE rob_bank9, NPC_THIEF_QUESTGIVER, dodgy_fellow, END_CONVERSATION
_conv_thieves_warning:          DECL_LINE thieves_warning, NPC_THIEF_QUESTGIVER, dodgy_fellow, END_CONVERSATION
_conv_bridge_broken:            DECL_LINE bridge_broken, NPC_BRIDGE_BROKEN, citizen, bridge_broken2
_conv_bridge_broken2:           DECL_LINE bridge_broken2, NPC_BRIDGE_BROKEN, citizen, END_CONVERSATION

conversation_string_table:
_conv_speaker_PLAYER_str:       ; placeholder
_conv_speaker_ruffian_str:      .db "Ruffian", 0
_conv_speaker_bandit_str:       .db "Bandit", 0, 0
_conv_speaker_drunk_str:        .db "Town drunk", 0, 0
_conv_speaker_fisherman_str:    .db "Fisherman", 0
_conv_speaker_farmer_str:       .db "Farmer", 0, 0
_conv_speaker_grieving_father_str: .db "Grieving father", 0
_conv_speaker_bartender_str:    .db "Bartender", 0
_conv_speaker_inn_guest_str:    .db "Tavern guest", 0, 0
_conv_speaker_bouncer_str:      .db "Bouncer", 0
_conv_speaker_bandit_chief_str: .db "Bandit chief", 0, 0
_conv_speaker_undercover_str:   .db "Cloaked villager", 0, 0
_conv_speaker_bandit_agent_str: .db "Bandit agent", 0, 0
_conv_speaker_highway_guard_str:.db "Highway guard", 0
_conv_speaker_scared_bandit_str:.db "Trepid bandit", 0
_conv_speaker_poet_str:         .db "Lonely poet", 0
_conv_speaker_haldir_guard_str: .db "Haldir guard", 0, 0
_conv_speaker_bard_str:         .db "Bard", 0, 0
_conv_speaker_citizen_str:      .db "Citizen", 0
_conv_speaker_bank_guard_str:   .db "Bank guard", 0, 0
_conv_speaker_dodgy_fellow_str: .db "Dodgy citizen", 0
_conv_speaker_empty_str:        .db 0, 0
_conv_what_happened_str:        .db "Ugh...  what happened?", 10, 10, 10, 10, 10, 10, "          Press <A> to continue", 0
_conv_what_happened2_str:       .db "How long have I been asleep?", 10, 10, "By Jove! Where are my weapons?", 10, "Where", 39, "s the letter?" , 0, 0
_conv_what_happened3_str:       .db "It must have been stolen. I haveto get it back at any cost.", 0
_conv_pickup_tutorial_str:      .db "Press <select> to pick up items.", 0, 0
_conv_pickup_tutorial2_str:     .db "Press <start> to view inventory.", 0, 0
_conv_battle_tutorial_halfling_str:.db "Hey you! Yeah you, shorty! No", 10, "passing without paying!", 0
_conv_battle_tutorial_str:      .db "Hey you! Yeah you, ugly! No", 10, "passing without paying!", 0
_conv_battle_tutorial3_str:     .db "I swear, I don", 39, "t have anything.", 0
_conv_battle_tutorial4_str:     .db "Begone, scoundrel. I am an", 10, "envoy of the queen, dare not", 10, "hinder me.", 0, 0
_conv_battle_tutorial5_str:     .db "Come on, then! Killing bandits is my favorite sport!", 0, 0
_conv_battle_tutorial6_str:     .db "Heh, heh. I", 39, "m gonna enjoy this.", 0
_conv_battle_tutorial7_str:     .db 10, 10, 10, 10, 10, "  Press <A> to defend yourself", 10, "      and <B> to dash.", 0, 0
_conv_threaten_str:             .db "Threaten", 0, 0
_conv_plead_str:                .db "Plead", 0
_conv_bluff_str:                .db "Bluff", 0
_conv_loot_tutorial_str:        .db "I think he got the point.", 0
_conv_loot_tutorial2_str:       .db 10, 10, 10, 10, 10, 10, "Press <select> to loot corpses.", 0
_conv_bandit_plead_str:         .db "I yield! Spare me, adventurer!", 0, 0
_conv_bandit_plead2_str:        .db "Then tell me quickly: did you", 10, "steal my letter?", 0, 0
_conv_bandit_plead3_str:        .db "Uh... it weren", 39, "t I, adventurer!", 10, "The others took it, but the big", 10, "boss", 39, "s men have it now.", 0
_conv_bandit_plead4_str:        .db "Big boss?", 0
_conv_bandit_plead5_str:        .db "His gang have a house in the woodeast of the town. Please,", 10, "adventurer, we didn", 39, "t harm you!", 0, 0
_conv_bandit_plead7_str:        .db "Ha! That letter means my life,", 10, "you will pay dearly!", 0
_conv_bandit_plead8_str:        .db "I spare you. But you must stop", 10, "robbing travelers.", 0
_conv_bandit_plead9_str:        .db "I swear it! I give you my sword asproof.", 0, 0
_conv_punish_str:               .db "Punish", 0, 0
_conv_spare_str:                .db "Spare", 0
_conv_interact_tutorial_str:    .db 10, 10, 10, 10, 10, 10, "    Press <select> to interact.", 0
_conv_drunks_warning_str:       .db "Say, ya just come outta them", 10, "woods?", 0
_conv_drunks_warning2_str:      .db "Be careful! There", 39, "s bandits", 10, "about, doncha know!", 0
_conv_save_tutorial_str:        .db 10, 10, 10, 10, 10, 10, "Press <select> to save progress", 0
_conv_kidnapped_str:            .db "Please help, adventurer! My", 10, "poor boy has been kidnapped by", 10, "the foxes!", 0
_conv_kidnapped3_str:           .db "Ask about the foxes", 0
_conv_kidnapped4_str:           .db "Foxes?", 0, 0
_conv_kidnapped5_str:           .db "Tell me where they are, and", 10, "I", 39, "ll bring him home!", 0, 0
_conv_kidnapped6_str:           .db "I", 39, "m sorry stranger, but I have", 10, "an important mission.", 0, 0
_conv_kidnapped7_str:           .db "Please, adventurer, we don", 39, "t", 10, "have much time!", 0, 0
_conv_kidnapped8_str:           .db "Oh, thank you, adventurer! The", 10, "foxes lurk in the woods. If you", 10, "follow the path behind the houseyou", 39, "ll surely find them.", 0
_conv_kidnapped9_str:           .db "Leave me, cruel adventurer!", 0
_conv_kidnapped10_str:          .db "Hurry, adventurer!", 0, 0
_conv_kidnapped11_str:          .db "Thank you, adventurer! Please", 10, "accept this potion in token of mydeepest gratitude!", 0
_conv_my_thanks_str:            .db "My thanks, adventurer!", 0, 0
_conv_kidnapped13_str:          .db "Foxes too much for you,", 10, "adventurer? My poor boy!", 0, 0
_conv_rescue_kidnapped_str:     .db "Come with me if you want to live!", 0
_conv_nice_day_str:             .db "Mornin", 39, "! Nice day for fishing,", 10, "ain", 39, "t it?", 0, 0
_conv_yes_str:                  .db "Yes", 0
_conv_no_str:                   .db "No", 0, 0
_conv_accept_str:               .db "Accept", 0, 0
_conv_refuse_str:               .db "Refuse", 0, 0
_conv_nice_day3_str:            .db "Huah hah!", 0
_conv_welcome_str:              .db "Hello there, adventurer! And", 10, "welcome to Frogford town!", 0, 0
_conv_welcome2_str:             .db "Anything I can do for you?", 0, 0
_conv_welcome4_str:             .db "Ask about bandits", 0
_conv_welcome5_str:             .db "Ask about Dor Haldir", 0, 0
_conv_welcome6_str:             .db "Leave", 0
_conv_welcome7_str:             .db "Bandits have stolen something", 10, "of mine, I must find them.", 0, 0
_conv_welcome8_str:             .db "How can I get to the city of Dor", 10, "Haldir?", 0, 0
_conv_welcome9_str:             .db "Speak softly, adventurer... yes,I", 39, "ve heard the bandits have somesort of hideout in the woods eastof here.", 0
_conv_welcome10_str:            .db "But be careful! I", 39, "ve no doubt youare a capable warrior, but the", 10, "bandits are a fearsome band. I", 10, "should rest here a while before", 10, "doing anything rash.", 0
_conv_welcome11_str:            .db "Dor Haldir? That", 39, "s an easy one,", 10, "adventurer, just follow the", 10, "main road south.", 0, 0
_conv_welcome12_str:            .db "But I warn you, the Highway", 10, "Guard has closed the road. They won", 39, "t let anyone through withouta pass.", 0
_conv_welcome13_str:            .db "Whyever not?", 0, 0
_conv_welcome14_str:            .db "The Guard won", 39, "t say. But as an", 10, "adventurer, you may be able to", 10, "get more out of them.", 0
_conv_tavern_sign_str:          .db "The Bristling Boar: Tavern & Inn", 10, 10, 10, 10, 10, 10, "        A Licensed Victualler", 0
_conv_bartender_str:            .db "What ho, adventurer! Can I", 10, "interest you in a drink or two?", 0, 0
_conv_bartender2_str:           .db 10, 10, 10, 10, 10, "  Press <A> to buy items", 10, "      and <B> to sell.", 0, 0
_conv_drunk_hiccup_str:         .db "H-hey you! You ain", 39, "t from these", 10, "parts, huh?", 0
_conv_drunk_hiccup2_str:        .db "Ha... you look like one of them", 10, "envoys.", 0
_conv_drunk_hiccup3_str:        .db "Yeah... Ah useta be like you...", 10, "watch out, they", 39, "ll throw y-you", 10, "away too.", 0, 0
_conv_drunk_hiccup4_str:        .db "Hey drunk! Leave the adventureralone!", 0
_conv_drunk_hiccup5_str:        .db "Hic!", 0, 0
_conv_whit_ye_daen_str:         .db "And whit dae ye think ye", 39, "re daen", 39, 10, "here?", 0
_conv_robbed_guest_str:         .db "Sae! A thief, are ye?", 0
_conv_guest_quest_str:          .db "Hello, adventurer! What are youdoing in my room?", 0, 0
_conv_guest_quest2_str:         .db "Silent type, eh? Doesn", 39, "t matter.Listen, I", 39, "ve lost my journal", 10, "somewhere around town. Could", 10, "you find it for me? There", 39, "ll be", 10, "something in it for you.", 0, 0
_conv_guest_quest4_str:         .db "Very obliging of you!", 0
_conv_guest_quest5_str:         .db "Fine, I", 39, "ll find it myself. I can dothat, you know.", 0, 0
_conv_guest_quest6_str:         .db "Got my journal yet?", 0
_conv_guest_quest7_str:         .db "Changed your mind, eh?", 0, 0
_conv_guest_quest8_str:         .db "Well, I thank you for returning my journal, adventurer. I, uh,", 10, "hope you didn", 39, "t read... anyway,", 10, "take this gold.", 0, 0
_conv_guest_quest9_str:         .db "What do you want now? Hoping", 10, "you", 39, "ll get more for hanging", 10, "around?", 0, 0
_conv_just_beat_it_str:         .db "Just keep moving, stranger.", 0
_conv_bandit_lies1_str:         .db "Adventurer! At last you", 39, "ve come to rid us of these blasted", 10, "bandits!", 0
_conv_bandit_lies2_str:         .db "If you", 39, "ll tell me where they areI shall do my best.", 0
_conv_bandit_lies3_str:         .db "Right glad I am to hear that!", 0
_conv_bandit_lies4_str:         .db "Two paths lead into the woods,", 10, "take the small, northern one.", 10, "It", 39, "ll be on your left.", 0
_conv_bandit_good_luck_str:     .db "Good luck, adventurer!", 0, 0
_conv_bandit_left_reveal1_str:  .db "Well, well. Find any bandits,", 10, "adventurer?", 0
_conv_bandit_left_reveal2_str:  .db "Hah... what was the point of that misdirection, anyway?", 0
_conv_bandit_left_reveal3_str:  .db "Obvious, isn", 39, "t it! Charge!", 0, 0
_conv_bandit_right_reveal_str:  .db "Well, well. I must admit I didn", 39, "t expect to see you again soon,", 10, "adventurer. But no matter, I", 39, "ll set that right.", 0
_conv_foxes_didnt_do_this_str:  .db "Foxes didn", 39, "t do this...", 0
_conv_bandit_speech_str:        .db "You", 39, "ll pay for this, adventurer.", 0, 0
_conv_bandit_speech2_str:       .db "Where is my letter?", 0
_conv_bandit_speech3_str:       .db "Haw haw... come and see.", 0, 0
_conv_find_pass_str:            .db "What", 39, "s this? ... A pass for HighwayGuard blockades, sealed by", 10, "Baron Zhev?", 0
_conv_find_pass2_str:           .db "Looks like the letter isn", 39, "t here.", 0
_conv_find_pass3_str:           .db "How is Zhev involved in this?", 10, "Perhaps I should travel to Dor", 10, "Haldir and find out.", 0
_conv_highway_guard_str:        .db "No further, adventurer! None", 10, "may pass without a pass.", 0
_conv_highway_guard2_str:       .db "You again? What do you want? Theroad is closed!", 0
_conv_highway_guard4_str:       .db "Ask for details", 0
_conv_highway_guard5_str:       .db "Push forward", 0, 0
_conv_highway_guard6_str:       .db "Show your pass", 0, 0
_conv_highway_guard7_str:       .db "Apologize", 0
_conv_highway_guard8_str:       .db "Under whose orders?", 0
_conv_highway_guard9_str:       .db "Make way, fools!", 0, 0
_conv_highway_guard10_str:      .db "I have a pass.", 0, 0
_conv_highway_guard11_str:      .db "Sorry, I didn", 39, "t know.", 0
_conv_highway_guard12_str:      .db "Orders from Dor Haldir. It", 39, "s for your own safety, adventurer.", 0
_conv_highway_guard13_str:      .db "I must keep going, I", 39, "ll take the", 10, "risk.", 0, 0
_conv_highway_guard14_str:      .db "Not without a pass, adventurer. Stay back.", 0, 0
_conv_highway_guard15_str:      .db "Stay back, adventurer, as you", 10, "value your life!", 0, 0
_conv_highway_guard16_str:      .db "Hmm... everything seems to be in", 10, "order. Pass, friend.", 0
_conv_highway_guard18_str:      .db "I see no pass. Do not try my", 10, "patience, adventurer. Go back.", 0
_conv_cold_feet_str:            .db "Adventurer! They", 39, "re destroying", 10, "the bridge!", 0, 0
_conv_cold_feet2_str:           .db "I just wanted a bit of fun, I", 10, "swear I never thought it", 39, "d go", 10, "this far...", 0
_conv_cold_feet3_str:           .db "If you hurry, you can stop them!", 0, 0
_conv_poet1_str:                .db "A visitor? What a pleasant", 10, "surprise! Stay a while and hear", 10, "my songs!", 0, 0
_conv_poet2_c1_str:             .db "Refuse politely", 0
_conv_poet2_c2_str:             .db "Refuse rudely", 0
_conv_poet3_str:                .db "I", 39, "m sorry, but I have a pressing mission elsewhere.", 0
_conv_poet4_str:                .db "Huh. I guess you", 39, "d better go", 10, "then.", 0, 0
_conv_poet5_str:                .db "I", 39, "d sooner die!", 0
_conv_poet6_str:                .db "Oh, would you?", 0, 0
_conv_poet7_str:                .db "Come back to hear my songs,", 10, "adventurer? Well, it", 39, "s too late.You", 39, "ve already had your chance.", 0
_conv_haldir1_str:              .db "Welcome to Haldir, adventurer.", 10, "We", 39, "re glad to have a warrior suchas yourself among us. But don", 39, "t", 10, "cause any trouble.", 0, 0
_conv_haldir2_c1_str:           .db "Ask about Dor Haldir", 0, 0
_conv_haldir2_c2_str:           .db "Ask about Baron Zhev", 0, 0
_conv_haldir2_c3_str:           .db "Romance", 0
_conv_haldir2_c4_str:           .db "Leave", 0
_conv_haldir3_str:              .db "How fares Haldir?", 0
_conv_haldir4_str:              .db "We stand strong, but strange", 10, "things have been sighted nearby,especially at night.", 0
_conv_haldir4_2_str:            .db "The citizens are fearful, and", 10, "many have left the city. Take", 10, "care, adventurer.", 0
_conv_haldir5_str:              .db "I have business with Baron Zhev. Where does he live?", 0, 0
_conv_haldir6_str:              .db "The Baron has a tower east of", 10, "Haldir. Though I warn you,", 10, "adventurer, you might find your welcome somewhat less than", 10, "expected.", 0
_conv_haldir7_str:              .db "Say, have you been working out?", 0
_conv_haldir8_str:              .db ". . .", 0
_conv_bard1_str:                .db "Well met, adventurer! I am a", 10, "bard, singer of songs and bearerof tales. Shall I sing for you?", 0, 0
_conv_bard3_str:                .db "I wrote this song myself.", 0
_conv_bard4_str:                .db "In Reginold, the land of gold", 10, "A place now grim and gloomy", 10, "Dwell the dreaded Grim Machol", 10, "Oh Gilmatich! Oh Gilma guey!", 0, 0
_conv_bard5_str:                .db "But still I see, though dimly now(and only in my head)", 10, "The Machol ships upon the tide", 10, "And how they left us all for", 10, "    dead.", 0, 0
_conv_bard6_str:                .db "Shall I sing it again?", 0, 0
_conv_no_message_str:           .db "There", 39, "s been no word from the", 10, "baron for two weeks... I fear", 10, "something", 39, "s amiss.", 0, 0
_conv_somethings_wrong_str:     .db "Guards in the streets... windows", 10, "shuttered during the day... can", 10, "you feel it? Something", 39, "s coming.", 0
_conv_might_leave_str:          .db "It", 39, "s so quiet... another group", 10, "left last night. Maybe I", 39, "ll be in the next.", 0, 0
_conv_leaving_str:              .db "I", 39, "m getting out of Haldir while I can. And if you have any sense,", 10, "so will you.", 0, 0
_conv_leaving2_str:             .db "If you want, take a look", 10, "upstairs. Anything you want,", 10, "keep it.", 0, 0
_conv_field_foxes_str:          .db "Adventurer! A strange breed of", 10, "foxes has overrun the fields!", 0, 0
_conv_field_foxes2_str:         .db "Can", 39, "t pay you myself, but funny thing about these foxes, they", 10, "drop all kinds of stuff. Might", 10, "get lucky.", 0
_conv_cant_leave_str:           .db "I can", 39, "t leave yet... I must find", 10, "the letter!", 0, 0
_conv_kill_thieves1_str:        .db "Bank", 39, "s closed, adventurer. Not", 10, "much left, anyway.", 0
_conv_kill_thieves2_str:        .db "But listen. Rumor has it a gang ofthieves has a place in Haldir,", 10, "they", 39, "re looking to rob us.", 0
_conv_kill_thieves3_str:        .db "Find them and clean them out,", 10, "and we", 39, "ll make it worth your", 10, "time. What do you say?", 0
_conv_kill_thieves5_str:        .db "Offer", 39, "s still open. Come back if", 10, "you change your mind.", 0, 0
_conv_kill_thieves6_str:        .db "What do you say, adventurer?", 0, 0
_conv_kill_thieves7_str:        .db "Ask for more information", 0, 0
_conv_kill_thieves8_str:        .db "Why do you need me to do this?", 0, 0
_conv_kill_thieves9_str:        .db "The baron hasn", 39, "t given orders.", 10, "We", 39, "ve been waiting for weeks, butwithout them, we can", 39, "t take", 10, "action. But you don", 39, "t need them.", 10, "So what do you say?", 0, 0
_conv_kill_thieves10_str:       .db "Great. Good luck, adventurer.", 0
_conv_kill_thieves11_str:       .db "Come back when you", 39, "ve finished", 10, "the job.", 0
_conv_kill_thieves12_str:       .db "Thanks, adventurer. You", 39, "ve doneHaldir a service.", 0, 0
_conv_rob_bank1_str:            .db "Say, adventurer, you look like", 10, "you could use some gold! Could", 10, "use some myself, heh heh.", 0
_conv_rob_bank2_str:            .db "What do you want?", 0
_conv_rob_bank3_str:            .db "You", 39, "re an adventurer, right?", 10, "There", 39, "s something in the bank", 10, "that we need. If you bring it", 10, "here, it", 39, "ll be worth your while.", 0
_conv_rob_bank5_str:            .db "Changed your mind? You gonna", 10, "help us out?", 0
_conv_rob_bank6_str:            .db "Then beat it. And don", 39, "t breathe aword of this to anyone.", 0, 0
_conv_rob_bank7_str:            .db "It", 39, "s a small chest in one of the", 10, "vaults, not sure which. Don", 39, "t tryto open it, you won", 39, "t be able to. Just bring it back here.", 0, 0
_conv_rob_bank8_str:            .db "Come back when you have it.", 0
_conv_rob_bank9_str:            .db "Many thanks for your help,", 10, "adventurer. Here", 39, "s the promised", 10, "reward, heh heh...", 0
_conv_bank_warning_str:         .db "Stay yourself, adventurer!", 10, "Bank", 39, "s closed. Just turn around and leave.", 0
_conv_thieves_warning_str:      .db "Hey you! Quit snooping or else!", 0
_conv_bridge_broken_str:        .db "Yep... bridge", 39, "s out. Can", 39, "t say as", 10, "how it happened, but a lot of", 10, "strange stuff", 39, "s been happening.", 0
_conv_bridge_broken2_str:       .db "Course, there have always been other ways. Tunnels, hidden", 10, "paths, that sort of thing.", 0
