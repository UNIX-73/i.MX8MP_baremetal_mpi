#include <arm/mmu/mmu.h>
#include <lib/memcpy.h>
#include <lib/stdmacros.h>

#include "lib/stdint.h"

#ifdef TEST
#    include <boot/panic.h>
#endif


static inline size_t table_entries(mmu_granularity g)
{
    return g / sizeof(mmu_page_descriptor);
}


static bool build_pd(mmu_granularity granularity, mmu_table_lvl lvl, mmu_page_descriptor_cfg cfg,
                     mmu_page_descriptor* pd)
{
    if (lvl == MMU_TABLE_LEVEL0 && cfg.type == MMU_TABLE_DESCRIPTOR_BLOCK)
        return false;

    if (cfg.output_address % granularity != 0)
        return false;


    uint64 pd_u64 = 0;

    // low attributes
    pd_u64 |= (uint64)cfg.valid;
    pd_u64 |= (uint64)cfg.type << 1;
    pd_u64 |= (uint64)(cfg.attr_index & 0b111) << 2;
    pd_u64 |= (uint64)cfg.non_secure << 5;
    pd_u64 |= (uint64)cfg.access_permissions << 6;
    pd_u64 |= (uint64)(cfg.shareability & 0b11) << 8;
    pd_u64 |= (uint64)cfg.access_flag << 10;

    // output_address
    pd_u64 |= cfg.output_address & output_address_mask(granularity);

    // high attributes
    pd_u64 |= (uint64)cfg.privileded_execute_never << 53;
    pd_u64 |= (uint64)cfg.unpriviliged_execute_never << 54;
    pd_u64 |= (uint64)(cfg.software_defined & 0xF) << 55;


    pd->u64 = pd_u64;
    return true;
}

mmu_table* mmu_create_table(void* addr, mmu_granularity granularity)
{
    if ((uintptr)addr % granularity != 0)
        return NULL;

    mmu_page_descriptor* addr64 = (mmu_page_descriptor*)addr;

    for (size_t i = 0; i < table_entries(granularity); i++)
        *addr64++ = (mmu_page_descriptor) {.u64 = 0};

    return (mmu_table*)addr;
}

bool mmu_set_page_descriptor_cfg(mmu_table table, size_t entry, mmu_page_descriptor_cfg cfg)
{
    if (table.table_addr == NULL || entry >= table_entries(table.granularity))
        return false;

    return build_pd(table.granularity, table.level, cfg, &table.table_addr[entry]);
}


bool mmu_get_page_descriptor(mmu_table table, size_t entry, mmu_page_descriptor* pd)
{
    if (table.table_addr == NULL || entry >= table_entries(table.granularity))
        return false;

    *pd = table.table_addr[entry];
    return true;
}
