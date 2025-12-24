#pragma once

#include <arm/cpu.h>
#include <drivers/interrupts/interrupts.h>
#include <lib/stdint.h>

void GICV3_set_irq_group1ns(imx8mp_irq irq, bool v);

void GICV3_route_spi_to_cpu(imx8mp_irq irq, ARM_cpu_affinity affinity);
void GICV3_route_spi_to_self(imx8mp_irq irq);

void GICV3_enable_spi(imx8mp_irq irq);

void GICV3_set_priority(imx8mp_irq irq, uint8 priority);

void GICV3_set_edge_triggered(imx8mp_irq irq);
void GICV3_set_level_sensitive(imx8mp_irq irq);

void GICV3_wake_redistributor(size_t n);

void GICV3_init_distributor(void);

void GICV3_init_cpu(size_t cpu);

void uart_irq_init(void);
