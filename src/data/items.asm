; All the properties of an item are stored in the item_table. These properties
; are pretty self-explanatory, except for the flags byte. The lower two bits of
; this flag (ITEM_WIELDABLE, ITEM_RANGED, ITEM_USABLE, ITEM_WEARABLE) describe
; what can be done with the item. The upper six bits provide additional information.
;
; The item table must match the order of the item sprites. Also, since the animation
; table uses the same item indexes, wieldable and wearable items must come before
; any usable items.
;
; Wieldable Flags: [range:2][cooldown:3][unused:1][type:2]
; Wieldable Extra: [unused:8]
;
; Ranged Flags: [effect speed/range:2][cooldown:3][high level:1][type:2]
; Ranged Extra: [extra damage:4][magical:1][effect:3]
;
; Wearable Flags: [speed:2][health:4][type:2]
; Wearable Extra: [unused:8]
;
; Usable Flags: [interval mask:5][eternal:1][type:2]
; Usable Extra: [unused:7][not actually usable:1]
;
; ****************************************************************************
; NOTE: IMPORTANT! For rendering reasons, no item may affect more than THREE
; attributes. The game will overwrite memory (including the stack!) and crash.
; ****************************************************************************

.set __ITEM_IDX = 1
.macro DECL_ITEM ; name, flags, cost, strength, vitality, dexterity, intellect, extra
    .equ ITEM_@0 = __ITEM_IDX
    .set __ITEM_IDX = __ITEM_IDX+1
    .dw 2*(_item_str_@0_name-item_string_table), 2*(_item_str_@0_desc-item_string_table)
    .db @1, low(@2), high(2), @3, @4, @5, @6, @7
    .if (@3 != 0) && (@4 != 0) && (@5 != 0) && (@6 != 0)
        .error "(@0) No item may affect more than THREE attributes"
    .endif
.endm

.set __LOSE_ITEM_IDX = 1
.macro DECL_LOOSE_ITEM ; name
    .equ LOOSE_ITEM_@0 = __LOSE_ITEM_IDX
    .set __LOSE_ITEM_IDX = __LOSE_ITEM_IDX+1
.endm

.equ USABLE_ETERNAL = (1 << 2)
.equ RANGED_HIGH_LEVEL = (1 << 2)
.equ RANGED_MAGICAL = (1 << 3)

item_table:
    DECL_ITEM wood_stick,           (1<<6)|(2<<3)|ITEM_WIELDABLE,       2,      2,  0,  0,  0,      0
    DECL_ITEM feathered_hat,        ITEM_WEARABLE,                      20,     0,  0,  2,  4,      0
    DECL_ITEM bloody_sword,         (1<<6)|(1<<3)|ITEM_WIELDABLE,       50,     6,  0,  0,  0,      0
    DECL_ITEM green_hood,           ITEM_WEARABLE,                      10,     0,  0,  3,  2,      0
    DECL_ITEM leather_armor,        (4<<2)|ITEM_WEARABLE,               50,     0,  2, -3,  0,      0
    DECL_ITEM invisible_weapon,     (1<<6)|ITEM_WIELDABLE,              10000,  0,  0,  0,  0,      0
    DECL_ITEM steel_sword,          (1<<6)|ITEM_WIELDABLE,              60,     6,  0,  0,  0,      0
    DECL_ITEM wooden_bow,           ITEM_RANGED,                        30,     0,  0,  0,  0,      0
    DECL_ITEM inventory_book,       ITEM_USABLE,                        0,      0,  0,  0,  0,      1
    DECL_ITEM raw_meat,             (3<<3)|ITEM_USABLE,                 20,     0,  8,  0,  0,      0
    DECL_ITEM rotten_meat,          (1<<3)|ITEM_USABLE,                 1,      0, -5,  0,  0,      0
    DECL_ITEM health_potion,        (0<<3)|ITEM_USABLE,                 100,    0, 64,  0,  0,      0
    DECL_ITEM beer,                 (3<<3)|ITEM_USABLE,                 5,      5,  5,  0, -5,      0
    DECL_ITEM croissant,            (3<<3)|ITEM_USABLE,                 10,     0, 10,  0,  0,      0
    DECL_ITEM whiskey,              (1<<3)|ITEM_USABLE,                 20,    10,  5, -5,  0,      0
    DECL_ITEM journal,              ITEM_USABLE,                        10,     0,  0,  0,  0,      1

DECL_LOOSE_ITEM intro_wood_stick
DECL_LOOSE_ITEM intro_bandit_gold
DECL_LOOSE_ITEM foxes_feathered_hat
DECL_LOOSE_ITEM tavern_guest_gold
DECL_LOOSE_ITEM lost_journal

item_string_table:
_item_str_wood_stick_name:          .db "Tree branch", 0
_item_str_wood_stick_desc:          .db "Better than nothing.", 0, 0
_item_str_feathered_hat_name:       .db "Dashing hat", 0
_item_str_feathered_hat_desc:       .db "Sporting an elegant red", 10, "feather.", 0, 0
_item_str_bloody_sword_name:        .db "Bloody sword", 0, 0
_item_str_bloody_sword_desc:        .db "The blade reeks of blood,marks of a cruel past.", 0
_item_str_green_hood_name:          .db "Faded green hood", 0, 0
_item_str_green_hood_desc:          .db "Bestows upon the wearer", 10, "an indefinable air of", 10, "mystery.", 0, 0
_item_str_leather_armor_name:       .db "Leather armor", 0
_item_str_leather_armor_desc:       .db "Scarred and worn, it has clearly seen much use.", 0
_item_str_invisible_weapon_name:
_item_str_invisible_weapon_desc:    .db 0, 0
_item_str_steel_sword_name:         .db "Steel sword", 0
_item_str_steel_sword_desc:         .db "An elegant blade.", 0
_item_str_wooden_bow_name:          .db "Wooden bow", 0, 0
_item_str_wooden_bow_desc:          .db "Crudely made, yet unexpectedlystrong.", 0
_item_str_inventory_book_name:      .db "Book of Inventory", 0
_item_str_inventory_book_desc:      .db "Press <A> to equip or unequip.", 10, "Press <B> to use a potion.", 10, "Press <select> to drop.", 0
_item_str_raw_meat_name:            .db "Raw meat", 0, 0
_item_str_raw_meat_desc:            .db "Probably safe to eat.", 0
_item_str_rotten_meat_name:         .db "Rotten meat", 0
_item_str_rotten_meat_desc:         .db "Tinged a poisonous green.", 0
_item_str_health_potion_name:       .db "Health potion", 0
_item_str_health_potion_desc:       .db "Quickly recover from even mortal wounds.", 0, 0
_item_str_beer_name:                .db "Pint of beer", 0, 0
_item_str_beer_desc:                .db "The local brew is", 10, "unusually bitter.", 0
_item_str_croissant_name:           .db "Croissant", 0
_item_str_croissant_desc:           .db "Fresh and flaky.", 0, 0
_item_str_whiskey_name:             .db "Whiskey", 0
_item_str_whiskey_desc:             .db "Burns the esophageal", 10, "tissues on the way down.", 0
_item_str_journal_name:             .db "Missing journal", 0
_item_str_journal_desc:             .db "A mysterious leather-bound", 10, "journal, tightly clasped shut.", 0
