; Read control inputs and set controller_values.
;
; Register Usage
;   r18     controller input values low byte
;   r20     input pin values
read_controls:
    lds r20, controller_values
    sts prev_controller_values, r20
    clr r18
    in r20, PINC
    sbrs r20, 7
    ori r18, 1<<CONTROLS_UP
    sbrs r20, 6
    sbr r18, 1<<CONTROLS_DOWN
    sbrs r20, 5
    ori r18, 1<<CONTROLS_LEFT
    sbrs r20, 4
    ori r18, 1<<CONTROLS_RIGHT
    sbrs r20, 3
    ori r18, 1<<CONTROLS_SPECIAL1
    sbrs r20, 2
    ori r18, 1<<CONTROLS_SPECIAL2
    sbrs r20, 1
    ori r18, 1<<CONTROLS_SPECIAL3
    sbrs r20, 0
    ori r18, 1<<CONTROLS_SPECIAL4
    sts controller_values, r18
    ret
