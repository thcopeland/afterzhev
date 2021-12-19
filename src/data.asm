; All game state and writable data lives here. This will be placed in SRAM, so
; we're limited to 8KB (minus stack). Everything that needs to be initialized will
; be initialized in init.asm.

    .dseg
    .org SRAM_START
    ; video data
framebuffer:
    .byte (DISPLAY_WIDTH*(DISPLAY_HEIGHT-FOOTER_HEIGHT)) ; 7200
sig_fbuff_offset:
    .byte 2     ; pointer into framebuffer indicating what to draw next
sig_current_row:
    .byte 2     ; high byte indicates the row, low byte indicates the row repetitions
sig_work_complete:
    .byte 1     ; whether the main work is complete
