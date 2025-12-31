`timescale 1ns/1ps
module tb_basic;

  apb_if apb();
  apb_regs_dut dut(.apb(apb));

  initial begin
    apb.PCLK = 0;
    forever #5 apb.PCLK = ~apb.PCLK;
  end

  task automatic do_reset();
    apb.PRESETn = 0;
    apb.PSEL    = 0;
    apb.PENABLE = 0;
    apb.PWRITE  = 0;
    apb.PADDR   = '0;
    apb.PWDATA  = '0;
    repeat (5) @(posedge apb.PCLK);
    apb.PRESETn = 1;
    repeat (2) @(posedge apb.PCLK);
  endtask

  task automatic apb_write(input logic [31:0] addr, input logic [31:0] data);
    @(posedge apb.PCLK);
    apb.PSEL    = 1;
    apb.PENABLE = 0;
    apb.PWRITE  = 1;
    apb.PADDR   = addr;
    apb.PWDATA  = data;

    @(posedge apb.PCLK);
    apb.PENABLE = 1;

    // Hold stable until completion
    while (!(apb.PSEL && apb.PENABLE && apb.PREADY)) @(posedge apb.PCLK);

    @(posedge apb.PCLK);
    apb.PSEL    = 0;
    apb.PENABLE = 0;
    apb.PWRITE  = 0;
    apb.PADDR   = '0;
    apb.PWDATA  = '0;
  endtask

  task automatic apb_read(input logic [31:0] addr, output logic [31:0] data);
    @(posedge apb.PCLK);
    apb.PSEL    = 1;
    apb.PENABLE = 0;
    apb.PWRITE  = 0;
    apb.PADDR   = addr;
    apb.PWDATA  = '0;

    @(posedge apb.PCLK);
    apb.PENABLE = 1;

    while (!(apb.PSEL && apb.PENABLE && apb.PREADY)) @(posedge apb.PCLK);

    data = apb.PRDATA;

    @(posedge apb.PCLK);
    apb.PSEL    = 0;
    apb.PENABLE = 0;
    apb.PADDR   = '0;
  endtask

  initial begin
    logic [31:0] rdata;
    do_reset();

    apb_write(32'h14, 32'hDEADBEEF);
    apb_read (32'h14, rdata);

    if (rdata !== 32'hDEADBEEF) begin
      $display("FAIL: SCRATCH readback got %h expected %h", rdata, 32'hDEADBEEF);
      $finish;
    end else begin
      $display("PASS: SCRATCH readback = %h", rdata);
    end
   // Negative test: invalid address should raise PSLVERR on completion
apb_read(32'h100, rdata);
if (apb.PSLVERR !== 1'b1) begin
  $display("FAIL: Expected PSLVERR=1 for invalid address");
  $finish;
end else begin
  $display("PASS: PSLVERR asserted for invalid address");
end

    $display("ALL DONE");
    $finish;
  end

endmodule
