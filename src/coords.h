#ifndef COORDS_H
#define COORDS_H

#include <stdint.h>

void determine_visible_sectors(uint8_t main_sector,
                               struct sector *upper_left, struct sector *upper_right,
                               struct sector *lower_left, struct sector *lower_right,
                               int8_t offset_x, int8_t offset_y,
                               uint8_t *ul_offset_x, uint8_t *ul_offset_y);
#endif
