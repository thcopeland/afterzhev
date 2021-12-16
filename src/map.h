#ifndef MAP_H
#define MAP_H

#include <avr/pgmspace.h>

#define WORLD_SIZE 2

#define SECTOR_WIDTH  20
#define SECTOR_HEIGHT 10
#define SECTOR_SIZE (SECTOR_WIDTH*SECTOR_HEIGHT)

#define MAX_SECTOR_NPCS  8
#define MAX_SECTOR_ITEMS 4

struct sector {
    uint8_t left, above, right, below;
    uint8_t npcs[MAX_SECTOR_NPCS];
    uint8_t items[MAX_SECTOR_ITEMS];
    uint8_t tiles[SECTOR_SIZE];
};

extern const __flash struct sector sectors[];

#endif
