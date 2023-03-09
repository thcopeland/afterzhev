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

.set __LOOSE_ITEM_IDX = 1
.macro DECL_LOOSE_ITEM ; name
    .equ LOOSE_ITEM_@0 = __LOOSE_ITEM_IDX
    .set __LOOSE_ITEM_IDX = __LOOSE_ITEM_IDX+1
.endm

.equ USABLE_ETERNAL = (1 << 2)
.equ RANGED_HIGH_LEVEL = (1 << 2)
.equ RANGED_MAGICAL = (1 << 3)

item_table:
    DECL_ITEM wood_stick,           (1<<6)|(4<<3)|ITEM_WIELDABLE,        5,     0,  0,  0,  0,      (1<<4)
    DECL_ITEM feathered_hat,        ITEM_WEARABLE,                      25,     0,  1,  1,  0,      1
    DECL_ITEM bloody_sword,         (1<<6)|(4<<3)|ITEM_WIELDABLE,       50,     0, -2,  0,  0,      (3<<4)
    DECL_ITEM green_hood,           ITEM_WEARABLE,                      25,     0,  0,  0,  3,      1
    DECL_ITEM leather_armor,        ITEM_WEARABLE,                      80,     1,  0, -1,  0,      3
    DECL_ITEM invisible_weapon,     (1<<6)|ITEM_WIELDABLE,               0,     0,  0,  0,  0,      0
    DECL_ITEM invisible_staff,      (2<<6)|ITEM_RANGED,                  0,     0,  0,  0,  0,      (4<<4)|EFFECT_MISSILE
    DECL_ITEM steel_sword,          (1<<6)|(2<<3)|ITEM_WIELDABLE,      100,     0,  0,  0,  0,      (3<<4)
    DECL_ITEM wooden_bow,           (2<<6)|(4<<3)|ITEM_RANGED,          50,     0,  0,  2,  0,      (3<<4)|EFFECT_ARROW
    DECL_ITEM guard_hat,            ITEM_WEARABLE,                      30,     0,  0, -2,  0,      2
    DECL_ITEM beard,                ITEM_WEARABLE,                       0,     0,  0,  0,  0,      0
    DECL_ITEM club,                 (1<<6)|(4<<3)|ITEM_WIELDABLE,       10,     0,  0,  0,  0,      (3<<4)
    DECL_ITEM glass_dagger,         ITEM_WIELDABLE,                     80,     0,  0,  4,  0,      (2<<4)
    DECL_ITEM great_bow,            (3<<6)|(4<<3)|ITEM_RANGED,         200,     0,  0,  0,  0,      (6<<4)|EFFECT_ARROW
    DECL_ITEM green_cloak,          ITEM_WEARABLE,                      40,     0,  0,  0,  0,      2
    DECL_ITEM green_cloak_small,    ITEM_WEARABLE,                      40,     0,  0,  0,  0,      2
    DECL_ITEM purple_hood,          ITEM_WEARABLE,                      25,     0,  0,  0,  3,      1
    DECL_ITEM hammer,               (7<<3)|ITEM_WIELDABLE,              50,     0,  0,  0,  0,      (5<<4)
    DECL_ITEM iron_armor,           ITEM_WEARABLE,                     500,     3,  0, -8, 0,       8
    DECL_ITEM iron_breastplate,     ITEM_WEARABLE,                     350,     2,  0, -6,  0,      5
    DECL_ITEM iron_helmet,          ITEM_WEARABLE,                     200,     2,  0, -3,  0,      3
    DECL_ITEM iron_staff,           (2<<6)|(3<<3)|RANGED_MAGICAL|ITEM_RANGED, 150,     0, -6,  0,  0,      (5<<4)|EFFECT_FIREBALL
    DECL_ITEM wood_staff,           (2<<6)|(2<<3)|RANGED_MAGICAL|ITEM_RANGED,  80,     0,  1,  0,  0,      (2<<4)|EFFECT_FIREBALL
    DECL_ITEM ivory_wand,           (2<<6)|(4<<3)|RANGED_MAGICAL|ITEM_RANGED,300,     0,  0,  0,  0,      (7<<4)|EFFECT_FIREBALL
    DECL_ITEM mithril_armor,        ITEM_WEARABLE,                    2000,     0,  5,  3,  0,      10
    DECL_ITEM mithril_breastplate,  ITEM_WEARABLE,                    1400,     0,  3,  2,  0,      8
    DECL_ITEM mithril_cap,          ITEM_WEARABLE,                     600,     0,  1,  1,  0,      3
    DECL_ITEM mithril_dagger,       ITEM_WIELDABLE,                    300,     0,  4,  4,  0,      (3<<4)
    DECL_ITEM mithril_spike,        ITEM_WIELDABLE,                    200,     0,  4,  0,  0,      (1<<4)
    DECL_ITEM spear,                (2<<6)|(5<<3)|ITEM_WIELDABLE,      150,     2,  0, -2,  0,      (8<<4)
    DECL_ITEM wooden_shield,        ITEM_WEARABLE,                      20,     0,  0,  0,  0,      0
    DECL_ITEM axe,                  (1<<6)|(2<<3)|ITEM_WIELDABLE,              30,     1,  0,  0,  0,      (3<<4)
    DECL_ITEM angel_of_death,       (2<<6)|(4<<3)|RANGED_MAGICAL|ITEM_RANGED,     5000,     0,  0,  0,  0,      (15<<4)|EFFECT_FIREBALL
    DECL_ITEM glass_staff,          (2<<6)|(2<<3)|RANGED_MAGICAL|ITEM_RANGED,      300,     0,  2,  0,  0,      (6<<4)|EFFECT_MISSILE
    DECL_ITEM blessed_sword,        (2<<6)|(1<<3)|ITEM_WIELDABLE,      340,     4,  4,  0,  0,      (6<<4)
    DECL_ITEM white_fox_eyes,       ITEM_WEARABLE,                       0,     0,  0,  0,  0,      0
    DECL_ITEM iron_breastplate_cloak, ITEM_WEARABLE,                   600,     2,  0, -10, 0,      8
    DECL_ITEM inventory_book,       ITEM_USABLE,                        20,     0,  0,  0,  0,      1
    DECL_ITEM manners_book,         ITEM_USABLE,                        20,     0,  0,  0,  0,      1
    DECL_ITEM war_book,             ITEM_USABLE,                        20,     0,  0,  0,  0,      1
    DECL_ITEM raw_meat,             (3<<3)|ITEM_USABLE,                 20,     0, 10,  0,  0,      0
    DECL_ITEM rotten_meat,          (1<<3)|ITEM_USABLE,                  1,     0, -5,  0,  0,      0
    DECL_ITEM health_potion,        (0<<3)|ITEM_USABLE,                100,     0, 40,  0,  0,      0
    DECL_ITEM beer,                 (3<<3)|ITEM_USABLE,                  5,     5,  5,  0, -3,      0
    DECL_ITEM croissant,            (3<<3)|ITEM_USABLE,                 10,     0, 10,  0,  0,      0
    DECL_ITEM whiskey,              (1<<3)|ITEM_USABLE,                 20,     7,  3, -3,  0,      0
    DECL_ITEM journal,              ITEM_USABLE,                        10,     0,  0,  0,  0,      1
    DECL_ITEM pass,                 ITEM_USABLE,                       100,     0,  0,  0,  0,      1
    DECL_ITEM curse_of_ullimar,     (7<<3)|ITEM_USABLE,                 20,   -20,-10,  0,-10,      0
    DECL_ITEM large_health_potion,  (1<<3)|ITEM_USABLE,                150,     0, 45,  0,  0,      0
    DECL_ITEM mint_tonic,           (3<<3)|ITEM_USABLE,                 50,     0,  0,  0, 10,      0
    DECL_ITEM mint_leaves,          (3<<3)|ITEM_USABLE,                 20,     0,  0,  0,  6,      0
    DECL_ITEM bismuth_subsalicylate,(1<<3)|ITEM_USABLE,                 10,     0,  2,  0,  0,      0
    DECL_ITEM strength_potion,      (3<<3)|ITEM_USABLE,                 50,    10,  0,  0,  0,      0
    DECL_ITEM speed_potion,         (1<<3)|ITEM_USABLE,                 60,     0,  0, 20,  0,      0
    DECL_ITEM glass_shard,          ITEM_USABLE,                        20,     0,  0,  0,  0,      1
    DECL_ITEM gold_chalice,         ITEM_USABLE,                       200,     0,  0,  0,  0,      1
    DECL_ITEM gold_bar,             ITEM_USABLE,                       150,     0,  0,  0,  0,      1
    DECL_ITEM small_chest,          ITEM_USABLE,                        10,     0,  0,  0,  0,      1
    DECL_ITEM letter,               ITEM_USABLE,                        10,     0,  0,  0,  0,      1

DECL_LOOSE_ITEM intro_wood_stick
DECL_LOOSE_ITEM intro_bandit_gold
DECL_LOOSE_ITEM tavern_guest_gold
DECL_LOOSE_ITEM town_lost_potion
DECL_LOOSE_ITEM lost_journal
DECL_LOOSE_ITEM abandoned_armor
DECL_LOOSE_ITEM abandoned_gold_1
DECL_LOOSE_ITEM abandoned_gold_2
DECL_LOOSE_ITEM bandit_pass
DECL_LOOSE_ITEM bandit_helmet
DECL_LOOSE_ITEM woods_mithril_spike
DECL_LOOSE_ITEM woods_mithril_dagger
DECL_LOOSE_ITEM mine_glass_staff
DECL_LOOSE_ITEM mine_glass_dagger_1
DECL_LOOSE_ITEM mine_glass_dagger_2
DECL_LOOSE_ITEM house_cloak
DECL_LOOSE_ITEM house_potion
DECL_LOOSE_ITEM bank_gold_bar_1
DECL_LOOSE_ITEM bank_gold_bar_2
DECL_LOOSE_ITEM bank_ullimar
DECL_LOOSE_ITEM bank_gold_chalice_1
DECL_LOOSE_ITEM bank_mithril_breastplate
DECL_LOOSE_ITEM bank_chest
DECL_LOOSE_ITEM bank_beer

.message "Unallocated preplaced items: ", low(TOTAL_PREPLACED_ITEM_COUNT - __LOOSE_ITEM_IDX + 1)

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
_item_str_leather_armor_desc:       .db "Scarred and worn, it has", 10, "clearly seen much use.", 0
_item_str_invisible_weapon_name:
_item_str_invisible_weapon_desc:
_item_str_invisible_staff_name:
_item_str_invisible_staff_desc:
_item_str_white_fox_eyes_name:
_item_str_white_fox_eyes_desc:
_item_str_iron_breastplate_cloak_name:
_item_str_iron_breastplate_cloak_desc:
_item_str_letter_desc:
_item_str_letter_name:
_item_str_beard_name:
_item_str_beard_desc:				.dw 0
_item_str_steel_sword_name:         .db "Steel sword", 0
_item_str_steel_sword_desc:         .db "An elegant blade.", 0
_item_str_wooden_bow_name:          .db "Wooden bow", 0, 0
_item_str_wooden_bow_desc:          .db "An old but sturdy wooden bow.", 0
_item_str_guard_hat_name:           .db "Guard", 39, "s hat", 0
_item_str_guard_hat_desc:           .db "Worn only by members of", 10, "the Town Guard, and", 10, "shameless murderers.", 0, 0
_item_str_inventory_book_name:      .db "Book of Inventory", 0
_item_str_manners_book_name:        .db "Book of Civility", 0, 0
_item_str_war_book_name:            .db "Book of War", 0
.if TARGETING_MCU
_item_str_inventory_book_desc:      .db "Press <A> to equip or unequip.", 10, "Press <B> to use a potion.", 10, "Press start to drop items.", 0, 0
_item_str_manners_book_desc:        .db "Press <A> to interact.", 10, "Press <B> and start to buy", 10, "and sell from a shopkeeper.", 0
_item_str_war_book_desc:            .db "Press <B> to attack.", 10, "Press start to dash.", 0
.else
_item_str_inventory_book_desc:      .db "Press <A> to equip or unequip.", 10, "Press <S> to use a potion.", 10, "Press <D> to drop items.", 0, 0
_item_str_manners_book_desc:        .db "Press <A> to interact.", 10, "Press <S> and <D> to buy", 10, "and sell from a shopkeeper.", 0
_item_str_war_book_desc:            .db "Press <S> to attack.", 10, "Press <D> to dash.", 0
.endif
_item_str_raw_meat_name:            .db "Raw meat", 0, 0
_item_str_raw_meat_desc:            .db "Probably safe to eat.", 0
_item_str_rotten_meat_name:         .db "Rotten meat", 0
_item_str_rotten_meat_desc:         .db "Tinged a poisonous green.", 0
_item_str_large_health_potion_name:
_item_str_health_potion_name:       .db "Health potion", 0
_item_str_large_health_potion_desc:
_item_str_health_potion_desc:       .db "Quickly recover from evenmortal wounds.", 0
_item_str_beer_name:                .db "Pint of beer", 0, 0
_item_str_beer_desc:                .db "The local brew is", 10, "unusually bitter.", 0
_item_str_croissant_name:           .db "Croissant", 0
_item_str_croissant_desc:           .db "Fresh and flaky.", 0, 0
_item_str_whiskey_name:             .db "Whiskey", 0
_item_str_whiskey_desc:             .db "Burns the esophageal", 10, "tissues on the way down.", 0
_item_str_journal_name:             .db "Missing journal", 0
_item_str_journal_desc:             .db "A leather-bound journal filled with mysterious,", 10, "unreadable lettering.", 0
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
_item_str_pass_name:	           	.db "Pass", 0, 0
_item_str_pass_desc:	           	.db "The bearer may pass the", 10, "Highway Guard. Sealed withBaron Haldir", 39, "s stamp.", 0
_item_str_axe_name:                 .db "Iron axe", 0, 0
_item_str_axe_desc:                 .db "Can chop trees and peopleequally well.", 0, 0
_item_str_angel_of_death_name:      .db "Angel of death", 0, 0
_item_str_angel_of_death_desc:      .db "Legendary.", 0, 0
_item_str_curse_of_ullimar_name:    .db "Curse of Ullimar", 0, 0
_item_str_curse_of_ullimar_desc:    .db "If you believe the myths,a few vials of the stuff", 10, "destroyed Ullimar.", 0, 0
_item_str_mint_tonic_name:          .db "Mint tonic", 0, 0
_item_str_mint_tonic_desc:          .db "A chilling, stimulating", 10, "beverage distilled from", 10, "mint leaves.", 0, 0
_item_str_mint_leaves_name:         .db "Mint leaves", 0
_item_str_mint_leaves_desc:         .db "Unpleasantly slimy when", 10, "chewed, but cheap and", 10, "invigorating.", 0
_item_str_bismuth_subsalicylate_name: .db "Bismuth subsalicylate", 0
_item_str_bismuth_subsalicylate_desc: .db "Aids indigestion.", 0
_item_str_strength_potion_name:     .db "Strength potion", 0
_item_str_strength_potion_desc:     .db "Banned in all organized", 10, "competion.", 0, 0
_item_str_glass_staff_name:         .db "Glass staff", 0
_item_str_glass_staff_desc:         .db "An extraordinary weapon,powerful yet fragile.", 0
_item_str_blessed_sword_name:       .db "Blessed sword", 0
_item_str_blessed_sword_desc:       .db "Tingles with powerful", 10, "elvish magic.", 0
_item_str_speed_potion_name:        .db "Essence of Dexterity", 0, 0
_item_str_speed_potion_desc:        .db "Filled with a strangely", 10, "effervescent blue liquid.", 0
_item_str_gold_chalice_name:        .db "Gold chalice", 0, 0
_item_str_gold_chalice_desc:        .db "Beautifully crafted and", 10, "very heavy.", 0
_item_str_gold_bar_name:            .db "Gold bar", 0, 0
_item_str_gold_bar_desc:            .db "Of unknown purity.", 0, 0
_item_str_small_chest_name:         .db "Locked chest", 0, 0
_item_str_small_chest_desc:         .db "A small wooden chest of", 10, "little apparent value.", 10, "Impossible to open.", 0, 0
