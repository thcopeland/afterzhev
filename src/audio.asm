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
; 0 - no effect, 1 - fade in, 2 - fade out, 3 - vibrato.
;
; Register Usage
;   r22-r25     calculations
update_audio_channels:
    lds r24, channel1_wave
    mov r25, r24
    andi r25, 0x60
    breq _uac_channel1_step
    cpi r25, 0x60
    brne _uac_channel1_fade
_uac_channel1_vibrato:
    lds r22, channel1_dphase
    lds r23, channel1_dphase+1
    mov r20, r23
    clr r21
    lsl r20
    lds r25, clock
    sbrc r25, 2
    neg r20
    sbrc r25, 2
    com r21
    add r22, r20
    adc r23, r21
    sts channel1_dphase, r22
    sts channel1_dphase+1, r23
    rjmp _uac_channel1_step
_uac_channel1_fade:
    cpi r25, 0x020
    brne _uac_channel1_fade_out
_uac_channel1_fade_in:
    lds r25, channel1_volume
    subi r25, low(-2)
    sts channel1_volume, r25
    rjmp _uac_channel1_step
_uac_channel1_fade_out:
    lds r25, channel1_volume
    subi r25, 2
    sts channel1_volume, r25
_uac_channel1_step:
    ; lds r23, clock
    ; andi r23, 0x01
    ; brne _uac_channel_2
    mov r25, r24
    andi r24, 0xe0
    andi r25, 0x1f
    subi r25, 1
    brsh _uac_channel1_save
    sts channel1_volume, r1
    sts channel1_wave, r1
    rjmp _uac_channel_2
_uac_channel1_save:
    or r24, r25
    sts channel1_wave, r24
_uac_channel_2:
    lds r24, channel2_wave
    mov r25, r24
    andi r25, 0x60
    breq _uac_channel2_step
    cpi r25, 0x60
    brne _uac_channel2_fade
_uac_channel2_vibrato:
    lds r22, channel2_dphase
    lds r23, channel2_dphase+1
    mov r20, r23
    clr r21
    lsl r20
    lds r25, clock
    sbrc r25, 2
    neg r20
    sbrc r25, 2
    com r21
    add r22, r20
    adc r23, r21
    sts channel2_dphase, r22
    sts channel2_dphase+1, r23
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
    ; lds r23, clock
    ; andi r23, 0x01
    ; brne _uac_end
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
;   X (r26:r27)     memory pointer
;   Z (r30:r31)     flash pointer
update_sound_and_music:
    lds r25, channel1_wave
    tst r25
    brne _usam_music
_usam_test_sfx_tracks:
    ldi XL, low(sfx_track)
    ldi XH, high(sfx_track)
    ld r25, X
    tst r25
    brne _usam_sfx_pointer
    adiw XL, 1
    ld r25, X
    tst r25
    breq _usam_music
_usam_sfx_pointer:
    ldi ZL, byte3(2*sfx_table)
    out RAMPZ, ZL
    ldi ZL, low(2*sfx_table)
    ldi ZH, high(2*sfx_table)
    ldi r24, 4
    mul r24, r25
    add ZL, r0
    adc ZH, r1
    clr r1
    elpm r24, Z+
    tst r24
    breq _usam_sfx_stop
_usam_sfx_note:
    sts channel1_wave, r24
    elpm r24, Z+
    sts channel1_volume, r24
    elpm r24, Z+
    sts channel1_dphase, r24
    elpm r24, Z+
    sts channel1_dphase+1, r24
    inc r25
    st X, r25
    rjmp _usam_music
_usam_sfx_stop:
    st X, r1
_usam_music:
    lds r25, channel2_wave
    tst r25
    brne _usam_end
    ldi ZL, byte3(2*music_tracks)
    out RAMPZ, ZL
    lds ZL, music_track
    lds ZH, music_track+1
_usam_music_check:
    elpm r20, Z+
    tst r20
    brne _usam_music_channel_2
    mov r25, r2
    andi r25, 3
    breq _usam_music_next
    dec r25
_usam_music_next:
    lsl r25
    inc r25
    add ZL, r25
    adc ZH, r1
    elpm r24, Z+
    elpm r25, Z+
    sts music_track, r24
    sts music_track+1, r25
    rjmp _usam_end
_usam_music_channel_2:
    elpm r21, Z+
    elpm r22, Z+
    elpm r23, Z+
    sts channel2_wave, r20
    sts channel2_volume, r21
    sts channel2_dphase, r22
    sts channel2_dphase+1, r23
_usam_music_channel_1:
    lds r25, channel1_wave
    tst r25
    brne _usam_advance_channel_1
    elpm r20, Z+
    elpm r21, Z+
    elpm r22, Z+
    elpm r23, Z+
    sts channel1_wave, r20
    sts channel1_volume, r21
    sts channel1_dphase, r22
    sts channel1_dphase+1, r23
    rjmp _usam_save_channel_1
_usam_advance_channel_1:
    adiw ZL, 4
_usam_save_channel_1:
    sts music_track, ZL
    sts music_track+1, ZH
_usam_end:
    ret

; Only update sound effects. This is used for most of the game, since music is
; hard.
;
; Register Usage
;   r24-r25         calculations
;   Z (r30-r31)     flash pointer
update_sound_effects:
    ldi ZL, byte3(2*sfx_table)
    out RAMPZ, ZL
_use_track_1:
    lds r25, sfx_track
    tst r25
    breq _use_track_2
    lds r24, channel1_wave
    tst r24
    brne _use_track_2
    ldi ZL, low(2*sfx_table)
    ldi ZH, high(2*sfx_table)
    ldi r24, 4
    mul r24, r25
    add ZL, r0
    adc ZH, r1
    clr r1
    elpm r24, Z+
    tst r24
    breq _use_track_1_stop
    sts channel1_wave, r24
    elpm r24, Z+
    sts channel1_volume, r24
    elpm r24, Z+
    sts channel1_dphase, r24
    elpm r24, Z+
    sts channel1_dphase+1, r24
    inc r25
    sts sfx_track, r25
    rjmp _use_track_2
_use_track_1_stop:
    sts sfx_track, r1
_use_track_2:
    lds r25, sfx_track+1
    tst r25
    breq _use_end
    lds r24, channel2_wave
    tst r24
    brne _use_end
    ldi ZL, low(2*sfx_table)
    ldi ZH, high(2*sfx_table)
    ldi r24, 4
    mul r24, r25
    add ZL, r0
    adc ZH, r1
    clr r1
    elpm r24, Z+
    tst r24
    breq _use_two_sticks
    sts channel2_wave, r24
    elpm r24, Z+
    sts channel2_volume, r24
    elpm r24, Z+
    sts channel2_dphase, r24
    elpm r24, Z+
    sts channel2_dphase+1, r24
    inc r25
    sts sfx_track, r25
    rjmp _use_end
_use_two_sticks:
    sts sfx_track+1, r1
_use_end:
    ret

; If a sound effect track is free, put the given effect in the track.
;
; Register Usage
;   r0          tmp
;   r25         sound effect (parameter)
play_sound_effect:
    lds r0, sfx_track
    tst r0
    brne _pse_test_track_2
    cpse r0, r25
    sts sfx_track, r25
    ret
_pse_test_track_2:
    lds r0, sfx_track+1
    tst r0
    brne _pse_end
    cpse r0, r25
    sts sfx_track+1, r25
_pse_end:
    ret
