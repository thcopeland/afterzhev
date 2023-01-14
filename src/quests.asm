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

.equ QUEST_HALDIR = 3
.equ QUEST_HALDIR_XP = 500
; Bits 0-3: Bank quest status
.equ QUEST_HALDIR_BANK_NOT_BEGUN = 0
.equ QUEST_HALDIR_BANK_ATTACKED = 1
.equ QUEST_HALDIR_BANK_ROBBED = 2
.equ QUEST_HALDIR_BANK_REFUSED = 3
.equ QUEST_HALDIR_BANK_ACCEPTED = 4
.equ QUEST_HALDIR_BANK_COMPLETED = 5
.equ QUEST_HALDIR_BANK_REWARDED = 6
; Bits 4-7: Rob bank
.equ QUEST_HALDIR_THIEVES_NOT_BEGUN = 0<<4
.equ QUEST_HALDIR_THIEVES_ATTACKING = 1<<4
.equ QUEST_HALDIR_THIEVES_REFUSED = 2<<4
.equ QUEST_HALDIR_THIEVES_ACCEPTED = 3<<4
.equ QUEST_HALDIR_THIEVES_COMPLETED = 4<<4
