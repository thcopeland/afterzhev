#ifndef RENDER_H
#define RENDER_H

#include <stdint.h>
#include "map.h"

void render_partial_tile3(uint8_t *buff, uint8_t tile,
                          uint8_t min_x, uint8_t width,
                          uint8_t min_y, uint8_t height);

void render_sector(uint8_t *fbuff,
                   const __flash struct sector *sector,
                   uint8_t offset_x_h, uint8_t offset_x_l,
                   uint8_t offset_y_h, uint8_t offset_y_l);

#endif
