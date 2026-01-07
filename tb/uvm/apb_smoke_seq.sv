import uvm_pkg::*;
`include "uvm_macros.svh"

class apb_smoke_seq extends uvm_sequence #(apb_item);
  `uvm_object_utils(apb_smoke_seq)

  function new(string name="apb_smoke_seq");
    super.new(name);
  endfunction

  task body();
    apb_item req;
    apb_item rsp;

    // WRITE
    req = apb_item::type_id::create("wr_req");
    start_item(req);
    req.write = 1;
    req.addr  = 32'h0000_0000;
    req.wdata = 32'h1234_5678;
    finish_item(req);

    // Drain write response (keeps sequencer/driver handshake clean)
    get_response(rsp);

    // READ
    req = apb_item::type_id::create("rd_req");
    start_item(req);
    req.write = 0;
    req.addr  = 32'h0000_0000;
    req.wdata = 32'h0;
    finish_item(req);

    // Get read response with rdata/slverr from driver
    get_response(rsp);

    `uvm_info("APB_SEQ",
              $sformatf("Readback rdata=0x%08h slverr=%0d",
                        rsp.rdata, rsp.slverr),
              UVM_LOW)
              
  endtask

endclass : apb_smoke_seq
