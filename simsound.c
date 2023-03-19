#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "SDL.h"
#include "sim/slimavr-0.1.5/slimavr.h"

#define GAME_DISPLAY_WIDTH 600
#define GAME_DISPLAY_HEIGHT 600

#define SAMPLING_RATE 44100
#define AUDIO_BUFFER_SIZE 2048

uint8_t video_buffer[3*GAME_DISPLAY_WIDTH*GAME_DISPLAY_HEIGHT];
int16_t audio_buffer[AUDIO_BUFFER_SIZE];

struct avr *avr;
int stayin_alive = 1;
uint64_t last_counter = 0;
SDL_Window *window;
SDL_Renderer *renderer;
SDL_Texture *framebuffer;
SDL_AudioDeviceID audio_device;

void run_to_sync(void) {
    static int scanline = 0;
    static int offset = 0;

    int drop_frame = SDL_GetQueuedAudioSize(audio_device) > 8*AUDIO_BUFFER_SIZE;
    int sampling_period = 283; // faster than 16000000/SAMPLING_RATE;
    int samples = 0;
    int16_t sample, last_sample = 0;

    while (1) {
        uint8_t sync = avr->mem[0x25] & 0x80;
        int hsync = avr->mem[0x25] & 0x40;
        int vsync = avr->mem[0x2e] & 0x10;
        avr_step(avr);
        int hsync2 = avr->mem[0x25] & 0x40;
        int vsync2 = avr->mem[0x2e] & 0x10;

        if (!drop_frame && (avr->clock % sampling_period) == 0) {
            sample = (int16_t) (avr->mem[0x28]<<8) - (128<<8);
            sample = sample/2 + last_sample/2;
            audio_buffer[samples++] = sample;
            last_sample = sample;
        }

        if (hsync2 == 0 && hsync != hsync2) {
            video_buffer[scanline*3*GAME_DISPLAY_WIDTH + 3*offset] = 255;
            offset = 0;
            scanline += 1;
        } else {
            offset += 1;

            if (offset > 10 && offset < 419 && scanline > 31 && scanline < 362) {
                uint8_t val = avr->mem[0x22] & avr->mem[0x21];
                video_buffer[scanline*3*GAME_DISPLAY_WIDTH + 3*offset] = 255*(val&7)/7;
                video_buffer[scanline*3*GAME_DISPLAY_WIDTH + 3*offset + 1] = 255*((val>>3)&7)/7;
                video_buffer[scanline*3*GAME_DISPLAY_WIDTH + 3*offset + 2] = 255*((val>>5)&6)/7;
            } else if (scanline > 31 && scanline < 362) {
                video_buffer[scanline*3*GAME_DISPLAY_WIDTH + 3*offset + 0] += avr->mem[0x28];
                video_buffer[scanline*3*GAME_DISPLAY_WIDTH + 3*offset + 1] += avr->mem[0x28];
                video_buffer[scanline*3*GAME_DISPLAY_WIDTH + 3*offset + 2] += avr->mem[0x28];
            } else {
                uint8_t val = avr->pc >> 5;
                video_buffer[scanline*3*GAME_DISPLAY_WIDTH + 3*offset + 0] += val;
                video_buffer[scanline*3*GAME_DISPLAY_WIDTH + 3*offset + 1] += val;
                video_buffer[scanline*3*GAME_DISPLAY_WIDTH + 3*offset + 2] += val;
            }
        }

        video_buffer[3*(GAME_DISPLAY_HEIGHT-2)*GAME_DISPLAY_WIDTH + avr->reg[6]*3+1] = 255;

        if (vsync2 == 0 && vsync != vsync2) {
            for (int i = 0; i < GAME_DISPLAY_WIDTH; i++) {
                video_buffer[scanline*3*GAME_DISPLAY_WIDTH+3*i] = 255;
            }
            scanline = 0;
            offset = 0;
        }

        if ((0x80 & avr->mem[0x25]) ^ sync) {
            break;
        } else if (avr->status == MCU_STATUS_CRASHED) {
            avr_dump(avr, NULL);
            exit(0);
        }
    }

    SDL_QueueAudio(audio_device, audio_buffer, sizeof(*audio_buffer)*samples);
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
    memcpy(pixels, video_buffer, sizeof(video_buffer));
    memset(video_buffer, 0, sizeof(video_buffer));
    SDL_UnlockTexture(framebuffer);
    SDL_RenderCopy(renderer, framebuffer, NULL, NULL);
    SDL_RenderPresent(renderer);
}

int main(int argc, char **argv) {
    (void) argc;
    (void) argv;

    avr = avr_new(AVR_MODEL_ATMEGA2560);
    avr->mem[0x26] = 0xff;

    if (avr_load_ihex(avr, "sound.hex") != 0) {
        exit(1);
    }

    if (SDL_Init(SDL_INIT_VIDEO|SDL_INIT_AUDIO) < 0) {
        fprintf(stderr, "unable to initialize SDL: %s\n", SDL_GetError());
        return 1;
    }

    window = SDL_CreateWindow("AfterZhev", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, GAME_DISPLAY_WIDTH, GAME_DISPLAY_HEIGHT, SDL_WINDOW_RESIZABLE|SDL_WINDOW_HIDDEN);
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

    SDL_AudioSpec out_spec, in_spec = {
        .freq = SAMPLING_RATE,
        .format = AUDIO_S16,
        .channels = 1,
        .samples = AUDIO_BUFFER_SIZE,
        .callback = NULL
    };

    audio_device = SDL_OpenAudioDevice(NULL, 0, &in_spec, &out_spec, 0);
    SDL_PauseAudioDevice(audio_device, 0);

    while (stayin_alive) {
        loop();
    }

    SDL_DestroyTexture(framebuffer);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_CloseAudioDevice(audio_device);
    SDL_Quit();
    return 0;
}
