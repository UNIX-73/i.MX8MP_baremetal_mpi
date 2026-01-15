#include <arm/exceptions/exceptions.h>
#include <arm/tfa/smccc.h>
#include <boot/panic.h>
#include <drivers/arm_generic_timer/arm_generic_timer.h>
#include <drivers/interrupts/gicv3/gicv3.h>
#include <drivers/tmu/tmu.h>
#include <drivers/uart/uart.h>
#include <kernel/init.h>
#include <lib/memcpy.h>
#include <lib/stdint.h>
#include <lib/stdmacros.h>
#include <lib/string.h>

#include "arm/cpu.h"
#include "kernel/devices/drivers.h"
#include "kernel/mm/mm.h"


extern void _secondary_entry(void);

// Main function of the kernel, called by the bootloader (/boot/boot.S)
_Noreturn void kernel_entry()
{
    ARM_cpu_affinity aff = ARM_get_cpu_affinity();

    if (aff.aff0 == 0)
    {
        kernel_init();

        UART_puts_sync(&UART2_DRIVER, "MMU:\n\r");

        mm_init();

        UART_puts(&UART2_DRIVER, "MMU apparently not crashing\n\r");
    }

    kmem_id i;
    void* adr = kalloc(5000, "test", false, &i);

    UART_puts(&UART2_DRIVER, mm_get_kmem_tag(i));


    kfree(adr);

    void* adr2 = kalloc(5000, "test2", false, &i);

    if (adr != adr2)
    {
        UART_puts(&UART2_DRIVER, "NOT EQUAL");
    }
    else
    {
        UART_puts(&UART2_DRIVER, " EQUAL\n\r");
        UART_puts(&UART2_DRIVER, mm_get_kmem_tag(i));
    }

    loop
    {
    }
}