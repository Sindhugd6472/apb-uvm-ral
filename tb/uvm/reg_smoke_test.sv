import uvm_pkg::*;
`include "uvm_macros.svh"

class reg_smoke_test extends uvm_test;
  `uvm_component_utils(reg_smoke_test)

  apb_env env;

  function new(string name="reg_smoke_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // Enable coverage before creating environment
    uvm_reg::include_coverage("*", UVM_CVR_FIELD_VALS);
    
    env = apb_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    uvm_status_e status;
    uvm_reg_data_t wdata, rdata;

    phase.raise_objection(this);
    
    `uvm_info("RAL_TEST", "Starting register smoke test", UVM_MEDIUM)

    // Test 1: Basic write/read
    wdata = 32'hDEAD_BEEF;
    `uvm_info("RAL_TEST", $sformatf("Writing SCRATCH: 0x%0h", wdata), UVM_MEDIUM)
    env.reg_model.SCRATCH.write(status, wdata);
    env.reg_model.SCRATCH.read(status, rdata);

    if (rdata !== wdata) begin
      `uvm_error("RAL_SMOKE", $sformatf("SCRATCH mismatch: wrote=0x%0h read=0x%0h", wdata, rdata))
    end else begin
      `uvm_info("RAL_SMOKE", $sformatf("SCRATCH readback OK: 0x%0h", rdata), UVM_LOW)
    end
    
    // Test 2: All zeros
    wdata = 32'h0000_0000;
    env.reg_model.SCRATCH.write(status, wdata);
    env.reg_model.SCRATCH.read(status, rdata);
    `uvm_info("RAL_TEST", $sformatf("All zeros test: 0x%0h", rdata), UVM_MEDIUM)
    
    // Test 3: All ones
    wdata = 32'hFFFF_FFFF;
    env.reg_model.SCRATCH.write(status, wdata);
    env.reg_model.SCRATCH.read(status, rdata);
    `uvm_info("RAL_TEST", $sformatf("All ones test: 0x%0h", rdata), UVM_MEDIUM)
    
    // Test 4: Pattern test
    wdata = 32'hA5A5_A5A5;
    env.reg_model.SCRATCH.write(status, wdata);
    env.reg_model.SCRATCH.read(status, rdata);
    `uvm_info("RAL_TEST", $sformatf("Pattern test: 0x%0h", rdata), UVM_MEDIUM)

    `uvm_info("RAL_TEST", "Register smoke test completed", UVM_LOW)
    
    phase.drop_objection(this);
  endtask

endclass
