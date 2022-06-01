#uart common parameters
include $(UART16550_DIR)/software/software.mk


# add pc-emul sources
SRC+=$(UART16550_SW_DIR)/pc-emul/iob_uart_swreg_pc_emul.c
