#pragma once

#include <drivers/interrupts/interrupts.h>

typedef void (*irq_handler_t)(void);

void kernel_handle_irq(imx8mp_irq irqid);