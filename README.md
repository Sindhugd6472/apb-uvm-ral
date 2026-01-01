[![CI (Verilator)](https://github.com/Sindhugd6472/apb-uvm-ral/actions/workflows/ci.yml/badge.svg)](https://github.com/Sindhugd6472/apb-uvm-ral/actions/workflows/ci.yml)
# apb-uvm-ral

AMBA APB3 slave RTL + verification: wait-state insertion (PREADY), error response (PSLVERR), and self-checking SystemVerilog tests running on Verilator.

## What’s inside
- `rtl/`: APB3 slave + register block
- `tb/`: SystemVerilog testbench

## Run (Verilator)

~~~bash
verilator --binary -j 0 -Wno-fatal -Itb -Irtl tb/tb_basic.sv tb/apb_if.sv rtl/apb_regs_dut.sv
./obj_dir/Vtb_basic
~~~


## Register map

| Offset | Name            | Access | Reset | Notes |
|------:|------------------|:------:|------:|-------|
| 0x00  | CTRL            | R/W    | 0x00000000 | `status[0]` mirrors `ctrl[0]`. |
| 0x04  | STATUS          | R      | 0x00000000 | Bit0 mirrors `ctrl[0]`. |
| 0x08  | CFG             | R/W    | 0x00000000 | — |
| 0x0C  | INTR_STATUS     | R/W1C  | 0x00000000 | Write-1-to-clear. |
| 0x10  | INTR_ENABLE     | R/W    | 0x00000000 | — |
| 0x14  | SCRATCH         | R/W    | 0x00000000 | Test writes/reads `0xDEADBEEF`. |

Invalid address: `PSLVERR` asserts only on completion (`PSEL && PENABLE && PREADY`).  
Wait states: during ACCESS, `PREADY` is 0 while `wait_cnt != 0`.

## Sample output

~~~text
PASS: SCRATCH readback = deadbeef
PASS: PSLVERR asserted for invalid address
ALL DONE
~~~

