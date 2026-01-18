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
#include "arm/mmu/mmu_page_descriptor.h"
#include "kernel/devices/drivers.h"
#include "kernel/mm/mm.h"
#include "lib/unit/mem.h"
#include "mm/init/early_kalloc.h"

p_uintptr early_kalloc(size_t bytes, const char* tag, bool permanent);

extern void _secondary_entry(void);
void early_kalloc_init();
extern void early_kalloc_test();

// Main function of the kernel, called by the bootloader (/boot/boot.S)
_Noreturn void kernel_entry()
{
    ARM_cpu_affinity aff = ARM_get_cpu_affinity();

    if (aff.aff0 == 0)
    {
        kernel_init();
        mm_early_init();

        early_kalloc_test();


        UART_puts(&UART2_DRIVER, "MMU apparently not crashing\n\r");
    }


    loop
    {
    }
}