; Audio is done by maintaining a buffer containing AUDIO_BUFFER_SIZE unsigned
; 8-bit samples. The samples are played at a constant rate by an interrupt, so
; the buffer MUST be refilled every 50k cycles or so.
;
; Helpful Diagram
;            played             samples                 junk
;      |               ###########################                  |
;      |               |                          |                 |
; audio_buffer       r4:r5                      r6:r7    audio_buffer+AUDIO_BUFFER_SIZE
;
; Audio-only Registers
;   r4-r5       audio buffer pointer
;   r6-r7       generated audio end pointer
;   r8-r10      temporary
;   r11         unused so far

; Move all samples to the beginning of the audio buffer, so the rest can be
; completely filled. AUDIO_BUFFER_SIZE bytes will copied every time, which will
; probably read past the end of the audio buffer, because performance.
;
; Register Usage
; r25           calculations
; XL, ZL        audio ponters
reset_audio_buffer:
    ldi ZL, low(audio_buffer)
    ldi ZH, high(audio_buffer)
    in r25, SREG
    cli
    sub r6, r4
    sbc r7, r5
    add r6, ZL
    adc r7, ZH
    movw XL, r4
    movw r4, ZL
.if AUDIO_BUFFER_SIZE != 14
    .error "reset_audio_buffer assumes buffer size of 14, update to match"
.endif
    ld r0, X+
    st Z+, r0
    out SREG, r25
    ld r0, X+
    st Z+, r0
    ld r0, X+
    st Z+, r0
    ld r0, X+
    st Z+, r0
    ld r0, X+
    st Z+, r0
    ld r0, X+
    st Z+, r0
    ld r0, X+
    st Z+, r0
    ld r0, X+
    st Z+, r0
    ld r0, X+
    st Z+, r0
    ld r0, X+
    st Z+, r0
    ld r0, X+
    st Z+, r0
    ld r0, X+
    st Z+, r0
    ld r0, X+
    st Z+, r0
    ld r0, X+
    st Z+, r0
    ret

; Sample and advance both channels, and mix them together. Exits early if at the
; end of the buffer.
;
; Register Usage
;  r20-r27      calculations
;  r25          generated sample
generate_audio_sample:
    ldi r20, low(audio_buffer+AUDIO_BUFFER_SIZE)
    ldi r21, high(audio_buffer+AUDIO_BUFFER_SIZE)
    movw ZL, r6
    cp ZL, r20
    cpc ZH, r21
    brlo generate_audio_sample2
    ret
generate_audio_sample2:
    lds r24, audio_noise
_gas_channel_1:
    lds r20, channel1_volume
    lds r21, channel1_phase+1
    lds r22, channel1_wave
_gas_channel_1_check_1:
    sbrc r22, 7
    rjmp _gas_channel_1_check_3
_gas_channel_1_check_2:
    sbrc r22, 6
    rjmp _gas_channel_1_noise
_gas_channel_1_sawtooth:
    mul r20, r21
    mov r25, r1
    clr r1
    rjmp _gas_channel_1_phase
_gas_channel_1_noise:
    mov r23, r24
    mov r22, r24
    lsr r22
    eor r23, r22
    lsr r22
    swap r22
    eor r23, r22
    lsr r22
    eor r23, r22
    lsr r23
    rol r24
    mul r20, r24
    mov r25, r1
    clr r1
    rjmp _gas_channel_2 ; don't update phase for performance
_gas_channel_1_check_3:
    sbrc r22, 6
    rjmp _gas_channel_1_square_75
_gas_channel_1_square_50:
    clr r25
    cpi r21, 128
    brsh _gas_channel_1_phase
    mov r25, r20
    rjmp _gas_channel_1_phase
_gas_channel_1_square_75:
    clr r25
    cpi r21, 192
    brsh _gas_channel_1_phase
    mov r25, r20
_gas_channel_1_phase:
    lds r20, channel1_phase
    lds r21, channel1_phase+1
    lds r22, channel1_dphase
    lds r23, channel1_dphase+1
    add r20, r22
    adc r21, r23
    sts channel1_phase, r20
    sts channel1_phase+1, r21
_gas_channel_2:
    lds r20, channel2_volume
    lds r21, channel2_phase+1
    lds r22, channel2_wave
_gas_channel_2_check_1:
    sbrc r22, 7
    rjmp _gas_channel_2_check_3
_gas_channel_2_check_2:
    sbrc r22, 6
    rjmp _gas_channel_2_noise
_gas_channel_2_sawtooth:
    mul r20, r21
    mov r26, r1
    clr r1
    rjmp _gas_channel_2_phase
_gas_channel_2_noise:
    mov r23, r24
    mov r22, r24
    lsr r22
    eor r23, r22
    lsr r22
    swap r22
    eor r23, r22
    lsr r22
    eor r23, r22
    lsr r23
    rol r24
    mul r20, r24
    mov r26, r1
    clr r1
    rjmp _gas_mix_channels
_gas_channel_2_check_3:
    clr r26
    sbrc r22, 6
    rjmp _gas_channel_2_square_75
_gas_channel_2_square_50:
    cpi r21, 128
    brsh _gas_channel_2_phase
    mov r26, r20
    rjmp _gas_channel_2_phase
_gas_channel_2_square_75:
    cpi r21, 192
    brsh _gas_channel_2_phase
    mov r26, r20
_gas_channel_2_phase:
    lds r20, channel2_phase
    lds r21, channel2_phase+1
    lds r22, channel2_dphase
    lds r23, channel2_dphase+1
    add r20, r22
    adc r21, r23
    sts channel2_phase, r20
    sts channel2_phase+1, r21
_gas_mix_channels:
    add r25, r26
    brcc _gas_write_sample
    ldi r25, 0xff
_gas_write_sample:
    sts audio_noise, r24
    st Z+, r25
    ldi r25, 1
    add r6, r25
    adc r7, r1
    ret

; Reset the audio buffer and generate samples until it's full.
;
; Register Usage
;   r18             counter
;   r20             temporary
;   Z (r30:r31)     audio buffer pointer
refill_audio_buffer:
    rcall reset_audio_buffer
    movw ZL, r6
    ldi r18, low(audio_buffer+AUDIO_BUFFER_SIZE)
    ldi r19, high(audio_buffer+AUDIO_BUFFER_SIZE)
    sub r18, ZL
    sbc r19, ZH
    breq _rab_end
_rab_loop:
    rcall generate_audio_sample2
    dec r18
    brne _rab_loop
_rab_end:
    ret

; Check note duration and handle fading if enabled.
;
; Register Usage
;   r23         calculations
;   r24-r25     channel info
update_audio_channels:
    lds r25, channel1_wave
    lds r23, clock
    andi r23, 0x01
    brne _uac_channel1_fade
    mov r24, r25
    andi r25, 0xe0
    andi r24, 0x1f
    breq _uac_channel2
    dec r24
    brne _uac_channel1_save
    sts channel1_volume, r1
    sts channel1_wave, r1
    rjmp _uac_channel2
_uac_channel1_save:
    or r25, r24
    sts channel1_wave, r25
_uac_channel1_fade:
    sbrs r25, 5
    rjmp _uac_channel2
    lds r25, channel1_volume
    subi r25, 1
    brsh _uac_channel1_save2
    clr r25
_uac_channel1_save2:
    sts channel1_volume, r25
_uac_channel2:
    lds r25, channel2_wave
    lds r23, clock
    andi r23, 0x01
    brne _uac_channel2_fade
    mov r24, r25
    andi r25, 0xe0
    andi r24, 0x1f
    breq _uac_end
    dec r24
    brne _uac_channel2_save
    sts channel2_volume, r1
    sts channel2_wave, r1
    rjmp _uac_end
_uac_channel2_save:
    or r25, r24
    sts channel2_wave, r25
_uac_channel2_fade:
    sbrs r25, 5
    rjmp _uac_end
    lds r25, channel2_volume
    subi r25, 1
    brsh _uac_channel2_save2
    clr r25
_uac_channel2_save2:
    sts channel2_volume, r25
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
