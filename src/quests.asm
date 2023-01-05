; Global data allocations are managed here.

.equ QUEST_KIDNAPPED = 0
;   0 - not begun
;   1 - refused
;   2 - accepted
;   3 - fighting foxes
;   4 - found
;   5 - rescued
;   6 - quest over
.equ QUEST_KIDNAPPED_XP = 200

.equ QUEST_JOURNAL = 1
;   0 - not begun
;   1 - refused
;   2 - accepted
;   3 - quest over
.equ QUEST_JOURNAL_XP = 10

.equ QUEST_BANDITS = 2
; Bits 0-2:
;   0 - not begun
;   1 - left path taken
;   2 - right path taken
;   3 - defeated
; Bit 3: archer ambush
.equ QUEST_BANDITS_XP = 300
