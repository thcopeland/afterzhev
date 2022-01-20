; This is a 4x6 bitmap font by Brian Swetland and Robey Pointer, available at
; https://robey.lag.net/2010/01/23/tiny-monospace-font.html.
;
; Each character is stored as 17 bits prefixed by a single bit indicating whether
; to lower the entire character by one row (used for lowercase and some special
; characters).
;
; The font_character_table contains only the printable ASCII characters, and some
; special graphical characters.
font_character_table:
    .db 0x7f, 0xff
    .db 0x5b, 0x7d
    .db 0x25, 0xff
    .db 0x20, 0x82
    .db 0x43, 0x0d
    .db 0x3d, 0x5e
    .db 0x12, 0x14
    .db 0x5b, 0xff
    .db 0x6b, 0x6e
    .db 0x3b, 0x6b
    .db 0x2a, 0xbf
    .db 0x7a, 0x2f
    .db 0xff, 0xeb
    .db 0x7e, 0x3f
    .db 0x7f, 0xfd
    .db 0x6d, 0x5b
    .db 0x44, 0x91
    .db 0x53, 0x6d
    .db 0x1d, 0x58
    .db 0x1d, 0x71
    .db 0x24, 0x36
    .db 0x06, 0x71
    .db 0x46, 0x10
    .db 0x0d, 0x5b
    .db 0x04, 0x10
    .db 0x04, 0x31
    .db 0x7b, 0xef
    .db 0x7b, 0xeb
    .db 0x6a, 0xee
    .db 0x71, 0xc7
    .db 0x3b, 0xab
    .db 0x0d, 0x7d
    .db 0x54, 0x1c
    .db 0x54, 0x12
    .db 0x14, 0x51
    .db 0x46, 0xdc
    .db 0x14, 0x91
    .db 0x06, 0x18
    .db 0x06, 0x1b
    .db 0x46, 0x14
    .db 0x24, 0x12
    .db 0x0b, 0x68
    .db 0x6d, 0x95
    .db 0x24, 0x52
    .db 0x36, 0xd8
    .db 0x20, 0x12
    .db 0x20, 0x02
    .db 0x54, 0x95
    .db 0x14, 0x5b
    .db 0x54, 0x84
    .db 0x14, 0x0a
    .db 0x47, 0x71
    .db 0x0b, 0x6d
    .db 0x24, 0x94
    .db 0x24, 0xad
    .db 0x24, 0x02
    .db 0x25, 0x52
    .db 0x25, 0x6d
    .db 0x0d, 0x58
    .db 0x06, 0xd8
    .db 0x77, 0x77
    .db 0x0d, 0xb0
    .db 0x55, 0xff
    .db 0x7f, 0xf8
    .db 0x3b, 0xff
    .db 0x73, 0x10
    .db 0x32, 0x91
    .db 0x78, 0xdc
    .db 0x68, 0x94
    .db 0x78, 0x8c
    .db 0x6a, 0x2d
    .db 0xc4, 0x35
    .db 0x32, 0x92
    .db 0x5f, 0x6d
    .db 0xfd, 0x95
    .db 0x34, 0x4a
    .db 0x1b, 0x68
    .db 0x70, 0x02
    .db 0x72, 0x92
    .db 0x7a, 0x95
    .db 0x94, 0x8b
    .db 0xc4, 0xa6
    .db 0x78, 0xdb
    .db 0x78, 0x61
    .db 0x51, 0x6c
    .db 0x74, 0x94
    .db 0x74, 0x85
    .db 0x74, 0x00
    .db 0x75, 0x6a
    .db 0xa5, 0x35
    .db 0x71, 0x08
    .db 0x4a, 0xec
    .db 0x5b, 0xed
    .db 0x1b, 0xa9
    .db 0x43, 0xff
    .db 0x00, 0x00
    .db 0x72, 0x0f
