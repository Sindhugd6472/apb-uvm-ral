import uvm_pkg::*;
`include "uvm_macros.svh"

class apb_driver extends uvm_driver #(apb_item);
  `uvm_component_utils(apb_driver)

  virtual apb_if vif;

  function new(string name="apb_driver", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NO_VIF", "No virtual interface 'vif' found in uvm_config_db")
    end
  endfunction

  task run_phase(uvm_phase phase);
    apb_item req;

    // Drive defaults
    vif.PSEL    <= 0;
    vif.PENABLE <= 0;
    vif.PWRITE  <= 0;
    vif.PADDR   <= '0;
    vif.PWDATA  <= '0;

    // Wait for reset deassert
    wait (vif.PRESETn == 1);

    forever begin
      seq_item_port.get_next_item(req);

      // SETUP
      @(posedge vif.PCLK);
      vif.PSEL    <= 1;
      vif.PENABLE <= 0;
      vif.PWRITE  <= req.write;
      vif.PADDR   <= req.addr;
      vif.PWDATA  <= req.wdata;

      // ACCESS
      @(posedge vif.PCLK);
      vif.PENABLE <= 1;

      // Wait-state support
      while (!(vif.PSEL && vif.PENABLE && vif.PREADY)) @(posedge vif.PCLK);

      // Sample response at completion
      req.rdata  = vif.PRDATA;
      req.slverr = vif.PSLVERR;

      // IDLE
      @(posedge vif.PCLK);
      vif.PSEL    <= 0;
      vif.PENABLE <= 0;
      vif.PWRITE  <= 0;
      vif.PADDR   <= '0;
      vif.PWDATA  <= '0;

      seq_item_port.item_done();
    end
  endtask
endclass
