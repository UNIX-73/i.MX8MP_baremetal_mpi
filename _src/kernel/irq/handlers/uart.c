
#include <boot/panic.h>
#include <drivers/uart/uart.h>
#include <kernel/irq/handlers/uart.h>
#include <lib/stdbitfield.h>
#include <lib/stdint.h>

typedef void (*uart_irq_handler)(UART_ID id);

static void handle_RRDY(UART_ID id)
{
	uint8 c;

	while (UART_read(id, &c) == true) {
		UART_putc(id, c);
	}
}

static void unhandled(UART_ID) { PANIC("Unhandled UART irq"); }

static const uart_irq_handler UART_IRQ_HANDLERS[UART_IRQ_SRC_COUNT] = {
	[UART_IRQ_SRC_RRDY] = handle_RRDY,
	[1 ... UART_IRQ_SRC_COUNT - 1] = unhandled,
};

// Handlers

void kernel_uart1_irq_handler() { PANIC("Unhandled"); }

void kernel_uart2_irq_handler()
{
	UART_puts(UART_ID_2, "-");

	bitfield16 sources = UART_get_irq_sources(UART_ID_2);

	for (size_t i = 0; i < UART_IRQ_SRC_COUNT; i++) {
		if (BITFIELD16_GET(sources, i)) {
			UART_IRQ_HANDLERS[i](UART_ID_2);
		}
	}
}

void kernel_uart3_irq_handler() { PANIC("Unhandled"); }

void kernel_uart4_irq_handler() { PANIC("Unhandled"); }
