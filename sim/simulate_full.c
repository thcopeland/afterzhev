#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "SDL.h"
#include "slimavr-0.1.6/slimavr.h"

#define GAME_DISPLAY_WIDTH 600
#define GAME_DISPLAY_HEIGHT 600

#define SAMPLING_RATE 44100
#define AUDIO_BUFFER_SIZE 1024

#define VSYNC_PERIOD 0x41800
#define TRUE_FPS 60
#define CYCLES_PER_TRUE_SECOND (VSYNC_PERIOD*TRUE_FPS)
#define SAMPLING_CYCLES (CYCLES_PER_TRUE_SECOND/SAMPLING_RATE-2)

#define HSYNC_PORT 'B'
#define HSYNC_PIN 6
#define VSYNC_PORT 'E'
#define VSYNC_PIN 4
#define VIDEO_PORT 'A'
#define AUDIO_PORT 'C'
#define CONTROLLER_PORT 'G'
#define CONTROLLER_LATCH_PIN 0
#define CONTROLLER_CLOCK_PIN 1
#define CONTROLLER_DATA_PIN 2

uint8_t video_buffer[3*GAME_DISPLAY_WIDTH*GAME_DISPLAY_HEIGHT];
int16_t audio_buffer[AUDIO_BUFFER_SIZE];

struct avr *avr;
int stayin_alive = 1;
uint64_t last_counter = 0;
SDL_Window *window;
SDL_Renderer *renderer;
SDL_Texture *framebuffer;
SDL_AudioDeviceID audio_device;

struct controller_data {
    enum avr_pin_state clock;
    uint8_t value;
    uint8_t latched;
};

struct controller_data controller = {
    .clock = AVR_PIN_HIGH,
    .value = 0xff,
    .latched = 0xff
};

void run_to_sync(void) {
    static int scanline = 0;
    static int offset = 0;

    int drop_frame = SDL_GetQueuedAudioSize(audio_device) > 8*AUDIO_BUFFER_SIZE;
    int samples = 0;

    while (1) {
        enum avr_pin_state hsync = avr_io_read(avr, HSYNC_PORT, HSYNC_PIN);
        enum avr_pin_state vsync = avr_io_read(avr, VSYNC_PORT, VSYNC_PIN);
        avr_step(avr);
        enum avr_pin_state hsync2 = avr_io_read(avr, HSYNC_PORT, HSYNC_PIN);
        enum avr_pin_state vsync2 = avr_io_read(avr, VSYNC_PORT, VSYNC_PIN);

        if (!drop_frame && (avr->clock % SAMPLING_CYCLES) == 0) {
            audio_buffer[samples++] = avr_io_read_port(avr, AUDIO_PORT) << 6;
        }

        if (hsync2 == AVR_PIN_LOW && hsync != hsync2) {
            video_buffer[scanline*3*GAME_DISPLAY_WIDTH + 3*offset] = 255;
            uint8_t sample = avr_io_read_port(avr, AUDIO_PORT);
            for (unsigned i = 1; offset+i < GAME_DISPLAY_WIDTH; i++) {
                video_buffer[scanline*3*GAME_DISPLAY_WIDTH + 3*(offset+i) + 0] += sample;
                video_buffer[scanline*3*GAME_DISPLAY_WIDTH + 3*(offset+i) + 1] += sample;
                video_buffer[scanline*3*GAME_DISPLAY_WIDTH + 3*(offset+i) + 2] += sample;
            }
            offset = 0;
            scanline += 1;
        } else {
            offset += 1;

            if (offset > 10 && offset < 419 && scanline > 31 && scanline < 362) {
                uint8_t val = avr_io_read_port(avr, VIDEO_PORT);
                video_buffer[scanline*3*GAME_DISPLAY_WIDTH + 3*offset] = 255*(val&7)/7;
                video_buffer[scanline*3*GAME_DISPLAY_WIDTH + 3*offset + 1] = 255*((val>>3)&7)/7;
                video_buffer[scanline*3*GAME_DISPLAY_WIDTH + 3*offset + 2] = 255*((val>>5)&6)/7;
            } else {
                uint8_t val = avr->pc >> 3;
                video_buffer[scanline*3*GAME_DISPLAY_WIDTH + 3*offset + 0] += val;
                video_buffer[scanline*3*GAME_DISPLAY_WIDTH + 3*offset + 1] += val;
                video_buffer[scanline*3*GAME_DISPLAY_WIDTH + 3*offset + 2] += val;
            }
        }

        if (vsync2 == AVR_PIN_LOW && vsync != vsync2) {
            for (int i = 0; i < GAME_DISPLAY_WIDTH; i++) {
                video_buffer[scanline*3*GAME_DISPLAY_WIDTH+3*i] = 255;
            }
            scanline = 0;
            offset = 0;
            break;
        }

        if (avr->status == MCU_STATUS_CRASHED) {
            avr_dump(avr, NULL);
            exit(1);
        }

        enum avr_pin_state controller_clock = avr_io_read(avr, CONTROLLER_PORT, CONTROLLER_CLOCK_PIN);
        enum avr_pin_state controller_latch = avr_io_read(avr, CONTROLLER_PORT, CONTROLLER_LATCH_PIN);
        if (controller_latch == AVR_PIN_HIGH) {
            controller.latched = controller.value;
            if (controller.latched & 1) {
                avr_io_write(avr, CONTROLLER_PORT, CONTROLLER_DATA_PIN, AVR_PIN_HIGH);
            } else {
                avr_io_write(avr, CONTROLLER_PORT, CONTROLLER_DATA_PIN, AVR_PIN_LOW);
            }
        } else if (controller_clock != controller.clock) {
            if (controller_clock == AVR_PIN_LOW) {
                controller.latched >>= 1;
                if (controller.latched & 1) {
                    avr_io_write(avr, CONTROLLER_PORT, CONTROLLER_DATA_PIN, AVR_PIN_HIGH);
                } else {
                    avr_io_write(avr, CONTROLLER_PORT, CONTROLLER_DATA_PIN, AVR_PIN_LOW);
                }
            }
            controller.clock = controller_clock;
        }
    }

    SDL_QueueAudio(audio_device, audio_buffer, sizeof(*audio_buffer)*samples);
}

void fps_delay(uint64_t timer_start) {
    const uint64_t expected_frametime = 1000/TRUE_FPS;
    uint64_t timer_end = SDL_GetPerformanceCounter();
    uint64_t frametime = 1000 * (timer_end - timer_start) / SDL_GetPerformanceFrequency();

    // a bit loose, but prevents crazy FPS and vsync should pick up the slack
    if (frametime < expected_frametime-2) {
        SDL_Delay(expected_frametime-frametime-1);
    }
}

void set_control_bit(int bit, int val) {
    if (val) controller.value |= (1 << bit);
    else controller.value &= ~(1 << bit);
}

void handle_events(void) {
    SDL_Event event;
    while (SDL_PollEvent(&event)) {
        if (event.type == SDL_KEYDOWN || event.type == SDL_KEYUP) {
            switch (event.key.keysym.sym) {
                case SDLK_UP:
                    set_control_bit(4, event.type == SDL_KEYUP);
                    break;
                case SDLK_LEFT:
                    set_control_bit(6, event.type == SDL_KEYUP);
                    break;
                case SDLK_DOWN:
                    set_control_bit(5, event.type == SDL_KEYUP);
                    break;
                case SDLK_RIGHT:
                    set_control_bit(7, event.type == SDL_KEYUP);
                    break;
                case SDLK_a:
                case SDLK_RETURN:
                    set_control_bit(0, event.type == SDL_KEYUP);
                    break;
                case SDLK_s:
                    set_control_bit(1, event.type == SDL_KEYUP);
                    break;
                case SDLK_d:
                    set_control_bit(3, event.type == SDL_KEYUP);
                    break;
                case SDLK_f:
                    set_control_bit(2, event.type == SDL_KEYUP);
                    break;
            }
        } else if (event.type == SDL_QUIT) {
            stayin_alive = 0;
        }
    }
}

void loop(void) {
    uint64_t timer_start = SDL_GetPerformanceCounter();
    handle_events();
    run_to_sync();
    fps_delay(timer_start);

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

    if (avr_load_ihex(avr, "bin/afterzhev.hex") != 0) {
        exit(1);
    }

    // set up IO connections
    avr_io_write(avr, HSYNC_PORT, HSYNC_PIN, AVR_PIN_PULLDOWN);
    avr_io_write(avr, VSYNC_PORT, VSYNC_PIN, AVR_PIN_PULLDOWN);
    avr_io_write(avr, VIDEO_PORT, 0, AVR_PIN_PULLDOWN);
    avr_io_write(avr, VIDEO_PORT, 1, AVR_PIN_PULLDOWN);
    avr_io_write(avr, VIDEO_PORT, 2, AVR_PIN_PULLDOWN);
    avr_io_write(avr, VIDEO_PORT, 3, AVR_PIN_PULLDOWN);
    avr_io_write(avr, VIDEO_PORT, 4, AVR_PIN_PULLDOWN);
    avr_io_write(avr, VIDEO_PORT, 5, AVR_PIN_PULLDOWN);
    avr_io_write(avr, VIDEO_PORT, 6, AVR_PIN_PULLDOWN);
    avr_io_write(avr, VIDEO_PORT, 7, AVR_PIN_PULLDOWN);
    avr_io_write(avr, AUDIO_PORT, 0, AVR_PIN_PULLDOWN);
    avr_io_write(avr, AUDIO_PORT, 1, AVR_PIN_PULLDOWN);
    avr_io_write(avr, AUDIO_PORT, 2, AVR_PIN_PULLDOWN);
    avr_io_write(avr, AUDIO_PORT, 3, AVR_PIN_PULLDOWN);
    avr_io_write(avr, AUDIO_PORT, 4, AVR_PIN_PULLDOWN);
    avr_io_write(avr, AUDIO_PORT, 5, AVR_PIN_PULLDOWN);
    avr_io_write(avr, AUDIO_PORT, 6, AVR_PIN_PULLDOWN);
    avr_io_write(avr, AUDIO_PORT, 7, AVR_PIN_PULLDOWN);
    avr_io_write(avr, CONTROLLER_PORT, CONTROLLER_LATCH_PIN, AVR_PIN_PULLDOWN);
    avr_io_write(avr, CONTROLLER_PORT, CONTROLLER_CLOCK_PIN, AVR_PIN_PULLDOWN);
    avr_io_write(avr, CONTROLLER_PORT, CONTROLLER_DATA_PIN, AVR_PIN_HIGH);

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
