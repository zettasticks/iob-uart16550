# SOURCES
VTOP:=uart_tb

#tests
TEST_LIST+=test1
test1:
	make run SIMULATOR=$(SIMULATOR)
