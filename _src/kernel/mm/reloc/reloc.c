#include "reloc.h"

#include <lib/mem.h>
#include <lib/stdbool.h>
#include <lib/stdmacros.h>

#include "../phys/page_allocator.h"
#include "arm/mmu/mmu.h"
#include "kernel/panic.h"


extern _Noreturn void _jmp_to_with_offset(void* to, size_t offset);
extern _Noreturn void _reloc_reconfigure_regs(void);


// allocator freer for the early identity mapping tables
static void reloc_free(void* addr)
{
    page_free((mm_page) {.phys = (p_uintptr)addr});
}


static void* reloc_alloc(size_t bytes, size_t)
{
    return (void*)page_malloc(page_allocator_bytes_to_order(bytes),
                              (mm_page_data) {
                                  .device_mem = false,
                                  .tag = "reloc_test",
                                  .permanent = false,
                                  .virt = 0,
                              })
        .phys;
}


void mm_reloc_kernel(p_uintptr kernel_base, mmu_handle* h)
{
    ASSERT(mmu_is_active());

    mmu_reconfig_allocators(h, reloc_alloc, reloc_free);

    mmu_pg_cfg device_cfg = mmu_pg_cfg_new(1, MMU_AP_EL0_NONE_EL1_RW, 0, false, 1, 0, 0, 0);
    mmu_pg_cfg mem_cfg = mmu_pg_cfg_new(0, MMU_AP_EL0_NONE_EL1_RW, 0, false, 1, 0, 0, 0);

    // device memory
    mmu_map(h, kernel_base, 0, MEM_GiB, device_cfg, NULL);

    // kernel memory TODO: watch if mapping all the ddr is neccesary or only the used memory
    mmu_map(h, kernel_base + MEM_GiB, MEM_GiB, 4 * MEM_GiB, mem_cfg, NULL);


    _jmp_to_with_offset(_reloc_reconfigure_regs, kernel_base);
}
