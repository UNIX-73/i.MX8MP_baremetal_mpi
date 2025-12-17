#include <arm/exceptions/exceptions.h>
#include <drivers/uart/uart.h>
#include <kernel/panic.h>
#include <lib/memcpy.h>
#include <lib/stdint.h>
#include <lib/stdmacros.h>
#include <lib/string.h>

extern void rust_test_panic();

static void kernel_init()
{
	init_panic();
	UART_init(UART_ID_2);

	/*
	exceptions_set_status((EXCEPTION_STATUS){
		.fiq = true,
		.irq = true,
		.serror = true,
		.debug = true,
	});
	*/
}

// Main function of the kernel, called by the bootloader (/boot/boot.S)
_Noreturn void kernel_entry()
{
	kernel_init();

	UART_puts(UART_ID_2, "Hello test!\n");

	EXCEPTION_STATUS status = exceptions_get_status();

	char *enabled = "enabled\n\r";
	char *disabled = "disabled\n\r";

	UART_puts(UART_ID_2, "Exceptions state:\n\r");

	UART_puts(UART_ID_2, "  FIQ:    ");
	UART_puts(UART_ID_2, status.fiq ? enabled : disabled);

	UART_puts(UART_ID_2, "  IRQ:    ");
	UART_puts(UART_ID_2, status.irq ? enabled : disabled);

	UART_puts(UART_ID_2, "  SError: ");
	UART_puts(UART_ID_2, status.serror ? enabled : disabled);

	UART_puts(UART_ID_2, "  Debug:  ");
	UART_puts(UART_ID_2, status.debug ? enabled : disabled);

	loop
	{
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