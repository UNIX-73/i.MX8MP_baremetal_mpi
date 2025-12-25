#include <arm/exceptions/exceptions.h>
#include <boot/panic.h>
#include <drivers/interrupts/gicv3/gicv3.h>
#include <drivers/uart/uart.h>
#include <kernel/init.h>
#include <lib/memcpy.h>
#include <lib/stdint.h>
#include <lib/stdmacros.h>
#include <lib/string.h>

extern uint64 _ARM_ICC_SRE_EL2();
extern uint64 _ARM_HCR_EL2();
extern void _switch_to_el1();

// Main function of the kernel, called by the bootloader (/boot/boot.S)
_Noreturn void kernel_entry()
{
	kernel_init();

	UART_puts(UART_ID_2, "Hello world!\n\r");

	uint8 data;
	while (1) {
		if (UART_read(UART_ID_2, &data)) {
			UART_putc(UART_ID_2, data);
		}
	}

	loop {}
}