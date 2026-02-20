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
#include "lib/unit/mem.h"
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

#define N 1493

    void* test[N];


    arm_exceptions_set_status((arm_exception_status) {false, false, false, true});

    for (size_t i = 0; i < N; i++) {
        term_printf("%d\n\r", i);

        raw_kmalloc_cfg c = RAW_KMALLOC_DYNAMIC_CFG;
        c.init_zeroed = false;


        test[i] = raw_kmalloc((MEM_MiB * 2) / KPAGE_SIZE, "test", &c);

        if ((uint64)test[i] % MEM_MiB * 2 == 0)
            term_printf(" va %p\n\r", test[i]);
    }

    term_prints("->>>>>>>>>1\n\r");


    page_allocator_debug();
    vmalloc_debug_free();
    vmalloc_debug_reserved();

    for (size_t i = 0; i < N; i++) {
        raw_kfree(test[i]);
    }

    term_prints("->>>>>>>>>2\n\r");


    page_allocator_debug();
    vmalloc_debug_free();
    vmalloc_debug_reserved();

    loop asm volatile("wfi");
}
