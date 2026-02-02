#include "panic_puts.h"

#include <lib/stdarg.h>
#include <lib/string.h>

#include "kernel/io/term.h"


static void panic_putc_colored(char c)
{
    term_printc(c);

    if (c == '\n') {
        const char* str = "\r" ANSI_ERASE_LINE;

        while (*str)
            term_printc(*str++);
    }
}


void panic_puts(const char* s, ...)
{
    va_list ap;
    va_start(ap, s);

    str_fmt_print(panic_putc_colored, s, ap);

    va_end(ap);
}
