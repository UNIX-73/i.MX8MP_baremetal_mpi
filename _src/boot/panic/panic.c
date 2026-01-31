#include "boot/panic.h"

#include <arm/cpu.h>
#include <arm/exceptions/exceptions.h>
#include <arm/sysregs/sysregs.h>
#include <drivers/uart/uart.h>
#include <kernel/devices/drivers.h>
#include <lib/stdint.h>
#include <lib/stdmacros.h>
#include <lib/string.h>


#define PANIC_UART_OUTPUT &UART2_DRIVER


static void putc(char c)
{
    uart_putc_sync(PANIC_UART_OUTPUT, c);
}

static void panic_puts_(const char* s, ...)
{
    va_list ap;
    va_start(ap, s);

    str_fmt_print(putc, s, ap);

    va_end(ap);
}


#define PANIC_MESSAGE_LEN_INIT_VALUE 4096
#define PANIC_FILE_LEN_INIT_VALUE 1024

// The global scope variables and buffers allow rust to easily send the
// message in a c format string with \0. It also allows to set the panic
// information without throwing the panic.

uint64 PANIC_MESSAGE_BUF_SIZE;
uint64 PANIC_FILE_BUF_SIZE;

// NOTE: If implementing multithreading the panic infos must be protected by a
// mutex

uint8* PANIC_MESSAGE_BUF_PTR;
uint8* PANIC_FILE_BUF_PTR;
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

    strcopy((char*)PANIC_MESSAGE_BUF_PTR,
            "Panic message not defined and not changed from init_panic() "
            "initialization stage.",
            PANIC_MESSAGE_LEN_INIT_VALUE);

    strcopy((char*)PANIC_FILE_BUF_PTR, "Panic file not defined", PANIC_FILE_LEN_INIT_VALUE);

    for (size_t i = 0; i < 32; i++)
        PANIC_REGISTERS[i] = 0xdeadbeefdeadbeef;
}

void set_panic(panic_info panic_info)
{
    PANIC_LINE = panic_info.location.line;
    PANIC_COL = panic_info.location.col;
    PANIC_REASON = panic_info.panic_reason;

    strcopy((char*)PANIC_MESSAGE_BUF_PTR, panic_info.message, PANIC_MESSAGE_LEN_INIT_VALUE);

    strcopy((char*)PANIC_FILE_BUF_PTR, panic_info.location.file, PANIC_FILE_LEN_INIT_VALUE);
}

static void log_system_info_();

// TODO: use panic via exceptions
_Noreturn void panic()
{
#ifdef DEBUG
    __attribute__((unused)) volatile uint64 GDB_esr = _ARM_ESR_EL1();
    __attribute__((unused)) volatile uint64 GDB_elr = _ARM_ELR_EL1();
    __attribute__((unused)) volatile uint64 GDB_far = _ARM_FAR_EL1();
    __attribute__((unused)) volatile uint64 GDB_spsr = _ARM_SPSR_EL1();
#endif

    panic_puts_("\n\r[PANIC!]\n\rCore: %p\n\r", ARM_get_cpu_affinity().aff0);

    char* panic_reason_str = "INVALID";
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

    panic_puts_("\n\rPanic reason:\t%s"
                "\n\rPanic message:\t%s"
                "\n\rPanic file:\t%s at line %d",
                panic_reason_str, PANIC_MESSAGE_BUF_PTR, PANIC_FILE_BUF_PTR, PANIC_LINE);


    if (PANIC_COL != 0)
        panic_puts_(":%d", PANIC_COL);


    log_system_info_();

    loop
    {
        asm volatile("wfe");
    } // TODO: TUI with options
}

_Noreturn void set_and_throw_panic(panic_info panic_info)
{
    _panic_exception_save_gpr();
    set_panic(panic_info);
    panic();
}

// System info
static void log_exception_info_();
static void log_registers_();

static void log_system_info_()
{
    ARM_exception_status status = ARM_exceptions_get_status();

    panic_puts_("\n\rExceptions state:\n\r");

    char* enabled = "enabled\n\r";
    char* disabled = "disabled\n\r";

    panic_puts_("\tFIQ:\t%s", status.fiq ? enabled : disabled);
    panic_puts_("\tIRQ:\t%s", status.irq ? enabled : disabled);
    panic_puts_("\tSError:\t%s", status.serror ? enabled : disabled);
    panic_puts_("\tDebug:\t%s", status.debug ? enabled : disabled);

    // TODO: log registers

    if (PANIC_REASON == PANIC_REASON_EXCEPTION)
        log_exception_info_();

    log_registers_();
}

static char* exception_reg_names_[4] = {
    "ESR",
    "ELR",
    "FAR",
    "SPSR",
};

static char* el_names_[4] = {
    "EL0",
    "EL1",
    "EL2",
    "EL3",
};

static void log_exception_info_()
{
    uint64 esr;
    uint64 elr;
    uint64 far;
    uint64 spsr;

    uint64 current_el = _ARM_currentEL();

    switch (current_el) {
        case 3:
            panic_puts_("\n\rException info (EL3)!\n\r");
            return;
        case 2:
            esr = _ARM_ESR_EL2();
            elr = _ARM_ELR_EL2();
            far = _ARM_FAR_EL2();
            spsr = _ARM_SPSR_EL2();

            panic_puts_("\n\rException info (EL2):\n\r");
            break;
        case 1:
            esr = _ARM_ESR_EL1();
            elr = _ARM_ELR_EL1();
            far = _ARM_FAR_EL1();
            spsr = _ARM_SPSR_EL1();

            panic_puts_("\n\rException info (EL1):\n\r");
            break;
        case 0:
            panic_puts_("\n\rException info (EL0)!\n\r");
            return;
        default:
            panic_puts_("\n\rERROR: log_exception_info\n\r");
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
        char* fmt_value = stdint_to_ascii((STDINT_UNION) {.uint64 = values[i]}, STDINT_UINT64, buf,
                                          200, STDINT_BASE_REPR_HEX);
        panic_puts_("\t");
        panic_puts_(exception_reg_names_[i]);
        panic_puts_("_");
        panic_puts_(el_names_[current_el]);
        panic_puts_(": ");
        panic_puts_(fmt_value);
        panic_puts_("\n\r");
    }
}

static void log_registers_()
{
    panic_puts_("Register info:\r\n");
    char reg_n[8];
    char reg_v[24];

    for (size_t i = 0; i < 32; i++) {
        uint64 x_reg = PANIC_REGISTERS[i];

        stdint_to_ascii((STDINT_UNION) {.uint64 = i}, STDINT_UINT64, reg_n, 8,
                        STDINT_BASE_REPR_DEC);

        stdint_to_ascii((STDINT_UNION) {.uint64 = x_reg}, STDINT_UINT64, reg_v, 24,
                        STDINT_BASE_REPR_HEX);

        if (i != 31) { // Gpr
            panic_puts_("\tx");
            panic_puts_(reg_n);
            panic_puts_(": ");
        }
        else // sp
            panic_puts_("\tsp: ");

        panic_puts_(reg_v);
        panic_puts_("\n\r");
    }
}