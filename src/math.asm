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
