; All the properties of an item are stored in the item_table. These properties
; are pretty self-explanatory, except for the flags byte. The lower two bits of
; this flag (ITEM_WIELDABLE, ITEM_USABLE, ITEM_WEARABLE, ITEM_SPECIAL) describe
; what can be done with the item. The upper six bits provide additional information.
; For wieldable items, bonus damage, for usable items, the duration of effects,
; for wearable items, nothing yet, and for special items, it depends.


; ****************************************************************************
; NOTE: IMPORTANT! For rendering reasons, no item may affect more than THREE
; attributes. The game will overwrite memory (including the stack!) and crash.
; ****************************************************************************

.macro DECL_ITEM ; name, flags, cost, strength, vitality, dexterity, intellect
    .dw 2*(_item_str_@0_name-item_string_table), 2*(_item_str_@0_desc-item_string_table)
    .db @1, low(@2), high(2), @3, @4, @5, @6, 0 ; final 0 for padding
.endm

item_table:
    DECL_ITEM wood_stick, ITEM_WIELDABLE, 7, 10, 0, -1, -4
    DECL_ITEM blue_shirt, ITEM_WEARABLE, 30, 2, 4, 0, 0
    DECL_ITEM health_potion, (0<<2)|ITEM_USABLE, 100, 2, 64, 2, 0
    DECL_ITEM mint_soda, (3<<2)|ITEM_USABLE, 20, 0, 0, 0, 1
    DECL_ITEM mint_leaves, (1<<2)|ITEM_USABLE, 10, 0, 0, 0, 1

item_string_table:
_item_str_wood_stick_name:      .db "Wood Stick", 0, 0
_item_str_wood_stick_desc:      .db "Although outwardly unassuming, this is a truly legendary weapon.", 0, 0
_item_str_blue_shirt_name:      .db "Blue Shirt", 0, 0
_item_str_blue_shirt_desc:      .db "A comfortable blue shirt.", 0
_item_str_health_potion_name:   .db "Healing Potion", 0, 0
_item_str_health_potion_desc:   .db "An elegant flask full of a blood-red liquid.", 0, 0
_item_str_mint_soda_name:       .db "Questionable Liquid", 0
_item_str_mint_soda_desc:       .db "Peculiarly, it smells strongly of mint.", 0
_item_str_mint_leaves_name:     .db "Useless Mint Leaves", 0
_item_str_mint_leaves_desc:     .db "Aromatic, but useless.", 0, 0
