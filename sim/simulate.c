#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "SDL.h"
#include "slimavr-0.1.4/slimavr.h"
#include "minimal_model.h"

#ifdef EMSCRIPTEN
#include <emscripten.h>
#endif

#define GAME_DISPLAY_WIDTH 120
#define GAME_DISPLAY_HEIGHT 66
#define SCALE 8

struct avr *avr;
int stayin_alive = 1;
SDL_Renderer *renderer;
SDL_Texture *framebuffer;

void run_to_sync(void) {
    while (1) {
        uint8_t sync = avr->mem[0x25] & 0x80;
        avr_step(avr);
        avr_step(avr);

        if ((0x80 & avr->mem[0x25]) ^ sync) {
            break;
        } else if (avr->status == CPU_STATUS_CRASHED) {
            fprintf(stderr, "CPU crashed (%d) at 0x%05x\n", avr->error, avr->pc);
            exit(0);
        }
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
                case SDLK_ESCAPE:
                    stayin_alive = 0;
                    break;
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
        }
    }
}

void loop(void) {
    handle_events();
    run_to_sync();

    uint8_t *pixels;
    int pitch;
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
    avr = avr_init(AFTERZHEV_MINIMAL_MODEL);
    avr->mem[0x26] = 0xff;

    if (avr_load_ihex(avr, "bin/main.hex") != 0) {
        exit(1);
    }

    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        fprintf(stderr, "unable to initialize SDL\n");
        return 1;
    }

    SDL_Window *window = SDL_CreateWindow("AfterZhev", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, GAME_DISPLAY_WIDTH*SCALE, GAME_DISPLAY_HEIGHT*SCALE, SDL_WINDOW_RESIZABLE|SDL_WINDOW_SHOWN);
    if (!window) {
        fprintf(stderr, "unable to create SDL window\n");
        return 1;
    }

    renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
    if (!renderer) {
        fprintf(stderr, "unable to create SDL renderer\n");
        return 1;
    }

    SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, 0);
    // it'd be nice to use the SDL_PIXELFORMAT_RGB332 format, but the bits are in opposite order
    framebuffer = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGB24, SDL_TEXTUREACCESS_STREAMING, GAME_DISPLAY_WIDTH, GAME_DISPLAY_HEIGHT);
    if (!framebuffer) {
        fprintf(stderr, "unable to create framebuffer\n");
        return 1;
    }

#ifdef EMSCRIPTEN
    emscripten_set_main_loop(&loop, 0, 1);
#else
    while (stayin_alive) {
        loop();
    }
#endif

    SDL_DestroyTexture(framebuffer);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
    return 0;
}
