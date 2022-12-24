SHELL:=bash

TOP_MODULE=iob_uart16550

#PATHS
REMOTE_ROOT_DIR ?=sandbox/iob-uart16550
SIM_DIR ?=$(UART16550_HW_DIR)/simulation
FPGA_DIR ?=$(shell find $(UART16550_DIR)/hardware -name $(FPGA_FAMILY))
DOC_DIR ?=$(UART16550_DIR)/document/$(DOC)

LIB_DIR ?=$(UART16550_DIR)/submodules/LIB
UART16550_HW_DIR:=$(UART16550_DIR)/hardware

#MAKE SW ACCESSIBLE REGISTER
MKREGS:=$(shell find $(LIB_DIR) -name mkregs.py)

#DEFAULT FPGA FAMILY AND FAMILY LIST
FPGA_FAMILY ?=CYCLONEV-GT
FPGA_FAMILY_LIST ?=CYCLONEV-GT XCKU

#DEFAULT DOC AND doc LIST
DOC ?=pb
DOC_LIST ?=pb ug


# default target
default: sim

# VERSION
VERSION ?=V0.1
$(TOP_MODULE)_version.txt:
	echo $(VERSION) > version.txt

uart16550-gen-clean:
	@rm -rf *# *~ version.txt

.PHONY: default uart16550-gen-clean
