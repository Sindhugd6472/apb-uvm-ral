# Simple Verilator runner for this repo
TOP         := tb_basic
EXE         := ./obj_dir/V$(TOP)
SIM_SOURCES := tb/tb_basic.sv tb/apb_if.sv rtl/apb_regs_dut.sv
VERILATOR   := verilator

.PHONY: help sim run test lint clean cleanall

.DEFAULT_GOAL := help

.PHONY: help # Show available targets
help:
	@echo "Targets:"
	@echo "  make sim    - Build Verilator binary"
	@echo "  make run    - Run basic SV test"
	@echo "  make test   - Run UVM reg_smoke_test"
	@echo "  make lint   - Verilator lint-only (no build)"
	@echo "  make clean  - Remove build artifacts"

.PHONY: sim run test lint clean

sim:
	$(VERILATOR) --binary -j 0 -Wno-fatal -Itb -Irtl $(SIM_SOURCES)

run: sim
	$(EXE)

test: sim
	$(EXE) +UVM_TESTNAME=reg_smoke_test

# --lint-only lints without generating output files
lint:
	$(VERILATOR) --lint-only --timing -Wall -Wno-fatal -Itb -Irtl $(SIM_SOURCES)

clean:
	rm -rf obj_dir

.PHONY: cleanall
cleanall: clean
	rm -f *.vcd *.log


