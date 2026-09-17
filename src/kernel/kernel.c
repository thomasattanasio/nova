#include "kernel/terminal.h"


void kernel_main(void) {
    terminal_initialize();
    terminal_write("NOVA_OS");


    while (1) {
        __asm__ volatile ("hlt");
    }
}
