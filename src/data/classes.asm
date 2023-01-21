; Classes specify the base stats for the player. Classes and characters are
; similarly named but are very different. A character describes animations and
; sprites, while a class describes stats. Also, the player and all NPCs have
; associated characters, but only players have a class.

class_table:
    ; stats, name (8 bytes), zero-terminated description (82 bytes)
    .db 8, 4, 2, 6, "Paladin",       0, "Descended from a proud, noble", 10, "tradition, a paladin fears", 10, "neither pain nor death. ", 0
    .db 5, 8, 8, 1, "Rogue",   0, 0, 0, "Hard, bold, and wicked, rogues", 10, "rely on speed and low cunning,", 10, "not brute force.   ", 0
    .db 6, 4, 8, 6, "Mage", 0, 0, 0, 0, "Blessed with power beyond the", 10, "lot of mortals, mages are", 10, "deadly and unpredictable.", 0
