// tb/apb_if.sv
interface apb_if #(parameter int ADDR_W = 32,
                   parameter int DATA_W = 32);

  // Clock + reset
  logic               PCLK;
  logic               PRESETn;   // Active-low reset

  // APB3 signals
  logic               PSEL;
  logic               PENABLE;
  logic               PWRITE;
  logic [ADDR_W-1:0]  PADDR;
  logic [DATA_W-1:0]  PWDATA;
  logic [DATA_W-1:0]  PRDATA;
  l/* verilator lint_off UNOPTFLAT */
logic PREADY;
/* verilator lint_on UNOPTFLAT */

  logic               PSLVERR;

  // Master drives request/control; slave drives response
  modport master (
    input  PCLK, PRESETn,
    output PSEL, PENABLE, PWRITE, PADDR, PWDATA,
    input  PRDATA, PREADY, PSLVERR
  );

  modport slave (
    input  PCLK, PRESETn,
    input  PSEL, PENABLE, PWRITE, PADDR, PWDATA,
    output PRDATA, PREADY, PSLVERR
  );

  // Monitor sees everything
  modport mon (
    input PCLK, PRESETn,
    input PSEL, PENABLE, PWRITE, PADDR, PWDATA, PRDATA, PREADY, PSLVERR
  );

endinterface
