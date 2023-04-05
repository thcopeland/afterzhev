; Sound effects are short, non-repeating bits of audio that are triggered when
; something happens in the game. They interrupt music playing on channel 1, but
; generally not other effects.
;
; Sound effects are referenced by a quad-byte offset from sound_effects, so the
; total number of notes in all sound effects must be at most 256.
;
; Note format
;   [wave:2][fade:1][duration:5] - if zero, end of effect (1 byte)
;   volume - should generally be <= 127 (1 byte)
;   dphase - controls pitch for non-noise waveforms (2 bytes)

.equ WAVE_SAWTOOTH = (0<<6)
.equ WAVE_NOISE = (1<<6)
.equ WAVE_SQUARE50 = (2<<6)
.equ WAVE_SQUARE75 = (3<<6)

.equ SFX_FADE = (1<<5)

.macro SFX_NOTE ; waveform, volume, dphase
    .db @0, @1, low(@2), high(@2)
.endm

.macro SFX_SILENCE ; duration
    SFX_NOTE WAVE_SAWTOOTH|@0, 0, 0
.endm

.macro SFX_END
    SFX_NOTE 0, 0, 0, 0
.endm

sound_effects:
sfx_null:
    SFX_END
sfx_confirm:
    ; SFX_NOTE WAVE_SQUARE50|15, 64, NOTE_A2
    ; SFX_NOTE WAVE_SQUARE50|15, 64, NOTE_A3
    ; SFX_NOTE WAVE_SQUARE50|15, 64, NOTE_A4
    ; SFX_NOTE WAVE_SQUARE50|15, 64, NOTE_A5
    ; SFX_NOTE WAVE_NOISE|1, 64, 0
    ; SFX_SILENCE 1
    ; SFX_NOTE WAVE_NOISE|1, 64, 0
    ; SFX_SILENCE 1
    ; SFX_NOTE WAVE_NOISE|1, 64, 0
    ; SFX_SILENCE 1
    ; SFX_NOTE WAVE_NOISE|31, 64, 0
    SFX_END
sfx_fail:

sfx_pickup:

sfx_drop:

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
