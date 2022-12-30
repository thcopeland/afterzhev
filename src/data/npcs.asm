; There are four different types of NPCs. The most common type, enemies, can
; move around, fight the player, and drop a somewhat random item on death. Talkers
; are associated with up to two conversations and do not move. Shopkeepers have
; items that they can sell and also do not move. Special NPCs can do literally
; anything and are handled separately. These are used for important or unique
; chararacters.
;
; All NPCs are (for better or worse) stored within a single table.
;
; Enemy (16 bytes)
;   type - always NPC_ENEMY (1 byte)
;   base character - used for rendering (1 bytes)
;   weapon, armor - used for rendering (2 bytes)
;   direction - used for rendering and attacks (1 byte)
;   health - initial health (1 byte)
;   x, y position - (2 bytes)
;   x, y velocity - (2 bytes)
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
.endm

.macro DECL_ENEMY_DATA ; xvel, yvel, acceleration, attack, defense, drop1, drop2, drop3
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
    DECL_ENEMY_DATA 0, 0, 8, 8, 5, ITEM_guard_hat, ITEM_guard_hat, ITEM_steel_sword

    DECL_NPC        NPC_BATTLE_TUTORIAL, NPC_ENEMY, CHARACTER_BANDIT, ITEM_bloody_sword, NO_ITEM, DIRECTION_DOWN, 5, 180, 26
    DECL_ENEMY_DATA 0, 0, 8, 4, 10, ITEM_bloody_sword, ITEM_bloody_sword, ITEM_bloody_sword

    DECL_NPC        NPC_BANDIT_1, NPC_ENEMY, CHARACTER_BANDIT, ITEM_bloody_sword, ITEM_green_hood, DIRECTION_LEFT, 10, 111, 73
    DECL_ENEMY_DATA 0, 0, 8, 4, 10, 128|20, ITEM_bloody_sword, ITEM_green_hood

    DECL_NPC        NPC_BANDIT_2, NPC_ENEMY, CHARACTER_MAN, ITEM_bloody_sword, ITEM_leather_armor, DIRECTION_UP, 14, 96, 84
    DECL_ENEMY_DATA 0, 0, 8, 4, 10, ITEM_leather_armor, ITEM_bloody_sword, 128|30

    DECL_NPC        NPC_BANDIT_3, NPC_ENEMY, CHARACTER_MAN, ITEM_bloody_sword, ITEM_green_hood, DIRECTION_UP, 20, 120, 146
    DECL_ENEMY_DATA 0, 0, 8, 4, 10, 128|20, ITEM_bloody_sword, ITEM_green_hood

    DECL_NPC        NPC_BANDIT_3_REFORMED, NPC_ENEMY, CHARACTER_MAN, NO_ITEM, ITEM_green_hood, DIRECTION_UP, 20, 120, 146
    DECL_ENEMY_DATA 0, 0, 8, 4, 10, 128|20, ITEM_green_hood, ITEM_green_hood

    DECL_NPC        NPC_DRUNK, NPC_TALKER, 128|NPC_DRUNK_SPRITE, NO_ITEM, NO_ITEM, DIRECTION_LEFT, 10, 165, 26
    DECL_TALK_DATA  NO_NPC, CONVERSATION_drunks_warning_ID, drunks_warning, 0, drunks_warning2, NO_NPC

    DECL_NPC        NPC_GRIEVING_FATHER, NPC_TALKER, 128|NPC_GRIEVING_FATHER_SPRITE, NO_ITEM, NO_ITEM, DIRECTION_LEFT, 10, 82, 132
    DECL_TALK_DATA  NO_NPC, 0, kidnapped, 0, END_CONVERSATION, NO_NPC

    DECL_NPC        NPC_FOX_1, NPC_ENEMY, CHARACTER_FOX, ITEM_invisible_weapon, NO_ITEM, DIRECTION_RIGHT, 10, 24, 24
    DECL_ENEMY_DATA 0, 0, 7, 2, 5, ITEM_raw_meat, ITEM_rotten_meat, 128|5

    DECL_NPC        NPC_FOX_2, NPC_ENEMY, CHARACTER_FOX, ITEM_invisible_weapon, NO_ITEM, DIRECTION_DOWN, 10, 168, 147
    DECL_ENEMY_DATA 0, 0, 7, 2, 5, ITEM_raw_meat, ITEM_rotten_meat, 128|5

    DECL_NPC        NPC_FOX_3, NPC_ENEMY, CHARACTER_FOX, ITEM_invisible_weapon, NO_ITEM, DIRECTION_RIGHT, 10, 144, 128
    DECL_ENEMY_DATA 0, 0, 8, 2, 5, ITEM_raw_meat, ITEM_rotten_meat, 128|5

    DECL_NPC        NPC_FOX_4, NPC_ENEMY, CHARACTER_FOX, ITEM_invisible_weapon, NO_ITEM, DIRECTION_LEFT, 10, 190, 120
    DECL_ENEMY_DATA 0, 0, 7, 2, 5, ITEM_raw_meat, ITEM_rotten_meat, 128|5

    DECL_NPC        NPC_FOX_5, NPC_ENEMY, CHARACTER_FOX, ITEM_invisible_weapon, NO_ITEM, DIRECTION_UP, 10, 130, 143
    DECL_ENEMY_DATA 0, 0, 8, 2, 5, ITEM_raw_meat, ITEM_rotten_meat, 128|5

    DECL_NPC        NPC_KIDNAPPED, NPC_ENEMY, CHARACTER_CHILD, NO_ITEM, NO_ITEM, DIRECTION_RIGHT, 10, 128, 25
    DECL_ENEMY_DATA 0, 0, 6, 2, 5, NO_ITEM, NO_ITEM, NO_ITEM

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

    DECL_NPC        NPC_ANNOYED_GUEST, NPC_TALKER, CHARACTER_BANDIT, NO_ITEM, ITEM_feathered_hat, DIRECTION_DOWN, 30, 192, 40
    DECL_TALK_DATA  NO_NPC, 0, just_beat_it, 0, just_beat_it, NPC_ROBBED_GUEST

    DECL_NPC        NPC_ROBBED_GUEST, NPC_ENEMY, CHARACTER_BANDIT, ITEM_steel_sword, ITEM_feathered_hat, DIRECTION_DOWN, 30, 192, 40
    DECL_ENEMY_DATA 0, 0, 6, 6, 5, NO_ITEM, ITEM_feathered_hat, ITEM_feathered_hat

    DECL_NPC        NPC_GUEST_QUEST, NPC_TALKER, CHARACTER_MAN, NO_ITEM, ITEM_leather_armor, DIRECTION_LEFT, 10, 59, 34
    DECL_TALK_DATA  NO_NPC, 0, guest_quest, 0, guest_quest, NO_NPC

    DECL_NPC        NPC_GRUFF_BOUNCER, NPC_TALKER, CHARACTER_MAN, ITEM_club, ITEM_beard, DIRECTION_DOWN, 30, 38, 123
    DECL_TALK_DATA  NO_NPC, 0, just_beat_it, 0, just_beat_it, NPC_ANGRY_BOUNCER

    DECL_NPC        NPC_ANGRY_BOUNCER, NPC_ENEMY, CHARACTER_MAN, ITEM_club, ITEM_beard, DIRECTION_DOWN, 30, 38, 123
    DECL_ENEMY_DATA 0, 0, 5, 5, 4, ITEM_club, ITEM_club, ITEM_club

    DECL_NPC        NPC_TOWN_BLACKSMITH, NPC_SHOPKEEPER, 128|NPC_BLACKSMITH_SPRITE, NO_ITEM, NO_ITEM, DIRECTION_DOWN, 40, 183, 93
    DECL_SHOP_DATA  NPC_TOWN_GUARD_ANGRY, SHOP_blacksmith_ID

    DECL_NPC        NPC_UNDERCOVER_BANDIT, NPC_TALKER, CHARACTER_MAN, NO_ITEM, ITEM_green_cloak, DIRECTION_LEFT, 30, 111, 90
    DECL_TALK_DATA  NO_NPC, CONVERSATION_bandit_lies_ID, bandit_lies1, 0, bandit_good_luck, NPC_UNDERCOVER_BANDIT_UNMASKED

    DECL_NPC        NPC_UNDERCOVER_BANDIT_UNMASKED, NPC_ENEMY, CHARACTER_MAN, ITEM_steel_sword, ITEM_green_cloak, DIRECTION_UP, 30, 139, 60
    DECL_ENEMY_DATA 0, 0, 7, 7, 4, ITEM_steel_sword, 128|50, 128|ITEM_health_potion

    DECL_NPC        NPC_UNDERCOVER_GOON1, NPC_ENEMY, CHARACTER_BANDIT, ITEM_wooden_bow, ITEM_green_hood, DIRECTION_UP, 30, 144, 66
    DECL_ENEMY_DATA 0, 0, 6, 7, 4, 128|25, 128|50, 128|ITEM_health_potion

    DECL_NPC        NPC_UNDERCOVER_GOON2, NPC_ENEMY, CHARACTER_BANDIT, ITEM_bloody_sword, ITEM_green_hood, DIRECTION_UP, 30, 130, 66
    DECL_ENEMY_DATA 0, 0, 6, 7, 4, 128|25, 128|50, 128|ITEM_health_potion

    DECL_NPC        NPC_FOX_6, NPC_ENEMY, CHARACTER_FOX, ITEM_invisible_weapon, NO_ITEM, DIRECTION_DOWN, 10, 159, 67
    DECL_ENEMY_DATA 0, 60, 8, 2, 5, ITEM_raw_meat, ITEM_rotten_meat, ITEM_raw_meat

    DECL_NPC        NPC_TMP, NPC_ENEMY, CHARACTER_FOX, ITEM_invisible_weapon, NO_ITEM, DIRECTION_DOWN, 10, 88, 94
    DECL_ENEMY_DATA 0, 60, 8, 2, 5, ITEM_raw_meat, ITEM_rotten_meat, ITEM_raw_meat

    DECL_NPC        NPC_TMP2, NPC_ENEMY, CHARACTER_FOX, ITEM_invisible_weapon, NO_ITEM, DIRECTION_DOWN, 10, 88, 94
    DECL_ENEMY_DATA 0, 60, 8, 2, 5, ITEM_raw_meat, ITEM_rotten_meat, ITEM_raw_meat
