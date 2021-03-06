#include <stdlib.h>
#include <GL/glut.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <pthread.h>

#include <simavr/sim_avr.h>
#include <simavr/avr_ioport.h>
#include <simavr/sim_hex.h>

#define GAME_DISPLAY_WIDTH 120
#define GAME_DISPLAY_HEIGHT 69
#define SCALE 8

#define RAMEND 0x2200
#ifndef TRACE
#define TRACE 0
#endif

avr_t *avr;
unsigned t = 0;
unsigned best_sp = RAMEND;
unsigned long stack_sizes[40];

void keypress(unsigned char c, int x, int y) {
    switch(c) {
        case 'w':
            avr->data[0x26] &= ~(1 << 7);
            break;
        case 'a':
            avr->data[0x26] &= ~(1 << 5);
            break;
        case 's':
            avr->data[0x26] &= ~(1 << 6);
            break;
        case 'd':
            avr->data[0x26] &= ~(1 << 4);
            break;
        case '1':
            avr->data[0x26] &= ~(1 << 3);
            break;
        case '2':
            avr->data[0x26] &= ~(1 << 2);
            break;
        case '3':
            avr->data[0x26] &= ~(1 << 1);
            break;
        case '4':
            avr->data[0x26] &= ~(1 << 0);
            break;
        case 27:
            #if TRACE != 0
            printf("Stack size frequencies:\n");
            for (int i = 0; i < 40; i++) {
                printf("%02i: %li\n", i, stack_sizes[i]);
            }
            #endif
            exit(0);
    }
}

void keyrelease(unsigned char c, int x, int y) {
    switch(c) {
        case 'w':
            avr->data[0x26] |= (1 << 7);
            break;
        case 'a':
            avr->data[0x26] |= (1 << 5);
            break;
        case 's':
            avr->data[0x26] |= (1 << 6);
            break;
        case 'd':
            avr->data[0x26] |= (1 << 4);
            break;
        case '1':
            avr->data[0x26] |= (1 << 3);
            break;
        case '2':
            avr->data[0x26] |= (1 << 2);
            break;
        case '3':
            avr->data[0x26] |= (1 << 1);
            break;
        case '4':
            avr->data[0x26] |= (1 << 0);
            break;
    }
}

void *run_game(void *x) {
    while (1) {
        int state = avr_run(avr);
        t++;

        #if TRACE != 0
        // log stack usage
        unsigned char spl = avr->data[0x5d],
                      sph = avr->data[0x5e];
        unsigned sp = (sph<<8)|spl;
        unsigned stack_size = RAMEND-sp;
        stack_sizes[stack_size]++;
        if (sp < best_sp) {
            best_sp = sp;
            printf("0x%04X: (%02u bytes) ", avr->pc, stack_size);
            for (int i = sp; i < RAMEND; i++) printf("%02x ", avr->data[i]);
            printf("\n");
        }
        #endif

        if (state == cpu_Done) {
            exit(0);
        } else if (state == cpu_Crashed) {
            fprintf(stderr, "CPU crashed\n");
            exit(0);
        }
    }
}

void render(void) {
    if (avr->pc < 1000 && t > 26660) {
        t = 0;
        glClear(GL_COLOR_BUFFER_BIT);
        glBegin(GL_QUADS);
        for (int row = 0; row < GAME_DISPLAY_HEIGHT; row++) {
            for (int col = 0; col < GAME_DISPLAY_WIDTH; col++) {
                unsigned char color = avr->data[0x200 + row*GAME_DISPLAY_WIDTH+col];
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
    }
    usleep(15000);
    glutPostRedisplay();
}

int main(int argc, char **argv) {
    if (argc < 2) printf("Must specify chip type\n");

    avr = avr_make_mcu_by_name(argv[1]);
    avr_init(avr);
    avr->frequency = 16000000;
    ihex_chunk_p chunks;
    int chunk_count = read_ihex_chunks("bin/main.hex", &chunks);
    avr->pc = chunks[0].baseaddr;
    for (int i = 0; i < chunk_count; i++) {
        ihex_chunk_t chunk = chunks[i];
        memcpy(avr->flash + chunk.baseaddr, chunk.data, chunk.size);
    }
    free_ihex_chunks(chunks);

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
