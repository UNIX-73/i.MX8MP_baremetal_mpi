#pragma once


#ifndef __ASSEMBLER__
#    include <arm/mmu/mmu.h>
#    include <lib/mem.h>
#    include <lib/stdbool.h>
#    include <lib/stdint.h>
#    include <lib/unit/mem.h>

#    define KERNEL_BASE 0xFFFF800000000000ULL
#    define KPAGE_SIZE (MEM_KiB * 4ULL)
#    define KPAGE_ALIGN KPAGE_SIZE

void mm_early_init();

/// it expects to be provided the identity mapping handle. It will free it, and replace it by the
/// kernel mmu handle after relocation
void mm_init();


bool mm_kernel_is_relocated();

p_uintptr mm_kva_to_kpa(v_uintptr va);
#    define mm_kva_to_kpa_ptr(va) (void*)mm_kva_to_kpa((v_uintptr)(va))

v_uintptr mm_kpa_to_kva(p_uintptr pa);
#    define mm_kpa_to_kva_ptr(pa) (void*)mm_kpa_to_kva((p_uintptr)(pa))


static inline bool ptrs_are_kmapped(pv_ptr pv)
{
    return mm_kpa_to_kva(pv.pa) == pv.va;
}

typedef struct {
    // if assign_phys == true, the kernel physmap offset is assured (va == pa + KERNEL_BASE), else
    // it is not assured and the phys addr is dynamically assigned
    bool assign_phys;
    // if the reserve allocator should be filled after the allocation occurs.
    bool fill_reserve;
    // TODO: add more cfgs if needed (for example mmu_cfg)
} raw_kmalloc_cfg;

extern const raw_kmalloc_cfg RAW_KMALLOC_DEFAULT_CFG;

void* raw_kmalloc(size_t size, const char* tag, const raw_kmalloc_cfg* cfg);
void raw_kfree(void* ptr, const raw_kmalloc_cfg* cfg);


#else
#    define KERNEL_BASE 0xFFFF800000000000
#endif
