#include <arm/exceptions/exceptions.h>
#include <boot/panic.h>
#include <drivers/uart/uart.h>
#include <lib/stdint.h>
#include <lib/stdmacros.h>
#include <lib/string.h>

#include "arm/sysregs.h"

#define PANIC_UART_OUTPUT UART_ID_2
#define PANIC_puts(str) UART_puts(PANIC_UART_OUTPUT, str)

#define PANIC_MESSAGE_LEN_INIT_VALUE 4096
#define PANIC_FILE_LEN_INIT_VALUE 1024

// The global static scope variables and buffers allow rust to easily send the
// message in a c format string with \0. It also allows to set the panic
// information without throwing the panic.

uint64 PANIC_MESSAGE_BUF_SIZE;
uint64 PANIC_FILE_BUF_SIZE;

// NOTE: If implementing multithreading the panic infos must be protected by a
// mutex

uint8 *PANIC_MESSAGE_BUF_PTR;
uint8 *PANIC_FILE_BUF_PTR;
uint32 PANIC_LINE;
uint32 PANIC_COL;

uint32 PANIC_REASON;

uint64 PANIC_REGISTERS[32];
/* x0-x30 + sp */

_Alignas(16) static uint8 panic_message_buffer[PANIC_MESSAGE_LEN_INIT_VALUE];
_Alignas(16) static uint8 panic_file_buffer[PANIC_FILE_LEN_INIT_VALUE];

void init_panic()
{
	PANIC_MESSAGE_BUF_SIZE = sizeof(panic_message_buffer);
	PANIC_FILE_BUF_SIZE = sizeof(panic_file_buffer);

	PANIC_MESSAGE_BUF_PTR = panic_message_buffer;
	PANIC_FILE_BUF_PTR = panic_file_buffer;

	PANIC_LINE = 0;
	PANIC_COL = 0;

	PANIC_REASON = PANIC_REASON_UNDEFINED;

	strcopy((char *)PANIC_MESSAGE_BUF_PTR,
			"Panic message not defined and not changed from init_panic() "
			"initialization stage.",
			PANIC_MESSAGE_LEN_INIT_VALUE);

	strcopy((char *)PANIC_FILE_BUF_PTR, "Panic file not defined",
			PANIC_FILE_LEN_INIT_VALUE);

	for (size_t i = 0; i < 32; i++) PANIC_REGISTERS[i] = 0xdeadbeefdeadbeef;
}

void set_panic(panic_info panic_info)
{
	PANIC_LINE = panic_info.location.line;
	PANIC_COL = panic_info.location.col;
	PANIC_REASON = panic_info.panic_reason;

	strcopy((char *)PANIC_MESSAGE_BUF_PTR, panic_info.message,
			PANIC_MESSAGE_LEN_INIT_VALUE);

	strcopy((char *)PANIC_FILE_BUF_PTR, panic_info.location.file,
			PANIC_FILE_LEN_INIT_VALUE);
}

static void log_system_info();

// TODO: use panic via exceptions
_Noreturn void panic()
{
#ifdef DEBUG
	__attribute__((unused)) volatile uint64 GDB_esr = _ARM_ESR_EL1();
	__attribute__((unused)) volatile uint64 GDB_elr = _ARM_ELR_EL1();
	__attribute__((unused)) volatile uint64 GDB_far = _ARM_FAR_EL1();
	__attribute__((unused)) volatile uint64 GDB_spsr = _ARM_SPSR_EL1();
#endif

	char buf[200];

	UART_init(PANIC_UART_OUTPUT);
	PANIC_puts("\n\r[PANIC!]");

	char *panic_reason_str = "INVALID";
	switch (PANIC_REASON) {
		case PANIC_REASON_UNDEFINED:
			panic_reason_str = "UNDEFINED";
			break;
		case PANIC_REASON_EXCEPTION:
			panic_reason_str = "EXCEPTION";
			break;
		case PANIC_REASON_MANUAL_ABORT:
			panic_reason_str = "MANUAL_ABORT";
			break;
		case PANIC_REASON_RUST_PANIC:
			panic_reason_str = "RUST_PANIC";
			break;
	}

	PANIC_puts("\n\rPanic reason:\t");
	PANIC_puts(panic_reason_str);

	PANIC_puts("\n\rPanic message:\t");
	PANIC_puts((char *)PANIC_MESSAGE_BUF_PTR);

	PANIC_puts("\n\rPanic file:\t");
	PANIC_puts((char *)PANIC_FILE_BUF_PTR);
	PANIC_puts(" at line ");

	PANIC_puts(stdint_to_ascii((STDINT_UNION){.uint32 = PANIC_LINE},
							   STDINT_UINT32, buf, 200, STDINT_BASE_REPR_DEC));

	if (PANIC_COL != 0) {
		PANIC_puts(":");
		PANIC_puts(stdint_to_ascii((STDINT_UNION){.uint32 = PANIC_COL},
								   STDINT_UINT32, buf, 200,
								   STDINT_BASE_REPR_DEC));
	}

	log_system_info();

	loop {}	 // TODO: TUI with options
}

_Noreturn void set_and_throw_panic(panic_info panic_info)
{
	_panic_exception_save_gpr();
	set_panic(panic_info);
	panic();
}

// System info
static void log_exception_info();
static void log_registers();

static void log_system_info()
{
	ARM_exception_status status = ARM_exceptions_get_status();

	PANIC_puts("\n\rExceptions state:\n\r");

	char *enabled = "enabled\n\r";
	char *disabled = "disabled\n\r";

	PANIC_puts("\tFIQ:    ");
	PANIC_puts(status.fiq ? enabled : disabled);

	PANIC_puts("\tIRQ:    ");
	PANIC_puts(status.irq ? enabled : disabled);

	PANIC_puts("\tSError: ");
	PANIC_puts(status.serror ? enabled : disabled);

	PANIC_puts("\tDebug:  ");
	PANIC_puts(status.debug ? enabled : disabled);

	// TODO: log registers

	if (PANIC_REASON == PANIC_REASON_EXCEPTION) log_exception_info();

	log_registers();
}

static char *exception_reg_names[4] = {
	"ESR",
	"ELR",
	"FAR",
	"SPSR",
};

static char *el_names[4] = {
	"EL0",
	"EL1",
	"EL2",
	"EL3",
};

static void log_exception_info()
{
	uint64 esr;
	uint64 elr;
	uint64 far;
	uint64 spsr;

	uint64 current_el = _ARM_currentEL();

	switch (current_el) {
		case 3:
			PANIC_puts("\n\rException info (EL3)!\n\r");
			return;
		case 2:
			esr = _ARM_ESR_EL2();
			elr = _ARM_ELR_EL2();
			far = _ARM_FAR_EL2();
			spsr = _ARM_SPSR_EL2();

			PANIC_puts("\n\rException info (EL2):\n\r");
			break;
		case 1:
			esr = _ARM_ESR_EL1();
			elr = _ARM_ELR_EL1();
			far = _ARM_FAR_EL1();
			spsr = _ARM_SPSR_EL1();

			PANIC_puts("\n\rException info (EL1):\n\r");
			break;
		case 0:
			PANIC_puts("\n\rException info (EL0)!\n\r");
			return;
		default:
			PANIC_puts("\n\rERROR: log_exception_info\n\r");
			return;
	}

	char buf[256];

	uint64 values[4] = {
		esr,
		elr,
		far,
		spsr,
	};

	for (size_t i = 0; i < 4; i++) {
		char *fmt_value =
			stdint_to_ascii((STDINT_UNION){.uint64 = values[i]}, STDINT_UINT64,
							buf, 200, STDINT_BASE_REPR_HEX);
		PANIC_puts("\t");
		PANIC_puts(exception_reg_names[i]);
		PANIC_puts("_");
		PANIC_puts(el_names[current_el]);
		PANIC_puts(": ");
		PANIC_puts(fmt_value);
		PANIC_puts("\n\r");
	}
}

static void log_registers()
{
	PANIC_puts("Register info:\r\n");
	char reg_n[8];
	char reg_v[24];

	for (size_t i = 0; i < 32; i++) {
		uint64 x_reg = PANIC_REGISTERS[i];

		stdint_to_ascii((STDINT_UNION){.uint64 = i}, STDINT_UINT64, reg_n, 8,
						STDINT_BASE_REPR_DEC);

		stdint_to_ascii((STDINT_UNION){.uint64 = x_reg}, STDINT_UINT64, reg_v,
						24, STDINT_BASE_REPR_HEX);

		if (i != 31) {	// Gpr
			PANIC_puts("\tx");
			PANIC_puts(reg_n);
			PANIC_puts(": ");
		} else	// sp
			PANIC_puts("\tsp: ");

		PANIC_puts(reg_v);
		PANIC_puts("\n\r");
	}
}