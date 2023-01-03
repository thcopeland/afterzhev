#include <GL/glew.h>
#include <GLFW/glfw3.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include "slimavr-0.1.4/slimavr.h"
#include "minimal_model.h"

#ifdef EMSCRIPTEN
#include <emscripten.h>
#else
#include <pthread.h>
#endif

#define GAME_DISPLAY_WIDTH 120
#define GAME_DISPLAY_HEIGHT 66
#define SCALE 8

struct avr *avr;
volatile int sync_hold;

const char *vertex_shader_src =                                                 \
"#version 300 es\n"                                                             \
"in vec3 aPos;\n"                                                               \
"in vec2 aTexCoord;\n"                                                          \
"out vec2 texCoord;\n"                                                          \
"void main() {\n"                                                               \
"   gl_Position = vec4(aPos, 1.0);\n"                                           \
"   texCoord = aTexCoord;\n"                                                    \
"}";

const char *fragment_shader_src =                                               \
"#version 300 es\n"                                                             \
"precision mediump float;\n"                                                    \
"out vec4 FragColor;\n"                                                         \
"in vec2 texCoord;\n"                                                           \
"uniform sampler2D tex;\n"                                                      \
"uniform int mask;\n"                                                           \
"void main() { \n"                                                              \
"    int val = mask & int(255.0*texture(tex, texCoord).r);\n"                   \
"    FragColor = vec4(float(val&7) / 7.0,\n"                                    \
"                     float((val>>3)&7) / 7.0,\n"                               \
"                     float((val>>5)&6) / 7.0, 1.0);\n"                         \
"}";

float quad_vertices[] = {
   // positions         // texture coords
    1.0f,  1.0f, 0.0f,  1.0f, 0.0f, // top right
    1.0f, -1.0f, 0.0f,  1.0f, 1.0f, // bottom right
   -1.0f, -1.0f, 0.0f,  0.0f, 1.0f, // bottom left
   -1.0f,  1.0f, 0.0f,  0.0f, 0.0f  // top left
};

unsigned quad_indices[] = {
    0, 1, 3,
    1, 2, 3
};

GLFWwindow *window;
unsigned program;

unsigned compileShaderProgram(const char *vertex_src, const char *frag_src) {
    int success;
    char log[512];

    unsigned vs = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vs, 1, &vertex_src, NULL);
    glCompileShader(vs);
    glGetShaderiv(vs, GL_COMPILE_STATUS, &success);
    if(!success) {
        glGetShaderInfoLog(vs, sizeof(log), NULL, log);
        printf("Vertex shader compilation error: %s\n", log);
        exit(1);
    }

    unsigned fs = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fs, 1, &frag_src, NULL);
    glCompileShader(fs);
    glGetShaderiv(fs, GL_COMPILE_STATUS, &success);
    if(!success) {
        glGetShaderInfoLog(fs, sizeof(log), NULL, log);
        printf("Fragment shader compilation error: %s\n", log);
        exit(1);
    }

    unsigned shader = glCreateProgram();
    glAttachShader(shader, vs);
    glAttachShader(shader, fs);
    glLinkProgram(shader);
    glGetProgramiv(shader, GL_LINK_STATUS, &success);
    if(!success) {
        glGetProgramInfoLog(shader, sizeof(log), NULL, log);
        printf("Shader linking error: %s\n", log);
        exit(1);
    }
    glDeleteShader(vs);
    glDeleteShader(fs);
    return shader;
}

void run_to_sync(void) {
    while (1) {
        uint8_t sync = avr->mem[0x25] & 0x80;
        avr_step(avr);
        avr_step(avr);

        if ((0x80 & avr->mem[0x25]) ^ sync) {
            sync_hold = 1; // synchronize to framerate
            break;
        } else if (avr->status == CPU_STATUS_CRASHED) {
            fprintf(stderr, "CPU crashed (%d)\n", avr->error);
            exit(0);
        }
    }
}

void *run_game(void *unused) {
    (void) unused;

    while (1) {
        if (sync_hold) {
            usleep(1000);
        } else {
            run_to_sync();
        }
    }
}

void window_resize_callback(GLFWwindow* window, int width, int height) {
    (void) window;
    glViewport(0, 0, width, height);
}

void set_control_bit(int bit, int val) {
    if (val) avr->mem[0x26] |= (1 << bit);
    else avr->mem[0x26] &= ~(1 << bit);
}

void window_key_callback(GLFWwindow* window, int key, int scancode, int action, int mods) {
    (void) scancode;
    (void) mods;

    switch (key) {
        case GLFW_KEY_ESCAPE:
            glfwSetWindowShouldClose(window, 1);
            break;
        case GLFW_KEY_W:
            set_control_bit(7, action == GLFW_RELEASE);
            break;
        case GLFW_KEY_A:
            set_control_bit(5, action == GLFW_RELEASE);
            break;
        case GLFW_KEY_S:
            set_control_bit(6, action == GLFW_RELEASE);
            break;
        case GLFW_KEY_D:
            set_control_bit(4, action == GLFW_RELEASE);
            break;
        case GLFW_KEY_1:
            set_control_bit(3, action == GLFW_RELEASE);
            break;
        case GLFW_KEY_2:
            set_control_bit(2, action == GLFW_RELEASE);
            break;
        case GLFW_KEY_3:
            set_control_bit(1, action == GLFW_RELEASE);
            break;
        case GLFW_KEY_4:
            set_control_bit(0, action == GLFW_RELEASE);
            break;
    }
}

void loop() {
#ifdef EMSCRIPTEN
    run_to_sync();
#endif

    if (sync_hold) {
        int loc = glGetUniformLocation(program, "mask");
        glProgramUniform1i(program, loc, avr->mem[0x21]);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_R8, GAME_DISPLAY_WIDTH, GAME_DISPLAY_HEIGHT, 0, GL_RED, GL_UNSIGNED_BYTE, avr->ram);
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
        glfwSwapBuffers(window);
        sync_hold = 0;
    }

    glfwPollEvents();
}

int main(int argc, char **argv) {
    // using a stripped-down ATmega 2560 for emulation for performance
    avr = avr_init(AFTERZHEV_MINIMAL_MODEL);
    avr->mem[0x26] = 0xff;

    if (avr_load_ihex(avr, "bin/main.hex") != 0) {
        exit(1);
    }

    glfwInit();
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    window = glfwCreateWindow(GAME_DISPLAY_WIDTH*SCALE, GAME_DISPLAY_HEIGHT*SCALE, "AfterZhev", NULL, NULL);
    if (!window) {
        printf("Error: Unable to create a window with GLFW\n");
        glfwTerminate();
        exit(1);
    }
    glfwSetWindowSizeCallback(window, window_resize_callback);
    glfwMakeContextCurrent(window);
    glfwSetKeyCallback(window, window_key_callback);
    glewInit();
    glClearColor(0, 0, 0, 1);
    glViewport(0, 0, GAME_DISPLAY_WIDTH*SCALE, GAME_DISPLAY_HEIGHT*SCALE);

    program = compileShaderProgram(vertex_shader_src, fragment_shader_src);
    glUseProgram(program);

    unsigned texture;
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_R8, GAME_DISPLAY_WIDTH, GAME_DISPLAY_HEIGHT, 0, GL_RED, GL_UNSIGNED_BYTE, avr->ram);

    unsigned vao, vbo, ebo;
    glGenVertexArrays(1, &vao);
    glGenBuffers(1, &vbo);
    glGenBuffers(1, &ebo);
    glBindVertexArray(vao);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(quad_vertices), quad_vertices, GL_STATIC_DRAW);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)0);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)(3 * sizeof(float)));
    glEnableVertexAttribArray(1);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(quad_indices), quad_indices, GL_STATIC_DRAW);

#ifdef EMSCRIPTEN
    emscripten_set_main_loop(&loop, 0, 1);
#else
    pthread_t run;
    pthread_create(&run, NULL, run_game, NULL);

    while(!glfwWindowShouldClose(window)) {
        loop();
    }
#endif

    glfwTerminate();
    return 0;
}
