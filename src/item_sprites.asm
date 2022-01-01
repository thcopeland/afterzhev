; Some items, like weapons and armor, are overlaid on character sprites, and are
; therefore animated. Weapons have 30 sprites: 16 for walking, 2 for idle, 12 for
; the three attacks (2 frames each). Wearable items have 20 sprites: 16 for
; walking and 4 for idle. For weapon attack and idle animations, the down-facing
; and right-facing sprites are mirrored and reused as the up-facing and down-facing
; sprites. This isn't the case for walking animations or for wearable items which
; should look different from different views.
;
; To save memory and cycles, each sprite has specific dimensions and offsets from
; the wielding character. Since each sprite may be a different size, this
; information, along a pointer to the sprite, is stored in a lookup table. This
; also allows us to reuse sprites within an animation.
;
; Animated Sprite LUT Entry (104 bytes)
;   walk down sprite 1 offsets x, offset y (signed 4 bit), width, height (unsigned 4 bit) (2 bytes)
;   relative pointer to walk up sprite 1 (2 bytes)
;   walk down sprite 2 offsets x, offset y (signed 4 bit), width, height (unsigned 4 bit) (2 bytes)
;   relative pointer to walk up sprite 2 (2 bytes)
;   walk down sprite 3 offsets x, offset y (signed 4 bit), width, height (unsigned 4 bit) (2 bytes)
;   relative pointer to walk up sprite 3 (2 bytes)
;   walk down sprite 4 offsets x, offset y (signed 4 bit), width, height (unsigned 4 bit) (2 bytes)
;   relative pointer to walk up sprite 4 (2 bytes)
;   ... 12 walk right, up, left
;   ... 4 idle (up and left are ignored for weapons)
;   ... 2 attack 1 (these are ignored for wearable items)
;   ... 2 attack 2
;   ... 2 attack 3
;
; Non-animated items, like potions and amulets, have only a single fixed-size
; sprite.

.equ PADDING = 0xc7

.macro item_animation_entry ; dx, dy, width, height, ptr (4 bytes)
    .dw (((((@0<<4)|@1)<<4)|@2)<<4)|@3, (@4-animated_item_sprite_table)<<2
.endm

.macro empty_animation_entry
    .dw 0x0000, 0x0000
.endm

animated_item_sprite_lut:
    item_animation_entry 0, 0, 5, 5, _wooden_stick_walk_down_0
    item_animation_entry 0, 0, 5, 5, _wooden_stick_walk_down_1
    item_animation_entry 0, 0, 5, 5, _wooden_stick_walk_down_2
    item_animation_entry 0, 0, 5, 5, _wooden_stick_walk_down_3
    item_animation_entry 0, 0, 5, 5, _wooden_stick_walk_right_0
    item_animation_entry 0, 0, 5, 5, _wooden_stick_walk_right_1
    item_animation_entry 0, 0, 5, 5, _wooden_stick_walk_right_2
    item_animation_entry 0, 0, 5, 5, _wooden_stick_walk_right_3
    item_animation_entry 0, 0, 5, 5, _wooden_stick_walk_up_0
    item_animation_entry 0, 0, 5, 5, _wooden_stick_walk_up_1
    item_animation_entry 0, 0, 5, 5, _wooden_stick_walk_up_2
    item_animation_entry 0, 0, 5, 5, _wooden_stick_walk_up_3
    item_animation_entry 0, 0, 5, 5, _wooden_stick_walk_left_0
    item_animation_entry 0, 0, 5, 5, _wooden_stick_walk_left_1
    item_animation_entry 0, 0, 5, 5, _wooden_stick_walk_left_2
    item_animation_entry 0, 0, 5, 5, _wooden_stick_walk_left_3
    item_animation_entry 0, 0, 5, 5, _wooden_stick_idle_down
    item_animation_entry 0, 0, 5, 5, _wooden_stick_idle_right
    empty_animation_entry
    empty_animation_entry
    ; item_animation_entry
    ; item_animation_entry
    ; item_animation_entry
    ; item_animation_entry
    ; item_animation_entry
    ; item_animation_entry

animated_item_sprite_table:
_wooden_stick_walk_down_0:
    .db 0x0a, 0xc7, 0xc7, 0xc7, 0xc7, 0x0a
    .db 0x0a, 0x0a, 0xc7, 0xc7, 0xc7, 0xc7
    .db 0x0a, 0x0a, 0xc7, 0xc7, 0xc7, 0x14
    .db 0x0a, 0x0a, 0xc7, 0xc7, 0xc7, 0x0a
    .db 0xc7, PADDING
_wooden_stick_walk_down_1:
    .db 0x0a, 0x0a, 0x0a, 0x0a, 0xc7, 0xc7, 0xc7, 0xc7
    .db 0xc7, 0xc7, 0xc7, 0x0a, 0x0a, 0x0a, 0x0a, 0x0a
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x14, 0x0a, 0xc7
_wooden_stick_walk_down_2:
    .db 0xc7, 0xc7, 0x0a, 0xc7, 0x0a, 0xc7
    .db 0xc7, 0xc7, 0x0a, 0x0a, 0xc7, 0xc7
    .db 0x0a, 0x14, 0xc7, 0xc7, 0x0a, 0x0a
    .db 0xc7, 0xc7, 0x14, 0x0a, 0xc7, 0xc7
    .db 0xc7, 0x0a, 0xc7, 0xc7, 0xc7, 0xc7
_wooden_stick_walk_down_3:
    .db 0x0a, 0xc7, 0xc7, 0xc7, 0xc7, 0x0a
    .db 0x0a, 0xc7, 0xc7, 0xc7, 0xc7, 0x0a
    .db 0x0a, 0xc7, 0xc7, 0xc7, 0xc7, 0x14
    .db 0x0a, 0x0a, 0xc7, 0xc7, 0xc7, 0x0a
    .db 0xc7, PADDING
_wooden_stick_walk_right_0:
    .db 0x0a, 0x0a, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7
    .db 0xc7, 0x0a, 0x0a, 0x0a, 0x14, 0xc7, 0xc7, 0xc7
    .db 0xc7, 0xc7, 0xc7, 0x0a, 0x0a, 0x0a, 0x0a, 0x0a
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x0a
_wooden_stick_walk_right_1:
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x0a, 0xc7
    .db 0x0a, 0x0a, 0x0a, 0x0a, 0x14, 0x0a, 0x0a, 0x0a
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x0a
_wooden_stick_walk_right_2:
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x0a, 0xc7, 0xc7
    .db 0xc7, 0xc7, 0x0a, 0x0a, 0x0a, 0x0a, 0xc7, 0x0a
    .db 0x0a, 0x0a, 0x14, 0xc7, 0xc7, 0x0a, 0x0a, 0xc7
    .db 0xc7, 0xc7, 0xc7, 0xc7
_wooden_stick_walk_right_3:
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x0a, 0xc7, 0x0a
    .db 0x0a, 0x0a, 0x14, 0x0a, 0x0a, 0x0a, 0xc7, 0xc7
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x0a, PADDING
_wooden_stick_walk_up_0:
    .db 0xc7, 0xc7, 0x0a, 0xc7
    .db 0xc7, 0x0a, 0x0a, 0x0a
    .db 0xc7, 0x0a, 0xc7, 0xc7
    .db 0x0a, 0x0a, 0xc7, 0xc7
    .db 0x0a, 0xc7, 0xc7, 0xc7
_wooden_stick_walk_up_1:
    .db 0xc7, 0xc7, 0x0a, 0x0a
    .db 0x0a, 0x0a, 0x0a, 0xc7
    .db 0xc7, PADDING
_wooden_stick_walk_up_2:
    .db 0xc7, 0xc7, 0xc7, 0x0a, 0xc7, 0xc7
    .db 0xc7, 0x0a, 0x0a, 0x0a, 0xc7, 0xc7
    .db 0x0a, 0xc7, 0xc7, 0xc7, 0x0a, 0x0a
    .db 0xc7, 0xc7, 0x0a, 0x0a, 0xc7, 0xc7
    .db 0xc7, PADDING
_wooden_stick_walk_up_3:
    .db 0xc7, 0xc7, 0xc7, 0x0a, 0xc7, 0xc7
    .db 0xc7, 0x0a, 0x0a, 0x0a, 0xc7, 0x0a
    .db 0x0a, 0xc7, 0xc7, 0x0a, 0xc7, 0xc7
    .db 0xc7, 0xc7
_wooden_stick_walk_left_0:
    .db 0xc7, 0x0a, 0xc7, 0xc7, 0xc7, 0xc7
    .db 0x0a, 0x0a, 0xc7, 0xc7, 0xc7, 0xc7
    .db 0xc7, 0x0a, 0x0a, 0xc7, 0xc7, 0xc7
    .db 0xc7, 0xc7, 0x0a, 0x0a, 0xc7, 0xc7
    .db 0xc7, 0xc7, 0xc7, 0x0a, 0x0a, 0xc7
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x0a, 0x0a
_wooden_stick_walk_left_1:
    .db 0xc7, 0x0a, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7
    .db 0x0a, 0x0a, 0x0a, 0x0a, 0x0a, 0x0a, 0x0a, 0x0a
_wooden_stick_walk_left_2:
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x0a, 0x0a, 0xc7
    .db 0xc7, 0xc7, 0x0a, 0x0a, 0x0a, 0xc7, 0xc7, 0xc7
    .db 0x0a, 0x0a, 0xc7, 0xc7, 0xc7, 0x0a, 0x0a, 0x0a
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x0a, 0xc7, 0xc7
    .db 0xc7, 0xc7, 0xc7, PADDING
_wooden_stick_walk_left_3:
    .db 0xc7, 0x0a, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x0a
    .db 0x0a, 0x0a, 0x0a, 0x0a, 0x0a, 0x0a, 0xc7, 0xc7
    .db 0xc7, 0xc7, 0xc7, 0x0a, 0xc7, PADDING
_wooden_stick_idle_down:
    .db 0xc7, 0xc7, 0x0a, 0xc7
    .db 0xc7, 0xc7, 0x0a, 0x0a
    .db 0xc7, 0x0a, 0x0a, 0xc7
    .db 0xc7, 0x0a, 0x14, 0xc7
    .db 0xc7, 0x0a, 0xc7, 0xc7
    .db 0x0a, 0x0a, 0xc7, 0xc7
    .db 0x14, 0xc7, 0xc7, 0xc7
    .db 0x0a, 0xc7, 0xc7, 0xc7
_wooden_stick_idle_right:
    .db 0xc7, 0xc7, 0x0a, 0xc7
    .db 0xc7, 0xc7, 0x0a, 0x0a
    .db 0xc7, 0x0a, 0x0a, 0xc7
    .db 0xc7, 0x0a, 0x14, 0xc7
    .db 0xc7, 0x0a, 0xc7, 0xc7
    .db 0x0a, 0x0a, 0xc7, 0xc7
    .db 0x14, 0xc7, 0xc7, 0xc7
    .db 0x0a, 0xc7, 0xc7, 0xc7

static_item_sprite_table:
