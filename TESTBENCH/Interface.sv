
`ifndef APB_INTERFACE_SV
`define APB_INTERFACE_SV

interface apb_interface(input logic P_clk, P_resetn);

  // APB control signals
  logic P_selx;
  logic P_enable;
  logic P_write;

  // APB address and data
  logic [31:0] P_addr;
  logic [31:0] P_wdata;
  logic [31:0] P_rdata;

  // APB response signals
  logic P_ready;
  logic P_slverr;

endinterface

`endif
