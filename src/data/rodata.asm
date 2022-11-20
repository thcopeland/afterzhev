; All fixed data lives here, such as sprites, music, and text. This is stored in
; flash, so cannot be (more than a few thousand times, at least) changed at runtime.

; Partition 1 (0x00000-x04ffff): code, font, items, classes
    .cseg
    .include "font.asm"
    .include "items.asm"
    .include "shops.asm"
    .include "conversations.asm"
    .include "npcs.asm"
    .include "classes.asm"
    .include "ui.asm"

; Partition 2 (words 0x08000-0x0ffff): tiles and maps
    .org 0x08000
    .include "world.asm"
    .include "tiles.asm"
    .include "features.asm"

; Partion 3 (words 0x10000-0x17fff): character and item sprites
    .org 0x10000
    .include "character_sprites.asm"
    .include "item_sprites.asm"
    .include "other_sprites.asm"

; Partion 4 (words 0x18000-0x7ffff): sounds
    .org 0x18000
