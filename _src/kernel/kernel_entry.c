#include <drivers/uart/uart.h>
#include <lib/kernel_utils.h>
#include <lib/stdmacros.h>

#include "lib/stdint.h"

extern uint64 rust_add(uint64 a, uint64 b);

void kernel_entry()
{
	UART_putc(UART_ID_2, (uint8)(_currentEL() + 48));

	UART_puts(UART_ID_2, "Hello world\n\r");

	// UART_reset(UART_ID_2);

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