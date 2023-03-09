#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "SDL.h"
#include "slimavr-0.1.5/slimavr.h"
#include "minimal_model.h"

#ifdef EMSCRIPTEN
#include <emscripten.h>
#endif

#define GAME_DISPLAY_WIDTH 120
#define GAME_DISPLAY_HEIGHT 66
#define SCALE 8

struct avr *avr;
int stayin_alive = 1;
uint64_t last_counter = 0;
SDL_Window *window;
SDL_Renderer *renderer;
SDL_Texture *framebuffer;

int min_idle = 100000;
int avg_idle = 0;
int min_avg_idle = 100000;

long profiled[1<<15];

char *labels[] = {"init", "main", "isr_loop", "framebuffer", "rand", "divmodb", "divmodw", "read_controls", "determine_character_sprite", "determine_weapon_sprite", "determine_armor_sprite", "move_character", "update_character_animation", "biased_character_distance", "character_striking_distance", "player_resolve_melee_damage", "player_resolve_effect_damage", "npc_resolve_melee_damage", "npc_resolve_ranged_damage", "resolve_enemy_death", "add_distant_npc", "write_entire_tile", "write_partial_tile", "write_12x12_sprite", "write_sprite", "write_sprite_flip_x", "write_sprite_flip_y", "write_sprite_flip_xy", "render_sector", "render_sprite", "render_character", "render_character_icon", "render_effect_animation", "render_item_icon", "putc", "putc_small", "putb", "putb_small", "putw", "putw_small", "puts", "puts_n", "render_element", "render_rect", "render_effect_progress", "render_item_with_underbar", "render_full_screen", "render_partial_screen", "fade_text", "fade_text_inverse", "calculate_player_stats", "update_player_stat_effects", "update_player_health", "calculate_max_health", "calculate_acceleration", "calculate_push_acceleration", "calculate_push_resistance", "calculate_dash_cooldown", "init_player_stats", "estimated_effect_ranges", "npc_move", "npc_update", "enemy_sector_bounds", "enemy_personal_space", "enemy_fighting_space", "corpse_update", "init_game_state", "explore_update_game", "render_game", "render_npc_health_bar", "handle_controls", "handle_main_button", "reset_camera", "player_dash", "player_attack", "update_active_effects", "update_savepoint_animation", "update_savepoint", "restore_from_savepoint", "add_active_effect", "update_player", "check_sector_bounds", "load_sector", "load_npc", "move_camera", "update_followers", "update_npcs", "sort_npcs", "add_nearby_followers", "inventory_update_game", "load_inventory", "inventory_handle_controls", "inventory_equip_item", "inventory_use_item", "inventory_drop_item", "inventory_render_game", "render_item_stat", "shop_update_game", "load_shop", "shop_handle_controls", "shop_buy_selected", "shop_sell_selected", "shop_render_game", "shop_determine_selection", "calculate_buy_price", "calculate_sell_price", "shop_most_valuable", "conversation_update_game", "conversation_handle_controls", "load_conversation", "conversation_render_game", "prev_controller_values", "controller_values", "savedmem_start", "clock", "mode_clock", "seed", "game_mode", "current_sector", "camera_position_x", "camera_position_y", "player_class", "player_position_data", "player_position_x", "player_subpixel_x", "player_velocity_x", "player_position_y", "player_subpixel_y", "player_velocity_y", "player_attack_cooldown", "player_dash_cooldown", "player_dash_direction", "player_character", "player_weapon", "player_armor", "player_direction", "player_action", "player_frame", "player_effect", "player_stats", "player_augmented_stats", "player_health", "player_gold", "upgrade_update_game", "player_xp", "player_effects", "load_upgrade_if_necessary", "player_inventory", "sector_data", "global_data", "preplaced_item_presence", "npc_presence", "conversation_over", "savedmem_end", "sector_npcs", "upgrade_handle_controls", "following_spawn_x", "following_spawn_y", "following_timer", "following_npcs", "savepoint_used", "savepoint_data", "savepoint_progress", "sector_loose_items", "active_effects", "current_shop_index", "shop_inventory", "start_selection", "inventory_selection", "shop_selection", "selected_choice", "upgrade_selection", "npc_move_flags", "gameover_state", "npc_move_flags2", "lightning_clock", "conversation_frame", "conversation_chars", "upgrade_points", "character_render", "subroutine_tmp", "upgrade_render_game", "end_game_allocs", "render_stat_selector", "render_stat_progress", "gameover_update_game", "load_gameover", "gameover_handle_controls", "gameover_render_game", "gameover_render_dead", "gameover_render_win", "gameover_text", "gfs_lightning", "gameover_lightning", "credits_update", "load_credits", "credits_handle_controls", "credits_render", "scrolling_text", "puts_outlined", "restart_game", "start_update_game", "start_render_screen", "screen_fade_out", "start_handle_controls", "start_change", "load_character_selection", "character_selection_update", "character_selection_controls", "character_selection_render", "load_intro", "intro_update_game", "intro_handle_controls", "intro_render", "load_resume", "resume_update_game", "resume_try_load_save", "resume_handle_controls", "resume_render", "load_about", "about_update", "about_handle_controls", "about_render", "render_logo", "load_help", "load_tutorial", "help_update", "clear_sector_data", "add_npc", "add_npc_direct", "find_npc", "release_if_damaged", "spawn_distant_npcs", "drop_item", "tutorial_update", "sector_start_1_update", "sector_start_2_update", "sector_start_fight_update", "sector_start_fight_choice", "sector_town_entrance_1_update", "sector_town_entrance_1_conversation", "sector_town_entrance_1_choice", "sector_town_wolves_update", "sector_start_post_fight_update", "sector_start_post_fight_conversation", "sector_town_tavern_1_update", "sector_town_tavern_2_update", "sector_town_tavern_2_conversation", "sector_town_tavern_2_choice", "sector_town_fields_init", "sector_town_fields_update", "sector_town_forest_path_2_init", "sector_town_forest_path_2_update", "sector_town_forest_path_4_update", "sector_town_forest_path_5_init", "sector_town_den_2_init", "sector_town_den_2_update", "sector_start_pretown_2_update", "sector_start_pretown_2_choice", "sector_river_hidden_house_choice", "sector_deep_forest_update", "sector_deep_forest_init", "sector_underground_update", "sector_fields_update", "sector_fields_init", "sector_final_2_update", "sector_city_shop_1_choice", "sector_city_4_init", "sector_city_4_conversation", "sector_city_4_choice", "sector_city_bank_1_update", "sector_city_bank_2_init", "sector_city_bank_3_update", "sector_city_bank_4_update", "sector_city_robbers_den_update", "sector_city_robbers_den_conversation", "sector_city_robbers_den_choice", "sector_city_robbers_den_2_init", "sector_final_castle_init", "sector_final_battle_init", "sector_final_battle_update", "font_character_table", "small_font_character_table", "item_table", "item_string_table", "shop_table", "shop_string_table", "conversation_table", "conversation_string_table"};
int addrs[] = {72, 190, 322, 1024, 1038, 1078, 1110, 1154, 1204, 1246, 1304, 1354, 2018, 2240, 2282, 2330, 2674, 2854, 3152, 3430, 3642, 3776, 3858, 3974, 4066, 4210, 4354, 4512, 4662, 5198, 5444, 5656, 5824, 5980, 6018, 6122, 6202, 6240, 6278, 6360, 6442, 6524, 6622, 6652, 6682, 6880, 6896, 6926, 6980, 7108, 7244, 7570, 7672, 7730, 7796, 7818, 7832, 7852, 7874, 7970, 7978, 8922, 9168, 9210, 9310, 9414, 9460, 9710, 9792, 10690, 10838, 11004, 11606, 11672, 11708, 11786, 11910, 11954, 12136, 12250, 12314, 12592, 12798, 13170, 13282, 13372, 13450, 13526, 13690, 13828, 13836, 13856, 13984, 14164, 14284, 14346, 15048, 15092, 15100, 15174, 15296, 15358, 15416, 15968, 16040, 16138, 16162, 16310, 16332, 16514, 16562, 16864, 16866, 16868, 16868, 16872, 16874, 16878, 16880, 16884, 16886, 16888, 16890, 16890, 16892, 16894, 16896, 16898, 16900, 16902, 16904, 16906, 16908, 16910, 16912, 16914, 16916, 16918, 16920, 16922, 16930, 16938, 16940, 16944, 16944, 16948, 16952, 16956, 16980, 16982, 16990, 16996, 17024, 17030, 17030, 17084, 17150, 17152, 17154, 17156, 17164, 17166, 17168, 17170, 17234, 17266, 17268, 17292, 17292, 17292, 17292, 17292, 17292, 17294, 17294, 17296, 17296, 17300, 17300, 17302, 17308, 17312, 17316, 17510, 17536, 17622, 17658, 17678, 17770, 17824, 17888, 18008, 18074, 18084, 18194, 18226, 18238, 18264, 18416, 18444, 18678, 18700, 18732, 18852, 18898, 18950, 18990, 19014, 19022, 19104, 19564, 19576, 19616, 19642, 19766, 19778, 19788, 19810, 19830, 19874, 19882, 19890, 19910, 19952, 19986, 20002, 20090, 20124, 20130, 20196, 20222, 20242, 20298, 20356, 20386, 20602, 20660, 20842, 20886, 20972, 21046, 21144, 21172, 21196, 21220, 21250, 21308, 21372, 21486, 21498, 21604, 21768, 21842, 21898, 21956, 21988, 22016, 22068, 22254, 22308, 22324, 22338, 22372, 22386, 22400, 22408, 22456, 22490, 22516, 22626, 22664, 22746, 22766, 22850, 22858, 22964, 23066, 23098, 23118, 23126, 23140, 23294, 23488, 23678, 24398, 27476, 27548, 27630, 29024};
void run_to_sync(void) {
    uint16_t idle = 0;
    while (1) {
        uint8_t sync = avr->mem[0x25] & 0x80;
        avr_step(avr);
        profiled[avr->pc/2]++;
        avr_step(avr);
        profiled[avr->pc/2]++;

        if (avr->status == MCU_STATUS_IDLE) {
            idle+=2;
        }

        if ((0x80 & avr->mem[0x25]) ^ sync) {
            break;
        } else if (avr->status == MCU_STATUS_CRASHED) {
            avr_dump(avr, NULL);
            exit(0);
        }
    }
    if (idle < min_idle && (idle > 0 || avr->insts > 10000)) {
        min_idle = idle;
        printf("idle %d (avg %d)\n", idle, avg_idle);
    }

    if (idle > 50000) {
        // printf("missed frame! %d\n", idle);
    } else {
        avg_idle = (avg_idle * 19 + idle) / 20;
        if (avg_idle < min_avg_idle && (avg_idle > 0 || avr->insts > 10000)) {
            min_avg_idle = avg_idle;
            printf("avr idle min %d\n", min_avg_idle);
        }
    }
}

void fps_delay(void) {
    const uint64_t expected_frametime = 1000/60;
    uint64_t counter = SDL_GetPerformanceCounter();
    uint64_t frametime = 1000 * (counter - last_counter) / SDL_GetPerformanceFrequency();
    last_counter = counter;

    // a bit loose, but prevents crazy FPS and vsync should pick up the slack
    if (frametime < expected_frametime-1) {
        SDL_Delay(expected_frametime-frametime-1);
    }
}

void set_control_bit(int bit, int val) {
    if (val) avr->mem[0x26] |= (1 << bit);
    else avr->mem[0x26] &= ~(1 << bit);
}

void handle_events(void) {
    SDL_Event event;
    while (SDL_PollEvent(&event)) {
        if (event.type == SDL_KEYDOWN || event.type == SDL_KEYUP) {
            switch (event.key.keysym.sym) {
                case SDLK_UP:
                    set_control_bit(7, event.type == SDL_KEYUP);
                    break;
                case SDLK_LEFT:
                    set_control_bit(5, event.type == SDL_KEYUP);
                    break;
                case SDLK_DOWN:
                    set_control_bit(6, event.type == SDL_KEYUP);
                    break;
                case SDLK_RIGHT:
                    set_control_bit(4, event.type == SDL_KEYUP);
                    break;
                case SDLK_a:
                case SDLK_RETURN:
                    set_control_bit(3, event.type == SDL_KEYUP);
                    break;
                case SDLK_s:
                    set_control_bit(2, event.type == SDL_KEYUP);
                    break;
                case SDLK_d:
                    set_control_bit(1, event.type == SDL_KEYUP);
                    break;
                case SDLK_f:
                    set_control_bit(0, event.type == SDL_KEYUP);
                    break;
            }
        } else if (event.type == SDL_QUIT) {
            stayin_alive = 0;
            for (int i = 0; i < sizeof(addrs)/sizeof(*addrs)-1; i++) {
                long count = 0;
                for (long j = addrs[i]; j < addrs[i+1]; j++) count += profiled[j/2];
                float val = (float) 1000*count/avr->clock;
                if (val > 0.01) {
                    if (val > 1) printf("\x1b[1m");
                    printf("0x%06x %-30s: %8.3f\x1b[0m\n", addrs[i], labels[i], val);
                }
            }
            printf("Recent average idle time:  %d\n", avg_idle);
            printf("Overall min idle time:     %d\n", min_idle);
            printf("Overall min avg idle time: %d\n", min_avg_idle);
        }
    }
}

void loop(void) {
    fps_delay();
    handle_events();
    run_to_sync();

    uint8_t *pixels;
    int pitch;
    SDL_RenderClear(renderer);
    SDL_LockTexture(framebuffer, NULL, (void**)(&pixels), &pitch);
    for (int i = 0; i < GAME_DISPLAY_WIDTH*GAME_DISPLAY_HEIGHT; i++) {
        uint8_t val = avr->ram[i] & avr->mem[0x21];
        pixels[3*i] = 255*(val&7)/7;
        pixels[3*i+1] = 255*((val>>3)&7)/7;
        pixels[3*i+2] = 255*((val>>5)&6)/7;
    }
    SDL_UnlockTexture(framebuffer);
    SDL_RenderCopy(renderer, framebuffer, NULL, NULL);
    SDL_RenderPresent(renderer);
}

int main(int argc, char **argv) {
    (void) argc;
    (void) argv;

    // using a stripped-down ATmega 2560 for emulation for performance
    avr = avr_new(AFTERZHEV_MINIMAL_MODEL);
    avr->mem[0x26] = 0xff;

    if (avr_load_ihex(avr, "bin/main.hex") != 0) {
        exit(1);
    }

    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        fprintf(stderr, "unable to initialize SDL: %s\n", SDL_GetError());
        return 1;
    }

    window = SDL_CreateWindow("AfterZhev", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, GAME_DISPLAY_WIDTH*SCALE, GAME_DISPLAY_HEIGHT*SCALE, SDL_WINDOW_RESIZABLE|SDL_WINDOW_HIDDEN);
    if (!window) {
        fprintf(stderr, "unable to create SDL window: %s\n", SDL_GetError());
        return 1;
    }

    renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED|SDL_RENDERER_PRESENTVSYNC);
    if (!renderer) {
        fprintf(stderr, "unable to create SDL renderer: %s\n", SDL_GetError());
        return 1;
    }

    SDL_ShowWindow(window);
    SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, 0);

    framebuffer = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGB24, SDL_TEXTUREACCESS_STREAMING, GAME_DISPLAY_WIDTH, GAME_DISPLAY_HEIGHT);
    if (!framebuffer) {
        fprintf(stderr, "unable to create framebuffer: %s\n", SDL_GetError());
        return 1;
    }

#ifdef EMSCRIPTEN
    emscripten_set_main_loop(&loop, 0, 1);
#else
    while (stayin_alive) loop();
#endif

    SDL_DestroyTexture(framebuffer);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
    return 0;
}
