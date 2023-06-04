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
_conv_tutorial_go_git_em:       DECL_LINE go_git_em, NPC_TUTORIAL_TALK, farmer, END_CONVERSATION
DECL_CONVERSATION what_happened
_conv_what_happened:            DECL_LINE what_happened, 0, PLAYER, what_happened2
_conv_what_happened2:           DECL_LINE what_happened2, 0, PLAYER, what_happened3
_conv_what_happened3:           DECL_LINE what_happened3, 0, PLAYER, END_CONVERSATION
DECL_CONVERSATION battle_tutorial
_conv_battle_tutorial_halfling: DECL_LINE battle_tutorial_halfling, NPC_BANDIT_0, ruffian, battle_tutorial2
_conv_battle_tutorial_generic:  DECL_LINE battle_tutorial, NPC_BANDIT_0, ruffian, battle_tutorial2
_conv_battle_tutorial2:         DECL_BRANCH 3
                                DECL_CHOICE plead, battle_tutorial3
                                DECL_CHOICE threaten, battle_tutorial4
                                DECL_CHOICE bluff, battle_tutorial5
_conv_battle_tutorial3:         DECL_LINE battle_tutorial3, 0, PLAYER, battle_tutorial6
_conv_battle_tutorial4:         DECL_LINE battle_tutorial4, 0, PLAYER, battle_tutorial6
_conv_battle_tutorial5:         DECL_LINE battle_tutorial5, 0, PLAYER, battle_tutorial6
_conv_battle_tutorial6:         DECL_LINE battle_tutorial6, NPC_BANDIT_0, ruffian, END_CONVERSATION
DECL_CONVERSATION loot_tutorial
_conv_loot_tutorial:            DECL_LINE loot_tutorial, 0, PLAYER, END_CONVERSATION
DECL_CONVERSATION bandit_plead
_conv_bandit_plead:             DECL_LINE bandit_plead, NPC_BANDIT_2, bandit, bandit_plead2
_conv_bandit_plead2:            DECL_BRANCH 2
                                DECL_CHOICE punish, bandit_plead3
                                DECL_CHOICE spare, bandit_plead4
_conv_bandit_plead3:            DECL_LINE bandit_plead3, 0, PLAYER, END_CONVERSATION
_conv_bandit_plead4:            DECL_LINE bandit_plead4, 0, PLAYER, bandit_plead5
_conv_bandit_plead5:            DECL_LINE bandit_plead5, NPC_BANDIT_2, bandit, bandit_plead6
_conv_bandit_plead6:            DECL_LINE bandit_plead6, 0, PLAYER, bandit_plead7
_conv_bandit_plead7:            DECL_LINE bandit_plead7, NPC_BANDIT_2, bandit, END_CONVERSATION
DECL_CONVERSATION drunks_warning
_conv_drunks_warning:           DECL_LINE drunks_warning, NPC_DRUNK, drunk, drunks_warning2
_conv_drunks_warning2:          DECL_LINE drunks_warning2, NPC_DRUNK, drunk, END_CONVERSATION
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
_conv_welcome13:                DECL_LINE welcome13, NPC_WELCOME, farmer, welcome3
_conv_tavern_sign:              DECL_LINE tavern_sign, NPC_TAVERN_SIGN, empty, END_CONVERSATION
DECL_CONVERSATION bartender
_conv_bartender:                DECL_LINE bartender, NPC_BARTENDER, bartender, END_CONVERSATION
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
_conv_find_pass2:               DECL_LINE find_pass2, 0, PLAYER, END_CONVERSATION
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
DECL_CONVERSATION cult_victim
_conv_cult_victim:              DECL_LINE cult_victim1, NPC_CULT_VICTIM, billiam, cult_victim2
_conv_cult_victim2:             DECL_LINE cult_victim2, NPC_CULTIST_6, cultist, cult_victim3
_conv_cult_victim3:             DECL_LINE cult_victim3, NPC_CULT_VICTIM, billiam, END_CONVERSATION
DECL_CONVERSATION welcome_to_haldir
_conv_haldir1:                  DECL_LINE haldir1, NPC_HALDIR_GUARD, haldir_guard, haldir2
_conv_haldir2:                  DECL_BRANCH 3
                                DECL_CHOICE haldir2_c1, haldir3
                                DECL_CHOICE haldir2_c2, haldir5
                                DECL_CHOICE haldir2_c3, END_CONVERSATION
_conv_haldir3:                  DECL_LINE haldir3, 0, PLAYER, haldir4
_conv_haldir4:                  DECL_LINE haldir4, NPC_HALDIR_GUARD, haldir_guard, haldir4_2
_conv_haldir4_2:                DECL_LINE haldir4_2, NPC_HALDIR_GUARD, haldir_guard, haldir2
_conv_haldir5:                  DECL_LINE haldir5, 0, PLAYER, haldir6
_conv_haldir6:                  DECL_LINE haldir6, NPC_HALDIR_GUARD, haldir_guard, haldir2
_conv_bard1:                    DECL_LINE bard1, NPC_BARD, bard, bard2
_conv_bard2:                    DECL_BRANCH 2
                                DECL_CHOICE accept, bard3
                                DECL_CHOICE refuse, END_CONVERSATION
_conv_bard3:                    DECL_LINE bard3, NPC_BARD, bard, bard4
_conv_bard4:                    DECL_LINE bard4, NPC_BARD, bard, bard5
_conv_bard5:                    DECL_LINE bard5, NPC_BARD, bard, bard2
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
DECL_CONVERSATION baron_haldir
_conv_baron_haldir1:            DECL_LINE baron_haldir1, 0, PLAYER, baron_haldir2
_conv_baron_haldir2:            DECL_LINE baron_haldir2, NPC_BARON_HALDIR, baron_haldir, baron_haldir3
_conv_baron_haldir3:            DECL_LINE baron_haldir3, 0, PLAYER, baron_haldir4
_conv_baron_haldir4:            DECL_LINE baron_haldir4, NPC_BARON_HALDIR, baron_haldir, END_CONVERSATION
_conv_final_boss1:              DECL_LINE final_boss1, NPC_ZHEV, zhev, final_boss2
_conv_final_boss2:              DECL_LINE final_boss2, 0, PLAYER, final_boss3
_conv_final_boss3:              DECL_LINE final_boss3, NPC_ZHEV, zhev, final_boss4
_conv_final_boss4:              DECL_LINE final_boss4, NPC_ZHEV, zhev, final_boss5
_conv_final_boss5:              DECL_LINE final_boss5, NPC_ZHEV, zhev, final_boss6
_conv_final_boss6:              DECL_LINE final_boss6, 0, PLAYER, final_boss7
_conv_final_boss7:              DECL_LINE final_boss7, NPC_ZHEV, zhev, END_CONVERSATION

.message "Unallocated conversation ids: ", low(TOTAL_CONVERSATION_COUNT - __CONVERSATION_IDX + 1)

conversation_string_table:
_conv_speaker_PLAYER_str:       ; placeholder
_conv_speaker_ruffian_str:      .db "Ruffian", 0
_conv_speaker_bandit_str:       .db "Bandit", 0, 0
_conv_speaker_drunk_str:        .db "Drunk", 0
_conv_speaker_fisherman_str:    .db "Fisherman", 0
_conv_speaker_farmer_str:       .db "Farmer", 0, 0
_conv_speaker_grieving_father_str: .db "Grieving father", 0
_conv_speaker_bartender_str:    .db "Gerald", 0, 0
_conv_speaker_inn_guest_str:    .db "Tavern guest", 0, 0
_conv_speaker_bouncer_str:      .db "Guard", 0
_conv_speaker_bandit_chief_str: .db "Bandit chief", 0, 0
_conv_speaker_undercover_str:   .db "Cloaked villager", 0, 0
_conv_speaker_bandit_agent_str: .db "Bandit spy", 0, 0
_conv_speaker_highway_guard_str:.db "Highway guard", 0
_conv_speaker_scared_bandit_str:.db "Trepid bandit", 0
_conv_speaker_poet_str:         .db "Lonely poet", 0
_conv_speaker_billiam_str:      .db "Hapless traveller", 0
_conv_speaker_cultist_str:      .db "Cultist", 0
_conv_speaker_haldir_guard_str: .db "Haldir guard", 0, 0
_conv_speaker_bard_str:         .db "Bard", 0, 0
_conv_speaker_citizen_str:      .db "Citizen", 0
_conv_speaker_bank_guard_str:   .db "Bank guard", 0, 0
_conv_speaker_dodgy_fellow_str: .db "Dodgy citizen", 0
_conv_speaker_baron_haldir_str: .db "Baron Haldir", 0, 0
_conv_speaker_zhev_str:         .db "Zhev", 0, 0
_conv_speaker_empty_str:        .db 0, 0
_conv_go_git_em_str:            .db "Go git ", 39, "em, adventurer!", 0
_conv_what_happened_str:        .db "Ugh...  what happened?", 0, 0
_conv_what_happened2_str:       .db "Zhev! What have you done?!", 0, 0
_conv_what_happened3_str:       .db "My apprentice has vanished,", 10, "along with the queen", 39, "s letter.", 10, "This is terrible.", 0, 0
_conv_battle_tutorial_halfling_str:.db "Hey you! Yeah you, shorty! No", 10, "passing without paying!", 0
_conv_battle_tutorial_str:      .db "Hey you! Yeah you, ugly! No", 10, "passing without paying!", 0
_conv_battle_tutorial3_str:     .db "Have mercy! I swear, I have", 10, "nothing of value.", 0
_conv_battle_tutorial4_str:     .db "Begone, scoundrel. I am an", 10, "envoy of the queen.", 0, 0
_conv_battle_tutorial5_str:     .db "Come on, then! Killing bandits is my favorite sport!", 0, 0
_conv_battle_tutorial6_str:     .db "Heh, heh, heh.", 0, 0
_conv_threaten_str:             .db "Threaten", 0, 0
_conv_plead_str:                .db "Plead", 0
_conv_bluff_str:                .db "Bluff", 0
_conv_loot_tutorial_str:        .db "I should take his sword.", 0, 0
_conv_bandit_plead_str:         .db "I yield! Spare me, adventurer!", 0, 0
_conv_bandit_plead3_str:        .db "Ha! You die today, brigand!", 0
_conv_bandit_plead4_str:        .db "Tell me, has another envoy comethis way?", 0, 0
_conv_bandit_plead5_str:        .db "Yes, not an hour ago. He carried a letter, maybe he was taking it to the gang east of the town.", 0
_conv_bandit_plead6_str:        .db "I spare you. But you must stop", 10, "robbing travellers.", 0, 0
_conv_bandit_plead7_str:        .db "I swear it! I give you my sword asproof.", 0, 0
_conv_punish_str:               .db "Punish", 0, 0
_conv_spare_str:                .db "Spare", 0
_conv_drunks_warning_str:       .db "Say, you just come outta the", 10, "woods?", 0
_conv_drunks_warning2_str:      .db "Careful! There", 39, "s bandits about, you know!", 0
_conv_kidnapped_str:            .db "Please help, adventurer! My", 10, "poor boy has been kidnapped by", 10, "the foxes!", 0
_conv_kidnapped3_str:           .db "Question", 0, 0
_conv_kidnapped4_str:           .db "Foxes?", 0, 0
_conv_kidnapped5_str:           .db "Tell me where they are, and", 10, "I", 39, "ll bring him home!", 0, 0
_conv_kidnapped6_str:           .db "I", 39, "m sorry, but I have a more", 10, "important mission.", 0
_conv_kidnapped7_str:           .db "Please, adventurer, we don", 39, "t", 10, "have much time!", 0, 0
_conv_kidnapped8_str:           .db "Oh, thank you, adventurer! The", 10, "foxes lurk in the woods. If you", 10, "follow the path behind the houseyou", 39, "ll surely find them.", 0
_conv_kidnapped9_str:           .db "Leave me to my sorrow.", 0, 0
_conv_kidnapped10_str:          .db "Hurry, adventurer!", 0, 0
_conv_kidnapped11_str:          .db "Thank you, adventurer! Please", 10, "accept this potion in token of mydeepest gratitude!", 0
_conv_my_thanks_str:            .db "My thanks, adventurer!", 0, 0
_conv_kidnapped13_str:          .db "Foxes too much for you,", 10, "adventurer? My poor boy!", 0, 0
_conv_rescue_kidnapped_str:     .db "Follow me! Don", 39, "t be afraid of thefoxes.", 0
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
_conv_welcome7_str:             .db "Where are the bandits?", 0, 0
_conv_welcome8_str:             .db "How can I get to the city of Dor", 10, "Haldir?", 0, 0
_conv_welcome9_str:             .db "Speak softly, adventurer... yes,I", 39, "ve heard the bandits have somesort of hideout in the woods eastof here.", 0
_conv_welcome10_str:            .db "But be careful! I", 39, "ve no doubt youare a capable warrior, but thesebandits are a fearsome band. I", 10, "should rest here a while before", 10, "doing anything hasty.", 0
_conv_welcome11_str:            .db "Dor Haldir? That", 39, "s an easy one,", 10, "adventurer, just follow the", 10, "main road south.", 0, 0
_conv_welcome12_str:            .db "But I warn you, the Highway", 10, "Guard has closed the road. They won", 39, "t let anyone through withouta pass.", 0
_conv_welcome13_str:            .db "I couldn", 39, "t say why. But as an", 10, "adventurer, you may be able to", 10, "get more out of them.", 0, 0
_conv_tavern_sign_str:          .db "The Bristling Boar: Tavern & Inn", 10, 10, 10, 10, 10, 10, "        A Licensed Victualler", 0
_conv_bartender_str:            .db "Welcome to the Bristling Boar,", 10, "adventurer! Best ale for ten", 10, "leagues!", 0, 0
_conv_drunk_hiccup_str:         .db "H-hey you! You ain", 39, "t from these", 10, "parts, huh?", 0
_conv_drunk_hiccup2_str:        .db "Ha... you look like one of them", 10, "envoys.", 0
_conv_drunk_hiccup3_str:        .db "Yeah... I useta be like you...", 10, "watch out, they", 39, "ll throw y-you", 10, "away too.", 0
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
_conv_bandit_left_reveal2_str:  .db "Hah. Stand aside, or else.", 0, 0
_conv_bandit_left_reveal3_str:  .db "Charge!", 0
_conv_bandit_right_reveal_str:  .db "Well, well. I must admit I didn", 39, "t expect to see you again soon,", 10, "adventurer. But no matter, I", 39, "ll set that right.", 0
_conv_foxes_didnt_do_this_str:  .db "Foxes didn", 39, "t do this...", 0
_conv_bandit_speech_str:        .db "You", 39, "ll pay for this, adventurer.", 0, 0
_conv_bandit_speech2_str:       .db "Where is my letter?", 0
_conv_bandit_speech3_str:       .db "Haw haw... you", 39, "re too late. ", 0, 0
_conv_find_pass_str:            .db "What", 39, "s this? ... A pass for HighwayGuard blockades, sealed by the", 10, "baron of Dor Haldir?", 0, 0
_conv_find_pass2_str:           .db "It seems Zhev", 39, "s scheme runs", 10, "deeper than I thought.", 0, 0
_conv_highway_guard_str:        .db "No further, adventurer! None", 10, "may pass without a pass.", 0
_conv_highway_guard2_str:       .db "You again? What do you want? Theroad is closed!", 0
_conv_highway_guard4_str:       .db "Question", 0, 0
_conv_highway_guard5_str:       .db "Disregard", 0
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
_conv_cult_victim1_str:         .db "Please! No! Save me!", 0, 0
_conv_cult_victim2_str:         .db "That", 39, "s enough! Take that!", 0
_conv_cult_victim3_str:         .db "Aaargh...", 0
_conv_haldir1_str:              .db "Welcome to Haldir, adventurer.", 10, "By your garb, I see that you area proven warrior.", 0, 0
_conv_haldir2_c1_str:           .db "Ask about Dor Haldir", 0, 0
_conv_haldir2_c2_str:           .db "Ask about Baron Haldir", 0, 0
_conv_haldir2_c3_str:           .db "Leave", 0
_conv_haldir3_str:              .db "How fares Dor Haldir?", 0
_conv_haldir4_str:              .db "The city stands strong, but", 10, "strange things have been sightednearby,especially at night.", 0
_conv_haldir4_2_str:            .db "The citizens are fearful, and", 10, "many have left the city. Take", 10, "care, adventurer.", 0
_conv_haldir5_str:              .db "I have business with Baron", 10, "Haldir. Where can I find him?", 0, 0
_conv_haldir6_str:              .db "The baron has a tower east of", 10, "Haldir. Though I warn you,", 10, "adventurer, you might find your welcome somewhat less than", 10, "expected.", 0
_conv_bard1_str:                .db "Well met, adventurer! I am a", 10, "bard, singer of songs and bearerof tales. Shall I sing for you?", 0, 0
_conv_bard3_str:                .db "I wrote this song myself.", 0
_conv_bard4_str:                .db "I see you there, a stranger fair", "    With purse and gold within", 10, "Before you stands a poet bare", 10, "    Will you give some to him?", 10, "Wo-o-o, yeah!", 0
_conv_bard5_str:                .db "Shall I sing it again?", 0, 0
_conv_no_message_str:           .db "There", 39, "s been no word from the", 10, "baron for two weeks... I fear", 10, "something", 39, "s amiss.", 0, 0
_conv_somethings_wrong_str:     .db "Guards in the streets... windows", 10, "shuttered during the day... can", 10, "you feel it? Something", 39, "s coming.", 0
_conv_might_leave_str:          .db "It", 39, "s so quiet... another group", 10, "left last night. Maybe I", 39, "ll be in the next.", 0, 0
_conv_leaving_str:              .db "I", 39, "m getting out of Haldir while I can. And if you have any sense,", 10, "so will you.", 0, 0
_conv_leaving2_str:             .db "If you want, take a look", 10, "upstairs. Anything you want,", 10, "keep it.", 0, 0
_conv_field_foxes_str:          .db "Adventurer! A strange breed of", 10, "foxes has overrun the fields!", 0, 0
_conv_field_foxes2_str:         .db "Can", 39, "t pay you myself, but the", 10, "thing about these foxes, they", 10, "drop all kinds of stuff.", 0, 0
_conv_cant_leave_str:           .db "I can", 39, "t leave yet... I must find", 10, "the letter!", 0, 0
_conv_kill_thieves1_str:        .db "Bank", 39, "s closed, adventurer. Not", 10, "much left, anyway.", 0
_conv_kill_thieves2_str:        .db "But listen. Rumor has it a gang ofthieves has a place in Haldir,", 10, "they", 39, "re looking to rob us.", 0
_conv_kill_thieves3_str:        .db "Find them and clean them out,", 10, "and we", 39, "ll make it worth your", 10, "time. What do you say?", 0
_conv_kill_thieves5_str:        .db "Offer", 39, "s still open. Come back if", 10, "you change your mind.", 0, 0
_conv_kill_thieves6_str:        .db "What do you say, adventurer?", 0, 0
_conv_kill_thieves7_str:        .db "Question guard", 0, 0
_conv_kill_thieves8_str:        .db "Why don", 39, "t you guards handle it?", 0
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
_conv_bridge_broken_str:        .db "Yep... bridge", 39, "s out. Can", 39, "t say as", 10, "how it happened, but a lot of", 10, "strange stuff", 39, "s been going on.", 0, 0
_conv_bridge_broken2_str:       .db "Course, there have always been other ways. Tunnels, hidden", 10, "paths, that sort of thing.", 0
_conv_baron_haldir1_str:        .db "Baron Haldir?!", 0, 0
_conv_baron_haldir2_str:        .db "Still here, heh, heh... that", 10, "blasted Zhev betrayed me! Kill", 10, "him, won", 39, "t you, envoy?", 0, 0
_conv_baron_haldir3_str:        .db "What have you done, traitor?", 0, 0
_conv_baron_haldir4_str:        .db "Ugh... leave me.", 0, 0
_conv_final_boss1_str:          .db "Well well! The loyal envoy at", 10, "last!", 0
_conv_final_boss2_str:          .db "Zhev, you traitor! Did the baron put you up to this?", 0, 0
_conv_final_boss3_str:          .db "His plan, yes... though I", 39, "ve made some improvements, did you", 10, "notice? Heh heh.", 0
_conv_final_boss4_str:          .db "He thought the letter held somegreat secret or subtle plan.", 10, "Something to give him an edge...", 10, "the fool.", 0, 0
_conv_final_boss5_str:          .db "No matter. But now you choose. I can tell you", 39, "ve become powerfulsince we parted. Will you join me,or die serving your thankless", 10, "queen?", 0, 0
_conv_final_boss6_str:          .db "Never! Give me the letter!", 0, 0
_conv_final_boss7_str:          .db "Ha! I", 39, "m going to enjoy this... I", 10, "have learned much during my", 10, "travels.", 0
