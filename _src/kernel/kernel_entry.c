#include <arm/exceptions/exceptions.h>
#include <boot/panic.h>
#include <drivers/interrupts/gicv3/gicv3.h>
#include <drivers/uart/uart.h>
#include <kernel/init.h>
#include <lib/memcpy.h>
#include <lib/stdint.h>
#include <lib/stdmacros.h>
#include <lib/string.h>

#include "drivers/arm_generic_timer/arm_generic_timer.h"
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

	uint8 data;
	while (1) {
		if (UART_read(&UART2_DRIVER, &data)) {
			uint64 time = AGT_cnt_time_us();

			stdint_to_ascii((STDINT_UNION){.uint64 = time}, STDINT_UINT64, buf1,
							100, STDINT_BASE_REPR_DEC);

			UART_puts(&UART2_DRIVER, buf1);
			UART_puts(&UART2_DRIVER, "\n\r");

			AGT_timer_schedule_delta(&AGT0_DRIVER, 100, NULL, NULL);
		}
	}

	loop {}
}