#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "SDL.h"

#define SAMPLING_RATE 44100
#define AUDIO_BUFFER_SIZE 2048

// -24.upto(23).map {|i| [440*(2**(i/12.0))*256*256/3900.0, ["A", "Bb", "B", "C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab"][i%12]+(i/12+4).to_s]}.each {|hz, n| puts "#define NOTE_#{n.ljust(3)} = #{hz.round}" }; nil

#define NOTE_A2  0
#define NOTE_Bb2 1
#define NOTE_B2  2
#define NOTE_C2  3
#define NOTE_Db2 4
#define NOTE_D2  5
#define NOTE_Eb2 6
#define NOTE_E2  7
#define NOTE_F2  8
#define NOTE_Gb2 9
#define NOTE_G2  10
#define NOTE_Ab2 11
#define NOTE_A3  12
#define NOTE_Bb3 13
#define NOTE_B3  14
#define NOTE_C3  15
#define NOTE_Db3 16
#define NOTE_D3  17
#define NOTE_Eb3 18
#define NOTE_E3  19
#define NOTE_F3  20
#define NOTE_Gb3 21
#define NOTE_G3  22
#define NOTE_Ab3 23
#define NOTE_A4  24
#define NOTE_Bb4 25
#define NOTE_B4  26
#define NOTE_C4  27
#define NOTE_Db4 28
#define NOTE_D4  29
#define NOTE_Eb4 30
#define NOTE_E4  31
#define NOTE_F4  32
#define NOTE_Gb4 33
#define NOTE_G4  34
#define NOTE_Ab4 35
#define NOTE_A5  36
#define NOTE_Bb5 37
#define NOTE_B5  38
#define NOTE_C5  39
#define NOTE_Db5 40
#define NOTE_D5  41
#define NOTE_Eb5 42
#define NOTE_E5  43
#define NOTE_F5  44
#define NOTE_Gb5 45
#define NOTE_G5  46
#define NOTE_Ab5 47

int dphase_table[] = {163, 173, 183, 194, 206, 218, 231, 245, 259, 275, 291, 309, 327, 346, 367, 389, 412, 436, 462, 490, 519, 550, 583, 617, 654, 693, 734, 778, 824, 873, 925, 980, 1038, 1100, 1165, 1234, 1308, 1386, 1468, 1555, 1648, 1746, 1849, 1959, 2076, 2199, 2330, 2469};
int a_harmonic_minor[] = {NOTE_A4, NOTE_B4, NOTE_C4, NOTE_D4, NOTE_E4, NOTE_F4, NOTE_Ab4};
int a_harmonic_major[] = {NOTE_A4, NOTE_B4, NOTE_Db4, NOTE_D4, NOTE_E4, NOTE_F4, NOTE_Ab4};
int notes[] = {24, 31, 24, 32, 39, 31, 39, 24, 28, 35, 32, 24, 32, 24, 28, 39, 24, 31, 28, 24, 28, 39, 35, 24, 35, 32, 24, 39, 28, 24, 35, 24, 28, 24, 31, 24, 26, 35, 28, 39, 24, 26, 35, 28, 31, 39, 24, 26, 35, 28, 39, 28, 35, 32, 35, 24, 35, 39, 32, 24, 35, 31, 32, 39, 32, 24, 32, 31, 24, 35, 24, 39, 24, 35, 24, 26, 24, 26, 35, 28, 31, 28, 31, 24, 35, 24, 35, 24, 32, 24, 32, 35, 28, 26, 31, 39, 24, 28, 35, 32, 28};
// int notes2[] = { NOTE_A5, NOTE_D5, NOTE_A5, NOTE_F4 };
int notes2[] = {NOTE_A4, NOTE_B4, NOTE_C4, NOTE_D4, NOTE_E4, NOTE_F4, NOTE_Ab4};

struct channel {
    int *src;
    uint16_t place;
    uint16_t end;
    uint16_t phase;
    uint16_t duration;
};

struct channel channel1 = {
    .src = notes,
    .place = 0,
    .end = sizeof(notes)/sizeof(notes[0]),
    .phase = 0,
    .duration = 20000
};

struct channel channel2 = {
    .src = notes2,
    .place = 0,
    .end = sizeof(notes2)/sizeof(notes2[0]),
    .phase = 0,
    .duration = 20000
};

SDL_AudioDeviceID audio_device;

void audio_callback(void *udata, uint8_t *buffer, int len) {
    (void) udata;
    int16_t *stream = (int16_t*) buffer;
    len /= sizeof(stream[0]);

    for (int i = 0; i < len; i++) {
        uint16_t note1 = channel1.src[channel1.place]-24;
        uint16_t note2 = channel2.src[channel2.place]-12;

        channel1.phase += dphase_table[note1];
        channel2.phase += dphase_table[note2];

        if (--channel1.duration == 0) {
            channel1.duration = (rand() % 2) ? 20000 : 10000;
            channel1.phase = 0;
            channel1.place = (channel1.place + 1) % channel1.end;
        }

        if (--channel2.duration == 0) {
            channel2.duration = 40000;
            channel2.phase = 0;
            channel2.place = (channel2.place + 1) % channel2.end;
        }

        stream[i] = channel1.phase/400 + (channel2.phase > 32000 ? 16384 : 0)/2;
    }
}

int stayin_alive = 1;

void handle_events(void) {
    SDL_Event event;
    while (SDL_PollEvent(&event)) {
        if (event.type == SDL_QUIT) {
            stayin_alive = 0;
        }
    }
    SDL_Delay(100);
}

int main(int argc, char **argv) {
    (void) argc;
    (void) argv;

    if (SDL_Init(SDL_INIT_AUDIO) < 0) {
        fprintf(stderr, "unable to initialize SDL: %s\n", SDL_GetError());
        return 1;
    }

    SDL_AudioSpec out_spec, in_spec = {
        .freq = SAMPLING_RATE,
        .format = AUDIO_S16,
        .channels = 1,
        .samples = AUDIO_BUFFER_SIZE,
        .callback = audio_callback
    };

    audio_device = SDL_OpenAudioDevice(NULL, 0, &in_spec, &out_spec, 0);
    SDL_PauseAudioDevice(audio_device, 0);

    while (stayin_alive) handle_events();

    SDL_CloseAudioDevice(audio_device);
    SDL_Quit();
    return 0;
}
