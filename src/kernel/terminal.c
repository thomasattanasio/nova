#include <stdint.h>


static volatile uint16_t *const video_memory = (uint16_t *)0xB8000;


void terminal_initialize(void) {
    for (uint16_t i = 0; i < 80 * 25; i++) {
        video_memory[i] = ((uint16_t)0x07 << 8) | ' ';
    }
}


void terminal_write(const char *string) {
    uint16_t position = 0;


    while (string[position] != '\0') {
        video_memory[position] = ((uint16_t)0x07 << 8) | string[position];


        position++;
    }
}
