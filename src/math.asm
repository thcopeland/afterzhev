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
