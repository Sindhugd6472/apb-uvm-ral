# Simple Verilator runner for this repo
TOP      := tb_basic
EXE      := ./obj_dir/V$(TOP)
SIM_SOURCES := tb/tb_basic.sv tb/apb_if.sv rtl/apb_regs_dut.sv

.PHONY: sim run test clean

sim:
	verilator --binary -j 0 -Wno-fatal -Itb -Irtl $(SIM_SOURCES)

run: sim
	$(EXE)

test: sim
	$(EXE) +UVM_TESTNAME=reg_smoke_test

clean:
	rm -rf obj_dir


