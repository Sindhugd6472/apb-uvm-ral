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
    env = apb_env::type_id::create("env", this);
  endfunction

 task run_phase(uvm_phase phase);
  apb_smoke_seq seq;

  phase.raise_objection(this);

  seq = apb_smoke_seq::type_id::create("seq");
  seq.start(env.agent.seqr);

phase.drop_objection(this);

`uvm_info("EOT", "About to call $finish", UVM_LOW)
#1;
$finish;

endtask
  endclass

