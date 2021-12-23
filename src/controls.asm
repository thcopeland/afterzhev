; Read control inputs and set controller_values. (This will change significantly
; if we end up using a joystick for movement).
;
; Register Usage
;   r18     controller input values low byte
;   r20     input pin values
read_controls:
    clr r18
    in r20, PINC
    sbrs r20, 7
    ori r18, (1 << CONTROLS_UP)
    sbrs r20, 6
    sbr r18, (1 << CONTROLS_DOWN)
    sbrs r20, 5
    ori r18, (1 << CONTROLS_LEFT)
    sbrs r20, 4
    ori r18, (1 << CONTROLS_RIGHT)
    sts controller_values, r18
    ret
