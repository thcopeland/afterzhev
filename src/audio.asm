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
    lds r21, channel1_phase
    lds r22, channel1_wave
    lds r23, channel1_dphase ; advance channel 1
    add r23, r21
    sts channel1_phase, r23
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
    rjmp _gas_channel_2
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
    rjmp _gas_channel_2
_gas_channel_1_check_3:
    sbrc r22, 6
    rjmp _gas_channel_1_square_75
_gas_channel_1_square_50:
    clr r25
    cpi r21, 64
    brsh _gas_channel_2
    mov r25, r20
    rjmp _gas_channel_2
_gas_channel_1_square_75:
    clr r25
    cpi r21, 192
    brsh _gas_channel_2
    mov r25, r20
_gas_channel_2:
    lds r20, channel2_volume
    lds r21, channel2_phase
    lds r22, channel2_wave
    lds r23, channel2_dphase
    add r23, r21
    sts channel2_phase, r23
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
    rjmp _gas_mix_channels
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
    cpi r21, 64
    brsh _gas_mix_channels
    mov r26, r20
    rjmp _gas_mix_channels
_gas_channel_2_square_75:
    cpi r21, 192
    brsh _gas_mix_channels
    mov r26, r20
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
    andi r23, 0x03
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
    subi r25, 2
    brsh _uac_channel1_save2
    clr r25
_uac_channel1_save2:
    sts channel1_volume, r25
_uac_channel2:
    lds r25, channel2_wave
    lds r23, clock
    andi r23, 0x03
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
    subi r25, 2
    brsh _uac_channel2_save2
    clr r25
_uac_channel2_save2:
    sts channel2_volume, r25
_uac_end:
    ret
