#pragma once
#include <kernel/devices/device.h>
#include <lib/lock/spinlock.h>
#include <lib/mem.h>
#include <lib/stdbitfield.h>
#include <lib/stdbool.h>
#include <lib/stdint.h>

#define UART_TX_BUF_SIZE 8192
#define UART_RX_BUF_SIZE 1024

typedef enum {
    UART_MODE_EARLY = 0,
    UART_MODE_FULL,
} uart_mode;


typedef struct {
    uart_mode mode;
    p_uintptr early_base;

    bitfield32 irq_status;
    spinlock_t rx_lock;
    spinlock_t tx_lock;
    _Alignas(64) struct {
        bool overwrite;
        size_t head;
        size_t tail;
        uint8 buf[UART_TX_BUF_SIZE];
    } tx;

    _Alignas(64) struct {
        bool overwrite;
        size_t head;
        size_t tail;
        uint8 buf[UART_RX_BUF_SIZE];
    } rx;
} uart_state;


uart_mode uart_get_mode(const driver_handle* h);


/*
    Early init features
*/
void uart_early_init(const driver_handle* h, p_uintptr base);

void uart_putc_early(const driver_handle* h, const char c);
void uart_puts_early(const driver_handle* h, const char* s);


/*
    Full features
*/
void uart_reset(const driver_handle* h);

// Pre IRQ initialization
void UART_init_stage0(const driver_handle* h);

// Post IRQ initialization
void uart_init_stage1(const driver_handle* h);

bool uart_read(const driver_handle* h, uint8* data);

// The kernel should call this fn
void uart_handle_irq(const driver_handle* h);

void uart_putc_sync(const driver_handle* h, const char c);
void uart_puts_sync(const driver_handle* h, const char* s);

void uart_putc(const driver_handle* h, const char c);
void uart_puts(const driver_handle* h, const char* s);


static inline size_t uart_tx_capacity()
{
    return UART_TX_BUF_SIZE;
}

static inline size_t uart_rx_capacity()
{
    return UART_RX_BUF_SIZE;
}

extern size_t uart_tx_len(const driver_handle* h);
extern size_t uart_rx_len(const driver_handle* h);