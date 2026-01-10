#pragma once
#include <kernel/devices/device.h>
#include <lib/stdbitfield.h>
#include <lib/stdbool.h>
#include <lib/stdint.h>

#include "lib/lock/_lock_types.h"

#define UART_TX_BUF_SIZE 8192
#define UART_RX_BUF_SIZE 1024

typedef struct
{
    bitfield32 irq_status;
    spinlock_t rx_lock;
    spinlock_t tx_lock;
    _Alignas(64) struct
    {
        bool overwrite;
        size_t head;
        size_t tail;
        uint8 buf[UART_TX_BUF_SIZE];
    } tx;

    _Alignas(64) struct
    {
        bool overwrite;
        size_t head;
        size_t tail;
        uint8 buf[UART_RX_BUF_SIZE];
    } rx;
} uart_state;

void UART_reset(const driver_handle* h);

// Pre IRQ initialization
void UART_init_stage0(const driver_handle* h);

// Post IRQ initialization
void UART_init_stage1(const driver_handle* h);

bool UART_read(const driver_handle* h, uint8* data);

// The kernel should call this fn
void UART_handle_irq(const driver_handle* h);

void UART_putc_sync(const driver_handle* h, const uint8 c);
void UART_puts_sync(const driver_handle* h, const char* s);

void UART_putc(const driver_handle* h, const uint8 c);
void UART_puts(const driver_handle* h, const char* s);