`ifndef APB_REG_PKG_SV
`define APB_REG_PKG_SV

package apb_reg_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // apb_item must be known before adapter uses it
  `include "tb/uvm/apb_item.sv"

  `include "tb/ral/apb_reg_block.sv"
  `include "tb/ral/apb_reg_adapter.sv"
endpackage

`endif


