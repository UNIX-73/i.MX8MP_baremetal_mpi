
#include "arm/sysregs.h"
#include "drivers/interrupts/interrupts.h"
#define DRIVERS

#include <arm/exceptions/exceptions.h>
#include <boot/panic.h>
#include <drivers/interrupts/gicv3/gicv3.h>
#include <drivers/uart/uart.h>
#include <lib/memcpy.h>
#include <lib/stdint.h>
#include <lib/stdmacros.h>
#include <lib/string.h>

#include "arm/cpu.h"
#include "drivers/interrupts/gicv3/gicv3_raw/gicr_typer.h"

static void kernel_init()
{
	UART_init(UART_ID_2);

	ARM_exceptions_set_status((ARM_exception_status){
		.fiq = true,
		.irq = true,
		.serror = true,
		.debug = true,
	});

	GICV3_init_distributor();
	GICV3_init_cpu(ARM_get_cpu_affinity().aff0);
	uart_irq_init();
}

extern uint64 _ARM_ICC_SRE_EL2();
extern uint64 _ARM_HCR_EL2();
extern void _switch_to_el1();

// Main function of the kernel, called by the bootloader (/boot/boot.S)
_Noreturn void kernel_entry()
{
	kernel_init();

	UART_puts(UART_ID_2, "Hello test!\n\r");

	char buf[500];

	for (size_t i = 0; i < 4; i++) {
		GicrTyper r = GICV3_GICR_TYPER_read(i);

		uint32 affinity =
			U32_FROM_CPU_AFFINITY(GICV3_GICR_TYPER_BF_get_AffinityValue(r));

		UART_puts(UART_ID_2, "ID: ");
		UART_puts(UART_ID_2, stdint_to_ascii((STDINT_UNION){.uint32 = affinity},
											 STDINT_UINT32, buf, 500,
											 STDINT_BASE_REPR_BIN));
		UART_puts(UART_ID_2, "\n\r");
	}

	UART_puts(UART_ID_2, "\n\r");

	size_t el = ARM_get_exception_level();
	UART_puts(UART_ID_2,
			  stdint_to_ascii((STDINT_UNION){.uint64 = el}, STDINT_UINT64, buf,
							  500, STDINT_BASE_REPR_DEC));

	UART_puts(UART_ID_2, "\n\rSCTLR_EL1: ");
	UART_puts(UART_ID_2,
			  stdint_to_ascii((STDINT_UNION){.uint64 = _ARM_SCTLR_EL1()},
							  STDINT_UINT64, buf, 500, STDINT_BASE_REPR_BIN));

	loop
	{
		uint8 data;

		if (UART_read(UART_ID_2, &data)) {
			UART_putc(UART_ID_2, data);
		}
	}

	loop {}
}