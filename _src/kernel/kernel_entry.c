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
#include "mm/mm_info.h"
#include "mm/phys/page_allocator.h"
#include "mm/virt/vmalloc.h"


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

    __attribute((unused)) mm_ksections x = MM_KSECTIONS;


    void* test[200];

    vmalloc_debug_free();


    for (size_t i = 0; i < 200; i++) {
        if (i < 100) {
            raw_kmalloc_cfg c = RAW_KMALLOC_KMAP_CFG;
            c.init_zeroed = true;

            test[i] = raw_kmalloc(8, "test", &c);
        }
        else {
            raw_kmalloc_cfg c = RAW_KMALLOC_DYNAMIC_CFG;
            c.init_zeroed = true;

            term_printf("%d\n\r", i);
            test[i] = raw_kmalloc(8 + i, "test", &c);
        }
    }

    __attribute((unused)) vmalloc_va_info i = vmalloc_get_addr_info((void*)(~(uint64)0 - 0x4000));

    term_prints("->>>>>>>>>\n\r");

    for (size_t i = 0; i < 200; i++) {
        raw_kfree(test[i]);
    }

    vmalloc_debug_free();
    vmalloc_debug_reserved();


    loop asm volatile("wfi");
}
