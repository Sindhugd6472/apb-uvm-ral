// tb/apb_bfm.sv
module apb_bfm #(parameter int ADDR_W = 32,
                 parameter int DATA_W = 32)
(
  apb_if.master apb
);

  task automatic init_master();
    apb.PSEL    = 0;
    apb.PENABLE = 0;
    apb.PWRITE  = 0;
    apb.PADDR   = '0;
    apb.PWDATA  = '0;
  endtask

  task automatic wait_reset_release();
    // Wait for PRESETn to go high, then one extra clock
    while (apb.PRESETn !== 1'b1) @(posedge apb.PCLK);
    @(posedge apb.PCLK);
  endtask

  task automatic apb_write(input logic [ADDR_W-1:0] addr,
                           input logic [DATA_W-1:0] data);
    // SETUP phase
    @(posedge apb.PCLK);
    apb.PSEL    <= 1'b1;
    apb.PENABLE <= 1'b0;
    apb.PWRITE  <= 1'b1;
    apb.PADDR   <= addr;
    apb.PWDATA  <= data;

    // ACCESS phase
    @(posedge apb.PCLK);
    apb.PENABLE <= 1'b1;

    // Wait for ready
    while (apb.PREADY !== 1'b1) @(posedge apb.PCLK);

    // Complete
    @(posedge apb.PCLK);
    apb.PSEL    <= 1'b0;
    apb.PENABLE <= 1'b0;
    apb.PWRITE  <= 1'b0;
  endtask

  task automatic apb_read(input  logic [ADDR_W-1:0] addr,
                          output logic [DATA_W-1:0] data);
    // SETUP phase
    @(posedge apb.PCLK);
    apb.PSEL    <= 1'b1;
    apb.PENABLE <= 1'b0;
    apb.PWRITE  <= 1'b0;
    apb.PADDR   <= addr;

    // ACCESS phase
    @(posedge apb.PCLK);
    apb.PENABLE <= 1'b1;

    while (apb.PREADY !== 1'b1) @(posedge apb.PCLK);

    data = apb.PRDATA;

    // Complete
    @(posedge apb.PCLK);
    apb.PSEL    <= 1'b0;
    apb.PENABLE <= 1'b0;
  endtask

endmodule
