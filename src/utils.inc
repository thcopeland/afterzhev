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

; approximate one step of 0.9375 exponential decay for a signed 8 bit number
.macro decay_94p ; x, tmp1, tmp2
    mov @1, @0
    sbrc @0, 7
    neg @1
    lsr @1
    mov @2, @1
    lsr @2
    add @1, @2
    lsr @2
    add @1, @2
    lsr @2
    add @1, @2
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
