import uvm_pkg::*;
`include "uvm_macros.svh"

class apb_driver extends uvm_driver #(apb_item);
  `uvm_component_utils(apb_driver)

  string bfm_path;

  function new(string name="apb_driver", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(string)::get(this, "", "bfm_path", bfm_path)) begin
      `uvm_fatal("NOBFM", "bfm_path not set in config_db")
    end
  endfunction

  task run_phase(uvm_phase phase);
    apb_item req;
    apb_item rsp;
    logic [31:0] rdata;

    // init + wait reset
    $root.tb_uvm_top.bfm.init_master();
    $root.tb_uvm_top.bfm.wait_reset_release();

    forever begin
      seq_item_port.get_next_item(req);

      // Build response and echo request fields
      rsp = apb_item::type_id::create("rsp");
      rsp.write  = req.write;
      rsp.addr   = req.addr;
      rsp.wdata  = req.wdata;
      rsp.rdata  = 32'h0;
      rsp.slverr = 1'b0;

      if (req.write) begin
        $root.tb_uvm_top.bfm.apb_write(req.addr, req.wdata);
      end else begin
        $root.tb_uvm_top.bfm.apb_read(req.addr, rdata);
        rsp.rdata = rdata;
      end

      // IMPORTANT: tag response with the request's IDs so get_response() works
      rsp.set_id_info(req);  // required to avoid "null sequence_id" [web:700]

      // Complete handshake and deliver response
      seq_item_port.item_done(rsp);
    end
  endtask

endclass : apb_driver

