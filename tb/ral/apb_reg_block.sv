class apb_scratch_reg extends uvm_reg;
  `uvm_object_utils(apb_scratch_reg)

  rand uvm_reg_field scratch;
  
  covergroup value_cg;
    option.per_instance = 1;
    scratch_val: coverpoint scratch.value[31:0] {
      bins zeros = {32'h0000_0000};
      bins ones  = {32'hFFFF_FFFF};
      bins low   = {[32'h0000_0001:32'h7FFF_FFFF]};
      bins high  = {[32'h8000_0000:32'hFFFF_FFFE]};
    }
  endgroup

  function new(string name="apb_scratch_reg");
    super.new(name, 32, UVM_CVR_FIELD_VALS);
  endfunction

  virtual function void build();
    scratch = uvm_reg_field::type_id::create("scratch");
    scratch.configure(this, 32, 0, "RW", 0, 32'h0, 1, 1, 0);
    
    if (has_coverage(UVM_CVR_FIELD_VALS))
      value_cg = new();
  endfunction
  
  virtual function void sample_values();
    super.sample_values();
    if (get_coverage(UVM_CVR_FIELD_VALS))
      value_cg.sample();
  endfunction
endclass

class apb_reg_block extends uvm_reg_block;
  `uvm_object_utils(apb_reg_block)

  rand apb_scratch_reg SCRATCH;

  function new(string name="apb_reg_block");
    super.new(name, UVM_CVR_ALL);
  endfunction

  virtual function void build();
    default_map = create_map("default_map", 'h0, 4, UVM_LITTLE_ENDIAN);
    
    SCRATCH = apb_scratch_reg::type_id::create("SCRATCH");
    SCRATCH.configure(this);
    SCRATCH.build();
    SCRATCH.set_coverage(UVM_CVR_FIELD_VALS);

    default_map.add_reg(SCRATCH, 'h14, "RW");
    lock_model();
  endfunction
endclass
