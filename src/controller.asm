; Read control inputs from the NES controller, and update controller_values and
; prev_controller_values. This is faster than spec but works on both my original
; and clone NES controllers.
;
;   latch   __----____________________________________________________________
;   clock   --------___---___---___---___---___---___---___---___-------------
;   data    ______a_____b_____c_____r_____^_____v_____<_____>_________________
;
; Register Usage
;   r24, r25        calculations
read_nes_controller:
    lds r25, controller_values
    sts prev_controller_values, r25
    clr r25
    cbi PORTG, PG0
    sbi PORTG, PG1
    sbi PORTG, PG0
    delay 32, r24
    cbi PORTG, PG0
    sbis PING, PG2
    ori r25, 1<<CONTROLS_SPECIAL1
    delay 16, r24

    cbi PORTG, PG1
    delay 16, r24
    sbi PORTG, PG1
    delay 16, r24
    sbis PING, PG2
    ori r25, 1<<CONTROLS_SPECIAL2

    cbi PORTG, PG1
    delay 16, r24
    sbi PORTG, PG1
    delay 16, r24
    sbis PING, PG2
    ori r25, 1<<CONTROLS_SPECIAL4

    cbi PORTG, PG1
    delay 16, r24
    sbi PORTG, PG1
    delay 16, r24
    sbis PING, PG2
    ori r25, 1<<CONTROLS_SPECIAL3

    cbi PORTG, PG1
    delay 16, r24
    sbi PORTG, PG1
    delay 16, r24
    sbis PING, PG2
    ori r25, 1<<CONTROLS_UP

    cbi PORTG, PG1
    delay 16, r24
    sbi PORTG, PG1
    delay 16, r24
    sbis PING, PG2
    ori r25, 1<<CONTROLS_DOWN

    cbi PORTG, PG1
    delay 16, r24
    sbi PORTG, PG1
    delay 16, r24
    sbis PING, PG2
    ori r25, 1<<CONTROLS_LEFT

    cbi PORTG, PG1
    delay 16, r24
    sbi PORTG, PG1
    delay 16, r24
    sbis PING, PG2
    ori r25, 1<<CONTROLS_RIGHT

    ; final clock is unnecessary for original controllers but my clone wants it
    cbi PORTG, PG1
    delay 16, r24
    sbi PORTG, PG1
    delay 16, r24

    sts controller_values, r25
    ret
