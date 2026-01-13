#pragma once

#include <boot/panic.h>
#include <lib/stdint.h>

typedef enum
{
    MMU_GRANULARITY_4KB = 4 * 1024,
    MMU_GRANULARITY_16KB = 16 * 1024,
    MMU_GRANULARITY_64KB = 64 * 1024,
} mmu_granularity;

typedef enum
{
    MMU_TABLE_LEVEL0 = 0,
    MMU_TABLE_LEVEL1,
    MMU_TABLE_LEVEL2,
    MMU_TABLE_LEVEL3,
} mmu_table_lvl;

typedef enum
{
    MMU_TABLE_DESCRIPTOR_BLOCK = 0,
    MMU_TABLE_DESCRIPTOR_TABLE = 1,

} mmu_table_descriptor_type;

typedef enum
{
    MMU_ACCESS_PERMISSION_EL0NA_EL1_RW = 0b00,
    MMU_ACCESS_PERMISSION_EL0RW_EL1_RW = 0b01,
    MMU_ACCESS_PERMISSION_EL0NA_EL1_RO = 0b10,
    MMU_ACCESS_PERMISSION_EL0RO_EL1_RO = 0b11,
} mmu_access_permission;


typedef struct
{
    uint64 u64;
} mmu_page_descriptor;

static inline uint64 mmu_granularity_shift(mmu_granularity g)
{
    switch (g)
    {
        case MMU_GRANULARITY_4KB:
            return 12;
        case MMU_GRANULARITY_16KB:
            return 14;
        case MMU_GRANULARITY_64KB:
            return 16;
#ifdef TEST
        default:
            PANIC("mmu_granularity_shift unhandled");
#endif
    }
    return 12;
}

static inline uint64 output_address_bits(mmu_granularity g)
{
    const uint64 shift = mmu_granularity_shift(g);
    const uint64 pa_bits = 48 - shift;

    return pa_bits;
}

static inline uint64 output_address_mask(mmu_granularity g)
{
    const uint64 shift = mmu_granularity_shift(g);
    const uint64 pa_bits = 48 - shift;

    return ((1ULL << pa_bits) - 1) << shift;
}


/*
    Page descriptor bit definitions
*/
#define MMU_PD_VALID_SHIFT 0
#define MMU_PD_VALID_WIDTH 1

#define MMU_PD_TYPE_SHIFT 1
#define MMU_PD_TYPE_WIDTH 1

#define MMU_PD_ATTR_INDEX_SHIFT 2
#define MMU_PD_ATTR_INDEX_WIDTH 3

#define MMU_PD_NS_SHIFT 5
#define MMU_PD_NS_WIDTH 1

#define MMU_PD_AP_SHIFT 6
#define MMU_PD_AP_WIDTH 2

#define MMU_PD_SH_SHIFT 8
#define MMU_PD_SH_WIDTH 2

#define MMU_PD_AF_SHIFT 10
#define MMU_PD_AF_WIDTH 1

#define MMU_PD_PXN_SHIFT 53
#define MMU_PD_PXN_WIDTH 1

#define MMU_PD_UXN_SHIFT 54
#define MMU_PD_UXN_WIDTH 1

#define MMU_PD_SW_SHIFT 55
#define MMU_PD_SW_WIDTH 4

/* helpers */
#define MMU_PD_BITS(width) ((1ULL << (width)) - 1)
#define MMU_PD_FIELD_MASK(shift, width) (MMU_PD_BITS(width) << (shift))


// getters
static inline bool mmu_pd_get_valid(const mmu_page_descriptor pd)
{
    return (bool)((pd.u64 >> MMU_PD_VALID_SHIFT) & MMU_PD_BITS(MMU_PD_VALID_WIDTH));
}

static inline mmu_table_descriptor_type mmu_pd_get_type(const mmu_page_descriptor pd)
{
    return (mmu_table_descriptor_type)((pd.u64 >> MMU_PD_TYPE_SHIFT) &
                                       MMU_PD_BITS(MMU_PD_TYPE_WIDTH));
}

static inline uint8 mmu_pd_get_attr_index(const mmu_page_descriptor pd)
{
    return (uint8)((pd.u64 >> MMU_PD_ATTR_INDEX_SHIFT) & MMU_PD_BITS(MMU_PD_ATTR_INDEX_WIDTH));
}

static inline bool mmu_pd_get_non_secure(const mmu_page_descriptor pd)
{
    return (bool)((pd.u64 >> MMU_PD_NS_SHIFT) & MMU_PD_BITS(MMU_PD_NS_WIDTH));
}

static inline mmu_access_permission mmu_pd_get_access_permissions(const mmu_page_descriptor pd)
{
    return (mmu_access_permission)((pd.u64 >> MMU_PD_AP_SHIFT) & MMU_PD_BITS(MMU_PD_AP_WIDTH));
}

static inline uint8 mmu_pd_get_shareability(const mmu_page_descriptor pd)
{
    return (uint8)((pd.u64 >> MMU_PD_SH_SHIFT) & MMU_PD_BITS(MMU_PD_SH_WIDTH));
}

static inline bool mmu_pd_get_access_flag(const mmu_page_descriptor pd)
{
    return (bool)((pd.u64 >> MMU_PD_AF_SHIFT) & MMU_PD_BITS(MMU_PD_AF_WIDTH));
}

static inline uint64 mmu_pd_get_output_address(const mmu_page_descriptor pd,
                                               mmu_granularity granularity)
{
    return (pd.u64 & output_address_mask(granularity)) >> mmu_granularity_shift(granularity);
}

static inline bool mmu_pd_get_privileged_execute_never(const mmu_page_descriptor pd)
{
    return (bool)((pd.u64 >> MMU_PD_PXN_SHIFT) & MMU_PD_BITS(MMU_PD_PXN_WIDTH));
}

static inline bool mmu_pd_get_unprivileged_execute_never(const mmu_page_descriptor pd)
{
    return (bool)((pd.u64 >> MMU_PD_UXN_SHIFT) & MMU_PD_BITS(MMU_PD_UXN_WIDTH));
}

static inline uint8 mmu_pd_get_software_defined(const mmu_page_descriptor pd)
{
    return (uint8)((pd.u64 >> MMU_PD_SW_SHIFT) & MMU_PD_BITS(MMU_PD_SW_WIDTH));
}


// setters
static inline void mmu_pd_set_valid(mmu_page_descriptor* pd, bool valid)
{
    pd->u64 &= ~MMU_PD_FIELD_MASK(MMU_PD_VALID_SHIFT, MMU_PD_VALID_WIDTH);
    pd->u64 |= ((uint64)valid << MMU_PD_VALID_SHIFT);
}

static inline void mmu_pd_set_type(mmu_page_descriptor* pd, mmu_table_descriptor_type type)
{
    pd->u64 &= ~MMU_PD_FIELD_MASK(MMU_PD_TYPE_SHIFT, MMU_PD_TYPE_WIDTH);
    pd->u64 |= ((uint64)type << MMU_PD_TYPE_SHIFT);
}

static inline void mmu_pd_set_attr_index(mmu_page_descriptor* pd, uint8 attr_index)
{
    pd->u64 &= ~MMU_PD_FIELD_MASK(MMU_PD_ATTR_INDEX_SHIFT, MMU_PD_ATTR_INDEX_WIDTH);
    pd->u64 |= ((uint64)attr_index & MMU_PD_BITS(MMU_PD_ATTR_INDEX_WIDTH))
               << MMU_PD_ATTR_INDEX_SHIFT;
}

static inline void mmu_pd_set_non_secure(mmu_page_descriptor* pd, bool non_secure)
{
    pd->u64 &= ~MMU_PD_FIELD_MASK(MMU_PD_NS_SHIFT, MMU_PD_NS_WIDTH);
    pd->u64 |= ((uint64)non_secure << MMU_PD_NS_SHIFT);
}

static inline void mmu_pd_set_access_permissions(mmu_page_descriptor* pd,
                                                 mmu_access_permission permissions)
{
    pd->u64 &= ~MMU_PD_FIELD_MASK(MMU_PD_AP_SHIFT, MMU_PD_AP_WIDTH);
    pd->u64 |= ((uint64)permissions << MMU_PD_AP_SHIFT);
}

static inline void mmu_pd_set_shareability(mmu_page_descriptor* pd, uint8 shareability)
{
    pd->u64 &= ~MMU_PD_FIELD_MASK(MMU_PD_SH_SHIFT, MMU_PD_SH_WIDTH);
    pd->u64 |= ((uint64)shareability & MMU_PD_BITS(MMU_PD_SH_WIDTH)) << MMU_PD_SH_SHIFT;
}

static inline void mmu_pd_set_access_flag(mmu_page_descriptor* pd, bool access_flag)
{
    pd->u64 &= ~MMU_PD_FIELD_MASK(MMU_PD_AF_SHIFT, MMU_PD_AF_WIDTH);
    pd->u64 |= ((uint64)access_flag << MMU_PD_AF_SHIFT);
}

static inline void mmu_pd_set_output_address(mmu_page_descriptor* pd, uint64 output_address,
                                             mmu_granularity granularity)
{
    const uint64 shift = mmu_granularity_shift(granularity);
    const uint64 pa_bits = output_address_bits(granularity);

    if (output_address >= (1ULL << pa_bits))
    {
#ifdef TEST
        PANIC("mmu_pd_set_output_address: invalid output address, out of granularity");
#endif
        return;
    }

    if (output_address % granularity != 0)
    {
#ifdef TEST
        PANIC("mmu_pd_set_output_address: invalid output address, not aligned to granularity");
#endif
        return;
    }


    const uint64 mask = output_address_mask(granularity);

    pd->u64 &= ~mask;
    pd->u64 |= (output_address << shift) & mask;
}

static inline void mmu_pd_set_privileged_execute_never(mmu_page_descriptor* pd, bool pxn)
{
    pd->u64 &= ~MMU_PD_FIELD_MASK(MMU_PD_PXN_SHIFT, MMU_PD_PXN_WIDTH);
    pd->u64 |= ((uint64)pxn << MMU_PD_PXN_SHIFT);
}

static inline void mmu_pd_set_unprivileged_execute_never(mmu_page_descriptor* pd, bool uxn)
{
    pd->u64 &= ~MMU_PD_FIELD_MASK(MMU_PD_UXN_SHIFT, MMU_PD_UXN_WIDTH);
    pd->u64 |= ((uint64)uxn << MMU_PD_UXN_SHIFT);
}

static inline void mmu_pd_set_software_defined(mmu_page_descriptor* pd, uint8 software_defined)
{
    pd->u64 &= ~MMU_PD_FIELD_MASK(MMU_PD_SW_SHIFT, MMU_PD_SW_WIDTH);
    pd->u64 |= ((uint64)software_defined & MMU_PD_BITS(MMU_PD_SW_WIDTH)) << MMU_PD_SW_SHIFT;
}


// Page descriptor bit definitions
#undef MMU_PD_VALID_SHIFT
#undef MMU_PD_VALID_WIDTH

#undef MMU_PD_TYPE_SHIFT
#undef MMU_PD_TYPE_WIDTH

#undef MMU_PD_ATTR_INDEX_SHIFT
#undef MMU_PD_ATTR_INDEX_WIDTH

#undef MMU_PD_NS_SHIFT
#undef MMU_PD_NS_WIDTH

#undef MMU_PD_AP_SHIFT
#undef MMU_PD_AP_WIDTH

#undef MMU_PD_SH_SHIFT
#undef MMU_PD_SH_WIDTH

#undef MMU_PD_AF_SHIFT
#undef MMU_PD_AF_WIDTH

#undef MMU_PD_PXN_SHIFT
#undef MMU_PD_PXN_WIDTH

#undef MMU_PD_UXN_SHIFT
#undef MMU_PD_UXN_WIDTH

#undef MMU_PD_SW_SHIFT
#undef MMU_PD_SW_WIDTH

// helpers
#undef MMU_PD_BITS
#undef MMU_PD_FIELD_MASK
