; Features are extra decorations rendered directly on top of the world tiles. To
; be honest, they're mostly to allow more variations than are really convenient
; with just tiles (chair on wood, chair on carpet, etc). They're fixed, unlike
; loose items and active effects, but can be collided with.
;
; Layout:
;   image data (144 bytes)

feature_sprites:
.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x01, 0x01, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;           ####
.db 0xc7, 0xc7, 0xc7, 0xc7, 0x01, 0x1d, 0x1d, 0x01, 0xc7, 0xc7, 0xc7, 0xc7	;         ##xxxx##
.db 0xc7, 0xc7, 0xc7, 0x01, 0x1d, 0x14, 0x14, 0x01, 0x01, 0xc7, 0xc7, 0xc7	;       ##xxXXXX####
.db 0xc7, 0xc7, 0x01, 0x1d, 0x14, 0x14, 0x14, 0x01, 0x14, 0x01, 0xc7, 0xc7	;     ##xxXXXXXX##XX##
.db 0xc7, 0xc7, 0x01, 0x14, 0x14, 0x14, 0x14, 0x01, 0x14, 0x01, 0xc7, 0xc7	;     ##XXXXXXXX##XX##
.db 0xc7, 0xc7, 0x01, 0x14, 0x14, 0x01, 0x14, 0x14, 0x14, 0x01, 0xc7, 0xc7	;     ##XXXX##XXXXXX##
.db 0xc7, 0x01, 0x01, 0x0a, 0x0a, 0x01, 0x0a, 0x0a, 0x0a, 0x01, 0x01, 0xc7	;   ####WWWW##WWWWWW####
.db 0xc7, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xc7	;   ####################
.db 0xc7, 0x01, 0x01, 0x0a, 0x14, 0x14, 0x14, 0x14, 0x0a, 0x01, 0x01, 0xc7	;   ####WWXXXXXXXXWW####
.db 0xc7, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xc7	;   ####################
.db 0xc7, 0xc7, 0x01, 0x0a, 0x01, 0xc7, 0xc7, 0x01, 0x0a, 0x01, 0xc7, 0xc7	;     ##WW##    ##WW##
.db 0xc7, 0xc7, 0x01, 0x01, 0x01, 0xc7, 0xc7, 0x01, 0x01, 0x01, 0xc7, 0xc7	;     ######    ######

.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x01, 0x01, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;           ####
.db 0xc7, 0xc7, 0xc7, 0xc7, 0x01, 0x1d, 0x1d, 0x01, 0xc7, 0xc7, 0xc7, 0xc7	;         ##xxxx##
.db 0xc7, 0xc7, 0xc7, 0x01, 0x1d, 0x14, 0x14, 0x14, 0x01, 0xc7, 0xc7, 0xc7	;       ##xxXXXXXX##
.db 0xc7, 0xc7, 0x01, 0x1d, 0x14, 0x14, 0x14, 0x14, 0x14, 0x01, 0xc7, 0xc7	;     ##xxXXXXXXXXXX##
.db 0xc7, 0xc7, 0x01, 0x14, 0x14, 0x14, 0x14, 0x14, 0x14, 0x01, 0xc7, 0xc7	;     ##XXXXXXXXXXXX##
.db 0xc7, 0xc7, 0x01, 0x14, 0x14, 0x14, 0x14, 0x14, 0x14, 0x01, 0xc7, 0xc7	;     ##XXXXXXXXXXXX##
.db 0xc7, 0x01, 0x01, 0x14, 0x14, 0x14, 0x0a, 0x0a, 0x0a, 0x01, 0x01, 0xc7	;   ####XXXXXXWWWWWW####
.db 0xc7, 0x01, 0x01, 0x14, 0x14, 0x14, 0x14, 0x14, 0x0a, 0x01, 0x01, 0xc7	;   ####XXXXXXXXXXWW####
.db 0xc7, 0x01, 0x01, 0x14, 0x14, 0x0a, 0x0a, 0x0a, 0x0a, 0x01, 0x01, 0xc7	;   ####XXXXWWWWWWWW####
.db 0xc7, 0x01, 0x01, 0x01, 0x0a, 0x0a, 0x0a, 0x0a, 0x01, 0x01, 0x01, 0xc7	;   ######WWWWWWWW######
.db 0xc7, 0xc7, 0x01, 0x0a, 0x01, 0x01, 0x01, 0x01, 0x0a, 0x01, 0xc7, 0xc7	;     ##WW########WW##
.db 0xc7, 0xc7, 0x01, 0x01, 0x01, 0xc7, 0xc7, 0x01, 0x01, 0x01, 0xc7, 0xc7	;     ######    ######

.db 0xc7, 0xc7, 0x01, 0x01, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;     ####
.db 0xc7, 0xc7, 0x01, 0x1d, 0x01, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;     ##xx##
.db 0xc7, 0xc7, 0x01, 0x1d, 0x01, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;     ##xx##
.db 0xc7, 0xc7, 0x01, 0x14, 0x01, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;     ##XX##
.db 0xc7, 0xc7, 0x01, 0x14, 0x01, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;     ##XX##
.db 0xc7, 0xc7, 0x01, 0x14, 0x01, 0x01, 0x01, 0x01, 0x01, 0xc7, 0xc7, 0xc7	;     ##XX##########
.db 0xc7, 0xc7, 0x01, 0x14, 0x01, 0x14, 0x14, 0x14, 0x01, 0xc7, 0xc7, 0xc7	;     ##XX##XXXXXX##
.db 0xc7, 0xc7, 0x01, 0x01, 0x01, 0x01, 0x14, 0x01, 0x01, 0x01, 0xc7, 0xc7	;     ########XX######
.db 0xc7, 0xc7, 0x01, 0x14, 0x14, 0x14, 0x14, 0x14, 0x14, 0x14, 0x01, 0xc7	;     ##XXXXXXXXXXXXXX##
.db 0xc7, 0xc7, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xc7	;     ##################
.db 0xc7, 0xc7, 0x01, 0x0a, 0x01, 0xc7, 0xc7, 0x01, 0x0a, 0x01, 0xc7, 0xc7	;     ##WW##    ##WW##
.db 0xc7, 0xc7, 0x01, 0x01, 0x01, 0xc7, 0xc7, 0x01, 0x01, 0x01, 0xc7, 0xc7	;     ######    ######

.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x01, 0x01, 0xc7, 0xc7	;                 ####
.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x01, 0x1d, 0x01, 0xc7, 0xc7	;               ##xx##
.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x01, 0x14, 0x01, 0xc7, 0xc7	;               ##XX##
.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x01, 0x14, 0x01, 0xc7, 0xc7	;               ##XX##
.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x01, 0x14, 0x01, 0xc7, 0xc7	;               ##XX##
.db 0xc7, 0xc7, 0xc7, 0x01, 0x01, 0x01, 0x01, 0x01, 0x14, 0x01, 0xc7, 0xc7	;       ##########XX##
.db 0xc7, 0xc7, 0xc7, 0x01, 0x1d, 0x14, 0x14, 0x01, 0x14, 0x01, 0xc7, 0xc7	;       ##xxXXXX##XX##
.db 0xc7, 0xc7, 0x01, 0x01, 0x01, 0x14, 0x01, 0x01, 0x01, 0x01, 0xc7, 0xc7	;     ######XX########
.db 0xc7, 0x01, 0x1d, 0x14, 0x14, 0x14, 0x14, 0x14, 0x14, 0x01, 0xc7, 0xc7	;   ##xxXXXXXXXXXXXX##
.db 0xc7, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xc7, 0xc7	;   ##################
.db 0xc7, 0xc7, 0x01, 0x0a, 0x01, 0xc7, 0xc7, 0x01, 0x0a, 0x01, 0xc7, 0xc7	;     ##WW##    ##WW##
.db 0xc7, 0xc7, 0x01, 0x01, 0x01, 0xc7, 0xc7, 0x01, 0x01, 0x01, 0xc7, 0xc7	;     ######    ######

.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;
.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;
.db 0xc7, 0x0a, 0x0a, 0x0a, 0xc7, 0xc7, 0xc7, 0xc7, 0x0a, 0x01, 0x01, 0xc7	;   WWWWWW        WW####
.db 0xc7, 0x0a, 0x01, 0x01, 0x58, 0xc7, 0xc7, 0x0a, 0x00, 0x01, 0x58, 0xc7	;   WW####WW    WW####WW
.db 0xc7, 0xc7, 0x01, 0x00, 0x00, 0x58, 0x00, 0x00, 0x01, 0x58, 0xc7, 0xc7	;     ######WW######WW
.db 0xc7, 0xc7, 0xc7, 0x58, 0x00, 0x01, 0x00, 0x00, 0x58, 0xc7, 0xc7, 0xc7	;       WW########WW
.db 0xc7, 0xc7, 0xc7, 0x00, 0x0a, 0x00, 0x00, 0x00, 0x00, 0x0a, 0x01, 0xc7	;       ##WW########WW##
.db 0xc7, 0xc7, 0xc7, 0x0a, 0x00, 0x01, 0x01, 0x00, 0x58, 0x01, 0x01, 0x01	;       WW########WW######
.db 0xc7, 0xc7, 0x0a, 0x01, 0x01, 0x58, 0x01, 0x01, 0x58, 0xc7, 0xc7, 0x01	;     WW####WW####WW    ##
.db 0xc7, 0x0a, 0x01, 0x01, 0x58, 0xc7, 0x0a, 0x01, 0x01, 0x58, 0xc7, 0xc7	;   WW####WW  WW####WW
.db 0xc7, 0xc7, 0xc7, 0x58, 0xc7, 0xc7, 0xc7, 0x01, 0x01, 0xc7, 0xc7, 0xc7	;       WW      ####
.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;

.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;
.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;
.db 0xc7, 0xc7, 0xc7, 0x09, 0x09, 0x09, 0x09, 0x09, 0x09, 0x09, 0xc7, 0xc7	;       ##############
.db 0xc7, 0xc7, 0x09, 0x58, 0x58, 0x58, 0x58, 0x58, 0x58, 0x58, 0x09, 0xc7	;     ##WWWWWWWWWWWWWW##
.db 0xc7, 0x09, 0x58, 0x58, 0x58, 0x58, 0x58, 0x58, 0x58, 0x58, 0x58, 0x09	;   ##WWWWWWWWWWWWWWWWWW##
.db 0xc7, 0x09, 0x58, 0x58, 0x58, 0x58, 0x58, 0x58, 0x58, 0x58, 0x50, 0x09	;   ##WWWWWWWWWWWWWWWWWW##
.db 0xc7, 0x09, 0x58, 0x58, 0x58, 0x58, 0x58, 0x58, 0x58, 0x50, 0x50, 0x09	;   ##WWWWWWWWWWWWWWWWWW##
.db 0xc7, 0xc7, 0x09, 0x09, 0x58, 0x58, 0x58, 0x50, 0x50, 0x09, 0x09, 0xc7	;     ####WWWWWWWWWW####
.db 0xc7, 0xc7, 0xc7, 0x09, 0x09, 0x09, 0x09, 0x09, 0x09, 0x58, 0xc7, 0xc7	;       ############WW
.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x0a, 0x14, 0x0a, 0x58, 0x58, 0xc7, 0xc7	;           WWXXWWWWWW
.db 0xc7, 0xc7, 0xc7, 0xc7, 0x0a, 0x14, 0x0a, 0x0a, 0x58, 0xc7, 0xc7, 0xc7	;         WWXXWWWWWW
.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x58, 0x58, 0x58, 0x58, 0xc7, 0xc7, 0xc7	;           WWWWWWWW

.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;
.db 0xc7, 0x01, 0x01, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;   ####
.db 0x01, 0x4d, 0x4d, 0x01, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	; ##xxxx##
.db 0x01, 0x4d, 0x4c, 0x01, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	; ##xxXX##
.db 0xc7, 0x01, 0x4c, 0x4c, 0x01, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;   ##XXXX##
.db 0xc7, 0x01, 0x4a, 0x4c, 0x4c, 0x01, 0x01, 0x01, 0x01, 0x01, 0xc7, 0xc7	;   ##WWXXXX##########
.db 0xc7, 0xc7, 0x01, 0x4a, 0x4c, 0x01, 0x4c, 0x4c, 0x4c, 0x4c, 0x01, 0xc7	;     ##WWXX##XXXXXXXX##
.db 0xc7, 0xc7, 0x01, 0x01, 0x4a, 0x4c, 0x4a, 0x4a, 0x01, 0x01, 0x01, 0x01	;     ####WWXXWWWW########
.db 0xc7, 0xc7, 0xc7, 0x01, 0x4a, 0x4a, 0x4a, 0x4a, 0x4a, 0x4a, 0x4a, 0x01	;       ##WWWWWWWWWWWWWW##
.db 0xc7, 0xc7, 0xc7, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01	;       ##################
.db 0xc7, 0xc7, 0xc7, 0x01, 0x0a, 0x01, 0xc7, 0xc7, 0x01, 0x0a, 0x01, 0xc7	;       ##WW##    ##WW##
.db 0xc7, 0xc7, 0xc7, 0x01, 0x01, 0x01, 0xc7, 0xc7, 0x01, 0x01, 0x01, 0xc7	;       ######    ######

.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;
.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x01, 0x01, 0xc7	;                   ####
.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x01, 0x4d, 0x4d, 0x01	;                 ##xxxx##
.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x01, 0x4d, 0x4c, 0x01	;                 ##xxXX##
.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x01, 0x4d, 0x4c, 0x01, 0xc7	;               ##xxXX##
.db 0xc7, 0xc7, 0x01, 0x01, 0x01, 0x01, 0x01, 0x4c, 0x4c, 0x4a, 0x01, 0xc7	;     ##########XXXXWW##
.db 0xc7, 0x01, 0x4c, 0x4c, 0x4c, 0x4c, 0x01, 0x4c, 0x4a, 0x01, 0xc7, 0xc7	;   ##XXXXXXXX##XXWW##
.db 0x01, 0x01, 0x01, 0x01, 0x4a, 0x4a, 0x4c, 0x4a, 0x01, 0x01, 0xc7, 0xc7	; ########WWWWXXWW####
.db 0x01, 0x4a, 0x4a, 0x4a, 0x4a, 0x4a, 0x4a, 0x4a, 0x01, 0xc7, 0xc7, 0xc7	; ##WWWWWWWWWWWWWW##
.db 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xc7, 0xc7, 0xc7	; ##################
.db 0xc7, 0x01, 0x0a, 0x01, 0xc7, 0xc7, 0x01, 0x0a, 0x01, 0xc7, 0xc7, 0xc7	;   ##WW##    ##WW##
.db 0xc7, 0x01, 0x01, 0x01, 0xc7, 0xc7, 0x01, 0x01, 0x01, 0xc7, 0xc7, 0xc7	;   ######    ######

.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;
.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;
.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;
.db 0xc7, 0xc7, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xc7, 0xc7	;     ################
.db 0xc7, 0x01, 0x1d, 0x01, 0xed, 0xed, 0xed, 0xf6, 0x01, 0x1d, 0x01, 0xc7	;   ##xx##,,,,,,..##xx##
.db 0xc7, 0x01, 0x14, 0x01, 0xed, 0xed, 0xf6, 0xed, 0x01, 0x14, 0x01, 0xc7	;   ##XX##,,,,..,,##XX##
.db 0xc7, 0x01, 0x14, 0x01, 0xed, 0xf6, 0xed, 0xed, 0x01, 0x14, 0x01, 0xc7	;   ##XX##,,..,,,,##XX##
.db 0xc7, 0x01, 0x0a, 0x01, 0xed, 0xed, 0xed, 0xed, 0x01, 0x0a, 0x01, 0xc7	;   ##WW##,,,,,,,,##WW##
.db 0xc7, 0xc7, 0x01, 0x01, 0xe4, 0xe4, 0xe4, 0xe4, 0x01, 0x01, 0xc7, 0xc7	;     ####--------####
.db 0xc7, 0xc7, 0xc7, 0xc7, 0x01, 0x01, 0x01, 0x01, 0xc7, 0xc7, 0xc7, 0xc7	;         ########
.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;
.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;

.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;
.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;
.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;
.db 0xc7, 0xc7, 0xc7, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xc7, 0xc7, 0xc7	;       ############
.db 0xc7, 0xc7, 0x00, 0x01, 0x1d, 0x0a, 0x01, 0x1d, 0x01, 0x00, 0xc7, 0xc7	;     ####xxWW##xx####
.db 0xc7, 0xc7, 0xc7, 0x01, 0x14, 0x0a, 0x01, 0x14, 0x01, 0xc7, 0xc7, 0xc7	;       ##XXWW##XX##
.db 0xc7, 0xc7, 0xc7, 0x01, 0x14, 0x01, 0x0a, 0x14, 0x01, 0xc7, 0xc7, 0xc7	;       ##XX##WWXX##
.db 0xc7, 0xc7, 0x00, 0x01, 0x14, 0x01, 0x0a, 0x14, 0x01, 0x00, 0xc7, 0xc7	;     ####XX##WWXX####
.db 0xc7, 0xc7, 0xc7, 0x01, 0x0a, 0x01, 0x01, 0x0a, 0x01, 0xc7, 0xc7, 0xc7	;       ##WW####WW##
.db 0xc7, 0xc7, 0xc7, 0xc7, 0x01, 0x01, 0x01, 0x01, 0xc7, 0xc7, 0xc7, 0xc7	;         ########
.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;
.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;

.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;
.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;
.db 0xc7, 0xc7, 0xc7, 0xc7, 0x01, 0x01, 0x01, 0x01, 0xc7, 0xc7, 0xc7, 0xc7	;         ########
.db 0xc7, 0xc7, 0xc7, 0x01, 0x1d, 0x14, 0x14, 0x14, 0x01, 0xc7, 0xc7, 0xc7	;       ##xxXXXXXX##
.db 0xc7, 0xc7, 0x01, 0x1d, 0x14, 0x14, 0x0a, 0x14, 0x0a, 0x01, 0xc7, 0xc7	;     ##xxXXXXWWXXWW##
.db 0xc7, 0xc7, 0x01, 0x1d, 0x14, 0x14, 0x0a, 0x14, 0x0a, 0x01, 0xc7, 0xc7	;     ##xxXXXXWWXXWW##
.db 0xc7, 0xc7, 0xc7, 0x01, 0x14, 0x0a, 0x0a, 0x0a, 0x01, 0xc7, 0xc7, 0xc7	;       ##XXWWWWWW##
.db 0xc7, 0xc7, 0xc7, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xc7, 0xc7, 0xc7	;       ############
.db 0xc7, 0xc7, 0x01, 0x14, 0x01, 0xc7, 0xc7, 0x01, 0x14, 0x01, 0xc7, 0xc7	;     ##XX##    ##XX##
.db 0xc7, 0xc7, 0x01, 0x01, 0xc7, 0xc7, 0xc7, 0xc7, 0x01, 0x01, 0xc7, 0xc7	;     ####        ####
.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;
.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;

.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;
.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;
.db 0xc7, 0xc7, 0xc7, 0xc7, 0x0a, 0x0a, 0x0a, 0x0a, 0x0a, 0xc7, 0xc7, 0xc7	;         WWWWWWWWWW
.db 0xc7, 0xc7, 0xc7, 0x0a, 0x14, 0x14, 0x14, 0x14, 0x0a, 0x01, 0xc7, 0xc7	;       WWXXXXXXXXWW##
.db 0xc7, 0xc7, 0xc7, 0x0a, 0x0a, 0x14, 0x14, 0x0a, 0x01, 0x01, 0xc7, 0xc7	;       WWWWXXXXWW####
.db 0xc7, 0xc7, 0xc7, 0x0a, 0x1d, 0x0a, 0x0a, 0x01, 0x01, 0x01, 0xc7, 0xc7	;       WWxxWWWW######
.db 0xc7, 0xc7, 0xc7, 0x0a, 0x1d, 0x14, 0x0a, 0x01, 0x0a, 0x01, 0xc7, 0xc7	;       WWxxXXWW##WW##
.db 0xc7, 0xc7, 0xc7, 0x0a, 0x0a, 0x01, 0x01, 0x01, 0x01, 0x01, 0xc7, 0xc7	;       WWWW##########
.db 0xc7, 0xc7, 0xc7, 0x0a, 0x14, 0x14, 0x01, 0x0a, 0x01, 0x01, 0x0a, 0x0a	;       WWXXXX##WW####WWWW
.db 0xc7, 0xc7, 0xc7, 0xc7, 0x01, 0x01, 0x01, 0x01, 0x01, 0x0a, 0x0a, 0x0a	;         ##########WWWWWW
.db 0xc7, 0xc7, 0xc7, 0xc7, 0x0a, 0x0a, 0x0a, 0x0a, 0x0a, 0x0a, 0x0a, 0xc7	;         WWWWWWWWWWWWWW
.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;

.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;
.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;
.db 0xc7, 0xc7, 0xc7, 0xad, 0xad, 0xc7, 0xc7, 0xc7, 0xad, 0xad, 0xc7, 0xc7	;       ----      ----
.db 0xc7, 0xc7, 0xad, 0x64, 0x04, 0x5b, 0xc7, 0x64, 0x64, 0x64, 0x05, 0xc7	;     --~~WWxx  ~~~~~~XX
.db 0xc7, 0xad, 0x64, 0x05, 0x04, 0x04, 0x5b, 0x05, 0x64, 0x64, 0x04, 0xc7	;   --~~XXWWWWxxXX~~~~WW
.db 0xc7, 0x64, 0x64, 0x04, 0x64, 0x04, 0x64, 0x04, 0x64, 0x64, 0x5b, 0xc7	;   ~~~~WW~~WW~~WW~~~~xx
.db 0xc7, 0xc7, 0xc7, 0x64, 0x64, 0x64, 0x05, 0x64, 0x5b, 0x64, 0x5b, 0xc7	;       ~~~~~~XX~~xx~~xx
.db 0xc7, 0xc7, 0xc7, 0xc7, 0x5b, 0x05, 0x04, 0x64, 0x5b, 0x5b, 0xc7, 0xc7	;         xxXXWW~~xxxx
.db 0xc7, 0xc7, 0xc7, 0xc7, 0x5b, 0x04, 0x64, 0x64, 0x5b, 0xc7, 0xc7, 0xc7	;         xxWW~~~~xx
.db 0xc7, 0xc7, 0xc7, 0x04, 0x64, 0x04, 0x64, 0x5b, 0x5b, 0x04, 0xc7, 0xc7	;       WW~~WW~~xxxxWW
.db 0xc7, 0xc7, 0xc7, 0xc7, 0x04, 0x04, 0x04, 0x04, 0x04, 0xc7, 0xc7, 0xc7	;         WWWWWWWWWW
.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;

.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;
.db 0xc7, 0xc7, 0xc7, 0xad, 0x64, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;       --~~
.db 0xc7, 0xc7, 0xad, 0x64, 0x64, 0x5b, 0xc7, 0xc7, 0xad, 0xad, 0xc7, 0xc7	;     --~~~~xx    ----
.db 0xc7, 0xc7, 0x64, 0x64, 0x64, 0x5b, 0x61, 0x64, 0x64, 0x64, 0x64, 0xc7	;     ~~~~~~xxXX~~~~~~~~
.db 0xc7, 0xc7, 0xc7, 0x64, 0x64, 0x64, 0x5b, 0x64, 0x64, 0x59, 0x59, 0x59	;       ~~~~~~xx~~~~XXXXXX
.db 0xc7, 0xc7, 0xc7, 0xc7, 0x64, 0x64, 0x64, 0x59, 0x59, 0x59, 0x5b, 0x58	;         ~~~~~~XXXXXXxxWW
.db 0xc7, 0xc7, 0xc7, 0x59, 0x64, 0x64, 0x59, 0x58, 0x5b, 0x59, 0xc7, 0x58	;       XX~~~~XXWWxxXX  WW
.db 0xc7, 0xc7, 0x59, 0x59, 0x59, 0x59, 0x58, 0x5b, 0xc7, 0x58, 0xc7, 0x58	;     XXXXXXXXWWxx  WW  WW
.db 0xc7, 0xc7, 0x64, 0x64, 0x59, 0x58, 0x5b, 0xc7, 0xc7, 0x58, 0xc7, 0xc7	;     ~~~~XXWWxx    WW
.db 0xc7, 0x58, 0x64, 0x64, 0x58, 0x58, 0x5b, 0x58, 0xc7, 0xc7, 0xc7, 0xc7	;   WW~~~~WWWWxxWW
.db 0xc7, 0xc7, 0x58, 0x58, 0x58, 0x58, 0x58, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;     WWWWWWWWWW
.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;

.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;
.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;
.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;
.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;
.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;
.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;
.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;
.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;
.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;
.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;
.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;
.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;

.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;
.db 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01	; ########################
.db 0x01, 0x15, 0x15, 0x15, 0x15, 0x15, 0x14, 0x14, 0x14, 0x14, 0x0a, 0x01	; ##xxxxxxxxxxXXXXXXXXWW##
.db 0x01, 0x14, 0x15, 0x14, 0x14, 0x14, 0x14, 0x14, 0x0a, 0x0a, 0x0a, 0x01	; ##XXxxXXXXXXXXXXWWWWWW##
.db 0x01, 0x15, 0x15, 0x15, 0x14, 0x14, 0x14, 0x14, 0x14, 0x14, 0x0a, 0x01	; ##xxxxxxXXXXXXXXXXXXWW##
.db 0x01, 0x15, 0x14, 0x14, 0x14, 0x14, 0x14, 0x14, 0x14, 0x0a, 0x0a, 0x01	; ##xxXXXXXXXXXXXXXXWWWW##
.db 0x01, 0x14, 0x14, 0x14, 0x14, 0x14, 0x0a, 0x0a, 0x0a, 0x0a, 0x0a, 0x01	; ##XXXXXXXXXXWWWWWWWWWW##
.db 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01	; ########################
.db 0x01, 0x0a, 0x0a, 0x0a, 0x01, 0xc7, 0xc7, 0xc7, 0xc7, 0x01, 0x0a, 0x01	; ##WWWWWW##        ##WW##
.db 0x01, 0x0a, 0x01, 0x0a, 0x01, 0xc7, 0xc7, 0xc7, 0xc7, 0x01, 0x0a, 0x01	; ##WW##WW##        ##WW##
.db 0x01, 0x0a, 0x0a, 0x0a, 0x01, 0xc7, 0xc7, 0xc7, 0xc7, 0x01, 0x0a, 0x01	; ##WWWWWW##        ##WW##
.db 0x01, 0x01, 0x01, 0x01, 0x01, 0xc7, 0xc7, 0xc7, 0xc7, 0x01, 0x01, 0x01	; ##########        ######

.db 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;
.db 0xc7, 0xc7, 0xc7, 0xc7, 0x59, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;         XX
.db 0xc7, 0xc7, 0xc7, 0x59, 0x7b, 0x59, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;       XX--XX
.db 0xc7, 0xc7, 0x59, 0x7b, 0x71, 0x69, 0x59, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;     XX--xxxxXX
.db 0xc7, 0xc7, 0x59, 0x59, 0x69, 0x69, 0x51, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7	;     XXXXxxxxWW
.db 0xc7, 0xc7, 0x59, 0x69, 0x59, 0x61, 0x51, 0xc7, 0x59, 0x59, 0x59, 0xc7	;     XXxxXXXXWW  XXXXXX
.db 0xc7, 0x59, 0x59, 0x69, 0x61, 0x69, 0x59, 0x59, 0x7b, 0x69, 0x59, 0xc7	;   XXXXxxXXxxXXXX--xxXX
.db 0x59, 0x7b, 0x59, 0x69, 0x59, 0x69, 0x59, 0x69, 0x71, 0x61, 0x51, 0xc7	; XX--XXxxXXxxXXxxxxXXWW
.db 0x59, 0x69, 0x51, 0x59, 0x61, 0x69, 0x7b, 0x71, 0x61, 0x51, 0xc7, 0xc7	; XXxxWWXXXXxx--xxXXWW
.db 0xc7, 0x59, 0x71, 0x51, 0x59, 0x51, 0x61, 0x61, 0x51, 0x61, 0x59, 0xc7	;   XXxxWWXXWWXXXXWWXXXX
.db 0xc7, 0xc7, 0x59, 0x61, 0x51, 0x61, 0x51, 0x51, 0x69, 0x61, 0x51, 0xc7	;     XXXXWWXXWWWWxxXXWW
.db 0xc7, 0xc7, 0xc7, 0x51, 0x51, 0x59, 0xc7, 0xc7, 0x51, 0x51, 0xc7, 0xc7	;       WWWWXX    WWWW

.db 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01	; ########################
.db 0x01, 0x14, 0x14, 0x14, 0x14, 0x14, 0x14, 0x14, 0x14, 0x14, 0x14, 0x01	; ##XXXXXXXXXXXXXXXXXXXX##
.db 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01	; ########################
.db 0x01, 0x14, 0x01, 0x15, 0x14, 0x01, 0x15, 0x14, 0x0a, 0x01, 0x14, 0x01	; ##XX##xxXX##xxXXWW##XX##
.db 0x01, 0x14, 0x01, 0x15, 0x14, 0x01, 0x15, 0x14, 0x0a, 0x01, 0x14, 0x01	; ##XX##xxXX##xxXXWW##XX##
.db 0x01, 0x14, 0x01, 0x15, 0x14, 0x01, 0x15, 0x14, 0x0a, 0x01, 0x14, 0x01	; ##XX##xxXX##xxXXWW##XX##
.db 0x01, 0x14, 0x01, 0x15, 0x14, 0x01, 0x15, 0x14, 0x52, 0x52, 0x14, 0x01	; ##XX##xxXX##xxXXXXXXXX##
.db 0x01, 0x14, 0x01, 0x15, 0x14, 0x01, 0x15, 0x14, 0x0a, 0x01, 0x14, 0x01	; ##XX##xxXX##xxXXWW##XX##
.db 0x01, 0x14, 0x01, 0x15, 0x14, 0x01, 0x15, 0x14, 0x0a, 0x01, 0x14, 0x01	; ##XX##xxXX##xxXXWW##XX##
.db 0x01, 0x14, 0x01, 0x15, 0x14, 0x01, 0x15, 0x14, 0x0a, 0x01, 0x14, 0x01	; ##XX##xxXX##xxXXWW##XX##
.db 0x01, 0x14, 0x01, 0x14, 0x0a, 0x01, 0x14, 0x0a, 0x0a, 0x01, 0x14, 0x01	; ##XX##XXWW##XXWWWW##XX##
.db 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01	; ########################

.db 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01	; ########################
.db 0x01, 0x14, 0x14, 0x14, 0x14, 0x14, 0x14, 0x14, 0x14, 0x14, 0x14, 0x01	; ##XXXXXXXXXXXXXXXXXXXX##
.db 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01	; ########################
.db 0x01, 0x14, 0x01, 0x0b, 0x01, 0x0a, 0x01, 0xc7, 0xc7, 0x01, 0x14, 0x01	; ##XX##WW##WW##    ##XX##
.db 0x01, 0x14, 0x01, 0x0b, 0x01, 0x0a, 0x01, 0xc7, 0xc7, 0x01, 0x14, 0x01	; ##XX##WW##WW##    ##XX##
.db 0x01, 0x14, 0x01, 0x0b, 0x01, 0x0a, 0x01, 0xc7, 0xc7, 0x01, 0x14, 0x01	; ##XX##WW##WW##    ##XX##
.db 0x01, 0x14, 0x01, 0x0b, 0x01, 0x0a, 0x01, 0xc7, 0xc7, 0x01, 0x14, 0x01	; ##XX##WW##WW##    ##XX##
.db 0x01, 0x14, 0x01, 0x0b, 0x01, 0x0a, 0x01, 0xc7, 0xc7, 0x01, 0x14, 0x01	; ##XX##WW##WW##    ##XX##
.db 0x01, 0x14, 0x01, 0x0b, 0x01, 0x01, 0xc7, 0xc7, 0xc7, 0x01, 0x14, 0x01	; ##XX##WW####      ##XX##
.db 0x01, 0x14, 0x01, 0x0b, 0x01, 0xc7, 0xc7, 0xc7, 0xc7, 0x01, 0x14, 0x01	; ##XX##WW##        ##XX##
.db 0x01, 0x14, 0x01, 0x01, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x01, 0x14, 0x01	; ##XX####          ##XX##
.db 0x01, 0x01, 0x01, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0xc7, 0x01, 0x01, 0x01	; ######            ######

.db 0xc7, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xc7	;   ####################
.db 0xc7, 0x01, 0x14, 0x01, 0x14, 0x14, 0x14, 0x14, 0x01, 0x14, 0x01, 0xc7	;   ##XX##XXXXXXXX##XX##
.db 0xc7, 0x01, 0x14, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x14, 0x01, 0xc7	;   ##XX############XX##
.db 0xc7, 0x01, 0x14, 0x01, 0xc7, 0xc7, 0xc7, 0xc7, 0x01, 0x14, 0x01, 0xc7	;   ##XX##        ##XX##
.db 0xc7, 0x01, 0x0b, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x0b, 0x01, 0xc7	;   ##WW############WW##
.db 0xc7, 0x01, 0x0b, 0x01, 0x0b, 0x0b, 0x0b, 0x0b, 0x01, 0x0b, 0x01, 0xc7	;   ##WW##WWWWWWWW##WW##
.db 0xc7, 0x01, 0x0b, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x0b, 0x01, 0xc7	;   ##WW############WW##
.db 0xc7, 0x01, 0x0b, 0x01, 0xc7, 0xc7, 0xc7, 0xc7, 0x01, 0x0b, 0x01, 0xc7	;   ##WW##        ##WW##
.db 0xc7, 0x01, 0x0a, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x0a, 0x01, 0xc7	;   ##WW############WW##
.db 0xc7, 0x01, 0x0a, 0x01, 0x0a, 0x0a, 0x0a, 0x0a, 0x01, 0x0a, 0x01, 0xc7	;   ##WW##WWWWWWWW##WW##
.db 0xc7, 0x01, 0x0a, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x0a, 0x01, 0xc7	;   ##WW############WW##
.db 0xc7, 0x01, 0x01, 0x01, 0xc7, 0xc7, 0xc7, 0xc7, 0x01, 0x01, 0x01, 0xc7	;   ######        ######
