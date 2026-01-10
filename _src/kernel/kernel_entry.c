#include <arm/exceptions/exceptions.h>
#include <arm/tfa/smccc.h>
#include <boot/panic.h>
#include <drivers/arm_generic_timer/arm_generic_timer.h>
#include <drivers/interrupts/gicv3/gicv3.h>
#include <drivers/uart/uart.h>
#include <kernel/init.h>
#include <lib/memcpy.h>
#include <lib/stdint.h>
#include <lib/stdmacros.h>
#include <lib/string.h>

#include "arm/cpu.h"
#include "kernel/devices/drivers.h"

static void test(timer_arg)
{
    UART_puts_sync(&UART2_DRIVER, "timer\n\r");
    AGT_timer_schedule_delta(&AGT0_DRIVER, 1e9, test, NULL);
}

extern void _secondary_entry(void);

// Main function of the kernel, called by the bootloader (/boot/boot.S)
_Noreturn void kernel_entry()
{
    ARM_cpu_affinity aff = ARM_get_cpu_affinity();

    if (aff.aff0 == 0)
    {
        kernel_init();
    }

    if (aff.aff0 < 3)
    {
        _smc_call(PSCI_CPU_ON_FID64, aff.aff0 + 1, (uintptr) _secondary_entry, 0x0, 0x0, 0x0, 0x0,
                  0x0);
    }

    asm volatile("nop");

    if (aff.aff0 == 0)
    {
        for (size_t i = 0; i < 900000; i++)
        {
            asm volatile("nop");
        }

        asm volatile("nop");

        UART_puts(&UART2_DRIVER, "CORE 0");

        AGT_timer_schedule_delta(&AGT0_DRIVER, 1e9, test, NULL);
    }
    else
    {
        char buf[200];
        stdint_to_ascii((STDINT_UNION) {.uint64 = aff.aff0}, STDINT_UINT64, buf, 200,
                        STDINT_BASE_REPR_DEC);
        UART_puts(&UART2_DRIVER, "CORE ");
        UART_puts(&UART2_DRIVER, buf);
        UART_puts(&UART2_DRIVER, "CORE \n\r");
    }

    loop
    {
    }
}