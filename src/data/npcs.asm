; There are four different types of NPCs. The most common type, enemies, can
; move around, fight the player, and drop a somewhat random item on death. Talkers
; are associated with a conversation and do not move. Shopkeepers have a several
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
;   x, y position - (2 bytes)
;   acceleration - used for movement (1 byte)
;   health - initial health (1 byte)
;   strength - related to damage (1 byte)
;   agility - related to defence (1 byte)
;   drop 1,2,3,4,5 - one is randomly dropped upon death (5 bytes)
;
; Shopkeeper (16 bytes)
;   type - always NPC_SHOPKEEPER (1 byte)
;   base character - used for rendering (1 byte) NOTE: if the MSB is clear, a static character is used and weapon, armor, and direction are ignored
;   weapon, armor - used for rendering, may be ignored (2 bytes)
;   direction - used for rendering, may be ignored (1 byte)
;   x, y position - (2 bytes)
;   shop id - (1 byte)
;   empty - (8 bytes)
;
; Talker (16 bytes)
;   type - always NPC_TALKER (1 byte)
;   base character - used for rendering (1 bytes) NOTE: if the MSB is clear, a static character is used and weapon, armor, and direction are ignored
;   weapon, armor - used for rendering, may be ignored (2 bytes)
;   direction - used for rendering and attacks, may be ignored (1 byte)
;   x, y position - (2 bytes)
;   conversations - (8 bytes)
;   end of conversations list - always NO_CONVERSATION (1 byte)
;
; Special (16 bytes)
;   type - always NPC_SPECIAL (1 byte)
;   base character - used for rendering (1 bytes)
;   weapon, armor - used for rendering (2 bytes)
;   direction - used for rendering and attacks (1 byte)
;   x, y position - (2 bytes)
;   custom data (9 bytes)

npc_table:
    .db NPC_ENEMY, CHARACTER_PALADIN, 1, NO_ITEM, DIRECTION_DOWN, 24, 12, 10, 100, 10, 10, 1, 2, 3, 3, 3
    .db NPC_SHOPKEEPER, 128|0, NO_ITEM, NO_ITEM, DIRECTION_RIGHT, 36, 36, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .db NPC_TALKER, CHARACTER_PALADIN, NO_ITEM, NO_ITEM, DIRECTION_LEFT, 30, 150, 1, 1, 1, 1, 1, 1, 1, 1, 0
