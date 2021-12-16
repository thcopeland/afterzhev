#ifndef DIMENSIONS_H
#define DIMENSIONS_H

// display data
#define DISPLAY_WIDTH 120
#define DISPLAY_HEIGHT 60
#define FOOTER_HEIGHT 12
#define DISPLAY_TOTAL_HEIGHT (DISPLAY_HEIGHT + FOOTER_HEIGHT)
#define DISPLAY_VERTICAL_SCALE 5

// sector data
#define SECTOR_WIDTH  20
#define SECTOR_HEIGHT 10
#define SECTOR_SIZE (SECTOR_WIDTH*SECTOR_HEIGHT)

// tile data
#define TILE_WIDTH 12
#define TILE_HEIGHT 12
#define TILE_SIZE (TILE_WIDTH*TILE_HEIGHT)

#define DISPLAY_TILE_WIDTH (DISPLAY_WIDTH/TILE_WIDTH)
#define DISPLAY_TILE_HEIGHT (DISPLAY_HEIGHT/TILE_HEIGHT)

#endif
