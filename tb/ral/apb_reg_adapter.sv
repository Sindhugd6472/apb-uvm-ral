class apb_reg_adapter extends uvm_reg_adapter;
  `uvm_object_utils(apb_reg_adapter)

  function new(string name="apb_reg_adapter");
    super.new(name);
    provides_responses = 1;
    supports_byte_enable = 0;
  endfunction

  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    apb_item t = apb_item::type_id::create("t");
    t.addr  = rw.addr[31:0];
    t.write = (rw.kind == UVM_WRITE);
    if (t.write)
      t.wdata = rw.data[31:0];
    return t;
  endfunction

  virtual function void bus2reg(uvm_sequence_item bus_item,
                                ref uvm_reg_bus_op rw);
    apb_item t;
    if (!$cast(t, bus_item)) begin
      `uvm_fatal("APB_ADAPTER", "bus_item is not apb_item")
    end

    rw.addr = t.addr;
    rw.kind = t.write ? UVM_WRITE : UVM_READ;

        if (rw.kind == UVM_READ) begin
      rw.data = t.rdata;
      `uvm_info("ADAPTER_DEBUG", $sformatf("bus2reg READ: addr=0x%0h rdata=0x%0h", t.addr, t.rdata), UVM_LOW)
    end else begin
      rw.data = t.wdata;
    end


    rw.status = t.slverr ? UVM_NOT_OK : UVM_IS_OK;
  endfunction
endclass
