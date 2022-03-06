; All moving characters have 20 associated sprites, consisting of a four-frame
; walk cycle and a single idle frame, both in all directions. The idle frame is
; reused during attacks.
;
; Static charaters have only a single sprite (perhaps a few, for simple animations).
;
; Character Sprite Layout
;   walk down - 4 frames
;   walk right - 4 frames
;   walk up - 4 frames
;   walk left - 4 frames
;   idle down - 1 frame
;   idle right - 1 frame
;   idle up - 1 frame
;   idle left - 1 frame

character_sprite_table:
    .db 0x0b, 0x0b, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	; WWWW
    .db 0xc7, 0x0b, 0x0b, 0x37, 0x1a, 0x1a, 0x00, 0x00, 0x00, 0x09, 0xc7, 0xc7	;   WWWW,,XXXX########
    .db 0xc7, 0xc7, 0x09, 0x09, 0x09, 0x1a, 0x00, 0x09, 0x09, 0x09, 0x09, 0xc7	;     ######XX##########
    .db 0xc7, 0xc7, 0x0a, 0x13, 0x09, 0x09, 0x09, 0x09, 0x13, 0x0a, 0xc7, 0xc7	;     WWXX########XXWW
    .db 0xc7, 0xc7, 0x0a, 0xff, 0x00, 0x6e, 0x1d, 0x00, 0xff, 0x0a, 0xc7, 0xc7	;     WW  ##--xx##  WW
    .db 0xc7, 0xc7, 0x1d, 0x6e, 0x6e, 0x6e, 0x1d, 0x6e, 0x6e, 0x1d, 0xc7, 0xc7	;     xx------xx----xx
    .db 0xc7, 0xc7, 0x5c, 0x1d, 0x14, 0x14, 0x13, 0x13, 0x1d, 0x52, 0xc7, 0xc7	;     xxxxXXXXXXXXxxXX
    .db 0xc7, 0xc7, 0xc7, 0x1d, 0x09, 0x14, 0x13, 0x09, 0x0a, 0xc7, 0xc7, 0xc7	;       xx##XXXX##WW
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x00, 0x00, 0x09, 0x09, 0x0a, 0xc7, 0xc7, 0xc7	;         ########WW
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x09, 0x09, 0x09, 0x09, 0x1d, 0xc7, 0xc7, 0xc7	;         ########xx
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x0a, 0xc7, 0xc7, 0x00, 0xc7, 0xc7, 0xc7, 0xc7	;         WW    ##
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x00, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;         ##
    .db 0x0b, 0x0b, 0x0b, 0x37, 0x1a, 0x1a, 0x00, 0x00, 0x00, 0x09, 0xc7, 0xc7	; WWWWWW,,XXXX########
    .db 0x0b, 0xc7, 0x09, 0x09, 0x09, 0x1a, 0x00, 0x09, 0x09, 0x09, 0x09, 0xc7	; WW  ######XX##########
    .db 0xc7, 0xc7, 0x0a, 0x13, 0x09, 0x09, 0x09, 0x09, 0x13, 0x0a, 0xc7, 0xc7	;     WWXX########XXWW
    .db 0xc7, 0xc7, 0x0a, 0xff, 0x00, 0x6e, 0x1d, 0x00, 0xff, 0x0a, 0xc7, 0xc7	;     WW  ##--xx##  WW
    .db 0xc7, 0xc7, 0x1d, 0x6e, 0x6e, 0x6e, 0x1d, 0x6e, 0x6e, 0x1d, 0xc7, 0xc7	;     xx------xx----xx
    .db 0xc7, 0xc7, 0xc7, 0x1d, 0x14, 0x14, 0x13, 0x13, 0x1d, 0xc7, 0xc7, 0xc7	;       xxXXXXXXXXxx
    .db 0xc7, 0xc7, 0x5c, 0x09, 0x09, 0x14, 0x13, 0x00, 0x00, 0x52, 0xc7, 0xc7	;     xx####XXXX####XX
    .db 0xc7, 0xc7, 0xc7, 0x13, 0x09, 0x00, 0x00, 0x09, 0x0a, 0xc7, 0xc7, 0xc7	;       XX########WW
    .db 0xc7, 0xc7, 0xc7, 0x66, 0x00, 0x00, 0x09, 0x09, 0x1d, 0xc7, 0xc7, 0xc7	;       --########xx
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x09, 0x09, 0x09, 0x09, 0xc7, 0xc7, 0xc7, 0xc7	;         ########
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x0a, 0xc7, 0xc7, 0x0a, 0xc7, 0xc7, 0xc7, 0xc7	;         WW    WW
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x00, 0xc7, 0xc7, 0x00, 0xc7, 0xc7, 0xc7, 0xc7	;         ##    ##
    .db 0xc7, 0x0b, 0x0b, 0x37, 0x1a, 0x1a, 0x00, 0x00, 0x00, 0x09, 0xc7, 0xc7	;   WWWW,,XXXX########
    .db 0x0b, 0x0b, 0x09, 0x09, 0x09, 0x1a, 0x00, 0x09, 0x09, 0x09, 0x09, 0xc7	; WWWW######XX##########
    .db 0xc7, 0xc7, 0x0a, 0x13, 0x09, 0x09, 0x09, 0x09, 0x13, 0x0a, 0xc7, 0xc7	;     WWXX########XXWW
    .db 0xc7, 0xc7, 0x0a, 0xff, 0x00, 0x6e, 0x1d, 0x00, 0xff, 0x0a, 0xc7, 0xc7	;     WW  ##--xx##  WW
    .db 0xc7, 0xc7, 0x1d, 0x6e, 0x6e, 0x6e, 0x1d, 0x6e, 0x6e, 0x1d, 0xc7, 0xc7	;     xx------xx----xx
    .db 0xc7, 0xc7, 0xc7, 0x1d, 0x14, 0x14, 0x13, 0x13, 0x1d, 0xc7, 0xc7, 0xc7	;       xxXXXXXXXXxx
    .db 0xc7, 0xc7, 0x5c, 0x09, 0x09, 0x14, 0x13, 0x00, 0x00, 0x52, 0xc7, 0xc7	;     xx####XXXX####XX
    .db 0xc7, 0xc7, 0xc7, 0x13, 0x09, 0x00, 0x00, 0x09, 0x1d, 0xc7, 0xc7, 0xc7	;       XX########xx
    .db 0xc7, 0xc7, 0xc7, 0x13, 0x00, 0x00, 0x09, 0x09, 0xc7, 0xc7, 0xc7, 0xc7	;       XX########
    .db 0xc7, 0xc7, 0xc7, 0x66, 0x09, 0x09, 0x09, 0x09, 0xc7, 0xc7, 0xc7, 0xc7	;       --########
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x00, 0xc7, 0xc7, 0x0a, 0xc7, 0xc7, 0xc7, 0xc7	;         ##    WW
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x00, 0xc7, 0xc7, 0xc7, 0xc7	;               ##
    .db 0xc7, 0x0b, 0x0b, 0x37, 0x1a, 0x1a, 0x00, 0x00, 0x00, 0x09, 0xc7, 0xc7	;   WWWW,,XXXX########
    .db 0x0b, 0x0b, 0x09, 0x09, 0x09, 0x1a, 0x00, 0x09, 0x09, 0x09, 0x09, 0xc7	; WWWW######XX##########
    .db 0xc7, 0xc7, 0x0a, 0x13, 0x09, 0x09, 0x09, 0x09, 0x13, 0x0a, 0xc7, 0xc7	;     WWXX########XXWW
    .db 0xc7, 0xc7, 0x0a, 0xff, 0x00, 0x6e, 0x1d, 0x00, 0xff, 0x0a, 0xc7, 0xc7	;     WW  ##--xx##  WW
    .db 0xc7, 0xc7, 0x1d, 0x6e, 0x6e, 0x6e, 0x1d, 0x6e, 0x6e, 0x1d, 0xc7, 0xc7	;     xx------xx----xx
    .db 0xc7, 0xc7, 0xc7, 0x1d, 0x14, 0x14, 0x13, 0x13, 0x1d, 0xc7, 0xc7, 0xc7	;       xxXXXXXXXXxx
    .db 0xc7, 0xc7, 0x5c, 0x09, 0x09, 0x14, 0x13, 0x00, 0x00, 0x52, 0xc7, 0xc7	;     xx####XXXX####XX
    .db 0xc7, 0xc7, 0xc7, 0x13, 0x09, 0x00, 0x00, 0x09, 0x0a, 0xc7, 0xc7, 0xc7	;       XX########WW
    .db 0xc7, 0xc7, 0xc7, 0x66, 0x00, 0x00, 0x09, 0x09, 0x1d, 0xc7, 0xc7, 0xc7	;       --########xx
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x09, 0x09, 0x09, 0x09, 0xc7, 0xc7, 0xc7, 0xc7	;         ########
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x0a, 0xc7, 0xc7, 0x0a, 0xc7, 0xc7, 0xc7, 0xc7	;         WW    WW
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x00, 0xc7, 0xc7, 0x00, 0xc7, 0xc7, 0xc7, 0xc7	;         ##    ##
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x1a, 0x1a, 0x37, 0x00, 0xc7, 0xc7, 0xc7, 0xc7	;         XXXX,,##
    .db 0xc7, 0xc7, 0xc7, 0x09, 0x09, 0x09, 0x0b, 0x09, 0x09, 0x0a, 0xc7, 0xc7	;       ######WW####WW
    .db 0xc7, 0xc7, 0x09, 0x09, 0x09, 0x0b, 0x0b, 0x13, 0x13, 0xc7, 0xc7, 0xc7	;     ######WWWWXXXX
    .db 0xc7, 0xc7, 0xc7, 0x0a, 0x0a, 0x01, 0x66, 0xff, 0x00, 0xc7, 0xc7, 0xc7	;       WWWW##--  ##
    .db 0xc7, 0xc7, 0xc7, 0x0a, 0x0a, 0x01, 0x66, 0x66, 0x66, 0x66, 0xc7, 0xc7	;       WWWW##--------
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x01, 0x1d, 0x66, 0x66, 0x13, 0xc7, 0xc7, 0xc7	;         ##xx----XX
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x5c, 0x52, 0x09, 0x09, 0xc7, 0xc7, 0xc7	;           xxXX####
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x00, 0x0a, 0x09, 0x09, 0xc7, 0xc7, 0xc7	;           ##WW####
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x1d, 0x0a, 0x00, 0x00, 0xc7, 0xc7, 0xc7	;           xxWW####
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x09, 0x09, 0x09, 0x09, 0xc7, 0xc7, 0xc7	;           ########
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x00, 0x0a, 0xc7, 0xc7, 0x0a, 0xc7, 0xc7, 0xc7	;         ##WW    WW
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x00, 0xc7, 0xc7, 0xc7	;                 ##
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x1a, 0x1a, 0x37, 0x00, 0xc7, 0xc7, 0xc7	;           XXXX,,##
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x09, 0x09, 0x09, 0x0b, 0x09, 0x09, 0x0a, 0xc7	;         ######WW####WW
    .db 0xc7, 0xc7, 0xc7, 0x09, 0x09, 0x09, 0x09, 0x0b, 0x13, 0x13, 0xc7, 0xc7	;       ########WWXXXX
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x0a, 0x0a, 0x01, 0x66, 0xff, 0x00, 0xc7, 0xc7	;         WWWW##--  ##
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x0a, 0x0a, 0x01, 0x66, 0x66, 0x66, 0x66, 0xc7	;         WWWW##--------
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x01, 0x1d, 0x66, 0x66, 0x13, 0xc7, 0xc7	;           ##xx----XX
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x09, 0x5c, 0x52, 0x09, 0x13, 0xc7, 0xc7	;           ##xxXX##XX
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x00, 0x09, 0x0a, 0x09, 0xc7, 0xc7, 0xc7	;           ####WW##
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x09, 0x00, 0x0a, 0x00, 0xc7, 0xc7, 0xc7	;           ####WW##
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x09, 0x09, 0x1d, 0x09, 0xc7, 0xc7, 0xc7	;           ####xx##
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x0a, 0xc7, 0x0a, 0xc7, 0xc7, 0xc7, 0xc7	;           WW  WW
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x00, 0xc7, 0xc7, 0x00, 0xc7, 0xc7, 0xc7, 0xc7	;         ##    ##
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x1a, 0x1a, 0x37, 0x00, 0xc7, 0xc7, 0xc7	;           XXXX,,##
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x09, 0x09, 0x09, 0x0b, 0x09, 0x09, 0x0a, 0xc7	;         ######WW####WW
    .db 0xc7, 0xc7, 0xc7, 0x09, 0x09, 0x09, 0x09, 0x0b, 0x0b, 0x13, 0xc7, 0xc7	;       ########WWWWXX
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x0a, 0x0a, 0x01, 0x66, 0xff, 0x00, 0xc7, 0xc7	;         WWWW##--  ##
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x0a, 0x0a, 0x01, 0x66, 0x66, 0x66, 0x66, 0xc7	;         WWWW##--------
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x01, 0x1d, 0x66, 0x66, 0x13, 0xc7, 0xc7	;           ##xx----XX
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x09, 0x5c, 0x52, 0x09, 0x13, 0xc7, 0xc7	;           ##xxXX##XX
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x00, 0x09, 0x0a, 0x09, 0xc7, 0xc7, 0xc7	;           ####WW##
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x09, 0x00, 0x0a, 0x1d, 0xc7, 0xc7, 0xc7	;           ####WWxx
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x09, 0x09, 0x09, 0x09, 0xc7, 0xc7, 0xc7	;           ########
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x0a, 0x00, 0x0a, 0xc7, 0xc7, 0xc7, 0xc7	;           WW##WW
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x00, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;           ##
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x1a, 0x1a, 0x37, 0x00, 0xc7, 0xc7, 0xc7	;           XXXX,,##
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x09, 0x09, 0x09, 0x0b, 0x09, 0x09, 0x0a, 0xc7	;         ######WW####WW
    .db 0xc7, 0xc7, 0xc7, 0x09, 0x09, 0x09, 0x09, 0x0b, 0x13, 0x13, 0xc7, 0xc7	;       ########WWXXXX
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x0a, 0x0a, 0x01, 0x66, 0xff, 0x00, 0xc7, 0xc7	;         WWWW##--  ##
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x0a, 0x0a, 0x01, 0x66, 0x66, 0x66, 0x66, 0xc7	;         WWWW##--------
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x01, 0x1d, 0x66, 0x66, 0x13, 0xc7, 0xc7	;           ##xx----XX
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x09, 0x5c, 0x52, 0x09, 0x13, 0xc7, 0xc7	;           ##xxXX##XX
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x00, 0x09, 0x0a, 0x09, 0xc7, 0xc7, 0xc7	;           ####WW##
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x09, 0x00, 0x0a, 0x00, 0xc7, 0xc7, 0xc7	;           ####WW##
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x09, 0x09, 0x1d, 0x09, 0xc7, 0xc7, 0xc7	;           ####xx##
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x0a, 0xc7, 0xc7, 0x0a, 0xc7, 0xc7, 0xc7	;           WW    WW
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x00, 0xc7, 0xc7, 0x00, 0xc7, 0xc7, 0xc7, 0xc7	;         ##    ##
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x0b, 0x0b, 0xc7	;                   WWWW
    .db 0xc7, 0xc7, 0xc7, 0x1a, 0x1a, 0x1a, 0x00, 0x00, 0x37, 0x0b, 0xc7, 0xc7	;       XXXXXX####,,WW
    .db 0xc7, 0x09, 0x09, 0x09, 0x1a, 0x1a, 0x00, 0x00, 0x09, 0x09, 0x09, 0xc7	;   ######XXXX##########
    .db 0xc7, 0xc7, 0x09, 0x09, 0x09, 0x1a, 0x00, 0x09, 0x09, 0x09, 0xc7, 0xc7	;     ######XX########
    .db 0xc7, 0xc7, 0x0a, 0x0a, 0x09, 0x09, 0x09, 0x09, 0x01, 0x01, 0xc7, 0xc7	;     WWWW############
    .db 0xc7, 0xc7, 0x0a, 0x0a, 0x0a, 0x0a, 0x01, 0x01, 0x01, 0x01, 0xc7, 0xc7	;     WWWWWWWW########
    .db 0xc7, 0xc7, 0x5c, 0x0a, 0x0a, 0x01, 0x01, 0x01, 0x01, 0x52, 0xc7, 0xc7	;     xxWWWW########XX
    .db 0xc7, 0xc7, 0xc7, 0x66, 0x09, 0x00, 0x00, 0x09, 0x0a, 0xc7, 0xc7, 0xc7	;       --########WW
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x09, 0x09, 0x00, 0x00, 0x0a, 0xc7, 0xc7, 0xc7	;         ########WW
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x09, 0x09, 0x09, 0x09, 0x1d, 0xc7, 0xc7, 0xc7	;         ########xx
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x0a, 0xc7, 0xc7, 0x00, 0xc7, 0xc7, 0xc7, 0xc7	;         WW    ##
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x00, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;         ##
    .db 0xc7, 0xc7, 0xc7, 0x1a, 0x1a, 0x1a, 0x00, 0x00, 0x37, 0x0b, 0x0b, 0xc7	;       XXXXXX####,,WWWW
    .db 0xc7, 0x09, 0x09, 0x09, 0x1a, 0x1a, 0x00, 0x00, 0x09, 0x09, 0x09, 0xc7	;   ######XXXX##########
    .db 0xc7, 0xc7, 0x09, 0x09, 0x09, 0x1a, 0x00, 0x09, 0x09, 0x09, 0xc7, 0xc7	;     ######XX########
    .db 0xc7, 0xc7, 0x0a, 0x0a, 0x09, 0x09, 0x09, 0x09, 0x01, 0x01, 0xc7, 0xc7	;     WWWW############
    .db 0xc7, 0xc7, 0x0a, 0x0a, 0x0a, 0x0a, 0x01, 0x01, 0x01, 0x01, 0xc7, 0xc7	;     WWWWWWWW########
    .db 0xc7, 0xc7, 0xc7, 0x0a, 0x0a, 0x01, 0x01, 0x01, 0x01, 0xc7, 0xc7, 0xc7	;       WWWW########
    .db 0xc7, 0xc7, 0x5c, 0x00, 0x00, 0x00, 0x09, 0x09, 0x00, 0x52, 0xc7, 0xc7	;     xx############XX
    .db 0xc7, 0xc7, 0xc7, 0x13, 0x09, 0x00, 0x00, 0x09, 0x0a, 0xc7, 0xc7, 0xc7	;       XX########WW
    .db 0xc7, 0xc7, 0xc7, 0x66, 0x09, 0x09, 0x00, 0x00, 0x1d, 0xc7, 0xc7, 0xc7	;       --########xx
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x09, 0x09, 0x09, 0x09, 0xc7, 0xc7, 0xc7, 0xc7	;         ########
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x0a, 0xc7, 0xc7, 0x0a, 0xc7, 0xc7, 0xc7, 0xc7	;         WW    WW
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x00, 0xc7, 0xc7, 0x00, 0xc7, 0xc7, 0xc7, 0xc7	;         ##    ##
    .db 0xc7, 0xc7, 0xc7, 0x1a, 0x1a, 0x1a, 0x00, 0x00, 0x37, 0x0b, 0xc7, 0xc7	;       XXXXXX####,,WW
    .db 0xc7, 0x09, 0x09, 0x09, 0x1a, 0x1a, 0x00, 0x00, 0x09, 0x09, 0x09, 0xc7	;   ######XXXX##########
    .db 0xc7, 0xc7, 0x09, 0x09, 0x09, 0x1a, 0x00, 0x09, 0x09, 0x09, 0xc7, 0xc7	;     ######XX########
    .db 0xc7, 0xc7, 0x0a, 0x0a, 0x09, 0x09, 0x09, 0x09, 0x01, 0x01, 0xc7, 0xc7	;     WWWW############
    .db 0xc7, 0xc7, 0x0a, 0x0a, 0x0a, 0x0a, 0x01, 0x01, 0x01, 0x01, 0xc7, 0xc7	;     WWWWWWWW########
    .db 0xc7, 0xc7, 0xc7, 0x0a, 0x0a, 0x01, 0x01, 0x01, 0x01, 0xc7, 0xc7, 0xc7	;       WWWW########
    .db 0xc7, 0xc7, 0x5c, 0x00, 0x00, 0x00, 0x09, 0x09, 0x00, 0x52, 0xc7, 0xc7	;     xx############XX
    .db 0xc7, 0xc7, 0xc7, 0x13, 0x09, 0x00, 0x00, 0x09, 0x1d, 0xc7, 0xc7, 0xc7	;       XX########xx
    .db 0xc7, 0xc7, 0xc7, 0x13, 0x09, 0x09, 0x00, 0x00, 0xc7, 0xc7, 0xc7, 0xc7	;       XX########
    .db 0xc7, 0xc7, 0xc7, 0x66, 0x09, 0x09, 0x09, 0x09, 0xc7, 0xc7, 0xc7, 0xc7	;       --########
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x00, 0xc7, 0xc7, 0x0a, 0xc7, 0xc7, 0xc7, 0xc7	;         ##    WW
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x00, 0xc7, 0xc7, 0xc7, 0xc7	;               ##
    .db 0xc7, 0xc7, 0xc7, 0x1a, 0x1a, 0x1a, 0x00, 0x00, 0x37, 0x0b, 0xc7, 0xc7	;       XXXXXX####,,WW
    .db 0xc7, 0x09, 0x09, 0x09, 0x1a, 0x1a, 0x00, 0x00, 0x09, 0x09, 0x09, 0xc7	;   ######XXXX##########
    .db 0xc7, 0xc7, 0x09, 0x09, 0x09, 0x1a, 0x00, 0x09, 0x09, 0x09, 0xc7, 0xc7	;     ######XX########
    .db 0xc7, 0xc7, 0x0a, 0x0a, 0x09, 0x09, 0x09, 0x09, 0x01, 0x01, 0xc7, 0xc7	;     WWWW############
    .db 0xc7, 0xc7, 0x0a, 0x0a, 0x0a, 0x0a, 0x01, 0x01, 0x01, 0x01, 0xc7, 0xc7	;     WWWWWWWW########
    .db 0xc7, 0xc7, 0xc7, 0x0a, 0x0a, 0x01, 0x01, 0x01, 0x01, 0xc7, 0xc7, 0xc7	;       WWWW########
    .db 0xc7, 0xc7, 0x5c, 0x00, 0x00, 0x00, 0x09, 0x09, 0x00, 0x52, 0xc7, 0xc7	;     xx############XX
    .db 0xc7, 0xc7, 0xc7, 0x13, 0x09, 0x00, 0x00, 0x09, 0x0a, 0xc7, 0xc7, 0xc7	;       XX########WW
    .db 0xc7, 0xc7, 0xc7, 0x66, 0x09, 0x09, 0x00, 0x00, 0x1d, 0xc7, 0xc7, 0xc7	;       --########xx
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x09, 0x09, 0x09, 0x09, 0xc7, 0xc7, 0xc7, 0xc7	;         ########
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x0a, 0xc7, 0xc7, 0x0a, 0xc7, 0xc7, 0xc7, 0xc7	;         WW    WW
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x00, 0xc7, 0xc7, 0x00, 0xc7, 0xc7, 0xc7, 0xc7	;         ##    ##
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x1a, 0x1a, 0x00, 0x00, 0xc7, 0xc7, 0xc7, 0xc7	;         XXXX####
    .db 0xc7, 0xc7, 0x0a, 0x09, 0x09, 0x09, 0x09, 0x09, 0x09, 0xc7, 0xc7, 0xc7	;     WW############
    .db 0xc7, 0xc7, 0xc7, 0x13, 0x13, 0x66, 0x09, 0x09, 0x09, 0x09, 0xc7, 0xc7	;       XXXX--########
    .db 0xc7, 0xc7, 0xc7, 0x00, 0xff, 0x66, 0x0a, 0x0a, 0x01, 0xc7, 0xc7, 0xc7	;       ##  --WWWW##
    .db 0xc7, 0xc7, 0x66, 0x66, 0x66, 0x66, 0x0a, 0x01, 0x01, 0xc7, 0xc7, 0xc7	;     --------WW####
    .db 0xc7, 0xc7, 0xc7, 0x13, 0x66, 0x66, 0x1d, 0x01, 0xc7, 0xc7, 0xc7, 0xc7	;       XX----xx##
    .db 0xc7, 0xc7, 0xc7, 0x09, 0x09, 0x5c, 0x52, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;       ####xxXX
    .db 0xc7, 0xc7, 0xc7, 0x09, 0x09, 0x0a, 0x00, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;       ####WW##
    .db 0xc7, 0xc7, 0xc7, 0x00, 0x00, 0x0a, 0x1d, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;       ####WWxx
    .db 0xc7, 0xc7, 0xc7, 0x09, 0x09, 0x09, 0x09, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;       ########
    .db 0xc7, 0xc7, 0xc7, 0x0a, 0xc7, 0xc7, 0x0a, 0x00, 0xc7, 0xc7, 0xc7, 0xc7	;       WW    WW##
    .db 0xc7, 0xc7, 0xc7, 0x00, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;       ##
    .db 0xc7, 0xc7, 0xc7, 0x1a, 0x1a, 0x00, 0x00, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;       XXXX####
    .db 0xc7, 0x0a, 0x09, 0x09, 0x09, 0x09, 0x09, 0x09, 0xc7, 0xc7, 0xc7, 0xc7	;   WW############
    .db 0xc7, 0xc7, 0x13, 0x13, 0x66, 0x09, 0x09, 0x09, 0x09, 0xc7, 0xc7, 0xc7	;     XXXX--########
    .db 0xc7, 0xc7, 0x00, 0xff, 0x66, 0x0a, 0x0a, 0x01, 0xc7, 0xc7, 0xc7, 0xc7	;     ##  --WWWW##
    .db 0xc7, 0x66, 0x66, 0x66, 0x66, 0x0a, 0x01, 0x01, 0xc7, 0xc7, 0xc7, 0xc7	;   --------WW####
    .db 0xc7, 0xc7, 0x13, 0x66, 0x66, 0x1d, 0x01, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;     XX----xx##
    .db 0xc7, 0xc7, 0x13, 0x09, 0x5c, 0x52, 0x09, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;     XX##xxXX##
    .db 0xc7, 0xc7, 0xc7, 0x09, 0x0a, 0x09, 0x00, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;       ##WW####
    .db 0xc7, 0xc7, 0xc7, 0x00, 0x0a, 0x00, 0x09, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;       ##WW####
    .db 0xc7, 0xc7, 0xc7, 0x09, 0x1d, 0x09, 0x09, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;       ##xx####
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x0a, 0xc7, 0x0a, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;         WW  WW
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x00, 0xc7, 0xc7, 0x00, 0xc7, 0xc7, 0xc7, 0xc7	;         ##    ##
    .db 0xc7, 0xc7, 0xc7, 0x1a, 0x1a, 0x00, 0x00, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;       XXXX####
    .db 0xc7, 0x0a, 0x09, 0x09, 0x09, 0x09, 0x09, 0x09, 0xc7, 0xc7, 0xc7, 0xc7	;   WW############
    .db 0xc7, 0xc7, 0x13, 0x13, 0x66, 0x09, 0x09, 0x09, 0x09, 0xc7, 0xc7, 0xc7	;     XXXX--########
    .db 0xc7, 0xc7, 0x00, 0xff, 0x66, 0x0a, 0x0a, 0x01, 0xc7, 0xc7, 0xc7, 0xc7	;     ##  --WWWW##
    .db 0xc7, 0x66, 0x66, 0x66, 0x66, 0x0a, 0x01, 0x01, 0xc7, 0xc7, 0xc7, 0xc7	;   --------WW####
    .db 0xc7, 0xc7, 0x13, 0x66, 0x66, 0x1d, 0x01, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;     XX----xx##
    .db 0xc7, 0xc7, 0x13, 0x09, 0x5c, 0x52, 0x09, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;     XX##xxXX##
    .db 0xc7, 0xc7, 0xc7, 0x09, 0x0a, 0x09, 0x00, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;       ##WW####
    .db 0xc7, 0xc7, 0xc7, 0x1d, 0x0a, 0x00, 0x09, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;       xxWW####
    .db 0xc7, 0xc7, 0xc7, 0x09, 0x09, 0x09, 0x09, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;       ########
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x0a, 0x00, 0x0a, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;         WW##WW
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x00, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;             ##
    .db 0xc7, 0xc7, 0xc7, 0x1a, 0x1a, 0x00, 0x00, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;       XXXX####
    .db 0xc7, 0x0a, 0x09, 0x09, 0x09, 0x09, 0x09, 0x09, 0xc7, 0xc7, 0xc7, 0xc7	;   WW############
    .db 0xc7, 0xc7, 0x13, 0x13, 0x66, 0x09, 0x09, 0x09, 0x09, 0xc7, 0xc7, 0xc7	;     XXXX--########
    .db 0xc7, 0xc7, 0x00, 0xff, 0x66, 0x0a, 0x0a, 0x01, 0xc7, 0xc7, 0xc7, 0xc7	;     ##  --WWWW##
    .db 0xc7, 0x66, 0x66, 0x66, 0x66, 0x0a, 0x01, 0x01, 0xc7, 0xc7, 0xc7, 0xc7	;   --------WW####
    .db 0xc7, 0xc7, 0x13, 0x66, 0x66, 0x1d, 0x01, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;     XX----xx##
    .db 0xc7, 0xc7, 0x13, 0x09, 0x5c, 0x52, 0x09, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;     XX##xxXX##
    .db 0xc7, 0xc7, 0xc7, 0x09, 0x0a, 0x09, 0x00, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;       ##WW####
    .db 0xc7, 0xc7, 0xc7, 0x00, 0x0a, 0x00, 0x09, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;       ##WW####
    .db 0xc7, 0xc7, 0xc7, 0x09, 0x1d, 0x09, 0x09, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;       ##xx####
    .db 0xc7, 0xc7, 0xc7, 0x0a, 0xc7, 0xc7, 0x0a, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;       WW    WW
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x00, 0xc7, 0xc7, 0x00, 0xc7, 0xc7, 0xc7, 0xc7	;         ##    ##
    .db 0xc7, 0x0b, 0x0b, 0x37, 0x1a, 0x1a, 0x00, 0x00, 0x00, 0x09, 0xc7, 0xc7	;   WWWW,,XXXX########
    .db 0x0b, 0x0b, 0x09, 0x09, 0x09, 0x1a, 0x00, 0x09, 0x09, 0x09, 0x09, 0xc7	; WWWW######XX##########
    .db 0xc7, 0xc7, 0x0a, 0x13, 0x09, 0x09, 0x09, 0x09, 0x13, 0x0a, 0xc7, 0xc7	;     WWXX########XXWW
    .db 0xc7, 0xc7, 0x0a, 0xff, 0x00, 0x6e, 0x1d, 0x00, 0xff, 0x0a, 0xc7, 0xc7	;     WW  ##--xx##  WW
    .db 0xc7, 0xc7, 0x1d, 0x6e, 0x6e, 0x6e, 0x1d, 0x6e, 0x6e, 0x1d, 0xc7, 0xc7	;     xx------xx----xx
    .db 0xc7, 0xc7, 0xc7, 0x1d, 0x14, 0x14, 0x13, 0x13, 0x1d, 0xc7, 0xc7, 0xc7	;       xxXXXXXXXXxx
    .db 0xc7, 0xc7, 0x5c, 0x09, 0x09, 0x14, 0x13, 0x00, 0x00, 0x52, 0xc7, 0xc7	;     xx####XXXX####XX
    .db 0xc7, 0xc7, 0xc7, 0x13, 0x09, 0x00, 0x00, 0x09, 0x0a, 0xc7, 0xc7, 0xc7	;       XX########WW
    .db 0xc7, 0xc7, 0xc7, 0x13, 0x00, 0x00, 0x09, 0x09, 0x0a, 0xc7, 0xc7, 0xc7	;       XX########WW
    .db 0xc7, 0xc7, 0xc7, 0x66, 0x09, 0x09, 0x09, 0x09, 0x1d, 0xc7, 0xc7, 0xc7	;       --########xx
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x0a, 0xc7, 0xc7, 0x0a, 0xc7, 0xc7, 0xc7, 0xc7	;         WW    WW
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x00, 0xc7, 0xc7, 0x00, 0xc7, 0xc7, 0xc7, 0xc7	;         ##    ##
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x1a, 0x1a, 0x37, 0x00, 0xc7, 0xc7, 0xc7	;           XXXX,,##
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x09, 0x09, 0x09, 0x0b, 0x09, 0x09, 0x0a, 0xc7	;         ######WW####WW
    .db 0xc7, 0xc7, 0xc7, 0x09, 0x09, 0x09, 0x0b, 0x66, 0x13, 0x13, 0xc7, 0xc7	;       ######WW--XXXX
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x0a, 0x0a, 0x01, 0x66, 0xff, 0x00, 0xc7, 0xc7	;         WWWW##--  ##
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x0a, 0x0a, 0x01, 0x66, 0x66, 0x66, 0x66, 0xc7	;         WWWW##--------
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x01, 0x1d, 0x66, 0x66, 0x13, 0xc7, 0xc7	;           ##xx----XX
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x09, 0x5c, 0x52, 0x09, 0x13, 0xc7, 0xc7	;           ##xxXX##XX
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x00, 0x09, 0x0a, 0x09, 0xc7, 0xc7, 0xc7	;           ####WW##
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x09, 0x00, 0x0a, 0x00, 0xc7, 0xc7, 0xc7	;           ####WW##
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x09, 0x09, 0x1d, 0x09, 0xc7, 0xc7, 0xc7	;           ####xx##
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x0a, 0xc7, 0xc7, 0x0a, 0xc7, 0xc7, 0xc7	;           WW    WW
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x00, 0xc7, 0xc7, 0x00, 0xc7, 0xc7, 0xc7	;           ##    ##
    .db 0xc7, 0xc7, 0xc7, 0x1a, 0x1a, 0x1a, 0x00, 0x00, 0x37, 0x0b, 0xc7, 0xc7	;       XXXXXX####,,WW
    .db 0xc7, 0x09, 0x09, 0x09, 0x1a, 0x1a, 0x00, 0x00, 0x09, 0x09, 0x09, 0xc7	;   ######XXXX##########
    .db 0xc7, 0xc7, 0x09, 0x09, 0x09, 0x1a, 0x00, 0x09, 0x09, 0x09, 0xc7, 0xc7	;     ######XX########
    .db 0xc7, 0xc7, 0x0a, 0x0a, 0x09, 0x09, 0x09, 0x09, 0x01, 0x01, 0xc7, 0xc7	;     WWWW############
    .db 0xc7, 0xc7, 0x0a, 0x0a, 0x0a, 0x0a, 0x01, 0x01, 0x01, 0x01, 0xc7, 0xc7	;     WWWWWWWW########
    .db 0xc7, 0xc7, 0xc7, 0x0a, 0x0a, 0x01, 0x01, 0x01, 0x01, 0xc7, 0xc7, 0xc7	;       WWWW########
    .db 0xc7, 0xc7, 0x5c, 0x00, 0x00, 0x00, 0x09, 0x09, 0x00, 0x52, 0xc7, 0xc7	;     xx############XX
    .db 0xc7, 0xc7, 0xc7, 0x13, 0x09, 0x00, 0x00, 0x09, 0x0a, 0xc7, 0xc7, 0xc7	;       XX########WW
    .db 0xc7, 0xc7, 0xc7, 0x13, 0x09, 0x09, 0x00, 0x00, 0x0a, 0xc7, 0xc7, 0xc7	;       XX########WW
    .db 0xc7, 0xc7, 0xc7, 0x66, 0x09, 0x09, 0x09, 0x09, 0x1d, 0xc7, 0xc7, 0xc7	;       --########xx
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x0a, 0xc7, 0xc7, 0x0a, 0xc7, 0xc7, 0xc7, 0xc7	;         WW    WW
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x00, 0xc7, 0xc7, 0x00, 0xc7, 0xc7, 0xc7, 0xc7	;         ##    ##
    .db 0xc7, 0xc7, 0xc7, 0x1a, 0x1a, 0x00, 0x00, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;       XXXX####
    .db 0xc7, 0x0a, 0x09, 0x09, 0x09, 0x09, 0x09, 0x09, 0xc7, 0xc7, 0xc7, 0xc7	;   WW############
    .db 0xc7, 0xc7, 0x13, 0x13, 0x66, 0x09, 0x09, 0x09, 0x09, 0xc7, 0xc7, 0xc7	;     XXXX--########
    .db 0xc7, 0xc7, 0x00, 0xff, 0x66, 0x0a, 0x0a, 0x01, 0xc7, 0xc7, 0xc7, 0xc7	;     ##  --WWWW##
    .db 0xc7, 0x66, 0x66, 0x66, 0x66, 0x0a, 0x01, 0x01, 0xc7, 0xc7, 0xc7, 0xc7	;   --------WW####
    .db 0xc7, 0xc7, 0x13, 0x66, 0x66, 0x1d, 0x01, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;     XX----xx##
    .db 0xc7, 0xc7, 0x13, 0x09, 0x5c, 0x52, 0x09, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;     XX##xxXX##
    .db 0xc7, 0xc7, 0xc7, 0x09, 0x0a, 0x09, 0x00, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;       ##WW####
    .db 0xc7, 0xc7, 0xc7, 0x00, 0x0a, 0x00, 0x09, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;       ##WW####
    .db 0xc7, 0xc7, 0xc7, 0x09, 0x1d, 0x09, 0x09, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;       ##xx####
    .db 0xc7, 0xc7, 0xc7, 0x0a, 0xc7, 0xc7, 0x0a, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;       WW    WW
    .db 0xc7, 0xc7, 0xc7, 0x00, 0xc7, 0xc7, 0x00, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;       ##    ##

static_character_sprite_table:
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;
    .db 0xc7, 0xc7, 0xc7, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xc7, 0xc7, 0xc7	;       ............
    .db 0xc7, 0xc7, 0xfe, 0xed, 0xed, 0xed, 0xed, 0xed, 0xed, 0xa4, 0xc7, 0xc7	;     ..,,,,,,,,,,,,~~
    .db 0xc7, 0xc7, 0xfe, 0x52, 0x52, 0xed, 0xa4, 0x52, 0x52, 0xa4, 0xc7, 0xc7	;     ..XXXX,,~~XXXX~~
    .db 0xc7, 0xc7, 0xfe, 0xed, 0xed, 0xed, 0xa4, 0xed, 0xed, 0xa4, 0xc7, 0xc7	;     ..,,,,,,~~,,,,~~
    .db 0xc7, 0xc7, 0xc7, 0xed, 0xed, 0x52, 0x52, 0xed, 0xa4, 0xc7, 0xc7, 0xc7	;       ,,,,XXXX,,~~
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x52, 0x52, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;           XXXX          
    .db 0xc7, 0xc7, 0xed, 0xed, 0xed, 0xed, 0xa4, 0xa4, 0xed, 0xed, 0xc7, 0xc7	;     ,,,,,,,,~~~~,,,,
    .db 0xc7, 0xc7, 0xed, 0xc7, 0xc7, 0xed, 0xa4, 0xc7, 0xc7, 0xa4, 0xc7, 0xc7	;     ,,    ,,~~    ~~
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xed, 0xed, 0xed, 0xa4, 0xc7, 0xc7, 0xc7, 0xc7	;         ,,,,,,~~
    .db 0xc7, 0xc7, 0xed, 0xa4, 0xa4, 0xc7, 0xc7, 0xed, 0xc7, 0xc7, 0xc7, 0xc7	;     ,,~~~~    ,,
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xed, 0xc7, 0xc7, 0xc7, 0xc7	;               ,,
    .db 0xc7, 0xc7, 0xc7, 0x0a, 0x0a, 0x1d, 0x1d, 0x0a, 0x0a, 0xc7, 0xc7, 0xc7	;       WWWW----WWWW
    .db 0xc7, 0xc7, 0x0a, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x0a, 0xc7, 0xc7	;     WW------------WW
    .db 0xc7, 0xc7, 0x0a, 0x52, 0x52, 0x6e, 0x1d, 0x52, 0x52, 0x0a, 0xc7, 0xc7	;     WWXXXX--xxXXXXWW
    .db 0xc7, 0xc7, 0x0a, 0x00, 0xff, 0x6e, 0x1d, 0x00, 0xff, 0x0a, 0xc7, 0xc7	;     WW  ##--xx  ##WW
    .db 0xc7, 0xc7, 0x1d, 0x6e, 0x6e, 0x6e, 0x1d, 0x6e, 0x6e, 0x1d, 0xc7, 0xc7	;     xx------xx----xx
    .db 0xc7, 0xc7, 0xc7, 0x1d, 0x1d, 0x0a, 0x0a, 0x1d, 0x1d, 0xc7, 0xc7, 0xc7	;       xxxxWWWWxxxx
    .db 0xc7, 0xc7, 0x00, 0x00, 0xff, 0xa4, 0xa4, 0xff, 0x00, 0x00, 0xc7, 0xc7	;     ####  ~~~~  ####
    .db 0xc7, 0xc7, 0x00, 0x00, 0x00, 0xa4, 0xff, 0x00, 0x00, 0x00, 0xc7, 0xc7	;     ######~~  ######
    .db 0xc7, 0xc7, 0xc7, 0x00, 0x00, 0xa4, 0x00, 0x00, 0x00, 0xc7, 0xc7, 0xc7	;       ####~~######
    .db 0xc7, 0xc7, 0xc7, 0x1d, 0x00, 0x00, 0x00, 0x00, 0x1d, 0xc7, 0xc7, 0xc7	;       xx########xx
    .db 0xc7, 0xc7, 0xc7, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc7, 0xc7, 0xc7	;       ############
    .db 0xc7, 0xc7, 0xc7, 0xc7, 0x00, 0xc7, 0xc7, 0x00, 0xc7, 0xc7, 0xc7, 0xc7	;         ##    ##
