; Write an entire tile or a horizontal slice of a tile to a framebuffer. This is
; slightly faster but less flexible than render_partial_tile.
;
; Register Usage
;   r0, r1          multiplication
;   r21             slice min y (param)
;   r22             slice height (param)
;   r23             tile number (param)
;   X (r26:r27)     framebuffer pointer (param)
;   Z (r30:r31)     tile pointer
render_whole_tile:
    ldi r20, TILE_MEMSIZE
    mul r23, r20
    movw ZL, r0
    ldi r20, TILE_WIDTH
    mul r21, r20
    add ZL, r0
    adc ZH, r1
    clr r1
    subi ZL, low(-(tile_table*2+TILE_DATA_OFFSET))  ; *2 to convert word address->byte address
    sbci ZH, high(-(tile_table*2+TILE_DATA_OFFSET))
    inc r22
    rjmp _rwt_loop_chk
_rwt_loop:
    lpm r0, Z+
    st X+, r0
    lpm r0, Z+
    st X+, r0
    lpm r0, Z+
    st X+, r0
    lpm r0, Z+
    st X+, r0
    lpm r0, Z+
    st X+, r0
    lpm r0, Z+
    st X+, r0
    lpm r0, Z+
    st X+, r0
    lpm r0, Z+
    st X+, r0
    lpm r0, Z+
    st X+, r0
    lpm r0, Z+
    st X+, r0
    lpm r0, Z+
    st X+, r0
    lpm r0, Z+
    st X+, r0
    subi XL, low(-(DISPLAY_WIDTH - TILE_WIDTH))
    sbci XH, high(-(DISPLAY_WIDTH - TILE_WIDTH))
_rwt_loop_chk:
    dec r22
    brne _rwt_loop
    ret

; Render any rectangular section of a tile.
;
; Register Usage
;   r0, r1          multiplication
;   r20             scratch register
;   r21             slice min y (param) and reused for buffer pointer increment
;   r22             slice height (param)
;   r23             slice min x (param) and reused for tile pointer increment
;   r24             slice width (param) and reused for jump low
;   r25             tile number (param) and reused for jump high
;   X (r26:r27)     framebuffer pointer (param)
;   Z (r30:r31)     tile pointer
render_partial_tile:
    ldi r20, TILE_MEMSIZE
    mul r25, r20
    movw ZL, r0
    ldi r20, TILE_WIDTH
    mul r21, r20
    add ZL, r0
    adc ZH, r1
    clr r1
    add ZL, r23
    adc ZH, r1
    subi ZL, low(-(tile_table*2+TILE_DATA_OFFSET))
    sbci ZH, high(-(tile_table*2+TILE_DATA_OFFSET))
    ldi r23, TILE_WIDTH
    sub r23, r24
    ldi r21, DISPLAY_WIDTH
    sub r21, r24
    ldi r24, low(_rpt_loop)
    ldi r25, high(_rpt_loop)
    add r24, r23
    adc r25, r1
    add r24, r23
    adc r25, r1
    inc r22
    rjmp _rpt_loop_chk
_rpt_loop:
    lpm r0, Z+
    st X+, r0
    lpm r0, Z+
    st X+, r0
    lpm r0, Z+
    st X+, r0
    lpm r0, Z+
    st X+, r0
    lpm r0, Z+
    st X+, r0
    lpm r0, Z+
    st X+, r0
    lpm r0, Z+
    st X+, r0
    lpm r0, Z+
    st X+, r0
    lpm r0, Z+
    st X+, r0
    lpm r0, Z+
    st X+, r0
    lpm r0, Z+
    st X+, r0
    lpm r0, Z+
    st X+, r0
    add ZL, r23
    adc ZH, r1
    add XL, r21
    adc XH, r1
_rpt_loop_chk:
    dec r22
    breq _rpt_end
    ; push an address to the stack and return, effectively a somewhat slow indirect
    ; jump. Unlike ijmp, however, we aren't restricted to using Z.
    push r24
    push r25
.if defined(__atmega2560) || defined(__atmega2561)
    push r1 ; atmega256* use 3 byte flash addresses
.endif
_rpt_end:
    ret

; Render
; render_sector:
