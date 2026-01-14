#pragma once


#include <lib/stdint.h>

#include "mmu_page_descriptor.h"


// https://github.com/bztsrc/raspi3-tutorial/blob/master/10_virtualmemory/mmu.c
// https://documentation-service.arm.com/static/63a43e333f28e5456434e18b?token=


/*
    ---------------- 4 KB granularity ----------------
struct
{
    uint64 valid : 1;            // [0]
    uint64 type : 1;             // [1] = 1 (page)
    uint64 attr_index : 3;       // [4:2]
    uint64 non_secure : 1;       // [5]
    uint64 ap : 2;               // [7:6]
    uint64 sh : 2;               // [9:8]
    uint64 access_flag : 1;      // [10]
    uint64 reserved0 : 1;        // [11]
    uint64 output_address : 36;  // [47:12]
    uint64 reserved1 : 5;        // [52:48]
    uint64 pxn : 1;              // [53]
    uint64 uxn : 1;              // [54]
    uint64 software_defined : 4; // [58:55]
    uint64 reserved2 : 5;        // [63:59]
} page_4kb;

    ---------------- 16 KB granularity ----------------
struct
{
    uint64 valid : 1;            // [0]
    uint64 type : 1;             // [1] = 1 (page)
    uint64 attr_index : 3;       // [4:2]
    uint64 non_secure : 1;       // [5]
    uint64 ap : 2;               // [7:6]
    uint64 sh : 2;               // [9:8]
    uint64 access_flag : 1;      // [10]
    uint64 reserved0 : 3;        // [13:11]
    uint64 output_address : 34;  // [47:14]
    uint64 reserved1 : 5;        // [52:48]
    uint64 pxn : 1;              // [53]
    uint64 uxn : 1;              // [54]
    uint64 software_defined : 4; // [58:55]
    uint64 reserved2 : 5;        // [63:59]
} page_16kb;

   ---------------- 64 KB granularity ----------------
struct
{
    uint64 valid : 1;            // [0]
    uint64 type : 1;             // [1] = 1 (page)
    uint64 attr_index : 3;       // [4:2]
    uint64 non_secure : 1;       // [5]
    uint64 ap : 2;               // [7:6]
    uint64 sh : 2;               // [9:8]
    uint64 access_flag : 1;      // [10]
    uint64 reserved0 : 5;        // [15:11]
    uint64 output_address : 32;  // [47:16]
    uint64 reserved1 : 5;        // [52:48]
    uint64 pxn : 1;              // [53]
    uint64 uxn : 1;              // [54]
    uint64 software_defined : 4; // [58:55]
    uint64 reserved2 : 5;        // [63:59]
} page_64kb;
*/


typedef struct
{
    _Alignas(16) bool valid;
    _Alignas(16) mmu_table_descriptor_type type;
    _Alignas(16) uint8 attr_index;
    _Alignas(16) bool non_secure;
    _Alignas(16) mmu_access_permission access_permissions;
    _Alignas(16) uint8 shareability;
    _Alignas(16) bool access_flag;
    _Alignas(16) uintptr output_address;
    _Alignas(16) bool privileged_execute_never;
    _Alignas(16) bool unprivileged_execute_never;
    _Alignas(16) uint8 software_defined;
} mmu_page_descriptor_cfg;


typedef struct
{
    mmu_page_descriptor* table_addr;
    mmu_granularity granularity;
    mmu_table_level level;
} mmu_table_handle;

/// Creates an uninitialized (set as invalid) table at the address
bool mmu_init_table(mmu_table_handle* tbl, void* addr, mmu_granularity granularity,
                    mmu_table_level lvl);

/// Sets a page descriptor values by a config struct
bool mmu_set_page_descriptor_cfg(mmu_table_handle table, size_t entry,
                                 const mmu_page_descriptor_cfg* cfg);

/// Sets the table page descriptor to the provided one
bool mmu_set_page_descriptor(mmu_table_handle table, size_t entry, mmu_page_descriptor pd);

/// Gets a copy of the descriptor (not the actual ref)
bool mmu_get_page_descriptor(mmu_table_handle table, size_t entry, mmu_page_descriptor* pd);


void mmu_init(mmu_table_handle lvl0_handle);