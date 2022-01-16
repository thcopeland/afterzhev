; quickly divide the given 8-bit unsigned value by 10. See "Jones on reciprocal
; multiplication" (https://homepage.divms.uiowa.edu/~jones/bcd/divide.html).
; The only argument constraint is that dividend != tmp
.macro div10u ; dividend, result, tmp
    ldi @2, 0xcd
    mul @0, @2
    mov @1, r1
    clr r1
    lsr @1
    lsr @1
    lsr @1
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
