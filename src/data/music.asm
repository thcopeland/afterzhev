; Music is dual-channel, but both tracks are played independently. This makes
; entering and playing the music straightforward, but it also means that if one
; track is paused (for example to play a sound effect) it'll be out of sync if
; resumed. This can be avoided by not playing music and sound effects at the
; same time. Not ideal, but the music system isn't good enough that you'd want
; to listen to it much anyway.
;
; Note format (4 bytes)
;   wave (1 byte)
;   volume (1 byte)
;   dphase (2 bytes)
;
; If the first byte is zero, then it marks the end of a track. The next track is
; then chosen at random from the three given options.
;
; End note format (8 bytes)
;   zero (2 bytes)
;   next music 1 - 50% chance (2 bytes)
;   next music 2 - 25% chance (2 bytes)
;   next music 3 - 25% chance (2 bytes)

.macro MUSIC_NOTE ; duration, volume, dphase
    .db @0, @1, low(@2), high(@2)
.endm

.macro TRACK_END ; next 1, next 2, next 3
    .dw 0, (2*@0)&0xffff, (2*@1)&0xffff, (2*@2)&0xffff
.endm

.equ MUSIC_FADE_IN = (1<<5)
.equ MUSIC_FADE_OUT = (2<<5)
.equ MUSIC_VIBRATO = (3<<5)

music_table:
music_null:
    TRACK_END music_null, music_null, music_null
music_start_channel_1:
    MUSIC_NOTE 30, 32, NOTE_A4
    MUSIC_NOTE 30, 32, NOTE_A4
    MUSIC_NOTE MUSIC_FADE_OUT|12, 32, NOTE_A4

    MUSIC_NOTE 30, 24, NOTE_D3
    MUSIC_NOTE 30, 24, NOTE_D3
    MUSIC_NOTE MUSIC_FADE_OUT|12, 24, NOTE_D3

    MUSIC_NOTE 30, 32, NOTE_Gb3
    MUSIC_NOTE 30, 32, NOTE_Gb3
    MUSIC_NOTE MUSIC_FADE_OUT|12, 32, NOTE_Gb3

    MUSIC_NOTE 30, 24, NOTE_A3
    MUSIC_NOTE 30, 24, NOTE_A3
    MUSIC_NOTE MUSIC_FADE_OUT|12, 24, NOTE_A3
    TRACK_END music_start_channel_1, music_start_channel_1, music_start_channel_1
music_start_channel_2:
    MUSIC_NOTE 22, 64, NOTE_D2
    MUSIC_NOTE 14, 64, NOTE_D3
    MUSIC_NOTE 22, 64, NOTE_A3
    MUSIC_NOTE 14, 64, NOTE_D3

    MUSIC_NOTE 1, 0, 0

    MUSIC_NOTE 22, 64, NOTE_D2
    MUSIC_NOTE 14, 64, NOTE_D3
    MUSIC_NOTE 22, 64, NOTE_A3
    MUSIC_NOTE 14, 64, NOTE_D3

    MUSIC_NOTE 1, 0, 0

    MUSIC_NOTE 22, 64, NOTE_D2
    MUSIC_NOTE 14, 64, NOTE_D3
    MUSIC_NOTE 22, 64, NOTE_A3
    MUSIC_NOTE 14, 64, NOTE_D3

    MUSIC_NOTE 1, 0, 0

    MUSIC_NOTE 22, 64, NOTE_D2
    MUSIC_NOTE 14, 64, NOTE_D3
    MUSIC_NOTE 22, 64, NOTE_A3
    MUSIC_NOTE 14, 64, NOTE_D3

    MUSIC_NOTE 1, 0, 0

    TRACK_END music_start_channel_2, music_start_channel_2, music_start_channel_2
