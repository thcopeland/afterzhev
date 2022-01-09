; All the properties of an item are stored in the item_table. These properties
; are pretty self-explanatory, except for the flags byte. The lower two bits of
; this flag (ITEM_WIELDABLE, ITEM_USABLE, ITEM_WEARABLE, ITEM_SPECIAL) describe
; what can be done with the item. The upper six bits provide additional information.
; For wieldable items, bonus damage, for usable items, the duration of effects,
; for wearable items, nothing yet, and for special items, it depends.

.macro DECL_ITEM ; name, flags, cost, strength, vitality, dexterity, charisma
    .dw 2*(_item_str_@0_name-item_string_table), 2*(_item_str_@0_desc-item_string_table)
    .db @1, @2, @3, @4, @5, @6
.endm

item_table:
    DECL_ITEM wood_stick, ITEM_WIELDABLE, 1, 10, 0, -1, -4
    DECL_ITEM health_potion, ITEM_USABLE, 15, 2, 50, 2, 0
    DECL_ITEM mint_soda, ITEM_USABLE, 3, 0, 0, 0, 1
    DECL_ITEM mint_leaves, ITEM_USABLE, 1, 0, 0, 0, 1

item_string_table:
_item_str_wood_stick_name:      .db "Wood Stick", 0, 0
_item_str_wood_stick_desc:      .db "Although outwardly un-assuming, this is the ancient weapon of the legendary Kalima-bah.", 0
_item_str_health_potion_name:   .db "Healing Potion", 0, 0
_item_str_health_potion_desc:   .db "An elegant flask full of a blood-red liquid.", 0, 0
_item_str_mint_soda_name:       .db "Questionable Liquid", 0
_item_str_mint_soda_desc:       .db "Peculiarly, it smells strongly of mint.", 0
_item_str_mint_leaves_name:     .db "Useless Mint Leaves", 0
_item_str_mint_leaves_desc:     .db "Aromatic, but useless.", 0, 0
