; All fixed data lives here, such as sprites, music, and text. This is stored in
; flash, so cannot be (easily) changed at runtime. Partitioning is handled manually.
    .cseg

; NOTE: during development, the code will change far more frequently than the data
; since they're stored largely separately, we can save upload time by only uploading
; the code.
    .include "world.asm"
    .include "tiles.asm"
    .include "classes.asm"
; store tiles and maps in partition 1 with code (64K)
; store sprites in partition 2 (64K)
; store everything else in partitions 3 and 4 (128K)
