# SOURCES
VTOP:=uart_test

#tests
TEST_LIST+=test1
test1:
	make run SIMULATOR=$(SIMULATOR)
