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
    DECL_ITEM wood_stick,           (1<<6)|(1<<3)|ITEM_WIELDABLE,       2,      2,  0,  0,  0,      PADDING
    DECL_ITEM feathered_hat,        ITEM_WEARABLE,                      20,     0,  0,  2,  4,      PADDING
    DECL_ITEM inventory_book,       ITEM_USABLE,                        0,      0,  0,  0,  0,      1

DECL_LOOSE_ITEM intro_wood_stick

item_string_table:
_item_str_wood_stick_name:          .db "Tree branch", 0
_item_str_wood_stick_desc:          .db "Better than nothing.", 0, 0
_item_str_feathered_hat_name:       .db "Dashing hat", 0
_item_str_feathered_hat_desc:       .db "Sporting an elegant red", 10, "feather.", 0, 0
_item_str_inventory_book_name:      .db "Book of Inventory", 0
_item_str_inventory_book_desc:      .db "Press <A> to equip or unequip.", 10, "Press <B> to use a potion.", 10, "Press <select> to drop.", 0
