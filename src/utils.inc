; write an immediate word to the given RAM address
; clobbers r18 and r19
.macro stiw
    ldi r18, low(@1)
    ldi r19, high(@1)
    sts @0+1, r19
    sts @0, r18
.endm
