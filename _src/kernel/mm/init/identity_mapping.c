#include "identity_mapping.h"

#include <arm/mmu/mmu.h>
#include <lib/mem.h>
#include <lib/stdint.h>
#include <lib/stdmacros.h>
#include <lib/string.h>

#include "../malloc/early_kalloc.h"
#include "../mm_info.h"
#include "arm/mmu/mmu.h"
#include "kernel/io/term.h"
#include "kernel/mm.h"
#include "kernel/panic.h"
#include "lib/stdbool.h"


/// returns the pa, not va, but as when relocating the address will be relocated, works fine.
/// Providing the va at this stage cannot work as it is the allocator for initializing the first
/// identity mapping without the mmu still enabled
static void* im_alloc(size_t bytes, size_t alignment)
{
    p_uintptr v = early_kalloc(bytes, "mmu_early_identity_mapping_tbl", false, false);

    ASSERT(v % alignment == 0);

    return (void*)v;
}


static void im_free(void* addr)
{
    char buf[200];
    stdint_to_ascii((STDINT_UNION) {.uint64 = (v_uintptr)addr}, STDINT_UINT64, buf, 200,
                    STDINT_BASE_REPR_HEX);

    term_printf("%s\n\r", buf);

#ifndef DEBUG
    PANIC("The early identity mapping allocations should not free any tables");
#endif
}


void early_identity_mapping()
{
    mmu_cfg cfg;
    mmu_cfg_new(&cfg, true, true, false, true, true, 48, 48, MMU_GRANULARITY_4KB,
                MMU_GRANULARITY_4KB);

    mmu_init(&mm_mmu_h, cfg, im_alloc, im_free, 0);


    mmu_pg_cfg device_cfg = mmu_pg_cfg_new(1, MMU_AP_EL0_NONE_EL1_RW, 0, false, 1, 0, 0, 0);
    mmu_pg_cfg mem_cfg = mmu_pg_cfg_new(0, MMU_AP_EL0_NONE_EL1_RW, 0, false, 1, 0, 0, 0);


    // device memory
    mmu_map(&mm_mmu_h, 0, 0, MEM_GiB, device_cfg, NULL);
    mmu_map(&mm_mmu_h, KERNEL_BASE, 0, MEM_GiB, device_cfg, NULL);


    // kernel memory TODO: watch if mapping all the ddr is neccesary or only the used memory
    mmu_map(&mm_mmu_h, MEM_GiB, MEM_GiB, 4 * MEM_GiB, mem_cfg, NULL);
    mmu_map(&mm_mmu_h, KERNEL_BASE + MEM_GiB, MEM_GiB, 4 * MEM_GiB, mem_cfg, NULL);


    mmu_activate();
}