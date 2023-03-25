; All fixed data lives here, such as sprites, music, and text. This is stored in
; flash, so cannot be changed (more than a few thousand times, anyway) at runtime.

; Partition 1 (0x00000-x07ffff): code, font, items, classes
    .cseg
    .include "font.asm"
    .include "items.asm"
    .include "shops.asm"
    .include "conversations.asm"
    .include "npcs.asm"
    .include "classes.asm"
    .include "ui.asm"
    .include "fade.asm" ; requires special alignment, must be last

; Partition 2 (words 0x08000-0x0ffff): tiles and maps
    .org 0x08000
    .include "world.asm"
    .include "tiles.asm"
    .include "features.asm"

; Partion 3 (words 0x10000-0x17fff): character and item sprites
    .org 0x10000
    .include "character_sprites.asm"
    .include "item_sprites.asm"
    .include "effect_sprites.asm"
    .include "other_sprites.asm"

; Partion 4 (words 0x18000-0x7ffff): images, sounds
    .org 0x18000
    .include "images.asm"
    .include "music.asm"
    .include "sfx.asm"
