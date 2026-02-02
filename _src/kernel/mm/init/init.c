#include <frdm_imx8mp.h>
#include <kernel/panic.h>

#include "../mm_info.h"
#include "../phys/page_allocator.h"
#include "../reloc/reloc.h"
#include "arm/mmu/mmu.h"
#include "early_kalloc.h"
#include "identity_mapping.h"
#include "kernel/mm.h"
#include "lib/unit/mem.h"


static void early_reserve_device_and_kernel_mem()
{
    // TODO: not hardcoded

    /* reserve memory for mmio */
    early_kalloc(MEM_GiB * 1, "mmio", true, true);


    /* reserve memory for TF-A reserved zone */
    size_t tf_a_bytes = mm_info_kernel_start() - mm_info_ddr_start();
    ASSERT(tf_a_bytes % MMU_GRANULARITY_4KB == 0);
    early_kalloc(tf_a_bytes, "tf_a_protected", true, false);


    /* reserve memory for the text + bss + rodata + data + el2 + el1 stacks of the kernel */
    ASSERT(mm_info_kernel_size() % MMU_GRANULARITY_4KB == 0);
    early_kalloc(mm_info_kernel_size(), "kernel_static", true, false);
}


void mm_early_init()
{
    mm_info_init();


    // init early kalloc
    early_kalloc_init();
    early_reserve_device_and_kernel_mem();


    // init identity mapping
    early_identity_mapping(&mm_mmu_h);
#ifdef DEBUG
    uart_puts(&UART2_DRIVER, "Identity mapping mmu: \n\r");
    mmu_debug_dump(&mm_mmu_h, MMU_TBL_LO);
    uart_puts(&UART2_DRIVER, "\n\rPage allocator test: \n\r");
#endif


    // init page allocator
    memblock* mblcks;
    size_t n;
    page_allocator_init();
    early_kalloc_get_memblocks(&mblcks, &n);
    page_allocator_reserve_memblocks(mblcks, n);
#ifdef DEBUG
    page_allocator_debug();
#endif


    // reloc kernel
    mm_reloc_kernel(KERNEL_BASE, &mm_mmu_h);
}


void mm_init()
{
}