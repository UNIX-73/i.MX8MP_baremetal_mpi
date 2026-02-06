#pragma once
#include <lib/math.h>
#include <lib/stdbool.h>

#include "arm/mmu/mmu.h"
#include "kernel/panic.h"
#include "lib/mem.h"
#include "lib/stdint.h"
#include "mmu_dc.h"
#include "mmu_types.h"


static inline v_uintptr pa_to_va_(mmu_handle* h, p_uintptr pa)
{
    return pa + h->physmap_offset;
}


static inline size_t level_shift_(mmu_granularity g, mmu_tbl_level l)
{
    size_t page_bits = log2_floor_u64(g); // 12 / 14 / 16
    size_t index_bits = page_bits - 3;

    size_t max_level = (g == MMU_GRANULARITY_64KB) ? MMU_TBL_LV2 : MMU_TBL_LV3;

    ASSERT(l <= max_level);

    return page_bits + index_bits * (max_level - l);
}


static inline size_t tbl_entries(mmu_granularity g)
{
    return g / sizeof(mmu_hw_dc);
}

static inline uint64 tbl_alignment(mmu_granularity g)
{
    return g;
}


static inline mmu_tbl ttbr0_from_handle(mmu_handle* h)
{
    DEBUG_ASSERT(h->tbl0_ && ((p_uintptr)h->tbl0_ % tbl_alignment(h->cfg_.lo_gran) == 0));

    v_uintptr va = pa_to_va_(h, (p_uintptr)h->tbl0_);

    return (mmu_tbl) {.dcs = (mmu_hw_dc*)va};
}


static inline mmu_tbl ttbr1_from_handle(mmu_handle* h)
{
    DEBUG_ASSERT(h->tbl1_ && ((p_uintptr)h->tbl1_ % tbl_alignment(h->cfg_.hi_gran) == 0));

    v_uintptr va = pa_to_va_(h, (p_uintptr)h->tbl1_);

    return (mmu_tbl) {.dcs = (mmu_hw_dc*)va};
}


static inline mmu_tbl tbl_from_td(mmu_handle* h, mmu_hw_dc dc, mmu_granularity g, mmu_tbl_level l)
{
    ASSERT(dc_get_type(dc, g, l) == MMU_DESCRIPTOR_TABLE);

    p_uintptr pa = dc_get_output_address(dc, g);
    v_uintptr va = pa_to_va_(h, pa);

    DEBUG_ASSERT(pa && pa % g == 0);

    return (mmu_tbl) {.dcs = (mmu_hw_dc*)va};
}


static inline size_t table_index(p_uintptr va, mmu_granularity g, mmu_tbl_level l)
{
    size_t index_bits = log2_floor_u64(g) - 3;
    size_t mask = (1ULL << index_bits) - 1;

    return (va >> level_shift_(g, l)) & mask;
}


static inline size_t dc_cover_bytes(mmu_granularity g, mmu_tbl_level l)
{
    size_t page_bits = log2_floor_u64(g);
    size_t index_bits = page_bits - 3;

    ASSERT(l <= max_level(g));

    return 1ULL << (page_bits + index_bits * (max_level(g) - l));
}


static inline void tbl_init_null(mmu_tbl tbl, mmu_granularity g)
{
    size_t entries = tbl_entries(g);

    for (size_t i = 0; i < entries; i++)
        tbl.dcs[i].v = 0;
}


static inline mmu_tbl alloc_tbl(mmu_alloc alloc, mmu_granularity g, bool init_null,
                                mmu_op_info* info)
{
    void* addr = alloc(sizeof(mmu_hw_dc) * tbl_entries(g), tbl_alignment(g));

    if (info)
        info->alocated_tbls++;

    ASSERT((v_uintptr)addr % tbl_alignment(g) == 0);


    mmu_tbl tbl = (mmu_tbl) {.dcs = addr};

    if (init_null)
        tbl_init_null(tbl, g);


    return tbl;
}


static inline mmu_pg_cfg cfg_from_dc(mmu_hw_dc dc)
{
    return (mmu_pg_cfg) {
        .attr_index = dc_get_attr_index(dc),
        .ap = dc_get_access_permissions(dc),
        .shareability = dc_get_shareability(dc),
        .non_secure = dc_get_non_secure(dc),
        .access_flag = dc_get_access_flag(dc),
        .pxn = dc_get_privileged_execute_never(dc),
        .uxn = dc_get_unprivileged_execute_never(dc),
        .sw = dc_get_software_defined(dc),
    };
}

/// divides a block into a next level table and udcates the parent. Returns the created table (of a
/// lower level)
static inline mmu_tbl split_block(mmu_handle* h, mmu_tbl parent, mmu_granularity g, size_t index,
                                  mmu_tbl_level l, mmu_op_info* info)
{
    mmu_alloc alloc = h->alloc_;

    mmu_hw_dc old = parent.dcs[index];
    bool valid = (dc_get_valid(old));

    mmu_tbl new_tbl = alloc_tbl(alloc, g, false, info);


    ASSERT(l < max_level(g));
    ASSERT(dc_get_type(old, g, l) == MMU_DESCRIPTOR_BLOCK);


    // create the new blocks
    if (valid) {
        mmu_pg_cfg cfg = cfg_from_dc(old);
        p_uintptr pa = dc_get_output_address(old, g);
        size_t new_l_bytes = dc_cover_bytes(g, l + 1);
        ASSERT(pa % dc_cover_bytes(g, l) == 0);

        for (size_t i = 0; i < tbl_entries(g); i++)
            new_tbl.dcs[i] = bd_build(cfg, pa + (i * new_l_bytes), g, l + 1);
    }
    else
        tbl_init_null(new_tbl, g);


    // set the new table
    parent.dcs[index] = td_build(new_tbl, g, h->physmap_offset);

    return new_tbl;
}


static inline bool tbl_is_null(mmu_tbl tbl, mmu_granularity g)
{
    bool r = true;
    for (size_t i = 0; i < tbl_entries(g); i++)
        if (dc_get_valid(tbl.dcs[i])) {
            r = false;
            break;
        }

    return r;
}


static inline bool va_uses_ttbr0(mmu_handle* h, v_uintptr va)
{
    uint64 top = va >> h->cfg_.lo_va_addr_bits;

    if (top == 0)
        return true;

    uint64 ones = (1ULL << (64 - h->cfg_.hi_va_addr_bits)) - 1;
    if (top == ones)
        return false;

    PANIC("non valid va");
}


static inline mmu_granularity granularity_from_va(mmu_handle* h, v_uintptr va)
{
    return va_uses_ttbr0(h, va) ? h->cfg_.lo_gran : h->cfg_.hi_gran;
}


static inline mmu_tbl get_first_tbl(mmu_handle* h, v_uintptr va, mmu_granularity* g)
{
    if (g)
        *g = granularity_from_va(h, va);

    return va_uses_ttbr0(h, va) ? ttbr0_from_handle(h) : ttbr1_from_handle(h);
}


static inline mmu_granularity get_granularity(mmu_handle* h, v_uintptr va)
{
    return va_uses_ttbr0(h, va) ? h->cfg_.lo_gran : h->cfg_.hi_gran;
}
