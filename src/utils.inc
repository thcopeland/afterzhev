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
.macro cpiw ; rl, rh, imm, rtmp
    cpi @0, low(@2)
    ldi @3, high(@2)
    cpc @1, @3
.endm
