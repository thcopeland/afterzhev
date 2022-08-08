// This simulates the game using the slimavr simulator, which is fast
// but also incomplete and may still have bugs.

#include <stdlib.h>
#include <GL/glut.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <pthread.h>
#include "slimavr-0.1.1/slimavr.h"

#define GAME_DISPLAY_WIDTH 120
#define GAME_DISPLAY_HEIGHT 69
#define SCALE 8

static struct avr *avr;

void keypress(unsigned char c, int unused1, int unused2) {
    switch(c) {
        case 'w':
            avr->mem[0x26] &= ~(1 << 7);
            break;
        case 'a':
            avr->mem[0x26] &= ~(1 << 5);
            break;
        case 's':
            avr->mem[0x26] &= ~(1 << 6);
            break;
        case 'd':
            avr->mem[0x26] &= ~(1 << 4);
            break;
        case '1':
            avr->mem[0x26] &= ~(1 << 3);
            break;
        case '2':
            avr->mem[0x26] &= ~(1 << 2);
            break;
        case '3':
            avr->mem[0x26] &= ~(1 << 1);
            break;
        case '4':
            avr->mem[0x26] &= ~(1 << 0);
            break;
        case 27:
            exit(0);
    }
}

void keyrelease(unsigned char c, int unused1, int unused2) {
    switch(c) {
        case 'w':
            avr->mem[0x26] |= (1 << 7);
            break;
        case 'a':
            avr->mem[0x26] |= (1 << 5);
            break;
        case 's':
            avr->mem[0x26] |= (1 << 6);
            break;
        case 'd':
            avr->mem[0x26] |= (1 << 4);
            break;
        case '1':
            avr->mem[0x26] |= (1 << 3);
            break;
        case '2':
            avr->mem[0x26] |= (1 << 2);
            break;
        case '3':
            avr->mem[0x26] |= (1 << 1);
            break;
        case '4':
            avr->mem[0x26] |= (1 << 0);
            break;
    }
}

void *run_game(void *unused) {
    while (1) {
        avr_step(avr);

        if (avr->status == CPU_STATUS_CRASHED) {
            fprintf(stderr, "CPU crashed (%d)\n", avr->error);
            exit(0);
        }
    }
}

void render(void) {
    static uint8_t sync;

    if (avr->pc < 1000 && avr->mem[0x25] != sync) {
        sync = avr->mem[0x25];

        glClear(GL_COLOR_BUFFER_BIT);
        glBegin(GL_QUADS);
        for (int row = 0; row < GAME_DISPLAY_HEIGHT; row++) {
            for (int col = 0; col < GAME_DISPLAY_WIDTH; col++) {
                unsigned char color = avr->ram[row*GAME_DISPLAY_WIDTH+col];
                float red = (color&7) / 7.0,
                      green = ((color>>3)&7) / 7.0,
                      blue = ((color>>5)&6) / 7.0;
                glColor3f(red, green, blue);
                glVertex2f((float) col/GAME_DISPLAY_WIDTH, (float) row/GAME_DISPLAY_HEIGHT);
                glVertex2f((float) (col+1)/GAME_DISPLAY_WIDTH, (float) row/GAME_DISPLAY_HEIGHT);
                glVertex2f((float) (col+1)/GAME_DISPLAY_WIDTH, (float) (row+1)/GAME_DISPLAY_HEIGHT);
                glVertex2f((float) col/GAME_DISPLAY_WIDTH, (float) (row+1)/GAME_DISPLAY_HEIGHT);
            }
        }
        glEnd();
        glFlush();
        usleep(12000);
    } else {
        usleep(5000);
    }

    glutPostRedisplay();
}

int main(int argc, char **argv) {
    struct avr_model model = AVR_MODEL_ATMEGA2560;
    if (argc > 1 && strcmp(argv[0], "atmega1280") == 0) {
      model = AVR_MODEL_ATMEGA1280;
    }

    avr = avr_init(model);
    avr->mem[0x26] = 0xff;

    if (avr_load_ihex(avr, "bin/main.hex") != 0) {
        exit(1);
    }

    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_SINGLE);
    glutInitWindowSize(GAME_DISPLAY_WIDTH*SCALE, GAME_DISPLAY_HEIGHT*SCALE);
    glutInitWindowPosition(0, 0);
    glutCreateWindow("AfterZhev Simulator");
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glScalef(1, -1, 1);
    glTranslatef(-1, -1, 0);
    glScalef(2, 2, 1);
    glutDisplayFunc(render);
    glutKeyboardFunc(keypress);
    glutKeyboardUpFunc(keyrelease);
    glutSetKeyRepeat(GLUT_KEY_REPEAT_OFF);

    pthread_t run;
	  pthread_create(&run, NULL, run_game, NULL);

    glutMainLoop();

    return 0;
}
