#include <arm/exceptions/exceptions.h>
#include <arm/tfa/smccc.h>
#include <drivers/arm_generic_timer/arm_generic_timer.h>
#include <drivers/interrupts/gicv3/gicv3.h>
#include <drivers/tmu/tmu.h>
#include <kernel/init.h>
#include <kernel/panic.h>
#include <lib/stdint.h>
#include <lib/stdmacros.h>
#include <lib/string.h>

#include "arm/cpu.h"
#include "kernel/io/term.h"
#include "kernel/mm.h"
#include "lib/mem.h"
#include "mm/malloc/reserve_malloc.h"
#include "mm/mm_info.h"


// Main function of the kernel, called by the bootloader (/boot/boot.S)
_Noreturn void kernel_entry()
{
    __attribute((unused)) v_uintptr ts = MM_KSECTIONS.text.start;

    size_t coreid = ARM_get_cpu_affinity().aff0;

    if (coreid == 0) {
        if (!mm_kernel_is_relocated()) {
            kernel_early_init();
        }
        else {
            kernel_init();
        }
    }


    __attribute((unused)) void* test = raw_kmalloc(1, "kmalloc_test", NULL);

    term_prints("prefree\n\r");

    loop asm volatile("wfi");
}
