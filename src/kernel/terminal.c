#include <stdint.h>


static volatile uint16_t *const video_memory = (uint16_t *)0xB8000;

static uint16_t terminal_row;
static uint16_t terminal_column;


void terminal_initialize(void) {
    terminal_row = 0;
    terminal_column = 0;


    for (uint16_t i = 0; i < 80 * 25; i++) {
        video_memory[i] = ((uint16_t)0x07 << 8) | ' ';
    }
}


void terminal_write(const char *string) {
    while (*string != '\0') {
        video_memory[terminal_row * 80 + terminal_column] = ((uint16_t)0x07 << 8) | *string;


        terminal_column++;


        if (terminal_column >= 80) {
            terminal_column = 0;
            terminal_row++;
        }


        string++;
    }
}
