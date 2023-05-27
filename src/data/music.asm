; Music is dual-channel, but during gameplay, sound effects have priority over
; channel 1. So anything that's played from that channel should be subtle enough
; that won't be missed.
;
; The music is updated whenever the current note on channel 2 ends, so channel 1
; notes should end when channel 2 does.
;
; Like sound effects, music tracks are stored as streams of notes, except that
; here they come in pairs, one for each channel. Music tracks are referenced by
; direct pointers.
;
; Note format (8 bytes)
;   wave 2 - played from channel 2 (1 byte)
;   volume 2 (1 byte)
;   dphase 2 (2 bytes)
;   wave 1 - played from channel 1 (1 byte)
;   volume 1 (1 byte)
;   dphase 1 (2 bytes)
;
; If the first byte is zero, then it marks the end of a track. The next track is
; then chosen at random from the three given options.
;
; End note format (8 bytes)
;   zero (2 bytes)
;   next music 1 - 50% chance (2 bytes)
;   next music 2 - 25% chance (2 bytes)
;   next music 3 - 25% chance (2 bytes)

.macro MUSIC_END ; next 1, next 2, next 3
    .dw 0, (2*@0)&0xffff, (2*@1)&0xffff, (2*@2)&0xffff
.endm

.equ MUSIC_FADE_IN = (1<<5)
.equ MUSIC_FADE_OUT = (2<<5)
.equ MUSIC_VIBRATO = (3<<5)

.macro MUSIC_PAIR ; duration 1, volume 1, dphase 1, duration 2, volume 2, dphase 2
    .db @0, @1, low(@2), high(@2), @3, @4, low(@5), high(@5)
.endm

music_tracks:
music_null:
    MUSIC_END music_null, music_null, music_null
music_test:
    .db (0<<7)|(24), 127, low(NOTE_D2), high(NOTE_D2)
    .db (0<<7)|(24), 0, 0, 0

    .db (0<<7)|(8), 127, low(NOTE_E3), high(NOTE_E3)
    .db (0<<7)|(8), 0, 0, 0

    .db (0<<7)|(4), 127, low(NOTE_G3), high(NOTE_G3)
    .db (0<<7)|(4), 0, 0, 0

    .db (0<<7)|(4), 0, 0, 0
    .db (0<<7)|(4), 0, 0, 0

    .db (0<<7)|(4), 127, low(NOTE_Gb3), high(NOTE_Gb3)
    .db (0<<7)|(4), 0, 0, 0

    .db (0<<7)|(4), 0, 0, 0
    .db (0<<7)|(4), 0, 0, 0

    .db (0<<7)|(4), 127, low(NOTE_E3), high(NOTE_E3)
    .db (0<<7)|(4), 0, 0, 0

    .db (0<<7)|(4), 0, 0, 0
    .db (0<<7)|(4), 0, 0, 0

    .db (0<<7)|(4), 127, low(NOTE_C3), high(NOTE_C3)
    .db (0<<7)|(4), 0, 0, 0

    .db (0<<7)|(4), 127, low(NOTE_B3), high(NOTE_B3)
    .db (0<<7)|(4), 0, 0, 0

    .db (0<<7)|(2<<5)|(31), 127, low(NOTE_B3), high(NOTE_B3)
    .db (0<<7)|(31), 0, 0, 0

    .db (0<<7)|(24), 127, low(NOTE_B4), high(NOTE_B4)
    .db (0<<7)|(24), 0, 0, 0

    .db (0<<7)|(8), 127, low(NOTE_E3), high(NOTE_E3)
    .db (0<<7)|(8), 0, 0, 0

    .db (0<<7)|(4), 127, low(NOTE_G3), high(NOTE_G3)
    .db (0<<7)|(4), 0, 0, 0

    .db (0<<7)|(4), 0, 0, 0
    .db (0<<7)|(4), 0, 0, 0

    .db (0<<7)|(4), 127, low(NOTE_Gb3), high(NOTE_Gb3)
    .db (0<<7)|(4), 0, 0, 0

    .db (0<<7)|(4), 0, 0, 0
    .db (0<<7)|(4), 0, 0, 0

    .db (0<<7)|(4), 127, low(NOTE_E3), high(NOTE_E3)
    .db (0<<7)|(4), 0, 0, 0

    .db (0<<7)|(4), 0, 0, 0
    .db (0<<7)|(4), 0, 0, 0

    .db (0<<7)|(4), 127, low(NOTE_C4), high(NOTE_C4)
    .db (0<<7)|(4), 0, 0, 0

    .db (0<<7)|(4), 127, low(NOTE_B4), high(NOTE_B4)
    .db (0<<7)|(4), 0, 0, 0

    .db (0<<7)|(2<<5)|(31), 127, low(NOTE_B4), high(NOTE_B4)
    .db (0<<7)|(31), 0, 0, 0

    .db (0<<7)|(24), 127, low(NOTE_C4), high(NOTE_C4)
    .db (0<<7)|(24), 0, 0, 0

    .db (0<<7)|(8), 127, low(NOTE_E3), high(NOTE_E3)
    .db (0<<7)|(8), 0, 0, 0

    .db (0<<7)|(16), 127, low(NOTE_G3), high(NOTE_G3)
    .db (0<<7)|(16), 0, 0, 0

    .db (0<<7)|(8), 127, low(NOTE_Gb3), high(NOTE_Gb3)
    .db (0<<7)|(8), 0, 0, 0

    .db (0<<7)|(8), 0, 0, 0
    .db (0<<7)|(8), 0, 0, 0

    .db (0<<7)|(24), 127, low(NOTE_B4), high(NOTE_B4)
    .db (0<<7)|(24), 0, 0, 0

    .db (0<<7)|(8), 127, low(NOTE_E3), high(NOTE_E3)
    .db (0<<7)|(8), 0, 0, 0

    .db (0<<7)|(16), 127, low(NOTE_Gb3), high(NOTE_Gb3)
    .db (0<<7)|(16), 0, 0, 0

    .db (0<<7)|(8), 127, low(NOTE_E3), high(NOTE_E3)
    .db (0<<7)|(8), 0, 0, 0

    .db (0<<7)|(8), 0, 0, 0
    .db (0<<7)|(8), 0, 0, 0

    .db (0<<7)|(24), 127, low(NOTE_A4), high(NOTE_A4)
    .db (0<<7)|(24), 0, 0, 0

    .db (0<<7)|(8), 127, low(NOTE_E3), high(NOTE_E3)
    .db (0<<7)|(8), 0, 0, 0

    .db (0<<7)|(4), 127, low(NOTE_G3), high(NOTE_G3)
    .db (0<<7)|(4), 0, 0, 0

    .db (0<<7)|(4), 0, 0, 0
    .db (0<<7)|(4), 0, 0, 0

    .db (0<<7)|(4), 127, low(NOTE_Gb3), high(NOTE_Gb3)
    .db (0<<7)|(4), 0, 0, 0

    .db (0<<7)|(4), 0, 0, 0
    .db (0<<7)|(4), 0, 0, 0

    .db (0<<7)|(4), 127, low(NOTE_F3), high(NOTE_F3)
    .db (0<<7)|(4), 0, 0, 0

    .db (0<<7)|(4), 0, 0, 0
    .db (0<<7)|(4), 0, 0, 0

    .db (0<<7)|(4), 127, low(NOTE_Gb3), high(NOTE_Gb3)
    .db (0<<7)|(4), 0, 0, 0

    .db (0<<7)|(4), 127, low(NOTE_B4), high(NOTE_B4)
    .db (0<<7)|(4), 0, 0, 0

    .db (0<<7)|(2<<5)|(31), 127, low(NOTE_B4), high(NOTE_B4)
    .db (0<<7)|(31), 0, 0, 0

    MUSIC_END music_null, music_null, music_null

music_start1:
    ; MUSIC_PAIR 16, 0, 0, 8, 64, NOTE_B4
    ; MUSIC_PAIR 16, 0, 0, 16, 64, NOTE_B4
    ; MUSIC_PAIR 24, 0, 0, 24, 64, NOTE_Gb4
    ; MUSIC_PAIR 24, 0, 0, 24, 64, NOTE_Gb4
    ; MUSIC_PAIR 8, 0, 0, 8, 64, NOTE_E4
    ; MUSIC_PAIR 8, 0, 0, 8, 64, NOTE_Gb4
    ; MUSIC_PAIR 2, 0, 0, 2, 64, NOTE_D4
    ; MUSIC_PAIR 2, 0, 0, 2, 64, NOTE_E4
    ; MUSIC_PAIR 16, 0, 0, 16, 64, NOTE_D4
    ; MUSIC_PAIR 8, 0, 0, 8, 64, NOTE_Db4
    ; MUSIC_PAIR 8, 0, 0, 8, 64, NOTE_B4
    ;
    ; MUSIC_PAIR 8, 0, 0, 8, 64, NOTE_Db4
    ; MUSIC_PAIR 8, 0, 0, 8, 64, NOTE_D4
    ; MUSIC_PAIR 24, 0, 0, 24, 64, NOTE_E4
    ; MUSIC_PAIR 16, 0, 0, 16, 64, NOTE_E4
    ; MUSIC_PAIR 16, 0, 0, 16, 64, NOTE_Gb4
    ; MUSIC_PAIR 2, 0, 0, 2, 64, NOTE_Db4
    ; MUSIC_PAIR 2, 0, 0, 2, 64, NOTE_D4
    ; MUSIC_PAIR 16, 0, 0, 16, 64, NOTE_Db4

    MUSIC_PAIR 22, 0, 0, 22, 32, NOTE_D2
    MUSIC_PAIR 14, 0, 0, 14, 32, NOTE_D3
    MUSIC_PAIR 22, 0, 0, 22, 32, NOTE_A3
    MUSIC_PAIR 14, 0, 0, 14, 32, NOTE_D3

    MUSIC_PAIR 22, 0, 0, 22, 32, NOTE_D2
    MUSIC_PAIR 14, 0, 0, 14, 32, NOTE_D3
    MUSIC_PAIR 22, 0, 0, 22, 32, NOTE_A3
    MUSIC_PAIR 14, 0, 0, 14, 32, NOTE_D3

    MUSIC_PAIR 22, 0, 0, 22, 32, NOTE_D2
    MUSIC_PAIR 14, 0, 0, 14, 32, NOTE_D3
    MUSIC_PAIR 22, 0, 0, 22, 32, NOTE_A3
    MUSIC_PAIR 14, 0, 0, 14, 32, NOTE_D3

    MUSIC_PAIR 30, 0, 0, 30, 32, NOTE_A4
    MUSIC_PAIR 30, 0, 0, 30, 32, NOTE_A4
    MUSIC_PAIR 12, 0, 0, MUSIC_FADE_OUT|12, 32, NOTE_A4

    MUSIC_PAIR 30, 0, 0, 30, 24, NOTE_D3
    MUSIC_PAIR 30, 0, 0, 30, 24, NOTE_D3
    MUSIC_PAIR 12, 0, 0, MUSIC_FADE_OUT|12, 24, NOTE_D3

    MUSIC_PAIR 30, 0, 0, 30, 32, NOTE_Gb3
    MUSIC_PAIR 30, 0, 0, 30, 32, NOTE_Gb3
    MUSIC_PAIR 12, 0, 0, MUSIC_FADE_OUT|12, 32, NOTE_Gb3

    MUSIC_PAIR 30, 0, 0, 30, 24, NOTE_A3
    MUSIC_PAIR 30, 0, 0, 30, 24, NOTE_A3
    MUSIC_PAIR 12, 0, 0, MUSIC_FADE_OUT|12, 24, NOTE_A3

    MUSIC_END music_start1, music_start1, music_start1
