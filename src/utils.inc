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

; Split a 8 bit register into two unsigned 4 bit values
; The high value is placed in dst, the low value remains in src
.macro splt ; src, dst
    mov @1, @0
    swap @1
    andi @0, 0x0f
    andi @1, 0x0f
.endm

; Split a 8 bit register into two signed 4 bit values
; The high value is placed in dst, the low value remains in src
.macro splts ; src, dst
    splt @0, @1
    sbrc @0, 3
    ori @0, 0xf0
    sbrc @1, 3
    ori @1, 0xf0
.endm

; add without signed overflow
.macro adnv ; r1, r2
    add @0, @1
    brvc _adnv_done_%
    ldi @0, 127
    sbrc @1, 7
    com @0
_adnv_done_%:
.endm

; subtract without signed overflow
.macro sbnv ; r1, r2
    sub @0, @1
    brvc _adnv_done_%
    ldi @0, 127
    sbrs @1, 7
    com @0
_adnv_done_%:
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

; peform a single iteration of an iterative modulo operation (mod K) for
; signed numbers
.macro qmod ; low, high, K
_ck_test_undeflow_%:
    cpi @0, 0
    brge _ck_test_overflow_%
    subi @0, -@2
    dec @1
    rjmp _ck_end_%
_ck_test_overflow_%:
    cpi @0, @2
    brlo _ck_end_%
    subi @0, @2
    inc @1
_ck_end_%:
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

; for positive values, multiply by 0.95. For negative values, multiply the (positive)
; magnitude by 0.95, keeping the sign. This is not pure multiplication, as it
; is symmetric about x=0. This symmetry allows us to decay positive and negative
; velocities identically.
.macro decay_95p ; x, tmp, tmp2
    mov @1, @0
    sbrc @0, 7
    neg @1
    ldi @2, 0xf4 ; 0xf4/0xff ~~ 0.95
    mul @1, @2
    mov @1, r1
    clr r1
    sbrc @0, 7
    neg @1
    mov @0, @1
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

.ifdef DEV
.macro display_byte ; r, offset
    ldi ZL, low(framebuffer+@1)
    ldi ZH, high(framebuffer+@1)
    ldi r18, 0xff
    ldi r19, 8
_db_lp_%:
    st Z, r1
    sbrc @0, 0
    st Z, r18
    adiw ZL, 1
    lsr @0
    dec r19
    brne _db_lp_%
.endm
.endif
