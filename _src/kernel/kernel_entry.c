#include <arm/exceptions/exceptions.h>
#include <arm/tfa/smccc.h>
#include <drivers/arm_generic_timer/arm_generic_timer.h>
#include <drivers/interrupts/gicv3/gicv3.h>
#include <drivers/tmu/tmu.h>
#include <drivers/uart/uart.h>
#include <kernel/init.h>
#include <kernel/panic.h>
#include <lib/memcpy.h>
#include <lib/stdint.h>
#include <lib/stdmacros.h>
#include <lib/string.h>

#include "arm/cpu.h"
#include "arm/mmu/mmu.h"
#include "devices/device_map.h"
#include "kernel/devices/drivers.h"
#include "kernel/io/term.h"
#include "kernel/mm.h"
#include "lib/unit/mem.h"

static mmu_handle h;

// Main function of the kernel, called by the bootloader (/boot/boot.S)
_Noreturn void kernel_entry()
{
    size_t coreid = ARM_get_cpu_affinity().aff0;


    if (coreid == 0) {
        if (!mm_kernel_is_relocated()) {
            kernel_early_init();
        }
        else {
            kernel_init();
        }
    }


    uart_puts_sync(&UART2_DRIVER, "prefree\n\r");


    mmu_unmap(&h, 0x0, MEM_GiB * 5, NULL);


    UART2_DRIVER.base += KERNEL_BASE;
    UART2_DRIVER.state += KERNEL_BASE;

    mmu_reloc(&h, KERNEL_BASE);

    mmu_debug_dump(&h, MMU_TBL_HI);

    uart_puts_sync(&UART2_DRIVER, "postfree\n\r");


    loop asm volatile("wfi");
}