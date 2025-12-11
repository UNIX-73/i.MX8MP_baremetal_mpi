#include <drivers/uart/uart.h>
#include <kernel/panic.h>
#include <lib/kernel_utils.h>
#include <lib/stdint.h>
#include <lib/stdmacros.h>
#include <lib/string.h>

#include "lib/memcpy.h"

extern void rust_test_panic();

static void kernel_init()
{
	init_panic();
	UART_init(UART_ID_2);
}

_Noreturn void kernel_entry()
{
	kernel_init();

	while (true) {
		uint8 data;

		if (UART_read(UART_ID_2, &data)) {
			UART_putc(UART_ID_2, data);
		}
	}

#ifdef TEST
	test_memcpy(0);
#endif

	loop {}
}