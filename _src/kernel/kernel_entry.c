#include <drivers/uart/uart.h>
#include <kernel/panic.h>
#include <lib/kernel_utils.h>
#include <lib/stdint.h>
#include <lib/stdmacros.h>
#include <lib/string.h>

void kernel_entry()
{
	init_panic();

	UART_putc(UART_ID_2, (uint8)(_currentEL() + 48));

	UART_puts(UART_ID_2, "Hello world\n\r");

	int64 test_v = -0x0;

	test_stdint_to_ascii(test_v, 67);

	PANIC(":)");

	UART_init(UART_ID_2);

	//	UART_puts(UART_ID_2, "Hello world :)\n\r");

	FOREVER {}

	FOREVER
	{
		UART_puts(UART_ID_2, "Hello world :)\n\r");

		for (volatile int i = 0; i < 20000; i++) {
			asm volatile("nop");
			asm volatile("nop");
			asm volatile("nop");
			asm volatile("nop");
			asm volatile("nop");
		}
	}
}