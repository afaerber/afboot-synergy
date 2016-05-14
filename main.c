#include <stdlib.h>
#include <stdint.h>

#define PORTx_PCNTR1(x)	(0x40040000UL + (x) * 0x20)
#define PORTx_PCNTR3(x)	(0x40040008UL + (x) * 0x20)

static void delay(uint32_t timeout)
{
	uint32_t i;

	for (i = 0; i < timeout; i++) {
		asm volatile ("nop; nop; nop; nop");
	}
}

int main(void)
{
	volatile uint32_t *PORT8_PCNTR1 = (void*)PORTx_PCNTR1(8);
	volatile uint32_t *PORT8_PCNTR3 = (void*)PORTx_PCNTR3(8);
	uint32_t val;

	val = *PORT8_PCNTR1;
	val |=    (1 << 10) | (1 << 9) | (1 << 8) | (1 << 7);
	val &= ~(((1 << 10) | (1 << 9) | (1 << 8) | (1 << 7)) << 16);
	*PORT8_PCNTR1 = val;

	while (1) {
		*PORT8_PCNTR3 = (((1 <<  9) | (1 << 8)) << 16) | (1 << 10) | (1 << 7);
		delay(100000);
		*PORT8_PCNTR3 = (((1 << 10) | (1 << 7)) << 16) | (1 <<  9) | (1 << 8);
		delay(100000);
	}

	return 0;
}

static void noop(void)
{
	while (1) {
	}
}

extern unsigned int _end_text;
extern unsigned int _start_data;
extern unsigned int _end_data;
extern unsigned int _start_bss;
extern unsigned int _end_bss;

void reset(void);

void reset(void)
{
	unsigned int *src, *dst;

	src = &_end_text;
	dst = &_start_data;
	while (dst < &_end_data) {
		*dst++ = *src++;
	}

	dst = &_start_bss;
	while (dst < &_end_bss) {
		*dst++ = 0;
	}

	main();
}

extern unsigned long _stack_top;

__attribute__((section(".vector_table")))
void (*vector_table[16 + 96])(void) = {
	(void (*))&_stack_top,
	reset,
	noop,
	noop,
	noop,
	noop,
	noop,
	NULL,
	NULL,
	NULL,
	NULL,
	noop,
	noop,
	NULL,
	noop,
	noop,
	[16 ... 16 + 96 - 1] = noop,
};
