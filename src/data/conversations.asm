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
_conv_bandit_plead:             DECL_LINE bandit_plead, NPC_BANDIT_2, bandit, bandit_plead2
_conv_bandit_plead2:            DECL_LINE bandit_plead2, 0, PLAYER, bandit_plead3
_conv_bandit_plead3:            DECL_LINE bandit_plead3, NPC_BANDIT_2, bandit, bandit_plead4
_conv_bandit_plead4:            DECL_LINE bandit_plead4, 0, PLAYER, bandit_plead5
_conv_bandit_plead5:            DECL_LINE bandit_plead5, NPC_BANDIT_2, bandit, bandit_plead_spare
_conv_bandit_plead_spare:       DECL_BRANCH 2
                                DECL_CHOICE bandit_plead_c1, END_CONVERSATION
                                DECL_CHOICE bandit_plead_c2, bandit_plead6
_conv_bandit_plead6:            DECL_LINE bandit_plead6, NPC_BANDIT_2, bandit, END_CONVERSATION
DECL_CONVERSATION interact_tutorial
_conv_interact_tutorial:        DECL_LINE interact_tutorial, 0, PLAYER, END_CONVERSATION
DECL_CONVERSATION drunks_warning
_conv_drunks_warning:           DECL_LINE drunks_warning, NPC_DRUNK, drunk, drunks_warning2
_conv_drunks_warning2:          DECL_LINE drunks_warning2, NPC_DRUNK, drunk, END_CONVERSATION
DECL_CONVERSATION save_tutorial
_conv_save_tutorial:            DECL_LINE save_tutorial, 0, PLAYER, END_CONVERSATION
_conv_kidnapped:                DECL_LINE kidnapped, NPC_GRIEVING_FATHER, grieving_father, kidnapped2
_conv_kidnapped2:               DECL_BRANCH 3
                                DECL_CHOICE kidnapped_c1, kidnapped3
                                DECL_CHOICE kidnapped_c2, kidnapped4
                                DECL_CHOICE kidnapped_c3, END_CONVERSATION
_conv_kidnapped3:               DECL_LINE kidnapped3, NPC_GRIEVING_FATHER, grieving_father, kidnapped2
_conv_kidnapped4:               DECL_LINE kidnapped4, NPC_GRIEVING_FATHER, grieving_father, END_CONVERSATION
_conv_kidnapped5:               DECL_LINE kidnapped5, NPC_GRIEVING_FATHER, grieving_father, END_CONVERSATION
_conv_kidnapped6:               DECL_LINE kidnapped6, NPC_GRIEVING_FATHER, grieving_father, END_CONVERSATION
_conv_kidnapped7:               DECL_LINE kidnapped7, NPC_GRIEVING_FATHER, grieving_father, END_CONVERSATION
_conv_kidnapped8:               DECL_LINE my_thanks, NPC_GRIEVING_FATHER, grieving_father, END_CONVERSATION
_conv_kidnapped9:               DECL_LINE kidnapped9, NPC_GRIEVING_FATHER, grieving_father, END_CONVERSATION
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
                                DECL_CHOICE welcome_c1, welcome4
                                DECL_CHOICE welcome_c2, welcome6
                                DECL_CHOICE welcome_c3, END_CONVERSATION
_conv_welcome4:                 DECL_LINE welcome4, NPC_WELCOME, farmer, welcome5
_conv_welcome5:                 DECL_LINE welcome5, NPC_WELCOME, farmer, welcome3
_conv_welcome6:                 DECL_LINE welcome6, NPC_WELCOME, farmer, welcome7
_conv_welcome7:                 DECL_LINE welcome7, NPC_WELCOME, farmer, welcome8
_conv_welcome8:                 DECL_LINE welcome8, 0, PLAYER, welcome9
_conv_welcome9:                 DECL_LINE welcome9, NPC_WELCOME, farmer, welcome3
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
                                DECL_CHOICE yes, guest_quest4
                                DECL_CHOICE no, guest_quest5
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
                                DECL_CHOICE highway_guard_c1, highway_guard4
                                DECL_CHOICE highway_guard_c2, highway_guard7
                                DECL_CHOICE highway_guard_c3, highway_guard8
                                DECL_CHOICE highway_guard_c4, END_CONVERSATION
_conv_highway_guard4:           DECL_LINE highway_guard4, NPC_HIGHWAY_GUARD_1, highway_guard, highway_guard5
_conv_highway_guard5:           DECL_LINE highway_guard5, 0, PLAYER, highway_guard6
_conv_highway_guard6:           DECL_LINE highway_guard6, NPC_HIGHWAY_GUARD_1, highway_guard, highway_guard3
_conv_highway_guard7:           DECL_LINE highway_guard7, NPC_HIGHWAY_GUARD_1, highway_guard, END_CONVERSATION
_conv_highway_guard8:           DECL_LINE highway_guard8, NPC_HIGHWAY_GUARD_1, highway_guard, END_CONVERSATION
_conv_highway_guard9:           DECL_LINE highway_guard9, NPC_HIGHWAY_GUARD_1, highway_guard, END_CONVERSATION

conversation_string_table:
_conv_speaker_PLAYER_str:       ; placeholder
_conv_speaker_ruffian_str:      .db "Ruffian", 0
_conv_speaker_bandit_str:       .db "Bandit", 0, 0
_conv_speaker_drunk_str:        .db "Town drunk", 0, 0
_conv_speaker_fisherman_str:    .db "Fisherman", 0
_conv_speaker_farmer_str:       .db "Farmer", 0, 0
_conv_speaker_grieving_father_str: .db "Grieving father", 0
_conv_speaker_bartender_str:    .db "Bartender", 0
_conv_speaker_inn_guest_str:    .db "Inn guest", 0
_conv_speaker_bouncer_str:      .db "Bouncer", 0
_conv_speaker_bandit_chief_str: .db "Bandit chief", 0, 0
_conv_speaker_undercover_str:   .db "Cloaked villager", 0, 0
_conv_speaker_bandit_agent_str: .db "Bandit agent", 0, 0
_conv_speaker_highway_guard_str:.db "Highway guard", 0
_conv_speaker_empty_str:        .db 0, 0
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
_conv_bandit_plead5_str:        .db "His gang have a house in the woodeast of the town. Please,", 10, "adventurer, we didn", 39, "t harm you!", 0, 0
_conv_bandit_plead_c1_str:      .db "Ha! That letter means my life,", 10, "you will pay dearly!", 0
_conv_bandit_plead_c2_str:      .db "I spare you. But you must stop", 10, "robbing travelers.", 0
_conv_bandit_plead6_str:        .db "I swear it! I give you my sword asproof.", 0, 0
_conv_interact_tutorial_str:    .db 10, 10, 10, 10, 10, 10, "    Press <select> to interact.", 0
_conv_drunks_warning_str:       .db "Say, ya just come outta them", 10, "woods?", 0
_conv_drunks_warning2_str:      .db "Be careful! There", 39, "s bandits", 10, "about, doncha know!", 0
_conv_save_tutorial_str:        .db 10, 10, 10, 10, 10, 10, "Press <select> to save progress", 0
_conv_kidnapped_str:            .db "Please help, adventurer! My", 10, "poor boy has been kidnapped by", 10, "the foxes!", 0
_conv_kidnapped_c1_str:         .db "Foxes?", 0, 0
_conv_kidnapped_c2_str:         .db "Tell me where they are, and", 10, "I", 39, "ll bring him home!", 0, 0
_conv_kidnapped_c3_str:         .db "I", 39, "m sorry stranger, but I have", 10, "an important mission.", 0, 0
_conv_kidnapped3_str:           .db "Please, adventurer, we don", 39, "t", 10, "have much time!", 0, 0
_conv_kidnapped4_str:           .db "Oh, thank you, adventurer! The", 10, "foxes lurk in the woods. If you", 10, "follow the path behind the houseyou", 39, "ll surely find them.", 0
_conv_kidnapped5_str:           .db "Leave me, cruel adventurer!", 0
_conv_kidnapped6_str:           .db "Hurry, adventurer!", 0, 0
_conv_kidnapped7_str:           .db "Thank you, adventurer! Please", 10, "accept this potion in token of mydeepest gratitude!", 0
_conv_my_thanks_str:            .db "My thanks, adventurer!", 0, 0
_conv_kidnapped9_str:           .db "Foxes too much for you,", 10, "adventurer? My poor boy!", 0, 0
_conv_rescue_kidnapped_str:     .db "Come with me if you want to live!", 0
_conv_nice_day_str:             .db "Mornin", 39, "! Nice day for fishing,", 10, "ain", 39, "t it?", 0, 0
_conv_yes_str:                  .db "Yes", 0
_conv_no_str:                   .db "No", 0, 0
_conv_nice_day3_str:            .db "Huah hah!", 0
_conv_welcome_str:              .db "Hello there, adventurer! And", 10, "welcome to Frogford town!", 0, 0
_conv_welcome2_str:             .db "Anything I can do for you?", 0, 0
_conv_welcome_c1_str:           .db "Bandits have stolen something", 10, "of mine, I must find them.", 0, 0
_conv_welcome_c2_str:           .db "I must to get to the city of DorHaldir.", 0
_conv_welcome_c3_str:           .db "Goodbye.", 0, 0
_conv_welcome4_str:             .db "Speak softly, adventurer... yes,I", 39, "ve heard the bandits have somesort of hideout in the woods eastof here.", 0
_conv_welcome5_str:             .db "But be careful! I", 39, "ve no doubt youare a capable warrior, but the", 10, "bandits are a fearsome band. I", 10, "should rest here a while before", 10, "doing anything rash.", 0
_conv_welcome6_str:             .db "Dor Haldir? That", 39, "s an easy one,", 10, "adventurer, just follow the", 10, "main road south.", 0, 0
_conv_welcome7_str:             .db "But I warn you, the Highway", 10, "Guard has closed the road. They won", 39, "t let anyone through withouta pass.", 0
_conv_welcome8_str:             .db "Why is the road closed?", 0
_conv_welcome9_str:             .db "The Guard won", 39, "t say. But as an", 10, "adventurer, you may be able to", 10, "get more out of them.", 0
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
_conv_guest_quest2_str:         .db "Silent type, eh? Doesn", 39, "t matter.", 10, 10, "Listen, I", 39, "ve lost my journal", 10, "somewhere around town. Could", 10, "you find it for me? There", 39, "ll be", 10, "something in it for you.", 0, 0
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
_conv_highway_guard_c1_str:     .db "Under whose orders?", 0
_conv_highway_guard_c2_str:     .db "Make way, fools!", 0, 0
_conv_highway_guard_c3_str:     .db "I have a pass.", 0, 0
_conv_highway_guard_c4_str:     .db "Sorry, I didn", 39, "t know.", 0
_conv_highway_guard4_str:       .db "Orders from Dor Haldir. It", 39, "s for your own safety, adventurer.", 0
_conv_highway_guard5_str:       .db "I must get to Dor Haldir, I", 39, "ll", 10, "take the risk.", 0
_conv_highway_guard6_str:       .db "Not without a pass, adventurer. Stay back.", 0, 0
_conv_highway_guard7_str:       .db "Stay back, adventurer, as you", 10, "value your life!", 0, 0
_conv_highway_guard8_str:       .db "Hmm... everything seems to be in", 10, "order. Pass, friend.", 0
_conv_highway_guard9_str:       .db "I see no pass. Do not try my", 10, "patience, adventurer. Go back.", 0
