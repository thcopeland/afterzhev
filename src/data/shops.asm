; A shop contains the shop's inventory and its name. Pricing information is
; stored with the associated NPC.
;
; Shop Layout (12 bytes)
;   name ptr - (2 bytes)
;   price adjustment - Hx+L (2 bytes)
;   items - (8 bytes)

.macro DECL_SHOP_HDR ; name, price adjustment const, price adjustment factor (3.5 fixed-point)
    .dw 2*(_shop_str_@0_name-shop_string_table)
    .db @1, @2
.endm

.macro DECL_SHOP_ITEMS ; 8 items
    .db @0, @1, @2, @3, @4, @5, @6, @7
.endm

shop_table:
    DECL_SHOP_HDR butcher_bob, 10, 0x4f
    DECL_SHOP_ITEMS 1, 1, 3, 3, 2, 4, 5, 5

shop_string_table:
_shop_str_butcher_bob_name:     .db "Bob the Butcher", 0
