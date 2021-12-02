#ifndef DISPLAY_H
#define DISPLAY_H

/*
GENERATING AN 8-BIT VGA SIGNAL
 PB6 : HSYNC     (pin associated with timer 1 OCR1B)
 PE4 : VSYNC     (pin associated with timer 3 OCR3B)
 PA0-PA2 : RED   (port A was chosen because it's convenient on my Arduino MEGA 1280)
 PA3-PA5 : GREEN
 PA6-PA7 : BLUE

TIMING
 The exact values aren't necessary (in fact, they're impossible at 16Mhz), since
 monitors will adjust to the signal.

       back porch             active video              front porch   sync
 RGB    __________|************************************|__________|___________
 HSYNC  __________|____________________________________|__________|-----------
         1.91 us                  254.22 us            | 0.636 us |  3.81 us

        back porch                active video              front porch  sync
 VSYNC  ___________|________________________________________|__________|------
          0.59 ms                 15.25 ms                    0.21 ms  0.038 ms

CIRCUIT
 Every pin outputs 0 or 5 volts. Different resistors will work fine (or better),
 but ideally they'd be 4-2-1 and produce a voltage of 0-0.7v across the (75 ohm)
 display (mine are a bit low).

 PA0 ----- 4700 ohms ----+
                         |
 PA1 ----- 2200 ohms ----+----- 0-0.55 volt red signal --- VGA pin 1 (75 ohm)
                         |
 PA2 ----- 1000 ohms ----+

 PA3 ----- 4700 ohms ----+
                         |
 PA4 ----- 2200 ohms ----+----- 0-0.55 volt green signal --- VGA pin 2 (75 ohm)
                         |
 PA5 ----- 1000 ohms ----+

 PA6 ----- 2200 ohms ----+
                         |----- 0-0.49 volt blue signal --- VGA pin 3 (75 ohm)
 PA7 ----- 1000 ohms ----+

 PB6 ----- 100 ohms ---------------------------------------- VGA pin 13

 PE4 ----- 100 ohms ---------------------------------------- VGA pin 14

 GND ------------------------------------------------------- VGA pins 5,6,7,8,10
*/

// TODO: if there's enough memory, upgrade to 80x60. (Memory is the main constraint,
// not time -- at 16Mhz, we could go up to 200x480 if memory wasn't tight).
#define DISPLAY_WIDTH 64
#define DISPLAY_HEIGHT 48
#define VBUFF_SIZE (DISPLAY_WIDTH*DISPLAY_HEIGHT)

// if the rows are vertically offset (the screen appears split horizontally),
// change this by a hundred or so.
#define VIRT_ADJUST 0

extern uint8_t vbuff[];

#endif
