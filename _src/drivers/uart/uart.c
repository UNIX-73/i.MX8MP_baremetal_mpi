#include <drivers/uart/uart.h>
#include <drivers/uart/uart_raw.h>
#include <lib/stdint.h>
#include <lib/stdmacros.h>

static const uintptr UART_N_BASE[] = {
	UART1_BASE,
	UART2_BASE,
	UART3_BASE,
	UART4_BASE,
};

static const uint8 USR1_IRQ_W1C_BITS[9] = {
	3, 4, 5, 7, 8, 10, 11, 12, 15,
};
static const uint8 USR2_IRQ_W2C_BITS[8] = {
	1, 2, 4, 7, 8, 11, 12, 15,
};

// Tx fifo full
static inline bool UART_tx_fifo_full(uintptr periph_base)
{
	UartUtsValue uts = UART_UTS_read(periph_base);
	return UART_UTS_BF_get_TXFULL(uts);
}

void UART_putc(UART_ID id, uint8 c)
{
	UartUtxdValue utxd = {(uint32)c};

	while (UART_tx_fifo_full(UART_N_BASE[id])) {
		asm volatile("nop");
	}

	UART_UTXD_write(UART_N_BASE[id], utxd);
}

void UART_puts(const UART_ID id, const char *s)
{
	while (*s) UART_putc(id, *s++);
}

void UART_reset(UART_ID id)
{
	// FIXME:

	uintptr base = UART_N_BASE[id];

	UART_UCR2_write(base, (UartUcr2Value){.val = 0});

	while (!(UART_UCR2_read(base).val & (1 << 0)));
}

void UART_init(UART_ID id)
{
	UART_reset(id);

	// 17.2.12.1 7357
	uintptr periph_base = UART_N_BASE[id];

	UartUcr1Value ucr1 = {0};
	UART_UCR1_BF_set_UARTEN(&ucr1, true);
	UART_UCR1_BF_set_RRDYEN(&ucr1, true);  // Rx IRQsw
	UART_UCR1_BF_set_IDEN(&ucr1, false);
	UART_UCR1_write(periph_base, ucr1);

	UartUcr2Value ucr2 = {0};
	UART_UCR2_BF_set_SRST(&ucr2, true);
	UART_UCR2_BF_set_RXEN(&ucr2, true);
	UART_UCR2_BF_set_TXEN(&ucr2, true);
	UART_UCR2_BF_set_WS(&ucr2, true);
	UART_UCR2_BF_set_IRTS(&ucr2, true);
	UART_UCR2_write(periph_base, ucr2);

	UartUcr3Value ucr3 = {0};
	UART_UCR3_BF_set_RXDMUXSEL(&ucr3, true);
	UART_UCR3_BF_set_RXDSEN(&ucr3, false);
	UART_UCR3_BF_set_AWAKEN(&ucr3, false);

	UART_UCR3_write(periph_base, ucr3);

	UartUcr4Value ucr4 = {0};
	UART_UCR4_BF_set_CTSTL(&ucr4, 31);
	UART_UCR4_write(periph_base, ucr4);

	UartUfcrValue ufcr = {0};		  // 0000 1010 0000 0001
	UART_UFCR_BF_set_RXTL(&ufcr, 1);  // RX fifo threashold interrupt 1
	UART_UFCR_BF_set_TXTL(&ufcr, 1);  // TX fifo threashold interrupt 1
	UART_UFCR_BF_set_DCEDTE(&ufcr, false);
	UART_UFCR_BF_set_RFDIV(&ufcr, UART_UFCR_RFDIV_DIV_BY_2);

	UART_UFCR_write(periph_base, ufcr);

	UartUbirValue ubir = {0};
	UART_UBIR_BF_set_INC(&ubir, 0xF);
	UART_UBIR_write(periph_base, ubir);

	UartUbmrValue ubmr = {0};
	UART_UBMR_BF_set_MOD(&ubmr, 0x68);
	UART_UBMR_write(periph_base, ubmr);

	UartUmcrValue umcr = {0};
	UART_UMCR_write(periph_base, umcr);

	// Flush rx fifo
	UartUrxdValue urxd = UART_URXD_read(periph_base);
	while (!UART_UTS_BF_get_RXEMPTY(UART_UTS_read(periph_base))) {
		UART_URDX_BF_get_RX_DATA(urxd);
	}

	uint32 usr1_v = 0;
	for (size_t i = 0; i < 9; i++) {
		usr1_v |= (0b1 << USR1_IRQ_W1C_BITS[i]);
	}

	uint32 usr2_v = 0;
	for (size_t i = 0; i < 8; i++) {
		usr2_v |= (0b1 << USR2_IRQ_W2C_BITS[i]);
	}

	UART_USR1_write(periph_base, (UartUsr1Value){.val = usr1_v});
	UART_USR2_write(periph_base, (UartUsr2Value){.val = usr2_v});
}

bool UART_read(UART_ID id, uint8 *data)
{
	uintptr periph_base = UART_N_BASE[id];
	if (UART_UTS_BF_get_RXEMPTY(UART_UTS_read(periph_base))) return false;

	UartUrxdValue urxd = UART_URXD_read(periph_base);
	*data = UART_URDX_BF_get_RX_DATA(urxd);

	return true;
}

bitfield16 UART_get_irq_sources(UART_ID id)
{
	uintptr periph_base = UART_N_BASE[id];

	UartUsr1Value usr1 = UART_USR1_read(periph_base);
	UartUsr2Value usr2 = UART_USR2_read(periph_base);

	UartUcr1Value ucr1 = UART_UCR1_read(periph_base);
	UartUcr2Value ucr2 = UART_UCR2_read(periph_base);
	UartUcr3Value ucr3 = UART_UCR3_read(periph_base);
	UartUcr4Value ucr4 = UART_UCR4_read(periph_base);

	bitfield16 sources = 0;

#define SET_SRC(bit, status, enabled) \
	sources |= ((bitfield16)((status) & (enabled)) << (bit))

	/* --- RX path --- */
	SET_SRC(UART_IRQ_SRC_RRDY, UART_USR1_BF_get_RRDY(usr1),
			UART_UCR1_BF_get_RRDYEN(ucr1));

	SET_SRC(UART_IRQ_SRC_IDLE, UART_USR2_BF_get_IDLE(usr2),
			UART_UCR1_BF_get_IDEN(ucr1));

	SET_SRC(UART_IRQ_SRC_AGTIM, UART_USR1_BF_get_AGTIM(usr1),
			UART_UCR2_BF_get_ATEN(ucr2));

	SET_SRC(UART_IRQ_SRC_ORE, UART_USR2_BF_get_ORE(usr2),
			UART_UCR4_BF_get_OREN(ucr4));

	SET_SRC(UART_IRQ_SRC_FRAMERR, UART_USR1_BF_get_FRAMERR(usr1),
			UART_UCR3_BF_get_FRAERREN(ucr3));

	SET_SRC(UART_IRQ_SRC_PARITYERR, UART_USR1_BF_get_PARITYERR(usr1),
			UART_UCR3_BF_get_PARERREN(ucr3));

	SET_SRC(UART_IRQ_SRC_BRCD, UART_USR2_BF_get_BRCD(usr2),
			UART_UCR4_BF_get_BKEN(ucr4));

	/* --- TX path --- */
	SET_SRC(UART_IRQ_SRC_TRDY, UART_USR1_BF_get_TRDY(usr1),
			UART_UCR1_BF_get_TRDYEN(ucr1));

	SET_SRC(UART_IRQ_SRC_TXFE, UART_USR2_BF_get_TXFE(usr2),
			UART_UCR1_BF_get_TXMPTYEN(ucr1));

	SET_SRC(UART_IRQ_SRC_TXDC, UART_USR2_BF_get_TXDC(usr2),
			UART_UCR4_BF_get_TCEN(ucr4));

	/* --- Modem / control --- */
	SET_SRC(UART_IRQ_SRC_RTSD, UART_USR1_BF_get_RTSD(usr1),
			UART_UCR1_BF_get_RTSDEN(ucr1));

	SET_SRC(UART_IRQ_SRC_WAKE, UART_USR2_BF_get_WAKE(usr2),
			UART_UCR4_BF_get_WKEN(ucr4));

	SET_SRC(UART_IRQ_SRC_ESC, UART_USR1_BF_get_ESCF(usr1),
			UART_UCR2_BF_get_ESCI(ucr2));

#undef SET_SRC

	return sources;
}

/*
void UART_clean_irq_source(UART_ID id, UART_IRQ_SOURCE source)
{
	// TODO:
}
*/