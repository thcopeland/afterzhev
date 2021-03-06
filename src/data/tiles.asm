; A tile is a 12x12 block of pixels.
;
; 0-143 - pixel data (row-major order)

tile_table:
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWWWWWWWWWWWWWWWWW
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWWWWWWWWWWWWWWWWW
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWWWWWWWWWWWWWWWWW
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWWWWWWWWWWWWWWWWW
    .db 0x18, 0x18, 0x32, 0x32, 0x18, 0x18, 0x18, 0x18, 0x28, 0x18, 0x18, 0x18	; WWWWxxxxWWWWWWWWXXWWWWWW
    .db 0x18, 0x18, 0x28, 0x18, 0x18, 0x11, 0x18, 0x18, 0x5d, 0x5d, 0x18, 0x18	; WWWWXXWWWWWWWWWW~~~~WWWW
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x11, 0x11, 0x5d, 0x6e, 0x28, 0x28	; WWWWWWWWWWWWWWWW~~--XXXX
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x5d, 0x6e, 0x6e, 0x6e, 0x6e	; WWWWWWWWWWWWWW~~--------
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x11, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; WWWWWWWWWWWWWW----------
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x5d, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; WWWWWWWWWW~~------------
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x5d, 0x6e, 0x6e, 0x5d, 0x5d, 0x5d	; WWWWWWWWWWWW~~----~~~~~~
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x5d, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; WWWWWWWWWWWW~~----------

    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWWWWWWWWWWWWWWWWW
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWWWWWWWWWWWWWWWWW
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWWWWWWWWWWWWWWWWW
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x28	; WWWWWWWWWWWWWWWWWWWWWWXX
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWWWWWWWWWWWWWWWWW
    .db 0x18, 0x18, 0x18, 0x18, 0x28, 0x18, 0x5d, 0x18, 0x18, 0x32, 0x28, 0x18	; WWWWWWWWXXWW~~WWWWxxXXWW
    .db 0x5d, 0x5d, 0x18, 0x11, 0x11, 0x5d, 0x5d, 0x5d, 0x6e, 0x5d, 0x28, 0x18	; ~~~~WWWWWW~~~~~~--~~XXWW
    .db 0x6e, 0x6e, 0x6e, 0x18, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; ------WW----------------
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; ------------------------
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x5d, 0x6e	; --------------------~~--
    .db 0x5d, 0x5d, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x5d	; ~~~~------------------~~
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; ------------------------

    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWWWWWWWWWWWWWWWWW
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWWWWWWWWWWWWWWWWW
    .db 0x32, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; xxWWWWWWWWWWWWWWWWWWWWWW
    .db 0x28, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; XXWWWWWWWWWWWWWWWWWWWWWW
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWWWWWWWWWWWWWWWWW
    .db 0x18, 0x18, 0x18, 0x11, 0x28, 0x28, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWXXXXWWWWWWWWWWWW
    .db 0x5d, 0x6e, 0x6e, 0x5d, 0x18, 0x5d, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; ~~----~~WW~~WWWWWWWWWWWW
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x5d, 0x5d, 0x18, 0x18, 0x18, 0x18, 0x18	; ----------~~~~WWWWWWWWWW
    .db 0x6e, 0x6e, 0x6e, 0x18, 0x18, 0x5d, 0x5d, 0x18, 0x18, 0x18, 0x18, 0x18	; ------WWWW~~~~WWWWWWWWWW
    .db 0x6e, 0x6e, 0x6e, 0x11, 0x18, 0x18, 0x11, 0x18, 0x18, 0x18, 0x18, 0x18	; ------WWWWWWWWWWWWWWWWWW
    .db 0x5d, 0x5d, 0x6e, 0x6e, 0x5d, 0x11, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; ~~~~----~~WWWWWWWWWWWWWW
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x5d, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; ----------~~WWWWWWWWWWWW

    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; ------------------------
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x5d, 0x5d, 0x6e, 0x6e, 0x6e, 0x6e	; ------------~~~~--------
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; ------------------------
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; ------------------------
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x11, 0x11, 0x6e, 0x6e, 0x6e, 0x28, 0x6e, 0x6e	; --------WWWW------XX----
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x32, 0x28, 0x11, 0x6e, 0x5d, 0x18, 0x11, 0x5d	; --------xxXXWW--~~WWWW~~
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x5d, 0x28, 0x18, 0x18, 0x5d, 0x18, 0x18, 0x18	; --------~~XXWWWW~~WWWWWW
    .db 0x6e, 0x5d, 0x5d, 0x6e, 0x6e, 0x5d, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; --~~~~----~~WWWWWWWWWWWW
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x11, 0x18, 0x18, 0x18, 0x18, 0x32, 0x18	; ----------WWWWWWWWWWxxWW
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x11, 0x18, 0x18, 0x18, 0x18, 0x28, 0x32, 0x18	; --------WWWWWWWWWWXXxxWW
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x5d, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; --------~~WWWWWWWWWWWWWW
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x5d, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; ----------~~WWWWWWWWWWWW

    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; ------------------------
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x5d	; ----------------------~~
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; ------------------------
    .db 0x6e, 0x6e, 0x11, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; ----WW------------------
    .db 0x6e, 0x28, 0x18, 0x11, 0x6e, 0x6e, 0x6e, 0x5d, 0x6e, 0x11, 0x5d, 0x6e	; --XXWWWW------~~--WW~~--
    .db 0x18, 0x11, 0x18, 0x11, 0x6e, 0x6e, 0x6e, 0x6e, 0x18, 0x32, 0x11, 0x5d	; WWWWWWWW--------WWxxWW~~
    .db 0x18, 0x11, 0x18, 0x18, 0x18, 0x6e, 0x5d, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWWW--~~WWWWWWWWWW
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWWWWWWWWWWWWWWWWW
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWWWWWWWWWWWWWWWWW
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x32, 0x28, 0x18, 0x18, 0x18	; WWWWWWWWWWWWWWxxXXWWWWWW
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x28, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWWWWWWWXXWWWWWWWW
    .db 0x18, 0x32, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWxxWWWWWWWWWWWWWWWWWWWW

    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; ------------------------
    .db 0x5d, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; ~~----------------------
    .db 0x5d, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x5d, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; ~~----------~~----------
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; ------------------------
    .db 0x6e, 0x28, 0x6e, 0x6e, 0x6e, 0x28, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; --XX------XX------------
    .db 0x6e, 0x18, 0x11, 0x6e, 0x5d, 0x5d, 0x11, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; --WWWW--~~~~WW----------
    .db 0x18, 0x18, 0x18, 0x5d, 0x18, 0x11, 0x11, 0x5d, 0x6e, 0x6e, 0x6e, 0x6e	; WWWWWW~~WWWWWW~~--------
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x5d, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; WWWWWWWWWWWW~~----------
    .db 0x18, 0x18, 0x32, 0x18, 0x18, 0x18, 0x18, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; WWWWxxWWWWWWWW----------
    .db 0x18, 0x18, 0x28, 0x18, 0x11, 0x18, 0x28, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; WWWWXXWWWWWWXX----------
    .db 0x18, 0x18, 0x18, 0x18, 0x11, 0x11, 0x18, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; WWWWWWWWWWWWWW----------
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; WWWWWWWWWWWW------------

    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x5d, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; WWWWWWWWWWWW~~----------
    .db 0x18, 0x18, 0x18, 0x18, 0x32, 0x32, 0x18, 0x28, 0x6e, 0x6e, 0x6e, 0x6e	; WWWWWWWWxxxxWWXX--------
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x11, 0x11, 0x6e, 0x6e, 0x6e, 0x6e	; WWWWWWWWWWWWWWWW--------
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x5d, 0x5d, 0x6e, 0x6e, 0x6e, 0x6e	; WWWWWWWWWWWW~~~~--------
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x11, 0x5d, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; WWWWWWWWWWWW~~----------
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x28, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; WWWWWWWWWWWWXX----------
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x28, 0x18, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; WWWWWWWWWWXXWW----------
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x11, 0x11, 0x5d, 0x6e, 0x6e, 0x6e, 0x6e	; WWWWWWWWWWWWWW~~--------
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x5d, 0x6e, 0x6e, 0x6e, 0x6e, 0x5d	; WWWWWWWWWWWW~~--------~~
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x5d, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; WWWWWWWWWW~~------------
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x5d, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; WWWWWWWWWW~~------------
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; WWWWWWWWWWWW------------

    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; ------------------------
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; ------------------------
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; ------------------------
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x5d, 0x5d, 0x5d, 0x6e, 0x6e, 0x6e, 0x6e	; ----------~~~~~~--------
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x5d, 0x5d, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; --------~~~~------------
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; ------------------------
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; ------------------------
    .db 0x6e, 0x6e, 0x5d, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; ----~~------------------
    .db 0x5d, 0x5d, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x5d	; ~~~~------------------~~
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; ------------------------
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; ------------------------
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; ------------------------

    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x18, 0x28, 0x11, 0x28, 0x18, 0x18, 0x18, 0x18	; --------WWXXWWXXWWWWWWWW
    .db 0x6e, 0x6e, 0x6e, 0x5d, 0x28, 0x6e, 0x11, 0x11, 0x18, 0x18, 0x18, 0x18	; ------~~XX--WWWWWWWWWWWW
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x5d, 0x28, 0x18, 0x18, 0x18, 0x18, 0x18	; ----------~~XXWWWWWWWWWW
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x5d, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; ----------~~WWWWWWWWWWWW
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x28, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; ----------XXWWWWWWWWWWWW
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x18, 0x18, 0x11, 0x18, 0x18, 0x18, 0x18, 0x18	; --------WWWWWWWWWWWWWWWW
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x11, 0x32, 0x18, 0x18, 0x18, 0x18, 0x18	; ----------WWxxWWWWWWWWWW
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; ------------WWWWWWWWWWWW
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x5d, 0x18, 0x18, 0x18, 0x18, 0x18	; ------------~~WWWWWWWWWW
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x5d, 0x18, 0x18, 0x18, 0x18, 0x18	; ------------~~WWWWWWWWWW
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x5d, 0x28, 0x18, 0x18, 0x18, 0x18, 0x18	; ----------~~XXWWWWWWWWWW
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x28, 0x11, 0x18, 0x18, 0x18, 0x18, 0x18	; ----------XXWWWWWWWWWWWW

    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x5d, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; ----------~~WWWWWWWWWWWW
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x5d, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; ----------~~WWWWWWWWWWWW
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x11, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; ----------WWWWWWWWWWWWWW
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; ----------WWWWWWWWWWWWWW
    .db 0x6e, 0x6e, 0x6e, 0x5d, 0x5d, 0x18, 0x5d, 0x5d, 0x18, 0x18, 0x18, 0x18	; ------~~~~WW~~~~WWWWWWWW
    .db 0x6e, 0x6e, 0x6e, 0x5d, 0x6e, 0x5d, 0x5d, 0x18, 0x18, 0x18, 0x18, 0x18	; ------~~--~~~~WWWWWWWWWW
    .db 0x6e, 0x6e, 0x5d, 0x6e, 0x6e, 0x6e, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; ----~~------WWWWWWWWWWWW
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; ------------WWWWWWWWWWWW
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x18, 0x11, 0x18, 0x18, 0x32, 0x18, 0x18, 0x18	; --------WWWWWWWWxxWWWWWW
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x28, 0x18, 0x18, 0x28, 0x18, 0x18, 0x18	; ----------XXWWWWXXWWWWWW
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; ------------WWWWWWWWWWWW
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x5d, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; ----------~~WWWWWWWWWWWW

    .db 0x18, 0x28, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWXXWWWWWWWWWWWWWWWWWWWW
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWWWWWWWWWWWWWWWWW
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWWWWWWWWWWWWWWWWW
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWWWWWWWWWWWWWWWWW
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x32, 0x18, 0x18, 0x18	; WWWWWWWWWWWWWWWWxxWWWWWW
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x28, 0x18, 0x18, 0x18	; WWWWWWWWWWWWWWWWXXWWWWWW
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWWWWWWWWWWWWWWWWW
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWWWWWWWWWWWWWWWWW
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWWWWWWWWWWWWWWWWW
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWWWWWWWWWWWWWWWWW
    .db 0x18, 0x32, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWxxWWWWWWWWWWWWWWWWWWWW
    .db 0x18, 0x28, 0x28, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWXXXXWWWWWWWWWWWWWWWWWW

    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x6e, 0x6e, 0x5d, 0x6e, 0x6e, 0x6e	; WWWWWWWWWWWW----~~------
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x5d, 0x11, 0x11, 0x6e, 0x6e, 0x6e	; WWWWWWWWWWWW~~WWWW------
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x11, 0x18, 0x28, 0x6e, 0x6e, 0x6e	; WWWWWWWWWWWWWWWWXX------
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x5d, 0x6e, 0x6e, 0x5d	; WWWWWWWWWWWWWWWW~~----~~
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x11, 0x6e, 0x6e, 0x6e, 0x6e, 0x5d	; WWWWWWWWWWWWWW--------~~
    .db 0x18, 0x18, 0x18, 0x18, 0x5d, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; WWWWWWWW~~--------------
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x5d, 0x5d, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; WWWWWWWWWW~~~~----------
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x11, 0x11, 0x5d, 0x6e, 0x6e, 0x6e	; WWWWWWWWWWWWWWWW~~------
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x11, 0x18, 0x28, 0x11, 0x6e, 0x6e, 0x6e	; WWWWWWWWWWWWWWXXWW------
    .db 0x18, 0x18, 0x18, 0x28, 0x28, 0x18, 0x18, 0x6e, 0x28, 0x6e, 0x6e, 0x6e	; WWWWWWXXXXWWWW--XX------
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; WWWWWWWWWWWW------------
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; WWWWWWWWWWWW------------

    .db 0x18, 0x18, 0x32, 0x18, 0x18, 0x18, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; WWWWxxWWWWWW------------
    .db 0x18, 0x18, 0x28, 0x18, 0x18, 0x18, 0x28, 0x32, 0x6e, 0x6e, 0x6e, 0x6e	; WWWWXXWWWWWWXXxx--------
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x11, 0x6e, 0x6e, 0x6e, 0x6e	; WWWWWWWWWWWWWWWW--------
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x11, 0x5d, 0x6e, 0x6e, 0x6e, 0x6e	; WWWWWWWWWWWWWW~~--------
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x5d, 0x5d, 0x5d, 0x5d, 0x5d, 0x6e, 0x6e	; WWWWWWWWWW~~~~~~~~~~----
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x5d, 0x28, 0x18, 0x11, 0x5d, 0x5d	; WWWWWWWWWWWW~~XXWWWW~~~~
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x11, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWWWWWWWWWWWWWWWWW
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWWWWWWWWWWWWWWWWW
    .db 0x18, 0x18, 0x18, 0x18, 0x32, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWxxWWWWWWWWWWWWWW
    .db 0x18, 0x18, 0x18, 0x18, 0x28, 0x28, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWXXXXWWWWWWWWWWWW
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWWWWWWWWWWWWWWWWW
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWWWWWWWWWWWWWWWWW

    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; ------------------------
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; ------------------------
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; ------------------------
    .db 0x6e, 0x28, 0x11, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; --XXWW------------------
    .db 0x6e, 0x18, 0x18, 0x11, 0x6e, 0x6e, 0x6e, 0x6e, 0x11, 0x6e, 0x6e, 0x6e	; --WWWWWW--------WW------
    .db 0x6e, 0x6e, 0x18, 0x11, 0x6e, 0x6e, 0x5d, 0x28, 0x28, 0x11, 0x6e, 0x6e	; ----WWWW----~~XXXXWW----
    .db 0x18, 0x18, 0x18, 0x11, 0x5d, 0x5d, 0x11, 0x18, 0x18, 0x18, 0x5d, 0x18	; WWWWWWWW~~~~WWWWWWWW~~WW
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWWWWWWWWWWWWWWWWW
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWWWWWWWWWWWWWWWWW
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWWWWWWWWWWWWWWWWW
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWWWWWWWWWWWWWWWWW
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWWWWWWWWWWWWWWWWW

    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x5d, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; ----------~~WWWWWWWWWWWW
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x11, 0x11, 0x18, 0x18, 0x18, 0x18, 0x18	; ----------WWWWWWWWWWWWWW
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x28, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; --------XXWWWWWWWWWWWWWW
    .db 0x6e, 0x6e, 0x5d, 0x5d, 0x5d, 0x11, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; ----~~~~~~WWWWWWWWWWWWWW
    .db 0x6e, 0x6e, 0x6e, 0x5d, 0x18, 0x11, 0x11, 0x18, 0x18, 0x18, 0x18, 0x18	; ------~~WWWWWWWWWWWWWWWW
    .db 0x6e, 0x5d, 0x28, 0x11, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; --~~XXWWWWWWWWWWWWWWWWWW
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWWWWWWWWWWWWWWWWW
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWWWWWWWWWWWWWWWWW
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x32, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWWWxxWWWWWWWWWWWW
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x28, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWWWXXWWWWWWWWWWWW
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWWWWWWWWWWWWWWWWW
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWWWWWWWWWWWWWWWWW

    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x5d, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; ----------~~WWWWWWWWWWWW
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x11, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; ----------WWWWWWWWWWWWWW
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x18, 0x11, 0x18, 0x18, 0x18, 0x18, 0x18	; ----------WWWWWWWWWWWWWW
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x28, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; --------XXWWWWWWWWWWWWWW
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x5d, 0x28, 0x18, 0x18, 0x18, 0x18, 0x18	; ----------~~XXWWWWWWWWWW
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x32, 0x11, 0x18, 0x18, 0x18	; --------------xxWWWWWWWW
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x18, 0x18, 0x18, 0x5d, 0x18	; --------------WWWWWW~~WW
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x28, 0x18, 0x11, 0x5d, 0x5d	; --------------XXWWWW~~~~
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x11, 0x11, 0x6e, 0x6e	; ----------------WWWW----
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; ------------------------
    .db 0x6e, 0x5d, 0x5d, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; --~~~~------------------
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; ------------------------

    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWWWWWWWWWWWWWWWWW
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWWWWWWWWWWWWWWWWW
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWWWWWWWWWWWWWWWWW
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x32, 0x18, 0x18	; WWWWWWWWWWWWWWWWWWxxWWWW
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x28, 0x18, 0x18	; WWWWWWWWWWWWWWWWWWXXWWWW
    .db 0x18, 0x18, 0x11, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWWWWWWWWWWWWWWWWW
    .db 0x18, 0x18, 0x11, 0x18, 0x18, 0x18, 0x5d, 0x18, 0x18, 0x18, 0x18, 0x18	; WWWWWWWWWWWW~~WWWWWWWWWW
    .db 0x6e, 0x6e, 0x28, 0x18, 0x11, 0x5d, 0x5d, 0x6e, 0x18, 0x11, 0x11, 0x5d	; ----XXWWWW~~~~--WWWWWW~~
    .db 0x6e, 0x6e, 0x6e, 0x32, 0x11, 0x5d, 0x6e, 0x6e, 0x6e, 0x18, 0x5d, 0x6e	; ------xxWW~~------WW~~--
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; ------------------------
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; ------------------------
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; ------------------------

    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; WWWWWWWWWWWW------------
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x5d, 0x11, 0x6e, 0x6e, 0x6e, 0x6e	; WWWWWWWWWWWW~~WW--------
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x11, 0x18, 0x6e, 0x6e, 0x6e, 0x6e	; WWWWWWWWWWWWWWWW--------
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; WWWWWWWWWWWW------------
    .db 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; WWWWWWWWWWWW------------
    .db 0x18, 0x18, 0x18, 0x18, 0x11, 0x5d, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; WWWWWWWWWW~~------------
    .db 0x18, 0x18, 0x18, 0x11, 0x11, 0x5d, 0x5d, 0x11, 0x6e, 0x6e, 0x6e, 0x6e	; WWWWWWWWWW~~~~WW--------
    .db 0x5d, 0x5d, 0x5d, 0x18, 0x11, 0x18, 0x11, 0x28, 0x6e, 0x6e, 0x6e, 0x6e	; ~~~~~~WWWWWWWWXX--------
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x18, 0x28, 0x32, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; --------WWXXxx----------
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x5d, 0x5d, 0x5d, 0x5d	; ----------------~~~~~~~~
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; ------------------------
    .db 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e, 0x6e	; ------------------------

    .db 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07
    .db 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07
    .db 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07
    .db 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07
    .db 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07
    .db 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07
    .db 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07
    .db 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07
    .db 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07
    .db 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07
    .db 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07
    .db 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07
