ifeq ($(filter UART, $(SW_MODULES)),)

SW_MODULES+=UART

include $(UART16550_DIR)/software/software.mk

endif
