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
int frame_count = 0;
int frame_time = 0;

long profiled[1<<15];

char *labels[] = {"init", "main", "isr_loop", "rand", "divmodb", "divmodw", "read_controls", "determine_character_sprite", "determine_weapon_sprite", "determine_armor_sprite", "move_character", "update_character_animation", "biased_character_distance", "character_striking_distance", "player_resolve_melee_damage", "player_resolve_effect_damage", "npc_resolve_melee_damage", "npc_resolve_ranged_damage", "resolve_enemy_death", "add_distant_npc", "write_entire_tile", "write_partial_tile", "write_12x12_sprite", "write_sprite", "write_sprite_flip_x", "write_sprite_flip_y", "write_sprite_flip_xy", "render_sector", "render_sprite", "render_character", "render_character_icon", "render_effect_animation", "render_item_icon", "putc", "putc_small", "putb", "putb_small", "putw", "putw_small", "puts", "puts_n", "render_element", "render_rect", "render_effect_progress", "render_item_with_underbar", "render_full_screen", "render_partial_screen", "fade_text", "fade_text_inverse", "calculate_player_stats", "update_player_stat_effects", "update_player_health", "calculate_max_health", "calculate_acceleration", "calculate_push_acceleration", "calculate_push_resistance", "calculate_dash_cooldown", "init_player_stats", "estimated_effect_ranges", "npc_move", "npc_update", "enemy_sector_bounds", "enemy_personal_space", "enemy_fighting_space", "corpse_update", "init_game_state", "load_explore", "explore_update_game", "render_game", "render_npc_health_bar", "handle_controls", "handle_main_button", "reset_camera", "player_dash", "player_attack", "update_active_effects", "update_savepoint_animation", "update_savepoint", "restore_from_savepoint", "add_active_effect", "update_player", "check_sector_bounds", "load_sector", "load_npc", "move_camera", "update_followers", "update_npcs", "sort_npcs", "add_nearby_followers", "inventory_update_game", "load_inventory", "inventory_handle_controls", "inventory_equip_item", "inventory_use_item", "inventory_drop_item", "inventory_render_game", "render_item_stat", "shop_update_game", "load_shop", "shop_handle_controls", "shop_buy_selected", "shop_sell_selected", "shop_render_game", "shop_determine_selection", "calculate_buy_price", "calculate_sell_price", "shop_most_valuable", "conversation_update_game", "conversation_handle_controls", "load_conversation", "conversation_render_game", "upgrade_update_game", "load_upgrade_if_necessary", "upgrade_handle_controls", "upgrade_render_game", "render_stat_selector", "render_stat_progress", "gameover_update_game", "load_gameover", "gameover_handle_controls", "gameover_render_game", "gameover_render_dead", "gameover_render_win", "gameover_text", "gfs_lightning", "gameover_lightning", "credits_update", "load_credits", "credits_handle_controls", "credits_render", "scrolling_text", "puts_outlined", "restart_game", "start_update_game", "start_render_screen", "screen_fade_out", "start_handle_controls", "start_change", "load_character_selection", "character_selection_update", "character_selection_controls", "character_selection_render", "load_intro", "intro_update_game", "intro_handle_controls", "intro_render", "load_resume", "resume_update_game", "resume_try_load_save", "resume_handle_controls", "resume_render", "load_about", "about_update", "about_handle_controls", "about_render", "render_logo", "load_help", "load_tutorial", "help_update", "clear_sector_data", "add_npc", "add_npc_direct", "find_npc", "release_if_damaged", "spawn_distant_npcs", "drop_item", "tutorial_update", "sector_start_1_update", "sector_start_2_update", "sector_start_fight_update", "sector_start_fight_choice", "sector_town_entrance_1_update", "sector_town_entrance_1_conversation", "sector_town_entrance_1_choice", "sector_town_wolves_update", "sector_start_post_fight_update", "sector_start_post_fight_conversation", "sector_town_tavern_1_update", "sector_town_tavern_2_update", "sector_town_tavern_2_conversation", "sector_town_tavern_2_choice", "sector_town_fields_init", "sector_town_fields_update", "sector_town_forest_path_2_init", "sector_town_forest_path_2_update", "sector_town_forest_path_4_update", "sector_town_forest_path_5_init", "sector_town_den_2_init", "sector_town_den_2_update", "sector_start_pretown_2_update", "sector_start_pretown_2_choice", "sector_river_hidden_house_choice", "sector_deep_forest_update", "sector_deep_forest_init", "sector_underground_update", "sector_fields_update", "sector_fields_init", "sector_final_2_update", "sector_city_shop_1_choice", "sector_city_4_init", "sector_city_4_conversation", "sector_city_4_choice", "sector_city_bank_1_update", "sector_city_bank_2_init", "sector_city_bank_3_update", "sector_city_bank_4_update", "sector_city_robbers_den_update", "sector_city_robbers_den_conversation", "sector_city_robbers_den_choice", "sector_city_robbers_den_2_init", "sector_final_castle_init", "sector_final_battle_init", "sector_final_battle_update"};
int addrs[] = {72, 194, 326, 1042, 1082, 1114, 1158, 1208, 1250, 1308, 1358, 2022, 2244, 2286, 2334, 2678, 2858, 3156, 3434, 3646, 3780, 3862, 3978, 4070, 4214, 4358, 4516, 4666, 5202, 5448, 5660, 5828, 5984, 6022, 6126, 6206, 6244, 6282, 6364, 6446, 6528, 6626, 6656, 6686, 6884, 6900, 6930, 6984, 7112, 7248, 7574, 7676, 7734, 7800, 7822, 7836, 7856, 7878, 7974, 7982, 8926, 9172, 9214, 9314, 9418, 9464, 9714, 9792, 9874, 10852, 11014, 11180, 11782, 11848, 11884, 11962, 12086, 12130, 12312, 12430, 12494, 12772, 12978, 13350, 13462, 13552, 13630, 13706, 13870, 14008, 14016, 14036, 14160, 14340, 14460, 14522, 15224, 15268, 15276, 15350, 15468, 15530, 15588, 16140, 16212, 16310, 16334, 16482, 16504, 16686, 16732, 17114, 17122, 17254, 17490, 17688, 17714, 17800, 17836, 17856, 17946, 18000, 18064, 18184, 18250, 18260, 18370, 18402, 18414, 18440, 18592, 18620, 18854, 18876, 18908, 19028, 19074, 19126, 19166, 19190, 19198, 19280, 19740, 19752, 19790, 19816, 19940, 19952, 19962, 19984, 20004, 20048, 20056, 20064, 20084, 20126, 20160, 20176, 20262, 20296, 20302, 20368, 20394, 20414, 20470, 20528, 20558, 20774, 20832, 21014, 21058, 21144, 21218, 21316, 21344, 21368, 21392, 21422, 21480, 21544, 21658, 21670, 21776, 21940, 22014, 22070, 22128, 22160, 22188, 22240, 22426, 22480, 22496, 22510, 22544, 22558, 22572, 22580, 22628, 22662, 22688, 22798, 22836, 22918, 22938, 23022, 23030, 23136, 23238, 23270, 23290, 23298, 23312};

void run_to_sync(void) {
    uint16_t idle = 0;
    while (1) {
        uint8_t sync = avr->mem[0x25] & 0x80;
        avr_step(avr);
        profiled[avr->pc/2]++;
        avr_step(avr);
        profiled[avr->pc/2]++;
        frame_time += 2;

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
    frame_count++;
    if (idle < min_idle && (idle > 0 || avr->insts > 10000)) {
        min_idle = idle;
        printf("idle %d (avg %d)\n", idle, avg_idle);
    }
    //
    // if (idle > 50000) {
    //     // printf("missed frame! %d\n", idle);
    // } else {
    //     avg_idle = (avg_idle * 19 + idle) / 20;
    //     if (avg_idle < min_avg_idle && (avg_idle > 0 || avr->insts > 10000)) {
    //         min_avg_idle = avg_idle;
    //         printf("avr idle min %d\n", min_avg_idle);
    //     }
    // }
    printf("%d/%d\n", frame_time, idle);
    frame_time = 0;
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
                if (val > 0.1) {
                    if (val > 1) printf("\x1b[1m");
                    printf("0x%06x %-30s: %8.3f\x1b[0m (%ld cycles/frame)\n", addrs[i], labels[i], val, count/frame_count);
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
