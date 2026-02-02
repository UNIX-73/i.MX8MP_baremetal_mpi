#include "kernel/mm.h"

#include <arm/mmu/mmu.h>
#include <frdm_imx8mp.h>
#include <kernel/panic.h>
#include <lib/stdint.h>


extern uintptr _get_pc(void);


mmu_handle mm_mmu_h;


bool mm_kernel_is_relocated()
{
    uintptr pc = _get_pc();

    return ((pc >> 47) & 0x1FFFFUL) == 0x1FFFFUL;
}


v_uintptr mm_remap(p_uintptr pa)
{
    DEBUG_ASSERT(pa < KERNEL_BASE);

    return pa + KERNEL_BASE;
}
