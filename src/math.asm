; The division/modulus subroutines use reciprocal multiplication, see
; https://homepage.divms.uiowa.edu/~jones/bcd/divide.html.

.macro div10u ; dividend, result, tmp
    ldi @2, 0xcd
    mul @0, @2
    mov @1, r1
    clr r1
    lsr @1
    lsr @1
    lsr @1
.endm

.macro divmod10u ; dividend, result, remainder
    div10u @0, @1, @2
    ldi @2, 10
    mul @2, @1
    mov @2, @0
    sub @2, r0
    clr r1
.endm

.macro div12u ; dividend, result
    ldi @1, 0xab
    mul @0, @1
    mov @1, r1
    clr r1
    lsr @1
    lsr @1
    lsr @1
.endm

.macro divmod12u ; dividend, result, remainder
    div12u @0, @1
    mov @2, @0
    ldi @0, 12
    mul @0, @1
    sub @2, r0
    clr r1
.endm

.macro mulw ; a1:a2, b1:b2, res1:res2, res3:res4
    mul @1, @3
    movw @6, r0
    mul @0, @2
    movw @4, r0
    mul @1, @2
    add @5, r0
    adc @6, r1
    clr r1
    adc @7, r1
    mul @0, @3
    add @5, r0
    adc @6, r1
    clr r1
    adc @7, r1
.endm

.macro divw10u ; d1:d2, q1:q2, tmp1:tmp2, tmp3:tmp4
    ldi @6, 0xcd
    ldi @7, 0xcc
    mulw @0, @1, @6, @7, @4, @5, @2, @3
    lsr @3
    ror @2
    lsr @3
    ror @2
    lsr @3
    ror @2
.endm

.macro divmodw10u ; d1:d2, q1:q2, r1:r2, tmp3:tmp4
    divw10u @0, @1, @2, @3, @4, @5, @6, @7
    ldi @4, 10
    mul @2, @4
    movw @6, r0
    mul @3, @4
    add @7, r0
    clr r1
    movw @4, @0
    sub @4, @6
    sbc @5, @7
.endm

; Generate a 16-bit pseudorandom number using the xorshift generator with triple
; 7, 9, 8.
;
; Register Usage
;   r0:r1       generated number
;   r2, r3      calculations
rand:
    lds r0, seed
    lds r1, seed+1
    ; seed ^= (seed << 7)
    movw r2, r0
    lsr r3
    ror r2
    eor r1, r2
    clr r2
    ror r2
    eor r0, r2
    ; seed ^= (seed >> 9)
    mov r2, r1
    lsr r2
    eor r0, r2
    ; seed ^= (seed << 8)
    eor r1, r0
    sts seed, r0
    sts seed+1, r1
    ret

; Divide an 8-bit unsigned value by another 8-bit unsigned value. Based on Atmel
; App Note AVR200, which is a really clever implementation.
;
; Register Usage
;   r0-r1   used, r1 set zero
;   r24     divisor/remainder (param)
;   r25     dividend/quotient (param)
divmodb:
    mov r0, r24
    ldi r24, 9
    mov r1, r24
    sub r24, r24
_dmb_1:
    rol r25
    dec r1
    brne _dmb_2
    ret
_dmb_2:
    rol r24
    sub r24, r0
    brcc _dmb_3
    add r24, r0
    clc
    rjmp _dmb_1
_dmb_3:
    sec
    rjmp _dmb_1

; Divide a 16-bit unsigned value by another 16-bit unsigned value, unrolled for
; speed. Based on Atmel App Note AVR200.
;
; Register Usage
;   r0-r1       used, r1 set zero
;   r22:r23     divisor/remainder (param)
;   r24:r25     divident/quotient (param)
divmodw:
    movw r0, r22
    clr r22
    sub r23, r23
_dmw_1:
    rol r24
    rol r25
    rol r22
    rol r23
    sub r22, r0
    sbc r23, r1
    brcc _dmw_1x
    add r22, r0
    adc r23, r1
    clc
    rjmp _dmw_2
_dmw_1x:
    sec
_dmw_2:
    rol r24
    rol r25
    rol r22
    rol r23
    sub r22, r0
    sbc r23, r1
    brcc _dmw_2x
    add r22, r0
    adc r23, r1
    clc
    rjmp _dmw_3
_dmw_2x:
    sec
_dmw_3:
    rol r24
    rol r25
    rol r22
    rol r23
    sub r22, r0
    sbc r23, r1
    brcc _dmw_3x
    add r22, r0
    adc r23, r1
    clc
    rjmp _dmw_4
_dmw_3x:
    sec
_dmw_4:
    rol r24
    rol r25
    rol r22
    rol r23
    sub r22, r0
    sbc r23, r1
    brcc _dmw_4x
    add r22, r0
    adc r23, r1
    clc
    rjmp _dmw_5
_dmw_4x:
    sec
_dmw_5:
    rol r24
    rol r25
    rol r22
    rol r23
    sub r22, r0
    sbc r23, r1
    brcc _dmw_5x
    add r22, r0
    adc r23, r1
    clc
    rjmp _dmw_6
_dmw_5x:
    sec
_dmw_6:
    rol r24
    rol r25
    rol r22
    rol r23
    sub r22, r0
    sbc r23, r1
    brcc _dmw_6x
    add r22, r0
    adc r23, r1
    clc
    rjmp _dmw_7
_dmw_6x:
    sec
_dmw_7:
    rol r24
    rol r25
    rol r22
    rol r23
    sub r22, r0
    sbc r23, r1
    brcc _dmw_7x
    add r22, r0
    adc r23, r1
    clc
    rjmp _dmw_8
_dmw_7x:
    sec
_dmw_8:
    rol r24
    rol r25
    rol r22
    rol r23
    sub r22, r0
    sbc r23, r1
    brcc _dmw_8x
    add r22, r0
    adc r23, r1
    clc
    rjmp _dmw_9
_dmw_8x:
    sec
_dmw_9:
    rol r24
    rol r25
    rol r22
    rol r23
    sub r22, r0
    sbc r23, r1
    brcc _dmw_9x
    add r22, r0
    adc r23, r1
    clc
    rjmp _dmw_10
_dmw_9x:
    sec
_dmw_10:
    rol r24
    rol r25
    rol r22
    rol r23
    sub r22, r0
    sbc r23, r1
    brcc _dmw_10x
    add r22, r0
    adc r23, r1
    clc
    rjmp _dmw_11
_dmw_10x:
    sec
_dmw_11:
    rol r24
    rol r25
    rol r22
    rol r23
    sub r22, r0
    sbc r23, r1
    brcc _dmw_11x
    add r22, r0
    adc r23, r1
    clc
    rjmp _dmw_12
_dmw_11x:
    sec
_dmw_12:
    rol r24
    rol r25
    rol r22
    rol r23
    sub r22, r0
    sbc r23, r1
    brcc _dmw_12x
    add r22, r0
    adc r23, r1
    clc
    rjmp _dmw_13
_dmw_12x:
    sec
_dmw_13:
    rol r24
    rol r25
    rol r22
    rol r23
    sub r22, r0
    sbc r23, r1
    brcc _dmw_13x
    add r22, r0
    adc r23, r1
    clc
    rjmp _dmw_14
_dmw_13x:
    sec
_dmw_14:
    rol r24
    rol r25
    rol r22
    rol r23
    sub r22, r0
    sbc r23, r1
    brcc _dmw_14x
    add r22, r0
    adc r23, r1
    clc
    rjmp _dmw_15
_dmw_14x:
    sec
_dmw_15:
    rol r24
    rol r25
    rol r22
    rol r23
    sub r22, r0
    sbc r23, r1
    brcc _dmw_15x
    add r22, r0
    adc r23, r1
    clc
    rjmp _dmw_16
_dmw_15x:
    sec
_dmw_16:
    rol r24
    rol r25
    rol r22
    rol r23
    sub r22, r0
    sbc r23, r1
    brcc _dmw_16x
    add r22, r0
    adc r23, r1
    clc
    rjmp _dmw_17
_dmw_16x:
    sec
_dmw_17:
    rol r24
    rol r25
    clr r1
    ret
