#include <arm/mmu/mmu.h>
#include <kernel/mm.h>
#include <kernel/panic.h>
#include <lib/math.h>
#include <lib/mem.h>
#include <lib/stdbool.h>
#include <lib/stdmacros.h>

#include "../mm_info.h"
#include "../phys/page.h"
#include "../phys/page_allocator.h"
#include "../virt/vmalloc/vmalloc.h"
#include "reserve_malloc.h"


const raw_kmalloc_cfg RAW_KMALLOC_DEFAULT_CFG = (raw_kmalloc_cfg) {
    .assign_phys = true,
    .fill_reserve = true,
};


void* raw_kmalloc(size_t size, const char* tag, const raw_kmalloc_cfg* cfg)
{
    cfg = (cfg != NULL) ? cfg : &RAW_KMALLOC_DEFAULT_CFG;
    ASSERT(cfg->assign_phys, "TODO: dynamic mapping not implemented yet");


    size_t pages = div_ceil(size, MM_PAGE_BYTES);
    size_t malloc_size = pages * MM_PAGE_BYTES;
    size_t order = log2_ceil(pages);

    mm_page page = page_malloc(order, (mm_page_data) {
                                          .tag = tag,
                                          .device_mem = false,
                                          .permanent = false,
                                      });


    p_uintptr pa = page.pa;
    v_uintptr va = vmalloc(pages, MM_VMEM_HI);


    // TODO: not map if already mapped
    mmu_pg_cfg mem_cfg = mmu_pg_cfg_new(0, MMU_AP_EL0_NONE_EL1_RW, 0, false, 1, 0, 0, 0);
    bool map_result = mmu_map(&mm_mmu_h, va, pa, malloc_size, mem_cfg, NULL);

    ASSERT(map_result, "kraw_malloc: mmu_map failed");

    if (cfg->fill_reserve)
        reserve_malloc_fill();

    return (void*)va;
}


void raw_kfree(void* ptr, const raw_kmalloc_cfg* cfg)
{
    (void)ptr;
    (void)cfg;

    PANIC("TODO: raw_kfree: NOT IMPLEMENTED YET");
}