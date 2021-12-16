#ifndef TILE_H
#define TILE_H

#include <avr/pgmspace.h>
#include "dimensions.h"

#define NUM_TILE_TYPES 4

extern const __flash uint8_t tileset[NUM_TILE_TYPES][TILE_SIZE];

#endif
