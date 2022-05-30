ifeq ($(filter UART, $(SW_MODULES)),)

SW_MODULES+=UART

include $(UART_DIR)/software/software.mk

endif
