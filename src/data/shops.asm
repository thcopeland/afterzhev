; A shop contains the shop's inventory, name, and pricing information.
;
; Shop Layout (12 bytes)
;   name ptr - (2 bytes)
;   price adjustment - Hx+L (2 bytes)
;   items - (8 bytes)

.set __SHOP_IDX = 1
.macro DECL_SHOP ; name, price adjustment const, price adjustment factor (3.5 fixed-point)
    .equ SHOP_@0_ID = __SHOP_IDX
    .set __SHOP_IDX = __SHOP_IDX + 1
    .dw 2*(_shop_@0_name-shop_string_table)
    .db @1, @2
.endm

.macro DECL_SHOP_ITEMS ; 8 items
    .db @0, @1, @2, @3, @4, @5, @6, @7
.endm

shop_table:
    DECL_SHOP bartender, 5, 0x28 ; 1.25x+5
    DECL_SHOP_ITEMS ITEM_beer, ITEM_beer, ITEM_beer, ITEM_beer, ITEM_whiskey, ITEM_whiskey, ITEM_croissant, ITEM_croissant

    DECL_SHOP blacksmith, 10, 0x24 ; 1.125x+10
    DECL_SHOP_ITEMS ITEM_steel_sword, ITEM_steel_sword, ITEM_iron_breastplate, ITEM_iron_breastplate, ITEM_iron_staff, ITEM_hammer, ITEM_health_potion, ITEM_health_potion

shop_string_table:
_shop_bartender_name:           .db "Bristling Boar", 0, 0
_shop_blacksmith_name:          .db "Boris the Blacksmith", 0, 0
