#include "kernel/terminal.h"


void kernel_main(void) {
    terminal_initialize();


    terminal_write("NOVA ");
    terminal_write("Kernel");


    while (1) {
        __asm__ volatile ("hlt");
    }
}
