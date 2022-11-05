; The world is divided into sectors, each about twice the visible screen area
; and containing various challenges and whatnot. Each entry in the sector table
; has the following layout:
;
; Sector Table Entry (356 bytes)
;   tile data, an array of each tile in the sector stored in row major order (300 bytes)
;   four adjacent sector indexs, stored in down, right, up, left order (4 bytes)
;   a list of NPCs (8 bytes)
;   a list of preplaced loose items, each item occupies four bytes: item index,
;       loose item index (used to track whether an item was picked up), x, y. (16 bytes)
;   savepoint data: savepoint index, x, y, padding (4 bytes)
;   list of portals, each occupies five bytes
;       x, y, dest sector, dest x, dest y. (20 bytes)
;   update subroutine (2 bytes)
;   on enter subroutine (2 bytes)
;   on pickup subroutine (2 bytes)
;   on conversation subroutine (2 bytes)
;   on choice subroutine (2 bytes)

sector_table:
; Sector 0 "test2"
.db 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, \
    005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, \
    005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, \
    005, 005, 005, 001, 004, 002, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, \
    005, 005, 005, 004, 004, 004, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, \
    005, 005, 005, 003, 004, 000, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, \
    005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, \
    005, 005, 005, 005, 004, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, \
    005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, \
    005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, \
    005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, \
    005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, \
    005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, \
    005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, \
    005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005, 005
.db 0, 0, 0, 0
.db NO_NPC, NO_NPC, NO_NPC, NO_NPC, NO_NPC, NO_NPC, NO_NPC, NO_NPC
.db NO_ITEM, 0, 0, 0, NO_ITEM, 0, 0, 0, NO_ITEM, 0, 0, 0, NO_ITEM, 0, 0, 0
.db 0, 0, 0, 0
.db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
.dw NO_HANDLER, NO_HANDLER, NO_HANDLER, NO_HANDLER, NO_HANDLER
