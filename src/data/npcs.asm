; There are four different types of NPCs. The most common type, enemies, can
; move around, fight the player, and drop a somewhat random item on death. Talkers
; are associated with up to two conversations and do not move. Shopkeepers have
; items that they can sell and also do not move. Special NPCs can do literally
; anything and are handled separately. I was originally going to use them for
; important or unique characters, but it was much easier and useful to expand
; the other NPCs with interesting behavior.
;
; Enemy (16 bytes)
;   type - always NPC_ENEMY (1 byte)
;   base character - used for rendering (1 bytes)
;   weapon, armor - used for rendering (2 bytes)
;   direction - used for rendering and attacks (1 byte)
;   health - initial health (1 byte)
;   x, y position - (2 bytes)
;   AI flags - (1 byte)
;   XP from defeating - (1 byte)
;   acceleration - used for movement (1 byte)
;   attack - weapon boosts are not considered (1 byte)
;   defense - wearable and weapon boosts are not considered (1 byte)
;   drop 1,2,3 - one is randomly dropped upon death (3 bytes) NOTE: prob distribution 50% 25% 25%
;
; Shopkeeper (16 bytes)
;   type - always NPC_SHOPKEEPER (1 byte)
;   base character - used for rendering (1 byte) NOTE: if the MSB is set, a static character is used and weapon, armor, and direction are ignored
;   weapon, armor - used for rendering, may be ignored (2 bytes)
;   direction - used for rendering, may be ignored (1 byte)
;   health - initial health (1 byte)
;   x, y position - (2 bytes)
;   avenger npc - if nonzero, attacks the player if the NPC dies (1 byte)
;   shop id - (1 byte)
;   empty - (6 bytes)
;
; Talker (16 bytes)
;   type - always NPC_TALKER (1 byte)
;   base character - used for rendering (1 byte) NOTE: if the MSB is set, a static character is used and weapon, armor, and direction are ignored
;   weapon, armor - used for rendering, may be ignored (2 bytes)
;   direction - used for rendering and attacks, may be ignored (1 byte)
;   health - initial health (1 byte)
;   x, y position - (2 bytes)
;   avenger npc - if nonzero, attacks the player if the NPC dies (1 byte)
;   conversation 1 id - used for checking if the conversation has happened. 0 is a special conversation that is never considered over (1 byte)
;   conversation 1 ptr - first conversation (2 bytes)
;   conversation 2 id -  (1 byte)
;   conversation 2 ptr - second conversation, used if the first is over (2 bytes)
;   replacement - if attacked and nonzero, replaces the talker (1 byte)
;
; Special (16 bytes)
;   type - always NPC_SPECIAL (1 byte)
;   base character - used for rendering (1 bytes)
;   weapon, armor - used for rendering (2 bytes)
;   direction - used for rendering and attacks (1 byte)
;   health - initial health (1 byte)
;   x, y position - (2 bytes)
;   custom data (8 bytes)

.set __NPC_IDX = 1

.macro DECL_NPC ; name, type, base, weapon, armor, direction, health, x, y
    .equ @0 = __NPC_IDX
    .set __NPC_IDX = __NPC_IDX + 1
    .db @1, @2, @3, @4, @5, @6, @7, @8

    .if __NPC_IDX == TOTAL_NPC_COUNT
        .error "Too many NPCs"
    .endif
.endm

.macro DECL_ENEMY_DATA ; flags, xp, acceleration, attack, defense, drop1, drop2, drop3
    .db @0, @1, @2, @3, @4, @5, @6, @7
.endm

.macro DECL_SHOP_DATA ; avenger, shop id
    .db @0, @1, 0, 0, 0, 0, 0, 0
.endm

.macro DECL_TALK_DATA ; avenger, id 1, conv 1, id 2, conv 2, replacement
    .db @0, @1
    .dw 2*(_conv_@2-conversation_table)
    .db @3, low(2*(_conv_@4-conversation_table)), high(2*(_conv_@4-conversation_table)), @5
.endm

.macro DECL_SPECIAL_DATA ; 8 bytes
    .db @0, @1, @2, @3, @4, @5, @6, @7
.endm

npc_table:
    DECL_NPC        NPC_CORPSE, NPC_SPECIAL, 128|NPC_CORPSE_SPRITE, NO_ITEM, NO_ITEM, DIRECTION_DOWN, 0, 0, 0
    DECL_SPECIAL_DATA 0, 0, 0, 0, 0, 0, 0, 0

    DECL_NPC        NPC_TOWN_GUARD_ANGRY, NPC_ENEMY, CHARACTER_MAN, ITEM_steel_sword, ITEM_guard_hat, DIRECTION_DOWN, 30, 0, 0
    DECL_ENEMY_DATA NPC_ATTACK, 50, 8, 7, 4, ITEM_guard_hat, ITEM_guard_hat, ITEM_steel_sword

    DECL_NPC        NPC_BANDIT_0, NPC_ENEMY, CHARACTER_BANDIT, ITEM_bloody_sword, NO_ITEM, DIRECTION_DOWN, 10, 180, 26
    DECL_ENEMY_DATA NPC_MOVE_HOLD|NPC_GUARD, 10, 6, 3, 0, ITEM_bloody_sword, ITEM_bloody_sword, ITEM_bloody_sword

    DECL_NPC        NPC_BANDIT_1, NPC_ENEMY, CHARACTER_BANDIT, ITEM_bloody_sword, ITEM_green_hood, DIRECTION_LEFT, 10, 108, 73
    DECL_ENEMY_DATA NPC_GUARD, 15, 6, 2, 2, 128|20, ITEM_green_hood, ITEM_green_hood

    DECL_NPC        NPC_BANDIT_2, NPC_ENEMY, CHARACTER_MAN, ITEM_bloody_sword, ITEM_purple_hood, DIRECTION_UP, 10, 136, 140
    DECL_ENEMY_DATA NPC_GUARD, 15, 4, 2, 2, ITEM_purple_hood, 128|20, ITEM_bloody_sword

    DECL_NPC        NPC_BANDIT_2_REFORMED, NPC_ENEMY, CHARACTER_MAN, NO_ITEM, ITEM_purple_hood, DIRECTION_UP, 10, 136, 140
    DECL_ENEMY_DATA NPC_MOVE_LOOKAT, 0, 0, 0, 0, ITEM_purple_hood, 128|20, ITEM_bloody_sword

    DECL_NPC        NPC_DRUNK, NPC_TALKER, 128|NPC_DRUNK_SPRITE, NO_ITEM, NO_ITEM, DIRECTION_LEFT, 10, 165, 26
    DECL_TALK_DATA  NPC_TOWN_GUARD_ANGRY, CONVERSATION_drunks_warning_ID, drunks_warning, 0, drunks_warning2, NO_NPC

    DECL_NPC        NPC_GRIEVING_FATHER, NPC_TALKER, 128|NPC_GRIEVING_FATHER_SPRITE, NO_ITEM, NO_ITEM, DIRECTION_LEFT, 10, 82, 132
    DECL_TALK_DATA  NPC_TOWN_GUARD_ANGRY, 0, kidnapped, 0, END_CONVERSATION, NO_NPC

    DECL_NPC        NPC_FOX_1, NPC_ENEMY, CHARACTER_FOX, ITEM_invisible_weapon, NO_ITEM, DIRECTION_RIGHT, 10, 24, 24
    DECL_ENEMY_DATA NPC_GUARD, 5, 7, 2, 0, ITEM_raw_meat, ITEM_rotten_meat, 128|5

    DECL_NPC        NPC_FOX_2, NPC_ENEMY, CHARACTER_FOX, ITEM_invisible_weapon, NO_ITEM, DIRECTION_DOWN, 10, 168, 147
    DECL_ENEMY_DATA NPC_GUARD, 5, 7, 2, 0, ITEM_raw_meat, ITEM_rotten_meat, 128|5

    DECL_NPC        NPC_FOX_3, NPC_ENEMY, CHARACTER_FOX, ITEM_invisible_weapon, NO_ITEM, DIRECTION_RIGHT, 10, 144, 128
    DECL_ENEMY_DATA NPC_GUARD, 5, 6, 2, 1, ITEM_raw_meat, ITEM_raw_meat, 128|5

    DECL_NPC        NPC_FOX_4, NPC_ENEMY, CHARACTER_FOX, ITEM_invisible_weapon, NO_ITEM, DIRECTION_LEFT, 10, 190, 120
    DECL_ENEMY_DATA NPC_GUARD, 5, 7, 2, 0, ITEM_raw_meat, ITEM_rotten_meat, 128|5

    DECL_NPC        NPC_FOX_5, NPC_ENEMY, CHARACTER_FOX, ITEM_invisible_weapon, NO_ITEM, DIRECTION_UP, 10, 130, 143
    DECL_ENEMY_DATA NPC_GUARD, 5, 6, 2, 0, ITEM_raw_meat, ITEM_raw_meat, 128|5

    DECL_NPC        NPC_KIDNAPPED, NPC_TALKER, CHARACTER_CHILD, NO_ITEM, NO_ITEM, DIRECTION_RIGHT, 10, 128, 25
    DECL_TALK_DATA  NPC_TOWN_GUARD_ANGRY, CONVERSATION_rescue_kidnapped_ID, rescue_kidnapped, 0, END_CONVERSATION, NPC_KIDNAPPED_FOLLOWING

    DECL_NPC        NPC_KIDNAPPED_FOLLOWING, NPC_ENEMY, CHARACTER_CHILD, NO_ITEM, NO_ITEM, DIRECTION_RIGHT, 10, 128, 25
    DECL_ENEMY_DATA NPC_FOLLOW, 0, 5, 0, 5, NO_ITEM, NO_ITEM, NO_ITEM

    DECL_NPC        NPC_FISHERMAN, NPC_TALKER, 128|NPC_FISHERMAN_SPRITE, NO_ITEM, NO_ITEM, DIRECTION_LEFT, 10, 146, 90
    DECL_TALK_DATA  NPC_TOWN_GUARD_ANGRY, CONVERSATION_nice_day_ID, nice_day, 0, nice_day3, NO_NPC

    DECL_NPC        NPC_WELCOME, NPC_TALKER, 128|NPC_WELCOME_SPRITE, NO_ITEM, NO_ITEM, DIRECTION_DOWN, 10, 156, 133
    DECL_TALK_DATA  NPC_TOWN_GUARD_ANGRY, CONVERSATION_welcome_ID, welcome, 0, welcome3, NO_NPC

    DECL_NPC        NPC_TAVERN_SIGN, NPC_TALKER, 128|NPC_SIGN_SPRITE, NO_ITEM, NO_ITEM, DIRECTION_DOWN, 10, 140, 100
    DECL_TALK_DATA  NO_NPC, 0, tavern_sign, 0, tavern_sign, NO_NPC

    DECL_NPC        NPC_DRINKER1, NPC_SPECIAL, 128|NPC_DRINKER_DOWN_SPRITE, NO_ITEM, NO_ITEM, DIRECTION_DOWN, 0, 105, 66
    DECL_SPECIAL_DATA 0, 0, 0, 0, 0, 0, 0, 0

    DECL_NPC        NPC_DRINKER2, NPC_SPECIAL, 128|NPC_DRINKER_UP_SPRITE, NO_ITEM, NO_ITEM, DIRECTION_UP, 0, 112, 78
    DECL_SPECIAL_DATA 0, 0, 0, 0, 0, 0, 0, 0

    DECL_NPC        NPC_BARTENDER, NPC_SHOPKEEPER, 128|NPC_BUSINESSMAN_SPRITE, NO_ITEM, NO_ITEM, DIRECTION_DOWN, 0, 71, 112
    DECL_SHOP_DATA  NPC_TOWN_GUARD_ANGRY, SHOP_bartender_ID

    DECL_NPC        NPC_DRUNK2, NPC_TALKER, 128|NPC_DRUNK_SPRITE, NO_ITEM, NO_ITEM, DIRECTION_LEFT, 10, 170, 95
    DECL_TALK_DATA  NPC_TOWN_GUARD_ANGRY, CONVERSATION_drunk_hiccup_ID, drunk_hiccup, 0, drunk_hiccup5, NO_NPC

    DECL_NPC        NPC_ANNOYED_GUEST, NPC_TALKER, CHARACTER_BANDIT, NO_ITEM, ITEM_feathered_hat, DIRECTION_DOWN, 20, 192, 40
    DECL_TALK_DATA  NO_NPC, 0, whit_ye_daen, 0, whit_ye_daen, NPC_ROBBED_GUEST

    DECL_NPC        NPC_ROBBED_GUEST, NPC_ENEMY, CHARACTER_BANDIT, ITEM_steel_sword, ITEM_feathered_hat, DIRECTION_DOWN, 20, 192, 40
    DECL_ENEMY_DATA NPC_ATTACK, 40, 8, 4, 4, ITEM_steel_sword, ITEM_steel_sword, ITEM_steel_sword

    DECL_NPC        NPC_GUEST_QUEST, NPC_TALKER, CHARACTER_MAN, NO_ITEM, ITEM_leather_armor, DIRECTION_LEFT, 10, 59, 34
    DECL_TALK_DATA  NO_NPC, 0, guest_quest, 0, guest_quest, NO_NPC

    DECL_NPC        NPC_GRUFF_BOUNCER, NPC_TALKER, CHARACTER_MAN, ITEM_club, ITEM_beard, DIRECTION_DOWN, 20, 38, 123
    DECL_TALK_DATA  NO_NPC, 0, just_beat_it, 0, just_beat_it, NPC_ANGRY_BOUNCER

    DECL_NPC        NPC_ANGRY_BOUNCER, NPC_ENEMY, CHARACTER_MAN, ITEM_club, ITEM_beard, DIRECTION_DOWN, 20, 38, 123
    DECL_ENEMY_DATA NPC_GUARD, 10, 6, 3, 2, ITEM_club, ITEM_club, ITEM_club

    DECL_NPC        NPC_TOWN_BLACKSMITH, NPC_SHOPKEEPER, 128|NPC_BLACKSMITH_SPRITE, NO_ITEM, NO_ITEM, DIRECTION_DOWN, 20, 183, 93
    DECL_SHOP_DATA  NPC_TOWN_GUARD_ANGRY, SHOP_blacksmith_ID

    DECL_NPC        NPC_UNDERCOVER_BANDIT, NPC_TALKER, CHARACTER_MAN, NO_ITEM, ITEM_green_cloak, DIRECTION_LEFT, 20, 111, 90
    DECL_TALK_DATA  NO_NPC, CONVERSATION_bandit_lies_ID, bandit_lies1, 0, bandit_good_luck, NPC_UNDERCOVER_BANDIT_UNMASKED

    DECL_NPC        NPC_UNDERCOVER_BANDIT_UNMASKED, NPC_ENEMY, CHARACTER_MAN, ITEM_steel_sword, ITEM_green_cloak, DIRECTION_UP, 20, 139, 60
    DECL_ENEMY_DATA NPC_MOVE_HOLD|NPC_ATTACK, 30, 7, 4, 2, ITEM_steel_sword, 128|50, ITEM_health_potion

    DECL_NPC        NPC_UNDERCOVER_GOON1, NPC_ENEMY, CHARACTER_BANDIT, ITEM_wooden_bow, ITEM_green_hood, DIRECTION_UP, 20, 144, 66
    DECL_ENEMY_DATA NPC_MOVE_HOLD|NPC_ATTACK, 20, 6, 2, 1, 128|25, 128|50, ITEM_health_potion

    DECL_NPC        NPC_UNDERCOVER_GOON2, NPC_ENEMY, CHARACTER_BANDIT, ITEM_bloody_sword, ITEM_green_hood, DIRECTION_UP, 20, 130, 66
    DECL_ENEMY_DATA NPC_MOVE_HOLD|NPC_ATTACK, 20, 6, 3, 2, 128|25, 128|50, ITEM_health_potion

    DECL_NPC        NPC_FOX_6, NPC_ENEMY, CHARACTER_FOX, ITEM_invisible_weapon, NO_ITEM, DIRECTION_UP, 12, 66, 26
    DECL_ENEMY_DATA NPC_PATROL, 5, 6, 2, 1, ITEM_raw_meat, ITEM_raw_meat, NO_ITEM

    DECL_NPC        NPC_FOX_7, NPC_ENEMY, CHARACTER_FOX, ITEM_invisible_weapon, NO_ITEM, DIRECTION_UP, 12, 143, 60
    DECL_ENEMY_DATA NPC_GUARD, 5, 6, 3, 1, ITEM_raw_meat, ITEM_raw_meat, NO_ITEM

    DECL_NPC        NPC_FOX_8, NPC_ENEMY, CHARACTER_FOX, ITEM_invisible_weapon, NO_ITEM, DIRECTION_UP, 12, 57, 62
    DECL_ENEMY_DATA NPC_GUARD, 5, 6, 2, 1, ITEM_raw_meat, 128|10, NO_ITEM

    DECL_NPC        NPC_FOX_9, NPC_ENEMY, CHARACTER_FOX, ITEM_invisible_weapon, NO_ITEM, DIRECTION_UP, 12, 103, 153
    DECL_ENEMY_DATA NPC_GUARD, 5, 6, 3, 1, ITEM_raw_meat, 128|10, NO_ITEM

    DECL_NPC        NPC_DEAD_1, NPC_TALKER, 128|NPC_CORPSE_SPRITE, NO_ITEM, NO_ITEM, DIRECTION_UP, 255, 202, 12
    DECL_TALK_DATA  NO_NPC, 0, foxes_didnt_do_this, 0, foxes_didnt_do_this, NO_NPC

    DECL_NPC        NPC_DEAD_2, NPC_TALKER, 128|NPC_CORPSE_SPRITE, NO_ITEM, NO_ITEM, DIRECTION_UP, 255, 210, 13
    DECL_TALK_DATA  NO_NPC, 0, foxes_didnt_do_this, 0, foxes_didnt_do_this, NO_NPC

    DECL_NPC        NPC_DEAD_3, NPC_TALKER, 128|NPC_CORPSE_SPRITE, NO_ITEM, NO_ITEM, DIRECTION_UP, 255, 206, 16
    DECL_TALK_DATA  NO_NPC, 0, foxes_didnt_do_this, 0, foxes_didnt_do_this, NO_NPC

    DECL_NPC        NPC_DEAD_4, NPC_TALKER, 128|NPC_CORPSE_SPRITE, NO_ITEM, NO_ITEM, DIRECTION_UP, 255, 68, 129
    DECL_TALK_DATA  NO_NPC, 0, END_CONVERSATION, 0, END_CONVERSATION, NO_NPC

    DECL_NPC        NPC_AMBUSHER, NPC_ENEMY, CHARACTER_BANDIT, ITEM_wooden_bow, ITEM_green_cloak, DIRECTION_DOWN, 15, 38, 59
    DECL_ENEMY_DATA NPC_ATTACK|NPC_MOVE_CIRCLE, 20, 6, 5, 1, 128|25, ITEM_green_cloak, ITEM_wooden_bow

    DECL_NPC        NPC_BANDIT_GUARD_1, NPC_ENEMY, CHARACTER_BANDIT, ITEM_bloody_sword, ITEM_beard, DIRECTION_DOWN, 25, 96, 86
    DECL_ENEMY_DATA NPC_GUARD, 20, 6, 4, 1, NO_ITEM, NO_ITEM, NO_ITEM

    DECL_NPC        NPC_BANDIT_GUARD_2, NPC_ENEMY, CHARACTER_BANDIT, ITEM_club, ITEM_purple_hood, DIRECTION_DOWN, 20, 143, 75
    DECL_ENEMY_DATA NPC_GUARD, 20, 6, 2, 1, NO_ITEM, NO_ITEM, NO_ITEM

    DECL_NPC        NPC_DEN_BANDIT_1, NPC_ENEMY, CHARACTER_BANDIT, ITEM_club, ITEM_leather_armor, DIRECTION_DOWN, 30, 172, 40
    DECL_ENEMY_DATA NPC_ATTACK, 20, 6, 3, 3, ITEM_club, 128|30, ITEM_leather_armor

    DECL_NPC        NPC_DEN_BANDIT_2, NPC_ENEMY, CHARACTER_BANDIT, ITEM_club, ITEM_green_cloak, DIRECTION_DOWN, 30, 126, 75
    DECL_ENEMY_DATA NPC_ATTACK, 20, 6, 3, 2, ITEM_club, 128|10, ITEM_green_cloak

    DECL_NPC        NPC_DEN_BANDIT_3, NPC_ENEMY, CHARACTER_BANDIT, ITEM_steel_sword, ITEM_leather_armor, DIRECTION_DOWN, 30, 130, 27
    DECL_ENEMY_DATA NPC_GUARD, 20, 6, 5, 3, ITEM_steel_sword, 128|30, ITEM_leather_armor

    DECL_NPC        NPC_DEN_BANDIT_CHIEF, NPC_ENEMY, CHARACTER_BANDIT, ITEM_iron_staff, ITEM_green_cloak, DIRECTION_DOWN, 40, 65, 86
    DECL_ENEMY_DATA NPC_ATTACK, 200, 8, 8, 3, ITEM_iron_staff, ITEM_iron_staff, ITEM_iron_staff

    DECL_NPC        NPC_HIGHWAY_GUARD_1, NPC_ENEMY, CHARACTER_MAN, ITEM_steel_sword, ITEM_iron_armor, DIRECTION_UP, 40, 155, 106
    DECL_ENEMY_DATA NPC_MOVE_HOLD|NPC_ATTACK, 100, 8, 7, 8, ITEM_steel_sword, ITEM_iron_breastplate, ITEM_iron_helmet

    DECL_NPC        NPC_HIGHWAY_GUARD_2, NPC_ENEMY, CHARACTER_MAN, ITEM_steel_sword, ITEM_iron_breastplate, DIRECTION_UP, 40, 176, 106
    DECL_ENEMY_DATA NPC_MOVE_HOLD|NPC_ATTACK, 100, 8, 7, 6, ITEM_steel_sword, ITEM_iron_breastplate, ITEM_steel_sword

    DECL_NPC        NPC_HIGHWAY_GUARD_3, NPC_ENEMY, CHARACTER_MAN, ITEM_steel_sword, ITEM_iron_breastplate, DIRECTION_UP, 40, 155, 120
    DECL_ENEMY_DATA NPC_MOVE_HOLD|NPC_ATTACK, 100, 7, 7, 6, ITEM_steel_sword, ITEM_iron_breastplate, ITEM_steel_sword

    DECL_NPC        NPC_HIGHWAY_GUARD_4, NPC_ENEMY, CHARACTER_MAN, ITEM_steel_sword, ITEM_iron_breastplate, DIRECTION_UP, 40, 176, 120
    DECL_ENEMY_DATA NPC_MOVE_HOLD|NPC_ATTACK, 100, 7, 7, 6, ITEM_steel_sword, ITEM_iron_breastplate, ITEM_steel_sword

    DECL_NPC        NPC_COLD_FEET, NPC_TALKER, 128|NPC_POINTING_SPRITE, NO_ITEM, NO_ITEM, DIRECTION_DOWN, 15, 193, 100
    DECL_TALK_DATA  NO_NPC, CONVERSATION_cold_feet_ID, cold_feet, 0, END_CONVERSATION, NO_NPC

    DECL_NPC        NPC_BRIDGE_BANDIT_1, NPC_ENEMY, CHARACTER_BANDIT, ITEM_axe, ITEM_iron_breastplate, DIRECTION_RIGHT, 30, 100, 81
    DECL_ENEMY_DATA NPC_ATTACK, 20, 6, 4, 4, ITEM_axe, ITEM_iron_breastplate, ITEM_strength_potion

    DECL_NPC        NPC_BRIDGE_BANDIT_2, NPC_ENEMY, CHARACTER_BANDIT, ITEM_axe, ITEM_green_cloak, DIRECTION_RIGHT, 30, 89, 105
    DECL_ENEMY_DATA NPC_ATTACK, 20, 8, 4, 2, ITEM_strength_potion, ITEM_bismuth_subsalicylate, ITEM_axe

    DECL_NPC        NPC_BRIDGE_BANDIT_3, NPC_ENEMY, CHARACTER_BANDIT, ITEM_great_bow, ITEM_green_hood, DIRECTION_RIGHT, 30, 89, 105
    DECL_ENEMY_DATA NPC_ATTACK, 20, 6, 4, 2, ITEM_great_bow, ITEM_bismuth_subsalicylate, ITEM_strength_potion

    DECL_NPC        NPC_LONELY_POET, NPC_TALKER, 128|NPC_POET_SPRITE, NO_ITEM, NO_ITEM, DIRECTION_RIGHT, 30, 107, 81
    DECL_TALK_DATA  NO_NPC, CONVERSATION_lonely_poet_ID, poet1, 0, poet7, NPC_ANGRY_POET

    DECL_NPC        NPC_ANGRY_POET, NPC_ENEMY, 128|NPC_POET_SPRITE, ITEM_angel_of_death, NO_ITEM, DIRECTION_RIGHT, 30, 107, 81
    DECL_ENEMY_DATA NPC_MOVE_ATTACK|NPC_MOVE_LOOKAT, 20, 8, 15, 2, ITEM_angel_of_death, ITEM_angel_of_death, ITEM_angel_of_death

    DECL_NPC        NPC_DEEP_FOREST_FOX, NPC_ENEMY, CHARACTER_FOX, ITEM_invisible_weapon, NO_ITEM, DIRECTION_DOWN, 20, 0, 0
    DECL_ENEMY_DATA NPC_PATROL, 10, 7, 3, 1, NO_ITEM, ITEM_mint_leaves, ITEM_raw_meat

    DECL_NPC        NPC_DEEP_FOREST_BANDIT_1, NPC_ENEMY, CHARACTER_BANDIT, ITEM_wooden_bow, ITEM_green_cloak, DIRECTION_DOWN, 30, 0, 0
    DECL_ENEMY_DATA NPC_PATROL, 20, 7, 3, 2, ITEM_mint_tonic, ITEM_green_cloak, ITEM_wooden_bow

    DECL_NPC        NPC_DEEP_FOREST_BANDIT_2, NPC_ENEMY, CHARACTER_BANDIT, ITEM_axe, ITEM_green_hood, DIRECTION_DOWN, 30, 0, 0
    DECL_ENEMY_DATA NPC_PATROL, 20, 8, 4, 2, ITEM_strength_potion, ITEM_axe, ITEM_green_hood

    DECL_NPC        NPC_DEEP_FOREST_BANDIT_3, NPC_ENEMY, CHARACTER_BANDIT, ITEM_bloody_sword, ITEM_wooden_shield, DIRECTION_DOWN, 30, 0, 0
    DECL_ENEMY_DATA NPC_PATROL, 20, 7, 4, 2, ITEM_speed_potion, ITEM_mint_tonic, ITEM_bloody_sword

    DECL_NPC        NPC_GHOUL_1, NPC_ENEMY, CHARACTER_GHOUL, ITEM_invisible_staff, NO_ITEM, DIRECTION_DOWN, 40, 114, 76
    DECL_ENEMY_DATA NPC_PATROL, 30, 6, 6, 1, NO_ITEM, 128|20, ITEM_glass_shard

    DECL_NPC        NPC_GHOUL_2, NPC_ENEMY, CHARACTER_GHOUL, ITEM_invisible_staff, NO_ITEM, DIRECTION_DOWN, 40, 91, 74
    DECL_ENEMY_DATA NPC_PATROL, 30, 6, 6, 0, NO_ITEM, 128|20, ITEM_glass_shard

    DECL_NPC        NPC_CULTIST_1, NPC_ENEMY, CHARACTER_CULTIST, ITEM_bloody_sword, NO_ITEM, DIRECTION_DOWN, 30, 44, 44
    DECL_ENEMY_DATA NPC_PATROL, 20, 6, 6, 2, NO_ITEM, ITEM_large_health_potion, ITEM_mint_tonic

    DECL_NPC        NPC_CULTIST_2, NPC_ENEMY, CHARACTER_CULTIST, ITEM_bloody_sword, NO_ITEM, DIRECTION_DOWN, 30, 120, 44
    DECL_ENEMY_DATA NPC_PATROL, 20, 6, 6, 2, NO_ITEM, ITEM_large_health_potion, ITEM_strength_potion

    DECL_NPC        NPC_CULTIST_3, NPC_ENEMY, CHARACTER_CULTIST, ITEM_bloody_sword, NO_ITEM, DIRECTION_UP, 30, 44, 88
    DECL_ENEMY_DATA NPC_PATROL, 20, 6, 6, 2, NO_ITEM, ITEM_large_health_potion, ITEM_mint_tonic

    DECL_NPC        NPC_CULTIST_4, NPC_ENEMY, CHARACTER_CULTIST, ITEM_bloody_sword, NO_ITEM, DIRECTION_UP, 30, 100, 88
    DECL_ENEMY_DATA NPC_PATROL, 20, 6, 6, 2, NO_ITEM, ITEM_large_health_potion, ITEM_strength_potion

    DECL_NPC        NPC_CULTIST_LEADER, NPC_ENEMY, CHARACTER_CULTIST, ITEM_iron_staff, NO_ITEM, DIRECTION_UP, 50, 194, 90
    DECL_ENEMY_DATA NPC_HOSTILE, 100, 6, 8, 5, ITEM_large_health_potion, ITEM_mint_tonic, ITEM_strength_potion

    DECL_NPC        NPC_HALDIR_GUARD, NPC_TALKER, CHARACTER_MAN, ITEM_spear, ITEM_iron_armor, DIRECTION_LEFT, 50, 180, 96
    DECL_TALK_DATA  NO_NPC, CONVERSATION_welcome_to_haldir_ID, haldir1, 0, haldir2, NPC_HALDIR_GUARD_1_ANGRY

    DECL_NPC        NPC_HALDIR_GUARD_1_ANGRY, NPC_ENEMY, CHARACTER_MAN, ITEM_spear, ITEM_iron_armor, DIRECTION_DOWN, 50, 0, 0
    DECL_ENEMY_DATA NPC_ATTACK, 50, 7, 8, 8, ITEM_spear, ITEM_iron_helmet, NO_ITEM

    DECL_NPC        NPC_HALDIR_GUARD_ANGRY, NPC_ENEMY, CHARACTER_MAN, ITEM_spear, ITEM_iron_armor, DIRECTION_DOWN, 50, 0, 0
    DECL_ENEMY_DATA NPC_ATTACK, 50, 7, 8, 8, ITEM_spear, ITEM_iron_helmet, NO_ITEM

    DECL_NPC        NPC_BARD, NPC_TALKER, 128|NPC_BARD_SPRITE, NO_ITEM, NO_ITEM, DIRECTION_LEFT, 20, 193, 92
    DECL_TALK_DATA  NPC_HALDIR_GUARD_ANGRY, 0, bard1, 0, bard1, NO_NPC

    DECL_NPC        NPC_ALCHEMIST, NPC_SHOPKEEPER, CHARACTER_WOMAN, NO_ITEM, ITEM_purple_hood, DIRECTION_DOWN, 20, 121, 58
    DECL_SHOP_DATA  NPC_HALDIR_GUARD_ANGRY, SHOP_alchemist_ID

    DECL_NPC        NPC_CITY_BLACKSMITH, NPC_SHOPKEEPER, 128|NPC_BLACKSMITH_SPRITE, NO_ITEM, NO_ITEM, DIRECTION_DOWN, 20, 169, 66
    DECL_SHOP_DATA  NPC_HALDIR_GUARD_ANGRY, SHOP_city_blacksmith_ID

    DECL_NPC        NPC_PAWNBROKER, NPC_SHOPKEEPER, 128|NPC_BUSINESSMAN_SPRITE, NO_ITEM, NO_ITEM, DIRECTION_DOWN, 20, 84, 88
    DECL_SHOP_DATA  NPC_HALDIR_GUARD_ANGRY, SHOP_pawnbroker_ID

    DECL_NPC        NPC_HALDIR_GUARD_2, NPC_TALKER, CHARACTER_MAN, ITEM_spear, ITEM_iron_armor, DIRECTION_RIGHT, 50, 121, 16
    DECL_TALK_DATA  NO_NPC, 0, no_message, 0, no_message, NPC_HALDIR_GUARD_2_ANGRY

    DECL_NPC        NPC_HALDIR_GUARD_2_ANGRY, NPC_ENEMY, CHARACTER_MAN, ITEM_spear, ITEM_iron_armor, DIRECTION_DOWN, 50, 0, 0
    DECL_ENEMY_DATA NPC_ATTACK, 50, 7, 8, 8, ITEM_spear, ITEM_iron_helmet, NO_ITEM

    DECL_NPC        NPC_CITIZEN_1, NPC_TALKER, CHARACTER_WOMAN, NO_ITEM, NO_ITEM, DIRECTION_LEFT, 20, 43, 153
    DECL_TALK_DATA  NPC_HALDIR_GUARD_ANGRY, 0, somethings_wrong, 0, somethings_wrong, NO_NPC

    DECL_NPC        NPC_CITIZEN_2, NPC_TALKER, CHARACTER_MAN, NO_ITEM, ITEM_beard, DIRECTION_DOWN, 20, 43, 157
    DECL_TALK_DATA  NPC_HALDIR_GUARD_ANGRY, 0, might_leave, 0, might_leave, NO_NPC

    DECL_NPC        NPC_CITIZEN_3, NPC_TALKER, 128|NPC_LEAVING_SPRITE, NO_ITEM, NO_ITEM, DIRECTION_LEFT, 20, 41, 132
    DECL_TALK_DATA  NPC_HALDIR_GUARD_ANGRY, 0, leaving, 0, leaving, NO_NPC

    DECL_NPC        NPC_FIELD_QUESTGIVER, NPC_TALKER, CHARACTER_MAN, NO_ITEM, ITEM_feathered_hat, DIRECTION_DOWN, 20, 70, 14
    DECL_TALK_DATA  NPC_HALDIR_GUARD_ANGRY, 0, field_foxes, 0, field_foxes, NO_NPC

    DECL_NPC        NPC_FIELD_FOX, NPC_ENEMY, CHARACTER_FOX, ITEM_invisible_weapon, ITEM_white_fox_eyes, DIRECTION_DOWN, 20, 0, 0
    DECL_ENEMY_DATA NPC_PATROL, 10, 7, 5, 2, ITEM_raw_meat, 128|5, 128|10

    DECL_NPC        NPC_BANK_QUESTGIVER, NPC_TALKER, CHARACTER_MAN, ITEM_blessed_sword, ITEM_iron_armor, DIRECTION_DOWN, 50, 123, 87
    DECL_TALK_DATA  NO_NPC, 0, kill_thieves1, 0, kill_thieves1, NPC_BANK_QUESTGIVER_ANGRY

    DECL_NPC        NPC_BANK_QUESTGIVER_ANGRY, NPC_ENEMY, CHARACTER_MAN, ITEM_blessed_sword, ITEM_iron_armor, DIRECTION_DOWN, 50, 123, 87
    DECL_ENEMY_DATA NPC_ATTACK, 100, 7, 10, 8, ITEM_iron_helmet, ITEM_iron_helmet, NO_ITEM

    DECL_NPC        NPC_BANK_GUARD_1, NPC_ENEMY, CHARACTER_MAN, ITEM_steel_sword, ITEM_iron_breastplate, DIRECTION_DOWN, 40, 96, 39
    DECL_ENEMY_DATA NPC_ATTACK|NPC_MOVE_HOLD, 50, 8, 7, 4, ITEM_steel_sword, NO_ITEM, NO_ITEM

    DECL_NPC        NPC_BANK_GUARD_2, NPC_ENEMY, CHARACTER_BANDIT, ITEM_steel_sword, ITEM_iron_breastplate, DIRECTION_DOWN, 40, 157, 39
    DECL_ENEMY_DATA NPC_ATTACK|NPC_MOVE_HOLD, 50, 8, 7, 4, ITEM_steel_sword, NO_ITEM, NO_ITEM

    DECL_NPC        NPC_BANK_GUARD_3, NPC_ENEMY, CHARACTER_MAN, ITEM_steel_sword, ITEM_iron_armor, DIRECTION_DOWN, 40, 127, 26
    DECL_ENEMY_DATA NPC_ATTACK, 50, 6, 7, 6, ITEM_steel_sword, ITEM_iron_helmet, NO_ITEM

    DECL_NPC        NPC_BANK_GUARD_4, NPC_ENEMY, CHARACTER_BANDIT, ITEM_steel_sword, ITEM_iron_breastplate, DIRECTION_DOWN, 50, 34, 26
    DECL_ENEMY_DATA NPC_ATTACK, 50, 8, 7, 4, ITEM_steel_sword, ITEM_iron_breastplate, NO_ITEM

    DECL_NPC        NPC_THIEF_QUESTGIVER, NPC_TALKER, CHARACTER_BANDIT, ITEM_spear, ITEM_iron_breastplate, DIRECTION_DOWN, 30, 138, 90
    DECL_TALK_DATA  NO_NPC, 0, rob_bank1, 0, rob_bank1, NPC_THIEF_QUESTGIVER_ANGRY

    DECL_NPC        NPC_THIEF_QUESTGIVER_ANGRY, NPC_ENEMY, CHARACTER_BANDIT, ITEM_spear, ITEM_iron_breastplate, DIRECTION_DOWN, 30, 138, 90
    DECL_ENEMY_DATA NPC_ATTACK, 30, 6, 6, 6, ITEM_spear, ITEM_iron_breastplate, NO_ITEM

    DECL_NPC        NPC_THIEF_QUESTGIVER_TRICKY, NPC_ENEMY, CHARACTER_BANDIT, ITEM_spear, ITEM_iron_breastplate, DIRECTION_DOWN, 30, 138, 90
    DECL_ENEMY_DATA NPC_ATTACK, 30, 6, 6, 6, ITEM_small_chest, ITEM_small_chest, ITEM_small_chest

    DECL_NPC        NPC_THIEF_1, NPC_ENEMY, CHARACTER_BANDIT, ITEM_steel_sword, ITEM_purple_hood, DIRECTION_DOWN, 30, 122, 41
    DECL_ENEMY_DATA NPC_MOVE_HOLD|NPC_ATTACK, 30, 6, 5, 3, ITEM_mint_tonic, ITEM_purple_hood, NO_ITEM

    DECL_NPC        NPC_THIEF_2, NPC_ENEMY, CHARACTER_MAN, ITEM_steel_sword, ITEM_iron_breastplate, DIRECTION_DOWN, 30, 157, 53
    DECL_ENEMY_DATA NPC_MOVE_HOLD|NPC_ATTACK, 30, 6, 5, 4, ITEM_whiskey, ITEM_iron_breastplate, NO_ITEM

    DECL_NPC        NPC_THIEF_3, NPC_ENEMY, CHARACTER_BANDIT, ITEM_steel_sword, ITEM_iron_helmet, DIRECTION_DOWN, 30, 122, 41
    DECL_ENEMY_DATA NPC_MOVE_HOLD|NPC_ATTACK, 30, 6, 5, 3, ITEM_steel_sword, ITEM_iron_helmet, NO_ITEM

    DECL_NPC        NPC_THIEF_4, NPC_ENEMY, CHARACTER_BANDIT, ITEM_steel_sword, ITEM_iron_breastplate, DIRECTION_DOWN, 30, 104, 61
    DECL_ENEMY_DATA NPC_ATTACK, 40, 6, 6, 5, ITEM_health_potion, ITEM_iron_breastplate, NO_ITEM

    DECL_NPC        NPC_THIEF_5, NPC_ENEMY, CHARACTER_CULTIST, ITEM_steel_sword, ITEM_iron_breastplate, DIRECTION_UP, 30, 128, 106
    DECL_ENEMY_DATA NPC_ATTACK, 40, 7, 6, 5, ITEM_iron_breastplate, ITEM_speed_potion, NO_ITEM

    DECL_NPC        NPC_THIEF_BOSS, NPC_ENEMY, CHARACTER_CULTIST, ITEM_glass_staff, ITEM_iron_breastplate, DIRECTION_UP, 50, 106, 120
    DECL_ENEMY_DATA NPC_ATTACK, 100, 5, 8, 4, 128|100, ITEM_iron_breastplate, ITEM_mint_tonic

    DECL_NPC        NPC_BRIDGE_BROKEN, NPC_TALKER, CHARACTER_HALFLING, NO_ITEM, ITEM_purple_hood, DIRECTION_RIGHT, 20, 206, 138
    DECL_TALK_DATA  NPC_HALDIR_GUARD_ANGRY, 0, bridge_broken, 0, bridge_broken, NO_NPC

    DECL_NPC        NPC_FINAL_FOX_1, NPC_ENEMY, CHARACTER_FOX, ITEM_invisible_weapon, ITEM_white_fox_eyes, DIRECTION_DOWN, 20, 123, 41
    DECL_ENEMY_DATA NPC_PATROL, 10, 7, 5, 2, ITEM_raw_meat, NO_ITEM, 128|10

    DECL_NPC        NPC_FINAL_FOX_2, NPC_ENEMY, CHARACTER_FOX, ITEM_invisible_weapon, ITEM_white_fox_eyes, DIRECTION_DOWN, 20, 176, 139
    DECL_ENEMY_DATA NPC_PATROL, 10, 7, 5, 2, ITEM_raw_meat, NO_ITEM, 128|10

    DECL_NPC        NPC_FINAL_FOX_3, NPC_ENEMY, CHARACTER_FOX, ITEM_invisible_weapon, ITEM_white_fox_eyes, DIRECTION_DOWN, 20, 74, 132
    DECL_ENEMY_DATA NPC_PATROL, 10, 7, 5, 2, ITEM_raw_meat, NO_ITEM, 128|10

    DECL_NPC        NPC_FINAL_BANDIT_1, NPC_ENEMY, CHARACTER_BANDIT, ITEM_spear, ITEM_leather_armor, DIRECTION_LEFT, 30, 68, 59
    DECL_ENEMY_DATA NPC_HOSTILE, 30, 7, 5, 3, ITEM_spear, NO_ITEM, NO_ITEM

    DECL_NPC        NPC_FINAL_BANDIT_2, NPC_ENEMY, CHARACTER_BANDIT, ITEM_blessed_sword, ITEM_mithril_breastplate, DIRECTION_LEFT, 40, 211, 91
    DECL_ENEMY_DATA NPC_PATROL, 50, 6, 8, 6, NO_ITEM, ITEM_blessed_sword, ITEM_mithril_breastplate

    DECL_NPC        NPC_FINAL_BANDIT_3, NPC_ENEMY, CHARACTER_BANDIT, ITEM_great_bow, ITEM_green_hood, DIRECTION_LEFT, 30, 164, 113
    DECL_ENEMY_DATA NPC_ATTACK, 40, 6, 8, 2, NO_ITEM, ITEM_great_bow, ITEM_green_hood

    DECL_NPC        NPC_FINAL_BANDIT_4, NPC_ENEMY, CHARACTER_BANDIT, ITEM_great_bow, ITEM_iron_helmet, DIRECTION_LEFT, 30, 164, 130
    DECL_ENEMY_DATA NPC_ATTACK, 40, 6, 8, 4, NO_ITEM, ITEM_great_bow, ITEM_iron_helmet

    DECL_NPC        NPC_BARON_HALDIR, NPC_TALKER, 128|NPC_BARON_SPRITE, NO_ITEM, NO_ITEM, DIRECTION_LEFT, 5, 85, 26
    DECL_TALK_DATA  NO_NPC, CONVERSATION_baron_haldir_ID, baron_haldir1, 0, baron_haldir4, NO_NPC

    DECL_NPC        NPC_ZHEV, NPC_ENEMY, CHARACTER_CULTIST, ITEM_ivory_wand, ITEM_iron_breastplate_cloak, DIRECTION_DOWN, 60, 120, 95
    DECL_ENEMY_DATA NPC_ATTACK|NPC_MOVE_CIRCLE, 200, 7, 11, 8, ITEM_letter, ITEM_letter, ITEM_letter

    DECL_NPC        NPC_ZHEV2, NPC_ENEMY, CHARACTER_CULTIST, ITEM_ivory_wand, ITEM_iron_breastplate_cloak, DIRECTION_DOWN, 50, 120, 95
    DECL_ENEMY_DATA NPC_ATTACK|NPC_MOVE_CIRCLE, 200, 5, 11, 6, NO_ITEM, NO_ITEM, NO_ITEM
