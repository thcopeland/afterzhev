; All the properties of an item are stored in the item_table. These properties
; are pretty self-explanatory, except for the flags byte. The lower two bits of
; this flag (ITEM_WIELDABLE, ITEM_RANGED, ITEM_USABLE, ITEM_WEARABLE) describe
; what can be done with the item. The upper six bits provide additional information.
;
; The item table must match the order of the item sprites. Also, since the animation
; table uses the same item indexes, wieldable and wearable items must come before
; any usable items.
;
; strength - additional melee attack
; vitality - health, healing
; dexterity - speed
; intellect - additional ranged attack, necessary for high level ranged
;
; attack = weapon attack + (strength or intellect)/2
; damage = max(rand(attack, attack*2) - defense
;
; Wieldable Flags: [range:2][cooldown:3][unused:1][type:2]
; Wieldable Extra: [attack:4][unused:4]
;
; Ranged Flags: [speed:2][cooldown:3][high level:1][type:2]
; Ranged Extra: [attack:4][magical:1][effect:3]
;
; Wearable Flags: [signed health:6][type:2]
; Wearable Extra: [unused:4][defence:4]
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
    .db @1, low(@2), high(@2), @3, @4, @5, @6, @7
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
    DECL_ITEM wood_stick,           (1<<6)|(3<<3)|ITEM_WIELDABLE,        3,     0,  0,  0,  0,      (1<<4)
    DECL_ITEM feathered_hat,        ITEM_WEARABLE,                      10,     0,  0,  1,  0,      1
    DECL_ITEM bloody_sword,         (1<<6)|(1<<3)|ITEM_WIELDABLE,       30,     0, -1,  0,  0,      (3<<4)
    DECL_ITEM green_hood,           ITEM_WEARABLE,                      10,     0,  0,  0,  2,      1
    DECL_ITEM leather_armor,        ITEM_WEARABLE,                      75,     1,  0, -1,  0,      4
    DECL_ITEM invisible_weapon,     (1<<6)|ITEM_WIELDABLE,              0,      0,  0,  0,  0,      0
    DECL_ITEM steel_sword,          (1<<6)|ITEM_WIELDABLE,              40,     0,  0,  0,  0,      (5<<4)
    DECL_ITEM wooden_bow,           (2<<6)|ITEM_RANGED,                 30,     0,  0,  0,  0,      (3<<4)|EFFECT_ARROW
    DECL_ITEM guard_hat,            ITEM_WEARABLE,                      30,     0,  0, -2,  0,      2
    DECL_ITEM beard,                ITEM_WEARABLE,                      0,      0,  0,  0,  0,      0
    DECL_ITEM club,                 (1<<6)|(2<<3)|ITEM_WIELDABLE,       10,     0,  0,  0,  0,      (3<<4)
    DECL_ITEM glass_dagger,         ITEM_WIELDABLE,                     60,     0,  0,  3,  0,      (2<<4)
    DECL_ITEM glass_shard,          ITEM_WIELDABLE,                     10,     0,  0,  1,  0,      (1<<4)
    DECL_ITEM great_bow,            (3<<6)|(2<<3)|RANGED_HIGH_LEVEL|ITEM_RANGED, 200,  0,  0,  0,  0,      (7<<4)|EFFECT_ARROW
    DECL_ITEM green_cloak,          ITEM_WEARABLE,                      20,     0,  0,  0,  0,      2
    DECL_ITEM green_cloak_small,    ITEM_WEARABLE,                      20,     0,  0,  0,  0,      2
    DECL_ITEM purple_hood,          ITEM_WEARABLE,                      30,     0,  0,  0,  0,      0
    DECL_ITEM hammer,               (2<<3)|ITEM_WIELDABLE,              40,     0,  0,  0,  0,      (2<<4)
    DECL_ITEM iron_armor,           ITEM_WEARABLE,                     500,     2,  0, -10,  0,      10
    DECL_ITEM iron_breastplate,     ITEM_WEARABLE,                     350,     1,  0, -6,  0,      6
    DECL_ITEM iron_helmet,          ITEM_WEARABLE,                     200,     1,  0, -4,  0,      2
    DECL_ITEM iron_staff,           ITEM_RANGED,                        50,     0, -2,  0,  0,      0
    DECL_ITEM wood_staff,           RANGED_HIGH_LEVEL|ITEM_RANGED,     120,     0,  1,  0,  0,      0
    DECL_ITEM ivory_wand,           RANGED_HIGH_LEVEL|ITEM_RANGED,     200,     0,  0,  0,  0,      0
    DECL_ITEM mithril_armor,        ITEM_WEARABLE,                    2000,     0,  5,  0,  0,      15
    DECL_ITEM mithril_breastplate,  ITEM_WEARABLE,                    1400,     0,  3,  0,  0,      10
    DECL_ITEM mithril_cap,          ITEM_WEARABLE,                     600,     0,  1,  0,  0,      3
    DECL_ITEM mithril_dagger,       ITEM_WIELDABLE,                    300,     0,  2,  0,  0,      (3<<4)
    DECL_ITEM mithril_spike,        ITEM_WIELDABLE,                    200,     0,  0,  0,  0,      (2<<4)
    DECL_ITEM spear,                (2<<6)|(2<<3)|ITEM_WIELDABLE,      100,     0,  0, -2,  0,      (6<<4)
    DECL_ITEM wooden_shield,        ITEM_WEARABLE,                      10,     0,  0,  0,  0,      0
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
_item_str_invisible_weapon_desc:
_item_str_beard_name:
_item_str_beard_desc:				.dw 0
_item_str_steel_sword_name:         .db "Steel sword", 0
_item_str_steel_sword_desc:         .db "An elegant blade.", 0
_item_str_wooden_bow_name:          .db "Wooden bow", 0, 0
_item_str_wooden_bow_desc:          .db "An old but sturdy wooden bow.", 0
_item_str_guard_hat_name:           .db "Guard", 39, "s hat", 0
_item_str_guard_hat_desc:           .db "Worn only by members of", 10, "the Town Guard, and", 10, "shameless murderers.", 0, 0
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
_item_str_club_name:				.db "Club", 0, 0
_item_str_club_desc:				.db "A clumsy, random weapon", 10, "for an uncivillized age.", 0, 0
_item_str_glass_dagger_name:		.db "Glass dagger", 0, 0
_item_str_glass_dagger_desc:		.db "Fashioned from fabled", 10, "green glass, this blade", 10, "has a bloody history.", 0
_item_str_glass_shard_name:			.db "Glass shard", 0
_item_str_glass_shard_desc:			.db "A fragment of rare green glass.", 0
_item_str_great_bow_name:			.db "Great bow", 0
_item_str_great_bow_desc:			.db "A mighty bow, once used toextinguish the northern", 10, "serpents.", 0
_item_str_green_cloak_small_name:
_item_str_green_cloak_name:			.db "Woodsman", 39, "s cloak", 0, 0
_item_str_green_cloak_small_desc:
_item_str_green_cloak_desc:			.db "Useful on a cold day.", 0
_item_str_purple_hood_name:			.db "Purple hood", 0
_item_str_purple_hood_desc:			.db "Elegant and expensive.", 0, 0
_item_str_hammer_name:				.db "Hammer", 0, 0
_item_str_hammer_desc:				.db "Better suited to metal-", 10, "working than fighting.", 0, 0
_item_str_iron_armor_name:			.db "Iron armor", 0, 0
_item_str_iron_armor_desc:			.db "Traditionally worn by theNorthern Legions during", 10, "the dragon wars.", 0
_item_str_iron_breastplate_name:	.db "Iron breastplate", 0, 0
_item_str_iron_breastplate_desc:	.db "Protects against nearly", 10, "everything, except for", 10, "dragonfire.", 0, 0
_item_str_iron_helmet_name:			.db "Iron helmet", 0
_item_str_iron_helmet_desc:			.db "A heavy iron helmet.", 0, 0
_item_str_iron_staff_name:			.db "Iron staff", 0, 0
_item_str_iron_staff_desc:			.db "Traditionally wielded by", 10, "dark wizards, but could", 10, "be put to nobler uses.", 0
_item_str_wood_staff_name:			.db "Wooden staff", 0, 0
_item_str_wood_staff_desc:			.db "Unassuming, but packs a", 10, "punch.", 0, 0
_item_str_ivory_wand_name:			.db "Ivory wand", 0, 0
_item_str_ivory_wand_desc:			.db "Mostly used for various", 10, "ceremonial purposes.", 0, 0
_item_str_mithril_armor_name:		.db "Mithril armor", 0
_item_str_mithril_armor_desc:		.db "An unparalleled suit of", 10, "armor. Many noble kings", 10, "have murdered for less.", 0
_item_str_mithril_breastplate_name:	.db "Mithril breastplate", 0
_item_str_mithril_breastplate_desc:	.db "The posessor may laugh atarrows.", 0, 0
_item_str_mithril_cap_name:			.db "Mithril cap", 0
_item_str_mithril_cap_desc:			.db "No better helm exists,", 10, "yet it is the least part ofthe full suit.", 0, 0
_item_str_mithril_dagger_name:		.db "Mithril dagger", 0, 0
_item_str_mithril_dagger_desc:		.db "Wonderfully forged, yet little better than any", 10, "other dagger.", 0, 0
_item_str_mithril_spike_name:		.db "Mithril spike", 0
_item_str_mithril_spike_desc:		.db "A poor weapon, but worth a princely sum.", 0, 0
_item_str_spear_name:				.db "Spear", 0
_item_str_spear_desc:				.db "When wielded with skill, adevastating weapon.", 0
_item_str_wooden_shield_name:		.db "Wooden shield", 0
_item_str_wooden_shield_desc:		.db "Not particularly elegantbut useful in a pinch.", 0, 0
