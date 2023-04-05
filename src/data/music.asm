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

music_tracks:
music_null:
    MUSIC_END music_null, music_null, music_null
music_test:
    .db (2<<6)|(16), 16, low(NOTE_A3), high(NOTE_A3)
    .db (1<<6)|(16), 0, 0, 0

    .db (2<<6)|(16), 16, low(NOTE_B3), high(NOTE_B3)
    .db (1<<6)|(16), 0, 0, 0

    .db (2<<6)|(16), 16, low(NOTE_Db3), high(NOTE_Db3)
    .db (1<<6)|(16), 0, 0, 0

    .db (2<<6)|(16), 16, low(NOTE_D3), high(NOTE_D3)
    .db (1<<6)|(16), 0, 0, 0

    .db (2<<6)|(16), 16, low(NOTE_E3), high(NOTE_E3)
    .db (1<<6)|(16), 0, 0, 0

    .db (2<<6)|(16), 16, low(NOTE_F3), high(NOTE_F3)
    .db (1<<6)|(16), 0, 0, 0

    .db (2<<6)|(16), 16, low(NOTE_Ab3), high(NOTE_Ab3)
    .db (1<<6)|(16), 0, 0, 0

    MUSIC_END music_null, music_null, music_null
