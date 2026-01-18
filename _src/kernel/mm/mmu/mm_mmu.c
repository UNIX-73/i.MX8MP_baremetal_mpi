/*

#include "mm_mmu.h"




#include <arm/mmu/mmu.h>
#include <kernel/mm/mm.h>
#include <lib/malloc/xalloc.h>
#include <lib/stdmacros.h>
#include <lib/unit/mem.h>

#include "arm/mmu/mmu_page_descriptor.h"

#include "mm_map.h"

typedef struct
{
    _Alignas(1024 * 4) mmu_page_descriptor pd[512];
} mmu_tbl_4kb_granularity;


_Alignas(1024 * 4) mmu_page_descriptor table_lv0[512];
_Alignas(1024 * 4) mmu_page_descriptor table_lv1[512];


static void mm_mmu_init_device_memory();
static void mm_mmu_init_text_memory();


// pointer to the address allocated by kalloc


static mmu_tbl_4kb_granularity* mmu_tables_pages_area;
static mmu_table_handle* mmu_tables_handles_area;

// The entries of both mmu_tables and mmu_tables_handles
static size_t mmu_tables_pair_count;


void mm_mmu_init()
{
    mmu_tables_pages_area =
        kalloc(KALLOC_BLOCK_BYTES, "mmu_tables_lvl2_2mib", true, &mmu_tbl_kmem_id);

    if (!mmu_tables_pages_area ||
        (uintptr)mmu_tables_pages_area % _Alignof(mmu_tbl_4kb_granularity) != 0)
        PANIC("mmu_tables: error initializing");

    mmu_tables_pair_count =
        KALLOC_BLOCK_BYTES / (sizeof(mmu_table_handle) + sizeof(mmu_tbl_4kb_granularity));

    // the handles for each page start where the actual pages end. Each page has a handle, ordered
    // equally (idx 0 for both a page and a handle from each pointer)
    mmu_tables_handles_area =
        (mmu_table_handle*)((uintptr)mmu_tables_pages_area +
                            sizeof(mmu_tbl_4kb_granularity) * mmu_tables_pair_count);

    if ((uintptr)mmu_tables_handles_area % _Alignof(mmu_table_handle) != 0)
        PANIC("mmu_tables_handles: not aligned");

    // init tables as null pages (the level will be changed later)
    for (size_t i = 0; i < mmu_tables_pair_count; i++)
        mmu_init_table(&mmu_tables_handles_area[i], &mmu_tables_pages_area[i], MMU_GRANULARITY_4KB,
                       MMU_TABLE_LEVEL0, NULL);


    // --------------- old

    mmu_table_handle lvl0_handle;
    mmu_table_handle lvl1_handle;


    mmu_init_table(&lvl0_handle, table_lv0, MMU_GRANULARITY_4KB, MMU_TABLE_LEVEL0, NULL);
    mmu_init_table(&lvl1_handle, table_lv1, MMU_GRANULARITY_4KB, MMU_TABLE_LEVEL1, NULL);

    mmu_page_descriptor_cfg lvl0_cfg = {
        .valid = true,
        .type = MMU_TABLE_DESCRIPTOR_TABLE,
        .attr_index = 0,
        .non_secure = 0,
        .access_permissions = MMU_ACCESS_PERMISSION_EL0RW_EL1_RW,
        .shareability = MMU_SHAREABILITY_INNER_SHAREABLE,
        .access_flag = 1,
        .output_address = (uintptr)table_lv1,
        .privileged_execute_never = 0,
        .unprivileged_execute_never = 0,
        .software_defined = 0,
    };

    lvl0_cfg.output_address = (uintptr)lvl1_handle.table_addr;
    mmu_set_page_descriptor_cfg(lvl0_handle, 0, &lvl0_cfg);

    // setup lvl1
    mmu_page_descriptor_cfg lvl1_cfg = {
        .valid = true,
        .type = MMU_TABLE_DESCRIPTOR_BLOCK,
        .attr_index = 0,
        .non_secure = 0,
        .access_permissions = MMU_ACCESS_PERMISSION_EL0NA_EL1_RW,
        .shareability = MMU_SHAREABILITY_INNER_SHAREABLE,
        .access_flag = 1,
        .output_address = (uintptr)NULL,
        .privileged_execute_never = 0,
        .unprivileged_execute_never = 0,
        .software_defined = 0,
    };

    for (size_t i = 0; i < 3; i++)
    {
        lvl1_cfg.output_address = i * 0x40000000UL; // i * 1gib for va=pa
        lvl1_cfg.software_defined = i;
        lvl1_cfg.attr_index = (i == 0) ? 1 : 0;

        mmu_set_page_descriptor_cfg(lvl1_handle, i, &lvl1_cfg);
    }

    mmu_init(lvl0_handle);

    mm_mmu_init_device_memory();
    mm_mmu_init_text_memory();
}


static void mm_mmu_init_device_memory(void)
{
}


static void mm_mmu_init_text_memory() {} */