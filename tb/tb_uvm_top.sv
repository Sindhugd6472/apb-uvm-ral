`timescale 1ns/1ps

module tb_uvm_top;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  apb_if apb();

  apb_regs_dut dut(.apb(apb));

  // Clock
  initial begin
    apb.PCLK = 0;
    forever #5 apb.PCLK = ~apb.PCLK;
  end

  // Reset + default drives (same intent as your tb_basic)
  initial begin
    apb.PRESETn = 0;
    apb.PSEL    = 0;
    apb.PENABLE = 0;
    apb.PWRITE  = 0;
    apb.PADDR   = '0;
    apb.PWDATA  = '0;

    repeat (5) @(posedge apb.PCLK);
    apb.PRESETn = 1;
  end

  // Give the interface handle to UVM (so driver/monitor can "get" it)
  initial begin
    uvm_config_db#(virtual apb_if)::set(null, "*", "vif", apb);
    run_test("reg_smoke_test");
  end

endmodule
