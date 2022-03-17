; All the properties of an item are stored in the item_table. These properties
; are pretty self-explanatory, except for the flags byte. The lower two bits of
; this flag (ITEM_WIELDABLE, ITEM_MAGIC, ITEM_USABLE, ITEM_WEARABLE) describe
; what can be done with the item. The upper six bits provide additional information.
;
; Wieldable Flags: [range:2][cooldown:3][unused:1][type:2]
;
; Magic Flags: [range:2][cooldown:3][high level:1][type:2]
;
; Wearable Flags: [speed:2][health:4][type:2]
;
; Usable Flags: [interval mask:5][eternal:1][type:2]
;
; ****************************************************************************
; NOTE: IMPORTANT! For rendering reasons, no item may affect more than THREE
; attributes. The game will overwrite memory (including the stack!) and crash.
; ****************************************************************************

.macro DECL_ITEM ; name, flags, cost, strength, vitality, dexterity, intellect, extra
    .dw 2*(_item_str_@0_name-item_string_table), 2*(_item_str_@0_desc-item_string_table)
    .db @1, low(@2), high(2), @3, @4, @5, @6, @7
.endm

.equ USABLE_ETERNAL = (1 << 2)
.equ MAGIC_HIGH_LEVEL = (1 << 2)

item_table:
    DECL_ITEM wood_stick,       (1<<6)|(1<<3)|ITEM_WIELDABLE,       7,  10, 0,  -1, -4, PADDING
    DECL_ITEM blue_shirt,       (0<<6)|((1&0xf)<<2)|ITEM_WEARABLE,  30, 2,  4,  0,  0, PADDING
    DECL_ITEM wood_staff,       (1<<6)|(3<<3)|ITEM_MAGIC,           80, 0,  10, -3, 0, (16<<2)|(0)
    DECL_ITEM health_potion,    (0x0<<2)|ITEM_USABLE,               100,2,  64, 2,  0, PADDING
    DECL_ITEM mint_soda,        (0x6<<2)|ITEM_USABLE,               20, 0,  0,  0,  1, PADDING
    DECL_ITEM mint_leaves,      (0x2<<2)|ITEM_USABLE,               10, 0,  0,  0,  1, PADDING
    DECL_ITEM curse_of_ullimar, USABLE_ETERNAL|ITEM_USABLE,         75, 0,  -75,0,  0, PADDING

item_string_table:
_item_str_wood_stick_name:          .db "Wood Stick", 0, 0
_item_str_wood_stick_desc:          .db "Although outwardly unassuming, this is a truly legendary weapon.", 0, 0
_item_str_blue_shirt_name:          .db "Blue Shirt", 0, 0
_item_str_blue_shirt_desc:          .db "A comfortable blue shirt.", 0
_item_str_wood_staff_name:          .db "Blessed Staff", 0
_item_str_wood_staff_desc:          .db "Made by a Lumbarith hermit, this old staff still contains power.", 0, 0
_item_str_health_potion_name:       .db "Healing Potion", 0, 0
_item_str_health_potion_desc:       .db "An elegant flask full of a blood-red liquid.", 0, 0
_item_str_mint_soda_name:           .db "Questionable Liquid", 0
_item_str_mint_soda_desc:           .db "Peculiarly, it smells strongly of mint.", 0
_item_str_mint_leaves_name:         .db "Useless Mint Leaves", 0
_item_str_mint_leaves_desc:         .db "Aromatic, but useless.", 0, 0
_item_str_curse_of_ullimar_name:    .db "Curse of Ullimar", 0, 0
_item_str_curse_of_ullimar_desc:    .db "An ice-cold vial of a strangely viscous black liquid.", 0
