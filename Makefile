CROSS_COMPILE ?= arm-none-eabi-

CC = $(CROSS_COMPILE)gcc
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump
SIZE = $(CROSS_COMPILE)size
GDB = $(CROSS_COMPILE)gdb
OPENOCD = openocd

CFLAGS := -mthumb -mcpu=cortex-m4
CFLAGS += -ffunction-sections -fdata-sections
CFLAGS += -Os -std=gnu99 -Wall
LDFLAGS := -nostartfiles -Wl,--gc-sections

obj-y += main.o

all: dk-s7g2.elf dk-s7g2

%.o: %.c
	$(CC) -c $(CFLAGS) $< -o $@

dk-s7g2.elf: $(obj-y) Makefile
	$(CC) -T s7g2.lds $(LDFLAGS) -o dk-s7g2.elf $(obj-y)

dk-s7g2: dk-s7g2.elf Makefile
	$(OBJCOPY) -Obinary dk-s7g2.elf dk-s7g2.bin
	$(OBJDUMP) -S dk-s7g2.elf > dk-s7g2.lst
	$(SIZE) dk-s7g2.elf

clean:
	@rm -f *.o *.elf *.bin *.lst

gdb-dk-s7g2-jlink:
	JLinkGDBServer -device R7FS7G2 -if SWD

flash-dk-s7g2-jlink: dk-s7g2
	$(GDB) dk-s7g2.elf -ex "target remote :2331" -ex "monitor reset" -ex "load" -ex "monitor reset" -ex "monitor go"
