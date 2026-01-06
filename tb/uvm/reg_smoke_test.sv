import uvm_pkg::*;
`include "uvm_macros.svh"

class reg_smoke_test extends uvm_test;
  `uvm_component_utils(reg_smoke_test)

  function new(string name="reg_smoke_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("REG_SMOKE", "Hello: UVM top + test is running.", UVM_LOW)
    #100ns;
    phase.drop_objection(this);
  endtask
endclass
