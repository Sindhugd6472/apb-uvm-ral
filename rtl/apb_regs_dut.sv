// rtl/apb_regs_dut.sv
module apb_regs_dut #(
  parameter int ADDR_W = 32,
  parameter int DATA_W = 32
)(
  apb_if.slave apb
);

  localparam logic [ADDR_W-1:0] REG_CTRL        = 32'h00;
  localparam logic [ADDR_W-1:0] REG_STATUS      = 32'h04;
  localparam logic [ADDR_W-1:0] REG_CFG         = 32'h08;
  localparam logic [ADDR_W-1:0] REG_INTR_STATUS = 32'h0C;
  localparam logic [ADDR_W-1:0] REG_INTR_ENABLE = 32'h10;
  localparam logic [ADDR_W-1:0] REG_SCRATCH     = 32'h14;

  logic [DATA_W-1:0] ctrl, status, cfg, intr_status, intr_enable, scratch;

  // Wait-state counter (0..3 wait cycles)
  logic [1:0] wait_cnt;

function automatic bit is_valid_addr(logic [31:0] a);
  case (a)
    32'h00, 32'h04, 32'h08, 32'h0C, 32'h10, 32'h14: is_valid_addr = 1'b1;
    default:                                       is_valid_addr = 1'b0;
  endcase
endfunction

  // Slave response
  always_comb begin
    // PSLVERR only meaningful on the completion cycle (PSEL&PENABLE&PREADY)
apb.PSLVERR = (apb.PSEL && apb.PENABLE && apb.PREADY && !is_valid_addr(apb.PADDR));


    // During ACCESS: ready only when wait_cnt==0
    if (apb.PSEL && apb.PENABLE) apb.PREADY = (wait_cnt == 2'd0);
    else                         apb.PREADY = 1'b1;

    // Read mux
    unique case (apb.PADDR)
      REG_CTRL:        apb.PRDATA = ctrl;
      REG_STATUS:      apb.PRDATA = status;
      REG_CFG:         apb.PRDATA = cfg;
      REG_INTR_STATUS: apb.PRDATA = intr_status;
      REG_INTR_ENABLE: apb.PRDATA = intr_enable;
      REG_SCRATCH:     apb.PRDATA = scratch;
      default:         apb.PRDATA = '0;
    endcase
  end

  // Manage wait states
  always_ff @(posedge apb.PCLK or negedge apb.PRESETn) begin
    if (!apb.PRESETn) begin
      wait_cnt <= 2'd0;
    end else if (apb.PSEL && !apb.PENABLE) begin
      // Load wait count at SETUP
      wait_cnt <= 2'd0;
    end else if (apb.PSEL && apb.PENABLE && wait_cnt != 2'd0) begin
      // Count down during ACCESS
      wait_cnt <= wait_cnt - 2'd1;
    end else if (!apb.PSEL) begin
      wait_cnt <= 2'd0;
    end
  end

  // Transfer completes here
  wire xfer_done = apb.PSEL && apb.PENABLE && apb.PREADY;

  // Registers
  always_ff @(posedge apb.PCLK or negedge apb.PRESETn) begin
    if (!apb.PRESETn) begin
      ctrl        <= '0;
      status      <= '0;
      cfg         <= '0;
      intr_status <= '0;
      intr_enable <= '0;
      scratch     <= '0;
    end else begin
      status[0] <= ctrl[0];

      if (xfer_done && apb.PWRITE) begin
        unique case (apb.PADDR)
          REG_CTRL:        ctrl <= apb.PWDATA;
          REG_CFG:         cfg  <= apb.PWDATA;
          REG_INTR_STATUS: intr_status <= intr_status & ~apb.PWDATA; // W1C
          REG_INTR_ENABLE: intr_enable <= apb.PWDATA;
          REG_SCRATCH:     scratch <= apb.PWDATA;
          default: /* no-op */ ;
        endcase
      end
    end
  end

endmodule
