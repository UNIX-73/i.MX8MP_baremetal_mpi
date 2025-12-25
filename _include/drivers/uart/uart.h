#pragma once
#include <lib/stdbitfield.h>
#include <lib/stdbool.h>
#include <lib/stdint.h>

typedef enum {
	UART_ID_1 = 0,
	UART_ID_2,
	UART_ID_3,
	UART_ID_4,
} UART_ID;

void UART_reset(UART_ID id);

void UART_init(UART_ID id);

void UART_putc(UART_ID id, uint8 c);

void UART_puts(const UART_ID id, const char *s);

bool UART_read(UART_ID id, uint8 *data);

typedef enum {
	/* --- RX path --- */
	UART_IRQ_SRC_RRDY = 0,	 // Rx FIFO threshold reached (RRDY + UCR1.RRDYEN)
	UART_IRQ_SRC_IDLE,		 // Idle line detected (IDLE + UCR1.IDEN)
	UART_IRQ_SRC_AGTIM,		 // Aging timer (AGTIM + UCR2.ATEN)
	UART_IRQ_SRC_ORE,		 // Overrun error (ORE + UCR4.OREN)
	UART_IRQ_SRC_FRAMERR,	 // Frame error (FRAMERR + UCR3.FRAERREN)
	UART_IRQ_SRC_PARITYERR,	 // Parity error (PARITYERR + UCR3.PARERREN)
	UART_IRQ_SRC_BRCD,		 // BREAK detected (BRCD + UCR4.BKEN)

	/* --- TX path --- */
	UART_IRQ_SRC_TRDY,	// Tx FIFO has space (TRDY + UCR1.TRDYEN)
	UART_IRQ_SRC_TXFE,	// Tx FIFO empty (TXFE + UCR1.TXMPTYEN)
	UART_IRQ_SRC_TXDC,	// Transmit complete (TXDC + UCR4.TCEN)

	/* --- Modem / control --- */
	UART_IRQ_SRC_RTSD,	// RTS delta (RTSD + UCR1.RTSDEN)
	UART_IRQ_SRC_WAKE,	// Wake-up detected (WAKE + UCR4.WKEN)
	UART_IRQ_SRC_ESC,	// Escape sequence detected (ESCF + UCR2.ESCI)

	UART_IRQ_SRC_COUNT	// number of sources
} UART_IRQ_SOURCE;

bitfield16 UART_get_irq_sources(UART_ID id);

// TODO: void UART_clean_irq_source(UART_ID id, UART_IRQ_SOURCE source);