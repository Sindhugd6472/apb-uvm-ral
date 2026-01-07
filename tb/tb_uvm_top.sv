module tb_uvm_top;
  timeunit 1ns;
  timeprecision 1ps;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  apb_if apb_vif();

  // Clock
  initial begin
    apb_vif.PCLK = 0;
    forever #5 apb_vif.PCLK = ~apb_vif.PCLK;
  end

  // Reset
  initial begin
    apb_vif.PRESETn = 0;
    repeat (5) @(posedge apb_vif.PCLK);
    apb_vif.PRESETn = 1;
  end

  // DUT (expects apb_if.slave apb)
  apb_regs_dut dut (
    .apb(apb_vif)
  );

  // Task-based BFM (no virtual interface)
  apb_bfm bfm (
    .apb(apb_vif)
  );

  // Start UVM
  initial begin
    // Provide BFM hierarchical path to components (if you use it)
    uvm_config_db#(string)::set(null, "*", "bfm_path", "$root.tb_uvm_top.bfm");

    // IMPORTANT: make UVM call $finish when the test completes
    uvm_root::get().finish_on_completion = 1;  // ends sim cleanly [web:581]

    run_test(); // uses +UVM_TESTNAME=... if provided
  end

endmodule
