#include <arm/exceptions/exceptions.h>
#include <boot/panic.h>
#include <drivers/interrupts/gicv3/gicv3.h>
#include <drivers/uart/uart.h>
#include <kernel/init.h>
#include <lib/memcpy.h>
#include <lib/stdint.h>
#include <lib/stdmacros.h>
#include <lib/string.h>

#include "drivers/tmu/tmu.h"
#include "kernel/devices/drivers.h"

extern uint64 _ARM_ICC_SRE_EL2();
extern uint64 _ARM_HCR_EL2();
extern void _switch_to_el1();

// Main function of the kernel, called by the bootloader (/boot/boot.S)
_Noreturn void kernel_entry()
{
	kernel_init();

	UART_puts(&UART2_DRIVER, "Hello world!\n\r");

	char buf1[100];

	int8 warn_temp = 26;

	uint8 data;
	while (1) {
		if (UART_read(&UART2_DRIVER, &data)) {
			int8 temp1 = TMU_get_temp(&TMU_DRIVER);

			stdint_to_ascii((STDINT_UNION){.int8 = temp1}, STDINT_INT8, buf1,
							100, STDINT_BASE_REPR_DEC);

			UART_puts(&UART2_DRIVER, "\n\r");
			UART_puts(&UART2_DRIVER, buf1);

			if (TMU_warn_pending(&TMU_DRIVER)) {
				UART_puts(&UART2_DRIVER, "\n\rWARNING!\n\r");

				TMU_set_warn_temp(&TMU_DRIVER, ++warn_temp);

				TMU_enable_warnings(&TMU_DRIVER);
			}
		}
	}

	loop {}
}