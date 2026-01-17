import uvm_pkg::*;
`include "uvm_macros.svh"

class reg_advanced_seq extends uvm_sequence;
  `uvm_object_utils(reg_advanced_seq)
  
  apb_reg_block reg_model;

  function new(string name="reg_advanced_seq");
    super.new(name);
  endfunction

  task body();
    uvm_status_e status;
    uvm_reg_data_t wdata, rdata;
    
    `uvm_info("ADV_SEQ", "Starting advanced register sequence", UVM_MEDIUM)
    
    // Test 1: Back-to-back writes
    `uvm_info("ADV_SEQ", "Testing back-to-back writes", UVM_MEDIUM)
    for (int i = 0; i < 5; i++) begin
      wdata = $urandom();
      reg_model.SCRATCH.write(status, wdata);
      `uvm_info("ADV_SEQ", $sformatf("Write[%0d]: 0x%0h", i, wdata), UVM_HIGH)
    end
    
    // Test 2: Read-modify-write pattern
    `uvm_info("ADV_SEQ", "Testing read-modify-write", UVM_MEDIUM)
    reg_model.SCRATCH.read(status, rdata);
    wdata = rdata ^ 32'hFFFF_FFFF;
    reg_model.SCRATCH.write(status, wdata);
    reg_model.SCRATCH.read(status, rdata);
    `uvm_info("ADV_SEQ", $sformatf("RMW result: 0x%0h", rdata), UVM_MEDIUM)
    
    // Test 3: Walking 1s pattern
    `uvm_info("ADV_SEQ", "Testing walking 1s pattern", UVM_MEDIUM)
    for (int i = 0; i < 32; i++) begin
      wdata = 1 << i;
      reg_model.SCRATCH.write(status, wdata);
      reg_model.SCRATCH.read(status, rdata);
      if (rdata !== wdata)
        `uvm_error("ADV_SEQ", $sformatf("Walking 1s failed at bit %0d", i))
    end
    
    `uvm_info("ADV_SEQ", "Advanced sequence completed", UVM_LOW)
  endtask

endclass
