#include <arm/exceptions/exceptions.h>
#include <boot/panic.h>
#include <drivers/interrupts/gicv3/gicv3.h>
#include <drivers/uart/uart.h>
#include <kernel/init.h>
#include <lib/stdint.h>

extern kernel_initcall_t __kernel_init_start[];
extern kernel_initcall_t __kernel_init_end[];

void kernel_init(void)
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

#if TEST
	if (((uintptr)__kernel_init_start & 0x7) ||
		((uintptr)__kernel_init_end & 0x7)) {
		PANIC("kernel_init section not 8 byte aligned");
	}
#endif

	for (kernel_initcall_t *fn = __kernel_init_start; fn < __kernel_init_end;
		 fn++) {
		(*fn)();
	}
}
