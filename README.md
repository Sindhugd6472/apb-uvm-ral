# apb-uvm-ral

AMBA APB3 slave RTL + verification: wait-state insertion (PREADY), error response (PSLVERR), and self-checking SystemVerilog tests running on Verilator.

## What’s inside
- `rtl/`: APB3 slave + register block
- `tb/`: SystemVerilog testbench

## Run (Verilator)
verilator --binary -j 0 -Wno-fatal -Itb -Irtl tb/tb_basic.sv tb/apb_if.sv rtl/apb_regs_dut.sv
./obj_dir/Vtb_basic
