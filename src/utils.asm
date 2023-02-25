; write an immediate to the given RAM address
; clobbers r18
.macro sti ; k, I
    ldi r18, @1
    sts @0, r18
.endm

; write an immediate word to the given RAM address
; clobbers r18 and r19
.macro stiw ; k, I
    ldi r18, low(@1)
    ldi r19, high(@1)
    sts @0+1, r19
    sts @0, r18
.endm

; compare an immediate word with the given registers
; rtmp can be rl
.macro cpiw ; rl, rh, I, rtmp
    cpi @0, low(@2)
    ldi @3, high(@2)
    cpc @1, @3
.endm

; sign extend a register into another
.macro ext ; low, high
    cpi @0, 128
    sbc @1, @1
    com @1
.endm

; add without signed overflow
.macro adnv ; r1, r2
    add @0, @1
    brvc _adnv_done_%
    ldi @0, 127
    sbrc @1, 7
    ldi @0, -128
_adnv_done_%:
.endm

; subtract without signed overflow
.macro sbnv ; r1, r2
    sub @0, @1
    brvc _sbnv_done_%
    ldi @0, 127
    sbrs @1, 7
    ldi @0, -128
_sbnv_done_%:
.endm

; add without signed overflow
.macro adnvi ; r1, imm
    subi @0, low(-(@1))
    brvc _adnvi_done_%
    .if (@1 & 0x80)
    ldi @0, -128
    .else
    ldi @0, 127
    .endif
_adnvi_done_%:
.endm

; subtract without signed overflow
.macro sbnvi ; r1, imm
    subi @0, @1
    brvc _sbnvi_done_%
    .if (@1 & 0x80)
    ldi @0, 127
    .else
    ldi @0, -128
    .endif
_sbnvi_done_%:
.endm

; read the nth bit of a register (the result is placed in the register). Only the
; last three bits of n are considered. The Z flag is set appropriately.
.macro nbit ; r, n
    andi @1, 7
    breq _nbit_end_%
_nbit_lp_%:
    lsr @0
    dec @1
    brne _nbit_lp_%
_nbit_end_%:
    andi @0, 1
.endm

; multiply the register by the given power of 2.
.macro mpow2 ; r, n
    andi @1, 7
    breq _mpow2_end_%
_mpow2_lp_%:
    lsl @0
    dec @1
    brne _mpow2_lp_%
_mpow2_end_%:
.endm

; clamp a signed value to the given range
.macro clampi ; r, min, max
_ci_le_%:
    cpi @0, @1
    brge _ci_ge_%
    ldi @0, @1
_ci_ge_%:
    cpi @0, @2
    brlt _ci_end_%
    ldi @0, @2
_ci_end_%:
.endm

; for positive values, multiply by 0.9. For negative values, multiply the (positive)
; magnitude by 0.9, keeping the sign. This is not pure multiplication, as it
; is symmetric about x=0. This symmetry allows us to decay positive and negative
; velocities identically.
.macro decay_90p ; x, tmp, tmp2
    mov @1, @0
    sbrc @0, 7
    neg @1
    ldi @2, 0xe6 ; 0xe6/0xff ~~ 0.9
    mul @1, @2
    mov @1, r1
    clr r1
    sbrc @0, 7
    neg @1
    mov @0, @1
.endm

; Perform an accurate B2G3R3 color fade. Unlike the shifting approximations I've
; used in other places, this supports all 8 levels of brightness. It's also much
; slower.
.macro fade_color ; color, tmp1, tmp2, fade
    mov @1, @0
    mov @2, @0
    andi @0, 0x07
    andi @1, 0x38
_fc_fade_red_%:
    sub @0, @3
    brsh _fc_fade_green_%
    clr @0
_fc_fade_green_%:
    lsl @3
    lsl @3
    lsl @3
    sub @1, @3
    brsh _fc_fade_blue_%
    clr @1
_fc_fade_blue_%:
    lsl @3
    sub @2, @3
    brlo _fc_clear_blue_%
    sub @2, @3
    brsh _fc_combine_channels_%
_fc_clear_blue_%:
    clr @2
_fc_combine_channels_%:
    andi @2, 0xc0
    or @0, @1
    or @0, @2
.endm

; Perform an accurate B2G3R3 color fade with an immediate fade amount.
.macro fade_color_imm ; color, tmp1, tmp2, fade
    mov @1, @0
    mov @2, @0
    andi @0, 0x07
    andi @1, 0x38
_fc_fade_red_%:
    subi @0, @3
    brsh _fc_fade_green_%
    clr @0
_fc_fade_green_%:
    subi @1, low(@3 << 3)
    brsh _fc_fade_blue_%
    clr @1
_fc_fade_blue_%:
    .if (@3 << 5) > 255
        clr @2
    .else
        subi @2, low(@3 << 5)
        brsh _fc_combine_channels_%
        clr @2
    .endif
_fc_combine_channels_%:
    andi @2, 0xc0
    or @0, @1
    or @0, @2
.endm

.macro DEBUG ; reg
    .dw 0x03e0 | (@0 & 0x1f)
.endm

; Calculate the manhattan distance from the player to the given coordinates.
; Only the first two given registers are changed, the distance is placed in the
; second.
.macro distance_between ; x1, y2, x2, y2
    sub @0, @2
    brsh _db_1_%
    neg @0
_db_1_%:
    sub @1, @3
    brsh _db_2_%
    neg @1
_db_2_%:
    add @1, @0
    brcc _db_3_%
    ser @1
_db_3_%:
.endm

; Set a small section of memory to a fixed value. Not really efficient.
.macro memset ; base addr, value, size
    ldi YL, low(@0)
    ldi YH, high(@0)
    ldi r24, @1
    ldi r25, @2
_cm_%:
    st Y+, r24
    dec r25
    brne _cm_%
.endm

; rapidly write 12 pixels to the given port
; clobbers r0
.macro write_12_pixels ; port, X|Y|Z
    ld r0, @1+
    out @0, r0
    ld r0, @1+
    out @0, r0
    ld r0, @1+
    out @0, r0
    ld r0, @1+
    out @0, r0
    ld r0, @1+
    out @0, r0
    ld r0, @1+
    out @0, r0
    ld r0, @1+
    out @0, r0
    ld r0, @1+
    out @0, r0
    ld r0, @1+
    out @0, r0
    ld r0, @1+
    out @0, r0
    ld r0, @1+
    out @0, r0
    ld r0, @1+
    out @0, r0
.endm
