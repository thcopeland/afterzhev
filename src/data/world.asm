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
;   world layer two objects (like loose items, but can't be picked up), each occupies three bytes
;       idx, x, y (24 bytes)
;   update subroutine (2 bytes)
;   on enter subroutine (2 bytes)
;   on pickup subroutine (2 bytes)
;   on conversation subroutine (2 bytes)
;   on choice subroutine (2 bytes)

sector_table:
.include "../../world2asm-world.asm"
; ; Sector 0 "test2"
; .db 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, \
;     038, 038, 052, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 051, 038, \
;     012, 183, 019, 038, 052, 032, 032, 032, 032, 032, 032, 032, 032, 051, 038, 039, 038, 038, 001, 194, \
;     035, 012, 194, 194, 019, 039, 039, 052, 032, 032, 032, 032, 051, 001, 194, 182, 194, 182, 183, 182, \
;     029, 035, 036, 012, 183, 183, 182, 019, 052, 032, 032, 051, 001, 183, 182, 183, 194, 194, 194, 183, \
;     029, 023, 025, 035, 012, 183, 182, 182, 031, 032, 032, 034, 182, 182, 183, 194, 183, 194, 194, 194, \
;     029, 035, 037, 029, 028, 182, 182, 182, 031, 032, 032, 034, 194, 194, 182, 194, 182, 194, 182, 182, \
;     029, 029, 029, 029, 028, 194, 194, 182, 031, 032, 032, 034, 182, 182, 183, 194, 182, 183, 194, 183, \
;     029, 029, 029, 023, 000, 182, 182, 183, 019, 038, 038, 001, 183, 182, 183, 183, 182, 183, 183, 194, \
;     029, 029, 029, 028, 182, 194, 194, 183, 182, 183, 182, 194, 183, 183, 183, 182, 182, 183, 182, 005, \
;     029, 029, 029, 028, 182, 183, 183, 194, 194, 194, 194, 194, 182, 194, 183, 183, 194, 183, 182, 031, \
;     029, 029, 023, 000, 182, 182, 182, 183, 183, 194, 182, 183, 194, 182, 183, 182, 183, 005, 026, 061, \
;     029, 029, 028, 194, 194, 183, 183, 183, 194, 183, 182, 182, 182, 194, 183, 182, 005, 061, 032, 032, \
;     029, 029, 028, 194, 183, 183, 194, 183, 183, 194, 182, 194, 182, 182, 194, 194, 031, 032, 032, 032, \
;     029, 029, 028, 182, 183, 194, 194, 182, 183, 194, 194, 182, 183, 183, 194, 182, 031, 032, 032, 032
; .db 2, 1, 0, 0
; .db NO_NPC, NO_NPC, NO_NPC, NO_NPC, NO_NPC, NO_NPC, NO_NPC, NO_NPC
; .db NO_ITEM, 0, 0, 0, NO_ITEM, 0, 0, 0, NO_ITEM, 0, 0, 0, NO_ITEM, 0, 0, 0
; .db 0, 0, 0, 0
; .db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
; .dw NO_HANDLER, NO_HANDLER, NO_HANDLER, NO_HANDLER, NO_HANDLER
;
; ; Sector 1 "test3"
; .db 032, 032, 051, 001, 182, 182, 183, 183, 183, 182, 194, 183, 019, 052, 032, 032, 032, 032, 032, 032, \
;     038, 039, 001, 194, 183, 194, 183, 183, 182, 194, 194, 194, 182, 019, 052, 032, 032, 032, 032, 032, \
;     182, 194, 194, 183, 182, 182, 182, 194, 182, 194, 183, 182, 194, 183, 031, 032, 032, 032, 032, 032, \
;     183, 183, 194, 183, 194, 183, 194, 194, 183, 183, 182, 182, 183, 183, 031, 032, 032, 032, 032, 032, \
;     194, 183, 183, 183, 183, 182, 182, 183, 194, 182, 194, 182, 194, 182, 031, 032, 032, 032, 032, 032, \
;     182, 194, 194, 183, 183, 194, 183, 194, 183, 183, 194, 182, 182, 183, 031, 032, 032, 032, 032, 032, \
;     182, 182, 182, 182, 182, 194, 194, 182, 182, 183, 194, 194, 183, 183, 019, 052, 032, 032, 032, 032, \
;     194, 194, 183, 182, 182, 194, 182, 194, 194, 194, 194, 194, 194, 182, 182, 019, 052, 032, 032, 032, \
;     182, 182, 182, 005, 026, 026, 011, 182, 194, 182, 182, 183, 182, 183, 194, 183, 031, 032, 032, 032, \
;     027, 027, 026, 061, 032, 032, 060, 011, 194, 005, 026, 011, 182, 183, 183, 005, 061, 032, 032, 032, \
;     032, 032, 032, 032, 032, 032, 032, 060, 027, 061, 032, 060, 011, 005, 027, 061, 032, 032, 032, 032, \
;     032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 060, 061, 032, 032, 032, 032, 032, 032, \
;     032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, \
;     032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, \
;     032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032
; .db 1, 1, 1, 0
; .db NO_NPC, NO_NPC, NO_NPC, NO_NPC, NO_NPC, NO_NPC, NO_NPC, NO_NPC
; .db NO_ITEM, 0, 0, 0, NO_ITEM, 0, 0, 0, NO_ITEM, 0, 0, 0, NO_ITEM, 0, 0, 0
; .db 0, 0, 0, 0
; .db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
; .dw NO_HANDLER, NO_HANDLER, NO_HANDLER, NO_HANDLER, NO_HANDLER
;
; ; Sector 2 "test1"
; .db 029, 029, 028, 182, 183, 183, 182, 183, 194, 194, 182, 194, 182, 183, 182, 183, 031, 032, 032, 032, \
;     029, 029, 028, 183, 183, 182, 183, 182, 194, 182, 183, 182, 183, 182, 182, 005, 061, 032, 032, 032, \
;     029, 023, 000, 182, 183, 183, 183, 183, 182, 183, 182, 182, 183, 182, 183, 031, 032, 032, 032, 032, \
;     029, 035, 012, 182, 183, 194, 183, 182, 194, 182, 183, 183, 182, 182, 194, 031, 032, 032, 032, 032, \
;     029, 029, 028, 183, 183, 183, 194, 182, 194, 183, 182, 182, 182, 182, 005, 061, 032, 032, 032, 032, \
;     029, 029, 028, 183, 182, 182, 182, 194, 183, 183, 183, 194, 183, 183, 031, 032, 032, 032, 032, 032, \
;     029, 029, 028, 182, 182, 194, 183, 183, 182, 194, 194, 194, 194, 194, 031, 032, 032, 032, 032, 032, \
;     029, 029, 035, 012, 183, 182, 194, 194, 183, 182, 182, 182, 183, 182, 019, 052, 032, 032, 032, 032, \
;     029, 029, 042, 028, 194, 194, 183, 183, 183, 183, 183, 194, 183, 183, 005, 061, 032, 032, 032, 032, \
;     029, 023, 024, 000, 194, 182, 182, 183, 194, 194, 182, 194, 183, 183, 031, 032, 032, 032, 032, 032, \
;     029, 028, 182, 183, 182, 194, 194, 182, 182, 194, 183, 005, 027, 027, 061, 032, 032, 032, 051, 052, \
;     023, 000, 183, 005, 026, 026, 011, 182, 182, 194, 182, 031, 032, 032, 032, 032, 032, 032, 060, 061, \
;     028, 182, 005, 061, 032, 032, 060, 026, 026, 026, 027, 061, 032, 032, 032, 032, 051, 039, 052, 032, \
;     000, 005, 061, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 060, 027, 061, 032, \
;     026, 061, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032, 032
; .db 2, 2, 0, 2
; .db NO_NPC, NO_NPC, NO_NPC, NO_NPC, NO_NPC, NO_NPC, NO_NPC, NO_NPC
; .db NO_ITEM, 0, 0, 0, NO_ITEM, 0, 0, 0, NO_ITEM, 0, 0, 0, NO_ITEM, 0, 0, 0
; .db 0, 0, 0, 0
; .db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
; .dw NO_HANDLER, NO_HANDLER, NO_HANDLER, NO_HANDLER, NO_HANDLER
