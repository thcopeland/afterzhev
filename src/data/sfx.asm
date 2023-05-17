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

.equ SFX_FADE_OUT = (1<<5)
.equ SFX_FADE_IN = (2<<5)
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
sfx_confirm:
    SFX_NOTE WAVE_SAWTOOTH|4, 64, NOTE_F5
    SFX_END
sfx_fail:

sfx_equip:
    SFX_NOTE WAVE_NOISE|2, 20, 0
    SFX_NOTE WAVE_NOISE|1, 40, 0
    SFX_END
sfx_unequip:
    SFX_NOTE WAVE_NOISE|2, 40, 0
    SFX_NOTE WAVE_NOISE|1, 20, 0
    SFX_END
sfx_pickup:

sfx_drop:
    SFX_NOTE WAVE_NOISE|2, 40, 0
    SFX_NOTE WAVE_NOISE|1, 20, 0
    SFX_NOTE WAVE_NOISE|SFX_FADE_OUT|2, 10, 0
    SFX_END
sfx_swing:

sfx_cast:

sfx_hurt1:

sfx_hurt2:

sfx_dash:

sfx_potion:

sfx_save:

sfx_death:

sfx_win:

sfx_talk1:

sfx_talk2:
