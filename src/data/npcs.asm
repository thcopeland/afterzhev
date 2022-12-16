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
;   strength - related to damage (1 byte)
;   dexterity - related to defense (1 byte)
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
;   empty - (1 bytes)
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

.macro DECL_ENEMY_DATA ; xvel, yvel, acceleration, strength, dexterity, drop1, drop2, drop3
    .db @0, @1, @2, @3, @4, @5, @6, @7
.endm

.macro DECL_SHOP_DATA ; avenger, shop id
    .db @0, @1, 0, 0, 0, 0, 0, 0
.endm

.macro DECL_TALK_DATA ; avenger, id 1, conv 1, id 2, conv 2
    .db @0, @1
    .dw 2*(_conv_@2-conversation_table)
    .db @3, low(2*(_conv_@4-conversation_table)), high(2*(_conv_@4-conversation_table)), 0
.endm

.macro DECL_SPECIAL_DATA ; 8 bytes
    .db @0, @1, @2, @3, @4, @5, @6, @7
.endm

npc_table:
    DECL_NPC        NPC_CORPSE, NPC_SPECIAL, 128|NPC_CORPSE_SPRITE, NO_ITEM, NO_ITEM, DIRECTION_DOWN, 0, 0, 0
    DECL_SPECIAL_DATA 0, 0, 0, 0, 0, 0, 0, 0

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
    DECL_TALK_DATA  NO_NPC, CONVERSATION_drunks_warning_ID, drunks_warning, 0, drunks_warning2

    DECL_NPC        NPC_GRIEVING_FATHER, NPC_TALKER, 128|NPC_GRIEVING_FATHER_SPRITE, NO_ITEM, NO_ITEM, DIRECTION_LEFT, 10, 82, 132
    DECL_TALK_DATA  NO_NPC, 0, kidnapped_daughter, 0, END_CONVERSATION

    DECL_NPC        NPC_FOX_1, NPC_ENEMY, CHARACTER_FOX, ITEM_invisible_weapon, NO_ITEM, DIRECTION_LEFT, 10, 132, 108
    DECL_ENEMY_DATA 0, 0, 6, 3, 10, ITEM_raw_meat, ITEM_rotten_meat, 128|5

    DECL_NPC        NPC_FOX_2, NPC_ENEMY, CHARACTER_FOX, ITEM_invisible_weapon, NO_ITEM, DIRECTION_DOWN, 10, 168, 147
    DECL_ENEMY_DATA 0, 0, 6, 3, 10, ITEM_raw_meat, ITEM_rotten_meat, 128|5

    DECL_NPC        NPC_FOX_3, NPC_ENEMY, CHARACTER_FOX, ITEM_invisible_weapon, NO_ITEM, DIRECTION_RIGHT, 10, 144, 128
    DECL_ENEMY_DATA 0, 0, 7, 3, 10, ITEM_raw_meat, ITEM_rotten_meat, 128|5

    DECL_NPC        NPC_FOX_4, NPC_ENEMY, CHARACTER_FOX, ITEM_invisible_weapon, NO_ITEM, DIRECTION_LEFT, 10, 190, 120
    DECL_ENEMY_DATA 0, 0, 6, 3, 10, ITEM_raw_meat, ITEM_rotten_meat, 128|5

    DECL_NPC        NPC_FOX_5, NPC_ENEMY, CHARACTER_FOX, ITEM_invisible_weapon, NO_ITEM, DIRECTION_UP, 10, 130, 143
    DECL_ENEMY_DATA 0, 0, 7, 3, 10, ITEM_raw_meat, ITEM_rotten_meat, 128|5

    DECL_NPC        NPC_KIDNAPPED_DAUGHTER, NPC_ENEMY, CHARACTER_ELF, NO_ITEM, ITEM_kidnapped_hair, DIRECTION_RIGHT, 10, 128, 25
    DECL_ENEMY_DATA 0, 0, 6, 3, 10, NO_ITEM, NO_ITEM, NO_ITEM

    ; DECL_NPC        NPC_TALKER, 128|NPC_SIGN_SPRITE, NO_ITEM, NO_ITEM, DIRECTION_DOWN, 0, 138, 14
    ; DECL_TALK_DATA  0, 1, fisherman_greeting, 0, fisherman_laugh

    ; DECL_NPC        NPC_ENEMY, CHARACTER_PALADIN, 3, 2, DIRECTION_RIGHT, 20, 24, 12
    ; DECL_ENEMY_DATA 40, 127, 8, 10, 10, 1, 2, 3
    ;
    ; DECL_NPC        NPC_ENEMY, CHARACTER_PALADIN, 1, NO_ITEM, DIRECTION_DOWN, 30, 48, 12
    ; DECL_ENEMY_DATA 0, 0, 8, 10, 10, 1, 2, 3
    ;
    ; DECL_NPC        NPC_SHOPKEEPER, 128 | 1, NO_ITEM, NO_ITEM, DIRECTION_RIGHT, 10, 36, 36
    ; DECL_SHOP_DATA  3, 1
    ;
    ; DECL_NPC        NPC_TALKER, CHARACTER_PALADIN, NO_ITEM, NO_ITEM, DIRECTION_LEFT, 20, 30, 150
    ; DECL_TALK_DATA  0, 1, fisherman_greeting, 0, fisherman_laugh
    ;
    ; DECL_NPC        NPC_ENEMY, CHARACTER_PALADIN, 1, NO_ITEM, DIRECTION_DOWN, 20, 48, 80
    ; DECL_ENEMY_DATA 0, 0, 8, 10, 10, 1, 2, 3
    ;
    ; DECL_NPC        NPC_ENEMY, CHARACTER_PALADIN, 1, NO_ITEM, DIRECTION_DOWN, 20, 100, 80
    ; DECL_ENEMY_DATA 0, 0, 8, 10, 10, 1, 2, 3
    ;
    ; DECL_NPC        NPC_ENEMY, CHARACTER_PALADIN, 1, NO_ITEM, DIRECTION_DOWN, 20, 130, 100
    ; DECL_ENEMY_DATA 0, 0, 8, 10, 10, 1, 2, 3
