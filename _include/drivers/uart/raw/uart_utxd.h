#pragma once

#ifndef DRIVERS
#error "This header should only be imported by a driver"
#endif

#include <lib/mmio/mmio_macros.h>

#include "uart_map.h"

// 17.2.14.2 - 7366

#define UART_UTXD_OFFSET 0x40UL

#define UTXD_VALUE_STRUCT_NAME UartUtxdValue

MMIO_DECLARE_REG32_VALUE_STRUCT(UTXD_VALUE_STRUCT_NAME);

MMIO_DECLARE_REG32_SETTER_WITH_BASE(UART, UTXD, UTXD_VALUE_STRUCT_NAME,
									UART_UTXD_OFFSET);

#define UTXD_SHIFT 0
#define UTXD_MASK (0xFF << UTXD_SHIFT)

UART_DECLARE_BIT_FIELD_SETTER(UTXD, TX_DATA, UTXD_VALUE_STRUCT_NAME, uint8,
							  UTXD_SHIFT, UTXD_MASK);