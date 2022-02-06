; Classes specify the base stats for the player. Classes and characters are
; similarly named but are very different. A character describes animations and
; sprites, while a class describes stats. Also, the player and all NPCs have
; associated characters, but only players have a class.

class_table:
    ; width, height, base sprite, stats, name (9 bytes), description (82 bytes)
    .db 10, 10, 0, 8, 4, 2, 6, "Paladin",       0, 0, "Descended from a proud, noble tradition, a paladin fears neither pain nor death. ", 0
    .db 10, 10, 0, 5, 8, 8, 1, "Halfling",         0, "Hard, bold, and wicked, halflings rely on speed and low cunning, not brute force.", 0
    .db 10, 10, 0, 6, 4, 8, 6, "Mage", 0, 0, 0, 0, 0, "Imbued with power beyond the lot of mortals, mages are deadly but unreliable.    ", 0
