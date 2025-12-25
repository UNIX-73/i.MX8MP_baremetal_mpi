#include <boot/panic.h>
#include <drivers/interrupts/interrupts.h>
#include <kernel/init.h>
#include <kernel/irq/handlers/uart.h>
#include <kernel/irq/irq.h>
#include <lib/stdint.h>

static irq_handler_t KERNEL_IRQ_HANDLER_TABLE[IMX8MP_IRQ_SIZE];

static void unhandled_irq() { PANIC("UNHANDLED IRQ"); }

static void init_irq_handler_table()
{
	for (size_t i = 0; i < IMX8MP_IRQ_SIZE; i++) {
		KERNEL_IRQ_HANDLER_TABLE[i] = unhandled_irq;
	}

	// KERNEL_IRQ_HANDLER_TABLE[IMX8MP_IRQ_UART1] = kernel_uart1_irq_handler;
	KERNEL_IRQ_HANDLER_TABLE[IMX8MP_IRQ_UART2] = kernel_uart2_irq_handler;
	// KERNEL_IRQ_HANDLER_TABLE[IMX8MP_IRQ_UART3] = kernel_uart3_irq_handler;
	// KERNEL_IRQ_HANDLER_TABLE[IMX8MP_IRQ_UART4] = kernel_uart4_irq_handler;
}
KERNEL_INITCALL(init_irq_handler_table);

void kernel_handle_irq(imx8mp_irq irqid) { KERNEL_IRQ_HANDLER_TABLE[irqid](); }
