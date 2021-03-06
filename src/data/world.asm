; The world is divided into sectors, each about twice the visible screen area
; and containing various challenges and whatnot. Each entry in the sector table
; has the following layout:
;
; Sector Table Entry (332 bytes)
;   tile data, an array of each tile in the sector stored in row major order (300 bytes)
;   four adjacent sector indexs, stored in down, right, up, left order (4 bytes)
;   a list of NPCs (8 bytes)
;   a list of preplaced loose items, each item occupies four bytes: item index,
;       loose item index (used to track whether an item was picked up), x, y. (16 bytes)
;   update subroutine (2 bytes)
;   event handling subroutine (2 bytes)

.equ NO_NPC = 0
.equ NO_ITEM = 0

sector_table:
    ; sector 0
    .db 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, \
        10, 00, 01, 01, 01, 02, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, \
        10, 06, 07, 18, 07, 08, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, \
        10, 06, 07, 07, 07, 08, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, \
        10, 06, 07, 07, 07, 08, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, \
        00, 17, 07, 03, 13, 14, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, \
        06, 07, 07, 08, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, \
        06, 07, 07, 15, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 02, 10, 10, 10, 10, 10, \
        06, 07, 07, 07, 07, 07, 07, 07, 07, 07, 07, 07, 07, 07, 15, 02, 10, 10, 10, 10, \
        17, 07, 07, 03, 13, 13, 13, 13, 13, 13, 13, 13, 05, 07, 07, 15, 01, 01, 01, 01, \
        07, 07, 07, 08, 10, 10, 10, 10, 10, 10, 10, 10, 12, 05, 07, 07, 07, 07, 07, 07, \
        07, 07, 03, 14, 10, 10, 10, 10, 10, 10, 10, 10, 10, 12, 05, 07, 07, 07, 07, 07, \
        13, 13, 14, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 12, 13, 13, 13, 13, 13, \
        10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, \
        10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10
    .db 0, 0, 1, 0
    .db 2, 3, 4, 6, 7, 8, NO_NPC, NO_NPC
    .db 1, 1, 24, 24, 4, 4, 96, 60, 128|123, 6, 60, 60, 3, 2, 30, 30
    .dw sector_0_update, sector_0_event
    ; sector 1
    .db 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, \
        10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, \
        10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, \
        10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, \
        10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, \
        10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, \
        10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, \
        10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, \
        10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, \
        10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, \
        10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, \
        10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, \
        10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, \
        10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, \
        10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10
    .db 0, 1, 1, 1
    .db 5, NO_NPC, NO_NPC, NO_NPC, NO_NPC, NO_NPC, NO_NPC, NO_NPC
    .db 5, 5, 24, 156, 7, 7, 60, 150, NO_ITEM, 0, 0, 0, NO_ITEM, 0, 0, 0
    .dw 0x0000, 0x0000
