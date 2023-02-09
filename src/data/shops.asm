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
    DECL_SHOP tutorial, 5, 0x20 ; 1x+5
    DECL_SHOP_ITEMS ITEM_bloody_sword, ITEM_beer, ITEM_croissant, NO_ITEM, NO_ITEM, NO_ITEM, NO_ITEM, NO_ITEM

    DECL_SHOP bartender, 5, 0x28 ; 1.25x+5
    DECL_SHOP_ITEMS ITEM_beer, ITEM_beer, ITEM_whiskey, ITEM_whiskey, ITEM_croissant, ITEM_croissant, ITEM_strength_potion, ITEM_speed_potion

    DECL_SHOP blacksmith, 10, 0x24 ; 1.125x+10
    DECL_SHOP_ITEMS ITEM_steel_sword, ITEM_wood_staff, ITEM_iron_breastplate, ITEM_leather_armor, ITEM_strength_potion, ITEM_hammer, ITEM_wooden_bow, ITEM_health_potion

    DECL_SHOP alchemist, 5, 0x28 ; 1.25x+5
    DECL_SHOP_ITEMS ITEM_large_health_potion, ITEM_large_health_potion, ITEM_strength_potion, ITEM_strength_potion, ITEM_mint_tonic, ITEM_mint_tonic, ITEM_speed_potion, ITEM_speed_potion

    DECL_SHOP city_blacksmith, 20, 0x24 ; 1.125x+5
    DECL_SHOP_ITEMS ITEM_iron_helmet, ITEM_spear, ITEM_blessed_sword, ITEM_leather_armor, ITEM_iron_armor, ITEM_mithril_cap, ITEM_glass_staff, ITEM_glass_dagger

    DECL_SHOP pawnbroker, 0, 0x40 ; 2x+0
    DECL_SHOP_ITEMS ITEM_mithril_cap, ITEM_bismuth_subsalicylate, ITEM_mithril_spike, ITEM_health_potion, ITEM_axe, ITEM_glass_dagger, ITEM_speed_potion, ITEM_purple_hood

shop_string_table:
_shop_tutorial_name:            .db "Merchant", 0, 0
_shop_bartender_name:           .db "Bristling Boar", 0, 0
_shop_blacksmith_name:          .db "Boris the Blacksmith", 0, 0
_shop_alchemist_name:           .db "Alchemist", 0
_shop_city_blacksmith_name:     .db "Blacksmith", 0, 0
_shop_pawnbroker_name:          .db "Pawnbroker", 0, 0
