; Audio is generated in 8-bit samples on the fly in the audio interrupt. This is
; somewhat more wasteful than maintaing a buffer of samples, but requires less
; memory.
;
; Audio-only Registers
;   r2:r3       noise (and source of randomness)
;   r4:r5       channel 1 phase
;   r6:r7       channel 2 phase
;   r8-r12      temporary

; Check note duration and handle fading. Four different types of effects:
; 0 - no effect, 1 - fade in, 2 - fade out, 3 - tremolo.
;
; Register Usage
;   r23-r25     calculations
update_audio_channels:
    ; TODO channel 1 as well
    lds r24, channel2_wave
    mov r25, r24
    andi r25, 0x60
    breq _uac_channel2_step
    cpi r25, 0x60
    brne _uac_channel2_fade
_uac_channel2_tremolo:
    lds r25, channel2_volume
    subi r25, low(-8)
    lds r23, clock
    sbrc r23, 2
    subi r25, 16
    sts channel2_volume, r25
    rjmp _uac_channel2_step
_uac_channel2_fade:
    cpi r25, 0x020
    brne _uac_channel2_fade_out
_uac_channel2_fade_in:
    lds r25, channel2_volume
    subi r25, low(-2)
    sts channel2_volume, r25
    rjmp _uac_channel2_step
_uac_channel2_fade_out:
    lds r25, channel2_volume
    subi r25, 2
    sts channel2_volume, r25
_uac_channel2_step:
    lds r23, clock
    andi r23, 0x01
    brne _uac_end
    mov r25, r24
    andi r24, 0xe0
    andi r25, 0x1f
    subi r25, 1
    brsh _uac_channel2_save
    sts channel2_volume, r1
    sts channel2_wave, r1
    rjmp _uac_end
_uac_channel2_save:
    or r24, r25
    sts channel2_wave, r24
_uac_end:
    ret

; Update sound effects and music, giving sound effects priority over channel 1.
;
; Register Usage
;   r20-r25         calculations
;   Z (r30:r31)     flash pointer
update_all_sound:
    lds r25, channel1_wave
    tst r25
    brne _uas_music
    lds r25, sfx_track
    tst r25
    breq _uas_music
    ldi ZL, byte3(2*sound_effects)
    out RAMPZ, ZL
    ldi ZL, low(2*sound_effects)
    ldi ZH, high(2*sound_effects)
    ldi r24, 4
    mul r24, r25
    add ZL, r0
    adc ZH, r1
    clr r1
    elpm r24, Z+
    tst r24
    breq _uas_sfx_stop
_uas_sfx_note:
    sts channel1_wave, r24
    elpm r24, Z+
    sts channel1_volume, r24
    elpm r24, Z+
    sts channel1_dphase, r24
    elpm r24, Z+
    sts channel1_dphase+1, r24
    inc r25
    sts sfx_track, r25
    rjmp _uas_music
_uas_sfx_stop:
    sts sfx_track, r1
_uas_music:
    lds r25, channel2_wave
    tst r25
    brne _uas_end
    ldi ZL, byte3(2*music_tracks)
    out RAMPZ, ZL
    lds ZL, music_track
    lds ZH, music_track+1
_uas_music_check:
    elpm r20, Z+
    tst r20
    brne _uas_music_channel_2
    lds r25, seed
    andi r25, 3
    breq _uas_music_next
    dec r25
_uas_music_next:
    lsl r25
    inc r25
    add ZL, r25
    adc ZH, r1
    elpm r24, Z+
    elpm r25, Z+
    sts music_track, r24
    sts music_track+1, r25
    rjmp _uas_end
_uas_music_channel_2:
    elpm r21, Z+
    elpm r22, Z+
    elpm r23, Z+
    sts channel2_wave, r20
    sts channel2_volume, r21
    sts channel2_dphase, r22
    sts channel2_dphase+1, r23
_uas_music_channel_1:
    lds r25, channel1_wave
    tst r25
    brne _uas_advance_channel_1
    elpm r20, Z+
    elpm r21, Z+
    elpm r22, Z+
    elpm r23, Z+
    sts channel1_wave, r20
    sts channel1_volume, r21
    sts channel1_dphase, r22
    sts channel1_dphase+1, r23
    rjmp _uas_save_channel_1
_uas_advance_channel_1:
    adiw ZL, 4
_uas_save_channel_1:
    sts music_track, ZL
    sts music_track+1, ZH
_uas_end:
    ret
