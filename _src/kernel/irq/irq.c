#include <boot/panic.h>
#include <drivers/interrupts/interrupts.h>
#include <drivers/uart/uart.h>
#include <kernel/init.h>
#include <kernel/irq/irq.h>
#include <lib/stdint.h>

static irq_handler_t KERNEL_IRQ_HANDLER_TABLE[IMX8MP_IRQ_SIZE];

static void unhandled_irq() { PANIC("UNHANDLED IRQ"); }

static void UART1_handler() { UART_handle_irq(UART_ID_1); }
static void UART2_handler() { UART_handle_irq(UART_ID_2); }
static void UART3_handler() { UART_handle_irq(UART_ID_3); }
static void UART4_handler() { UART_handle_irq(UART_ID_4); }

static void init_irq_handler_table()
{
	for (size_t i = 0; i < IMX8MP_IRQ_SIZE; i++) {
		KERNEL_IRQ_HANDLER_TABLE[i] = unhandled_irq;
	}

	KERNEL_IRQ_HANDLER_TABLE[IMX8MP_IRQ_UART1] = UART1_handler;
	KERNEL_IRQ_HANDLER_TABLE[IMX8MP_IRQ_UART2] = UART2_handler;
	KERNEL_IRQ_HANDLER_TABLE[IMX8MP_IRQ_UART3] = UART3_handler;
	KERNEL_IRQ_HANDLER_TABLE[IMX8MP_IRQ_UART4] = UART4_handler;
}

KERNEL_INITCALL(init_irq_handler_table);

void kernel_handle_irq(imx8mp_irq irqid) { KERNEL_IRQ_HANDLER_TABLE[irqid](); }
