#ifndef RENDER_H
#define RENDER_H

#include <stdint.h>

// void render_tile(uint8_t *buffer, uint8_t tile, uint8_t row_min, uint8_t row_max, uint8_t col_min, uint8_t col_max);

void render_visible_sectors(uint8_t *fbuff,
                            const __flash struct sector *upper_left,
                            const __flash struct sector *upper_right,
                            const __flash struct sector *lower_left,
                            const __flash struct sector *lower_right,
                            uint8_t lr_offset_x_h, uint8_t lr_offset_x_l,
                            uint8_t lr_offset_y_h, uint8_t lr_offset_y_l);
#endif
