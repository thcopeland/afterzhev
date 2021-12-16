#ifndef TILE_H
#define TILE_H

#include <avr/pgmspace.h>
#include "display.h"

#define TILE_WIDTH 12
#define TILE_HEIGHT 12
#define TILE_SIZE (TILE_WIDTH*TILE_HEIGHT)

#define DISPLAY_TILE_WIDTH (DISPLAY_WIDTH/TILE_WIDTH)
#define DISPLAY_TILE_HEIGHT (DISPLAY_HEIGHT/TILE_HEIGHT)

#define NUM_TILE_TYPES 4

extern const __flash uint8_t tileset[NUM_TILE_TYPES][TILE_SIZE];

#endif
