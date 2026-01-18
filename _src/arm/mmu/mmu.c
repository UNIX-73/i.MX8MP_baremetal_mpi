#include <arm/mmu/mmu.h>
#include <lib/memcpy.h>
#include <lib/stdint.h>
#include <lib/stdmacros.h>

#include "arm/mmu/mmu_page_descriptor.h"

#ifdef TEST
#    include <boot/panic.h>
#endif


extern uint64 _mmu_get_MAIR_EL1(void);
extern void _mmu_set_MAIR_EL1(uint64 v);

extern uint64 _mmu_get_SCTLR_EL1(void);
extern void _mmu_set_SCTLR_EL1(uint64 v);

extern uint64 _mmu_get_TTBR0_EL1(void);
extern void _mmu_set_TTBR0_EL1(uint64 v);

extern uint64 _mmu_get_TTBR1_EL1(void);
extern void _mmu_set_TTBR1_EL1(uint64 v);

// https://df.lth.se/~getz/ARM/SysReg/AArch64-tcr_el1.html#fieldset_0-5_0
extern uint64 _mmu_get_TCR_EL1(void);
extern void _mmu_set_TCR_EL1(uint64 v);

extern uint64 _mmu_get_ID_AA64MMFR0_EL1(void);


extern void _mmu_asm_init(void);


static inline size_t table_entries_(mmu_granularity g)
{
    return g / sizeof(mmu_page_descriptor);
}


static bool build_pd_(mmu_granularity granularity, mmu_table_level lvl,
                     const mmu_page_descriptor_cfg* cfg, mmu_page_descriptor* pd)
{
    if (lvl == MMU_TABLE_LEVEL0 && cfg->type == MMU_TABLE_DESCRIPTOR_BLOCK)
        return false;

    if (cfg->output_address % granularity != 0)
        return false;

    if (cfg->output_address >= (1ULL << output_address_bit_n(granularity)))
        return false;

    uint64 pd_u64 = 0;

    // low attributes
    pd_u64 |= (uint64)cfg->valid << MMU_PD_VALID_SHIFT;
    pd_u64 |= (uint64)cfg->type << MMU_PD_TYPE_SHIFT;
    pd_u64 |= (uint64)(cfg->attr_index & 0b111) << MMU_PD_ATTR_INDEX_SHIFT;
    pd_u64 |= (uint64)cfg->non_secure << MMU_PD_NS_SHIFT;
    pd_u64 |= (uint64)cfg->access_permissions << MMU_PD_AP_SHIFT;
    pd_u64 |= (uint64)(cfg->shareability & 0b11) << MMU_PD_SH_SHIFT;
    pd_u64 |= (uint64)cfg->access_flag << MMU_PD_AF_SHIFT;

    // output_address
    pd_u64 |= cfg->output_address & output_address_mask(granularity);

    // high attributes
    pd_u64 |= (uint64)cfg->privileged_execute_never << MMU_PD_PXN_SHIFT;
    pd_u64 |= (uint64)cfg->unprivileged_execute_never << MMU_PD_UXN_SHIFT;
    pd_u64 |= (uint64)(cfg->software_defined & 0xF) << MMU_PD_SW_SHIFT;

    pd->v = pd_u64;

    return true;
}

bool mmu_init_table(mmu_table_handle* tbl, void* addr, mmu_granularity granularity,
                    mmu_table_level lvl, mmu_page_descriptor_cfg* pd_cfg)
{
    if ((uintptr)addr % granularity != 0)
        return false;

    if (lvl == MMU_TABLE_LEVEL3 && granularity == MMU_GRANULARITY_64KB)
        return false;

    tbl->granularity = granularity;
    tbl->level = lvl;
    tbl->table_addr = (mmu_page_descriptor*)addr;


    mmu_page_descriptor pd;
    (pd_cfg != NULL) ? build_pd_(granularity, lvl, pd_cfg, &pd) : (pd.v = 0);

    for (size_t i = 0; i < table_entries_(granularity); i++)
        tbl->table_addr[i] = pd;

    return true;
}

bool mmu_get_page_descriptor_cfg(mmu_table_handle table, size_t entry, mmu_page_descriptor_cfg* cfg)
{
    if (cfg == NULL || table.table_addr == NULL || entry >= table_entries_(table.granularity))
        return false;

    mmu_page_descriptor pd = table.table_addr[entry];

    cfg->valid = mmu_pd_get_valid(pd);
    cfg->type = mmu_pd_get_type(pd);
    cfg->attr_index = mmu_pd_get_attr_index(pd);
    cfg->non_secure = mmu_pd_get_non_secure(pd);
    cfg->access_permissions = mmu_pd_get_access_permissions(pd);
    cfg->shareability = mmu_pd_get_shareability(pd);
    cfg->access_flag = mmu_pd_get_access_flag(pd);
    cfg->output_address = mmu_pd_get_output_address(pd, table.granularity);
    cfg->privileged_execute_never = mmu_pd_get_privileged_execute_never(pd);
    cfg->unprivileged_execute_never = mmu_pd_get_unprivileged_execute_never(pd);
    cfg->software_defined = mmu_pd_get_software_defined(pd);

    return true;
}


bool mmu_set_page_descriptor_cfg(mmu_table_handle table, size_t entry,
                                 const mmu_page_descriptor_cfg* cfg)
{
    if (cfg == NULL || table.table_addr == NULL || entry >= table_entries_(table.granularity))
        return false;

    return build_pd_(table.granularity, table.level, cfg, &table.table_addr[entry]);
}


bool mmu_get_page_descriptor(mmu_table_handle table, size_t entry, mmu_page_descriptor* pd)
{
    if (table.table_addr == NULL || entry >= table_entries_(table.granularity))
        return false;

    *pd = table.table_addr[entry];
    return true;
}

//  DDI0500J_cortex_a53_trm.pdf p.104
static inline bool mmu_supports_4kb_(uint64 id_aa64mmfr0)
{
    return (((id_aa64mmfr0 >> 28) & 0xF) == 0);
}

//  DDI0500J_cortex_a53_trm.pdf p.104
static inline bool mmu_supports_64kb_(uint64 id_aa64mmfr0)
{
    return (((id_aa64mmfr0 >> 24) & 0xF) == 0);
}

//  DDI0500J_cortex_a53_trm.pdf p.104
static inline bool mmu_supports_16kb_(uint64 id_aa64mmfr0)
{
    return (((id_aa64mmfr0 >> 20) & 0xF) == 0);
}

// TODO: make it cleaner and less hardcoded
void mmu_init(mmu_table_handle lvl0_handle)
{
    if (lvl0_handle.level != MMU_TABLE_LEVEL0)
        PANIC("Invalid mmu table level");

    if ((uintptr)lvl0_handle.table_addr % lvl0_handle.granularity != 0)
        PANIC("Invalid mmu table alignment");

    uint64 id_aa64mmfr0 = _mmu_get_ID_AA64MMFR0_EL1();
    uint64 pa_range = id_aa64mmfr0 & 0xFUL; // [3:0] DDI0500J_cortex_a53_trm.pdf p.104

    switch (lvl0_handle.granularity)
    {
        case MMU_GRANULARITY_4KB:
            if (!mmu_supports_4kb_(id_aa64mmfr0))
                PANIC("4KB granularity not supported");
            break;
        case MMU_GRANULARITY_16KB:
            if (!mmu_supports_16kb_(id_aa64mmfr0))
                PANIC("16KB granularity not supported");
            break;
        case MMU_GRANULARITY_64KB:
            if (!mmu_supports_64kb_(id_aa64mmfr0))
                PANIC("64KB granularity not supported");
            break;
        default:
            PANIC("Unknown MMU granularity");
    }

    uint64 ips;
    switch (pa_range)
    {
        case 0b0000:
            ips = 0b000;
            break; // 32 bits
        case 0b0001:
            ips = 0b001;
            break; // 36 bits
        case 0b0010:
            ips = 0b010;
            break; // 40 bits
        case 0b0011:
            ips = 0b011;
            break; // 42 bits
        case 0b0100:
            ips = 0b100;
            break; // 44 bits
        case 0b0101:
            ips = 0b101;
            break; // 48 bits
        default:
            PANIC("Unsupported PA range");
    }

    uint64 sctlr = _mmu_get_SCTLR_EL1();
    sctlr &= ~(1ULL << 0);  // M = 0
    sctlr &= ~(1ULL << 2);  // C = 0
    sctlr &= ~(1ULL << 12); // I = 0
    _mmu_set_SCTLR_EL1(sctlr);


    // AttrIdx 0: Normal memory, WB WA
    // AttrIdx 1: Device-nGnRE
    // https://df.lth.se/~getz/ARM/SysReg/AArch64-mair_el1.html
    uint64 mair = (0xFFUL << 0) | (0x04UL << 8);

    uint64 tcr = 0;
    tcr |= (16ULL << 0);    // T0SZ = 16 (48-bit VA)
    tcr |= (0b00ULL << 14); // TG0 = 4KB
    tcr |= (0b11ULL << 12); // SH0 = Inner
    tcr |= (0b01ULL << 10); // ORGN0 = WB WA
    tcr |= (0b01ULL << 8);  // IRGN0 = WB WA
    tcr |= (1ULL << 23);    // EPD1 = 1 (disable TTBR1)
    tcr |= (ips << 32);     // IPS

    _mmu_set_MAIR_EL1(mair);
    _mmu_set_TCR_EL1(tcr);
    _mmu_set_TTBR0_EL1((uintptr)lvl0_handle.table_addr);
    _mmu_set_TTBR1_EL1(0); // TODO: allow using ttbr1


    asm volatile("tlbi vmalle1\n"
                 "dsb ish\n"
                 "isb\n");

    // http://classweb.ece.umd.edu/enee447.S2021/baremetal_boot_code_for_ARMv8_A_processors.pdf
    sctlr = _mmu_get_SCTLR_EL1();
    asm volatile("isb");
    sctlr |= (1UL << 12); // I Enable instruction cache
    sctlr |= (1UL << 2);  // Enable data cache
    sctlr &= ~(1UL << 1); // Disable alignment trap
    sctlr |= (1UL << 0);  // M MMU enable
    asm volatile("dsb sy\n");
    _mmu_set_SCTLR_EL1(sctlr);
    asm volatile("isb\n"
                 "dsb sy");
}
