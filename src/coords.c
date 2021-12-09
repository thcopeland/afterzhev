#include "tile.h"
#include "map.h"
#include "coords.h"

void determine_visible_sectors(uint8_t main_sector,
                               struct sector *upper_left, struct sector *upper_right,
                               struct sector *lower_left, struct sector *lower_right,
                               int8_t offset_x, int8_t offset_y,
                               uint8_t *ul_offset_x, uint8_t *ul_offset_y) {
    if (offset_x < 0) {
        if (offset_y < 0) {
            *upper_left  = sectors[main_sector];
            *upper_right = sectors[upper_left->right];
            *lower_left  = sectors[upper_left->below];
            *lower_right = sectors[upper_right->below];
            *ul_offset_x = -offset_x;
            *ul_offset_y = -offset_y;
        } else {
            *lower_left  = sectors[main_sector];
            *lower_right = sectors[lower_left->right];
            *upper_left  = sectors[lower_left->above];
            *upper_right = sectors[lower_right->above];
            *ul_offset_x = -offset_x;
            *ul_offset_y = offset_y;
        }
    } else {
        if (offset_y < 0) {
            *upper_right = sectors[main_sector];
            *upper_left  = sectors[upper_right->left];
            *lower_left  = sectors[upper_left->below];
            *lower_right = sectors[upper_right->below];
            *ul_offset_x = offset_x;
            *ul_offset_y = -offset_y;
        } else {
            *lower_right = sectors[main_sector];
            *lower_left  = sectors[lower_right->left];
            *upper_left  = sectors[lower_left->above];
            *upper_right = sectors[lower_right->above];
            *ul_offset_x = offset_x;
            *ul_offset_y = offset_y;
        }
    }
}
