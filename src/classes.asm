; Classes specify the base stats for the player. Classes and characters are
; similarly named but are very different. A character describes animations and
; sprites, while a class describes stats. Also, the player and all NPCs have
; associated characters, but only players have a class.

class_table:
    ; paladin class
    ; acceleration, max speed, width, height, base sprite, stats
    .db 12, low(1000), high(1000), 10, 10, 0, 0, 0, 0, 0
