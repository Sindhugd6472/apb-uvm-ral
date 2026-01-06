import uvm_pkg::*;
`include "uvm_macros.svh"

class apb_item extends uvm_sequence_item;
  `uvm_object_utils(apb_item)

  rand bit        write;
  rand bit [31:0] addr;
  rand bit [31:0] wdata;

       bit [31:0] rdata;
       bit        slverr;

  function new(string name="apb_item");
    super.new(name);
  endfunction
endclass
