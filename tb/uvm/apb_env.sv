import uvm_pkg::*;
`include "uvm_macros.svh"

class apb_env extends uvm_env;
  `uvm_component_utils(apb_env)

  apb_agent agent;

  function new(string name="apb_env", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = apb_agent::type_id::create("agent", this);
  endfunction

endclass
