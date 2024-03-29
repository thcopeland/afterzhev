; Sound effects are short, non-repeating bits of audio that are triggered when
; something happens in the game. They interrupt music playing on channel 1, but
; generally not other effects.
;
; Sound effects are referenced by a quad-byte offset from sfx_table, so the
; total number of notes in all sound effects must be at most 256.
;
; Note format
;   [wave:1][effect:2][duration:5] - if zero, end of effect (1 byte)
;   volume - should generally be <= 127 (1 byte)
;   dphase - controls pitch for non-noise waveforms (2 bytes)

.equ WAVE_SAWTOOTH = (0<<7)
.equ WAVE_NOISE = (1<<7)

.equ SFX_FADE_IN = (1<<5)
.equ SFX_FADE_OUT = (2<<5)
.equ SFX_VIBRATO = (3<<5)

.macro SFX_NOTE ; waveform, volume, dphase
    .db @0, @1, low(@2), high(@2)
.endm

.macro SFX_SILENCE ; duration
    SFX_NOTE WAVE_SAWTOOTH|@0, 0, 0
.endm

.macro SFX_END
    SFX_NOTE 0, 0, 0, 0
.endm

sfx_table:
sfx_null:
    SFX_END
sfx_boop:
    SFX_NOTE WAVE_SAWTOOTH|3, 80, NOTE_B4
    SFX_NOTE WAVE_SAWTOOTH|2, 80, NOTE_C4
    SFX_NOTE WAVE_SAWTOOTH|SFX_FADE_OUT|2, 60, NOTE_F3
    SFX_END
sfx_fail:
    SFX_NOTE WAVE_SAWTOOTH|4, 127, NOTE_Bb2
    SFX_END
sfx_cursor:
    SFX_NOTE WAVE_SAWTOOTH|SFX_FADE_OUT|4, 64, NOTE_A3
    SFX_END
sfx_equip:
    SFX_NOTE WAVE_SAWTOOTH|2, 127, NOTE_C4
    SFX_NOTE WAVE_SAWTOOTH|SFX_FADE_OUT|4, 80, NOTE_E4
    SFX_END
sfx_unequip:
    SFX_NOTE WAVE_SAWTOOTH|2, 127, NOTE_E4
    SFX_NOTE WAVE_SAWTOOTH|SFX_FADE_OUT|4, 80, NOTE_C4
    SFX_END
sfx_potion:
    SFX_NOTE WAVE_NOISE|4, 20, 0
    SFX_NOTE WAVE_NOISE|SFX_FADE_IN|6, 20, 0
    SFX_END
sfx_pickup:
    SFX_NOTE WAVE_SAWTOOTH|4, 127, NOTE_G3
    SFX_NOTE WAVE_SAWTOOTH|SFX_FADE_OUT|16, 80, NOTE_C4
    SFX_END
sfx_drop:
    SFX_NOTE WAVE_SAWTOOTH|4, 127, NOTE_C4
    SFX_NOTE WAVE_SAWTOOTH|SFX_FADE_OUT|16, 80, NOTE_G3
    SFX_END
sfx_swing:
    SFX_NOTE WAVE_NOISE|3, 127, 0
    SFX_NOTE WAVE_NOISE|2, 96, 0
    SFX_NOTE WAVE_NOISE|2, 64, 0
    SFX_END
sfx_cast:
    SFX_NOTE WAVE_NOISE|5, 127, 0
    SFX_NOTE WAVE_NOISE|2, 100, 0
    SFX_NOTE WAVE_NOISE|2, 32, 0
    SFX_NOTE WAVE_NOISE|2, 16, 0
    SFX_NOTE WAVE_NOISE|2, 4, 0
    SFX_END
sfx_cast2: ; shorter and quieter, for NPCS
    SFX_NOTE WAVE_NOISE|SFX_FADE_OUT|4, 96, 0
    SFX_NOTE WAVE_NOISE|SFX_FADE_OUT|2, 48, 0
    SFX_NOTE WAVE_NOISE|SFX_FADE_OUT|4, 16, 0
    SFX_END
sfx_dash:
    SFX_NOTE WAVE_NOISE|2, 64, 0
    SFX_NOTE WAVE_NOISE|SFX_FADE_OUT|2, 32, 0
    SFX_NOTE WAVE_NOISE|2, 0, 0
    SFX_NOTE WAVE_NOISE|2, 64, 0
    SFX_NOTE WAVE_NOISE|SFX_FADE_OUT|2, 32, 0
    SFX_NOTE WAVE_NOISE|2, 0, 0
    SFX_NOTE WAVE_NOISE|2, 64, 0
    SFX_NOTE WAVE_NOISE|SFX_FADE_OUT|2, 32, 0
    SFX_NOTE WAVE_NOISE|2, 0, 0
    SFX_END
sfx_portal:
    SFX_NOTE WAVE_SAWTOOTH|4, 96, NOTE_Db4
    SFX_NOTE WAVE_SAWTOOTH|2, 88, NOTE_Ck4
    SFX_NOTE WAVE_SAWTOOTH|2, 80, NOTE_Cj4
    SFX_NOTE WAVE_SAWTOOTH|2, 72, NOTE_Ci4
    SFX_NOTE WAVE_SAWTOOTH|2, 64, NOTE_C4
    SFX_NOTE WAVE_SAWTOOTH|2, 56, NOTE_Ci4
    SFX_NOTE WAVE_SAWTOOTH|2, 48, NOTE_Cj4
    SFX_NOTE WAVE_SAWTOOTH|SFX_FADE_OUT|8, 40, NOTE_Ck4
    SFX_END
sfx_save:
    SFX_NOTE WAVE_NOISE|SFX_FADE_IN|16, 0, 0
    SFX_NOTE WAVE_NOISE|16, 64, 0
    SFX_NOTE WAVE_NOISE|SFX_FADE_OUT|16, 64, 0
    SFX_END
sfx_restore:

sfx_kill:
    SFX_NOTE WAVE_SAWTOOTH|SFX_VIBRATO|4, 127, NOTE_B4
    SFX_NOTE WAVE_SAWTOOTH|SFX_VIBRATO|2, 127, NOTE_Bbk4
    SFX_NOTE WAVE_SAWTOOTH|SFX_VIBRATO|1, 100, NOTE_Bbj4
    SFX_NOTE WAVE_SAWTOOTH|SFX_VIBRATO|1, 80, NOTE_Bbi4
    SFX_NOTE WAVE_SAWTOOTH|SFX_VIBRATO|1, 40, NOTE_Bb4
    SFX_NOTE WAVE_SAWTOOTH|SFX_VIBRATO|1, 20, NOTE_Bk4
    SFX_END
sfx_death:
    SFX_NOTE WAVE_NOISE|SFX_FADE_OUT|14, 100, 0
    SFX_NOTE WAVE_NOISE|14, 127, 0
    SFX_NOTE WAVE_NOISE|SFX_FADE_OUT|30, 127, 0
    SFX_NOTE WAVE_NOISE|SFX_FADE_OUT|20, 90, 0
    SFX_END
sfx_level_up:
    SFX_NOTE WAVE_SAWTOOTH|8, 100, NOTE_C4
    SFX_NOTE WAVE_SAWTOOTH|8, 100, NOTE_D4
    SFX_NOTE WAVE_SAWTOOTH|16, 100, NOTE_E4
    SFX_NOTE WAVE_SAWTOOTH|16, 100, NOTE_G4
    SFX_NOTE WAVE_SAWTOOTH|SFX_VIBRATO|31, 100, NOTE_C5
    SFX_NOTE WAVE_SAWTOOTH|SFX_FADE_OUT|24, 100, NOTE_C5
    SFX_END
sfx_win:
    SFX_NOTE WAVE_SAWTOOTH|8, 64, NOTE_Gb3
    SFX_NOTE WAVE_SAWTOOTH|8, 72, NOTE_A4
    SFX_NOTE WAVE_SAWTOOTH|8, 72, NOTE_G3
    SFX_NOTE WAVE_SAWTOOTH|8, 80, NOTE_B4
    SFX_NOTE WAVE_SAWTOOTH|16, 96, NOTE_D4
    SFX_NOTE WAVE_SAWTOOTH|SFX_FADE_OUT|24, 96, NOTE_D4
    SFX_END
sfx_talk1:
    SFX_NOTE WAVE_SAWTOOTH|8, 60, NOTE_C3
    SFX_END
sfx_talk2:
    SFX_NOTE WAVE_SAWTOOTH|8, 64, NOTE_D3
    SFX_END
sfx_talk3:
    SFX_NOTE WAVE_SAWTOOTH|8, 60, NOTE_E3
    SFX_END
sfx_talk4:
    SFX_NOTE WAVE_SAWTOOTH|8, 64, NOTE_F3
    SFX_END
sfx_talk5:
    SFX_NOTE WAVE_SAWTOOTH|8, 60, NOTE_G3
    SFX_END
sfx_talk6:
    SFX_NOTE WAVE_SAWTOOTH|8, 64, NOTE_A4
    SFX_END
sfx_talk7:
    SFX_NOTE WAVE_SAWTOOTH|8, 60, NOTE_B4
    SFX_END
sfx_talk8:
    SFX_NOTE WAVE_SAWTOOTH|8, 64, NOTE_C3
    SFX_END
