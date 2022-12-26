SHELL:=bash

TOP_MODULE=iob_uart16550

#PATHS
REMOTE_ROOT_DIR ?=sandbox/iob-uart16550
SIM_DIR ?=$(UART16550_HW_DIR)/simulation

UART16550_HW_DIR:=$(UART16550_DIR)/hardware

# default target
default: sim

# VERSION
VERSION ?=V0.1
$(TOP_MODULE)_version.txt:
	echo $(VERSION) > version.txt

uart16550-gen-clean:
	@rm -rf *# *~ version.txt

.PHONY: default uart16550-gen-clean
