#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "SDL.h"
#include "slimavr-0.1.6/slimavr.h"
#include "minimal_model.h"

#ifdef EMSCRIPTEN
#include <emscripten.h>
#endif

#define TRUE_FPS 60
#define GAME_DISPLAY_WIDTH 120
#define GAME_DISPLAY_HEIGHT 66

#define SAMPLING_RATE 44100
#define AUDIO_BUFFER_SIZE 1024
#define VSYNC_PERIOD 0x41800
#define AUDIO_PERIOD 1024
#define AUDIO_DPHASE_UPSCALE(val) (TRUE_FPS*VSYNC_PERIOD*(val)/AUDIO_PERIOD/SAMPLING_RATE)

#define SYNC_PORT 'B'
#define SYNC_PIN 7
#define VIDEO_MASK 0x21
#define AUDIO_CHANNEL1_ADDR 0x20F0
#define AUDIO_CHANNEL2_ADDR 0x20F4

struct avr *avr;
int stayin_alive = 1;
uint64_t last_counter = 0;
SDL_Window *window;
SDL_Renderer *renderer;
SDL_Texture *framebuffer;
SDL_AudioDeviceID audio_device;

struct channel_data {
    int16_t phase;
    int16_t dphase;
    uint8_t volume;
    uint8_t wave;
};

struct channel_data channel1, channel2;

void generate_audio(void *udata, uint8_t *raw, int len) {
    (void) udata;
    int16_t *stream = (int16_t *) raw;
    len /= sizeof(stream[0])/sizeof(raw[0]);

    // load channel data from AVR memory
    channel1.dphase = AUDIO_DPHASE_UPSCALE((avr->mem[AUDIO_CHANNEL1_ADDR+1]<<8) | avr->mem[AUDIO_CHANNEL1_ADDR]);
    channel1.volume = avr->mem[AUDIO_CHANNEL1_ADDR+2];
    channel1.wave = avr->mem[AUDIO_CHANNEL1_ADDR+3];
    channel2.dphase = AUDIO_DPHASE_UPSCALE((avr->mem[AUDIO_CHANNEL2_ADDR+1]<<8) | avr->mem[AUDIO_CHANNEL2_ADDR]);
    channel2.volume = avr->mem[AUDIO_CHANNEL2_ADDR+2];
    channel2.wave = avr->mem[AUDIO_CHANNEL2_ADDR+3];

    // generate samples (see audio in main.asm)
    for (int i = 0; i < len; i++) {
        channel1.phase += channel1.dphase;
        if (channel1.wave & 0x080) {
            stream[i] = (int16_t) ((rand() & 0xffff)*channel1.volume >> 10);
        } else {
            stream[i] = channel1.phase*channel1.volume >> 10;
        }

        channel2.phase += channel2.dphase;
        if (channel2.wave & 0x080) {
            stream[i] += (int16_t) ((rand() & 0xffff)*channel2.volume >> 10);
        } else {
            stream[i] += channel2.phase*channel2.volume >> 10;
        }

        // simple low-pass filter
        if (i > 0) {
            stream[i] = 7*stream[i]/8 + stream[i-1]/8;
        }
    }
}

void run_to_sync(void) {
    unsigned cycles = 0;

    while (1) {
        enum avr_pin_state sync = avr_io_read(avr, SYNC_PORT, SYNC_PIN);
        avr_step(avr);

        if (avr_io_read(avr, SYNC_PORT, SYNC_PIN) != sync) {
            break;
        } else if (avr->status == MCU_STATUS_CRASHED) {
            avr_dump(avr, NULL);
            exit(1);
        } else if (cycles++ > 2*VSYNC_PERIOD) {
            fprintf(stderr, "game stalled (check build target), exiting...\n");
            exit(1);
        }
    }
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
    if (!val) avr->ram[0x1F01] |= (1 << bit);
    else avr->ram[0x1F01] &= ~(1 << bit);
}

void handle_events(void) {
    SDL_Event event;
    while (SDL_PollEvent(&event)) {
        if (event.type == SDL_KEYDOWN || event.type == SDL_KEYUP) {
            switch (event.key.keysym.sym) {
                case SDLK_UP:
                    set_control_bit(2, event.type == SDL_KEYUP);
                    break;
                case SDLK_LEFT:
                    set_control_bit(3, event.type == SDL_KEYUP);
                    break;
                case SDLK_DOWN:
                    set_control_bit(0, event.type == SDL_KEYUP);
                    break;
                case SDLK_RIGHT:
                    set_control_bit(1, event.type == SDL_KEYUP);
                    break;
                case SDLK_a:
                case SDLK_RETURN:
                    set_control_bit(4, event.type == SDL_KEYUP);
                    break;
                case SDLK_s:
                    set_control_bit(5, event.type == SDL_KEYUP);
                    break;
                case SDLK_d:
                    set_control_bit(6, event.type == SDL_KEYUP);
                    break;
                case SDLK_f:
                    set_control_bit(7, event.type == SDL_KEYUP);
                    break;
            }
        } else if (event.type == SDL_QUIT) {
            stayin_alive = 0;
        }
    }
}

void loop(void) {
#ifdef EMSCRIPTEN
    // Emscripten emulates SDL_Delay() with a busy wait, which isn't great. So
    // instead use a uglier but more efficient method.
    static uint64_t window[4];
    const uint64_t expected_window_time = sizeof(window)/sizeof(window[0])*1000/TRUE_FPS;
    uint64_t time = SDL_GetPerformanceCounter();
    if (window[0] == 0 || (time - window[0]) >= expected_window_time) {
        handle_events();
        run_to_sync();
        for (unsigned i = 1; i < sizeof(window)/sizeof(window[0]); i++) {
            window[i-1] = window[i];
        }
        window[sizeof(window)/sizeof(window[0])-1] = time;
    } else {
        return;
    }
#else
    uint64_t timer_start = SDL_GetPerformanceCounter();
    handle_events();
    run_to_sync();
    fps_delay(timer_start);
#endif

    uint8_t *pixels;
    int pitch;
    SDL_RenderClear(renderer);
    SDL_LockTexture(framebuffer, NULL, (void**)(&pixels), &pitch);
    for (int i = 0; i < GAME_DISPLAY_WIDTH*GAME_DISPLAY_HEIGHT; i++) {
        uint8_t val = avr->ram[i] & avr->mem[VIDEO_MASK];
        pixels[3*i] = 255*(val&7)/7;
        pixels[3*i+1] = 255*((val>>3)&7)/7;
        pixels[3*i+2] = 255*((val>>5)&6)/7;
    }
    SDL_UnlockTexture(framebuffer);
    SDL_RenderCopy(renderer, framebuffer, NULL, NULL);
    SDL_RenderPresent(renderer);
}

#ifdef EMSCRIPTEN
EM_JS(int, request_screen_width, (), {
    return window.innerWidth;
});
#else
int request_screen_width(void) {
    SDL_DisplayMode dm;
    if (SDL_GetDesktopDisplayMode(0, &dm) != 0) {
         SDL_Log("unable to get display mode: %s", SDL_GetError());
         return 1300;
    }
    return dm.w;
}
#endif

int main(int argc, char **argv) {
    (void) argc;
    (void) argv;

    // using a stripped-down ATmega 2560 for performance
    avr = avr_new(AFTERZHEV_MINIMAL_MODEL);

    if (avr_load_ihex(avr, "bin/afterzhev.hex") != 0) {
        exit(1);
    }

    // set up IO connections
    avr_io_write(avr, SYNC_PORT, SYNC_PIN, AVR_PIN_PULLDOWN);

    if (SDL_Init(SDL_INIT_VIDEO|SDL_INIT_AUDIO) < 0) {
        fprintf(stderr, "unable to initialize SDL: %s\n", SDL_GetError());
        return 1;
    }

    int width = 2*request_screen_width()/3;
    int height = GAME_DISPLAY_HEIGHT*width/GAME_DISPLAY_WIDTH;
    window = SDL_CreateWindow("AfterZhev", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, width, height, SDL_WINDOW_RESIZABLE|SDL_WINDOW_HIDDEN);
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
        .callback = generate_audio
    };

    audio_device = SDL_OpenAudioDevice(NULL, 0, &in_spec, &out_spec, 0);
    SDL_PauseAudioDevice(audio_device, 0);

#ifdef EMSCRIPTEN
    printf("This is the PC build of AfterZhev, running on slimavr.\n"
           "Use the arrow keys and ASDF to control the game.\n");
    emscripten_set_main_loop(&loop, 0, 1);
#else
    while (stayin_alive) loop();
#endif

    SDL_DestroyTexture(framebuffer);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_CloseAudioDevice(audio_device);
    SDL_Quit();
    return 0;
}
