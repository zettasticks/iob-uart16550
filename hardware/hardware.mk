ifeq ($(filter UART16550, $(HW_MODULES)),)

include $(UART16550_DIR)/config.mk

#add itself to HW_MODULES list
HW_MODULES+=UART16550


UART16550_INC_DIR:=$(UART16550_HW_DIR)/include
UART16550_SRC_DIR:=$(UART16550_HW_DIR)/src

USE_NETLIST ?=0

#include files
VHDR+=$(wildcard $(UART16550_INC_DIR)/*.vh)
VHDR+=$(LIB_DIR)/hardware/include/iob_lib.vh

#hardware include dirs
INCLUDE+=$(incdir). $(incdir)$(UART16550_INC_DIR) $(incdir)$(LIB_DIR)/hardware/include

#sources
VSRC+=$(UART16550_SRC_DIR)/uart_wb.v $(UART16550_SRC_DIR)/uart_transmitter.v $(UART16550_SRC_DIR)/uart_top.v $(UART16550_SRC_DIR)/uart_tfifo.v $(UART16550_SRC_DIR)/uart_sync_flops.v $(UART16550_SRC_DIR)/uart_rfifo.v $(UART16550_SRC_DIR)/uart_regs.v $(UART16550_SRC_DIR)/uart_receiver.v $(UART16550_SRC_DIR)/uart_debug_if.v $(UART16550_SRC_DIR)/raminfr.v $(UART16550_SRC_DIR)/iob_uart16550.v

uart16550-hw-clean: uart16550-gen-clean
	@rm -f *.v *.vh

.PHONY: uart16550-hw-clean

endif
