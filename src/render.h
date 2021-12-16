#ifndef RENDER_H
#define RENDER_H

#include <stdint.h>
#include "map.h"

void render_sector(uint8_t *fbuff,
                   const __flash struct sector *sector,
                   uint8_t offset_x_h, uint8_t offset_x_l,
                   uint8_t offset_y_h, uint8_t offset_y_l);

#endif
