`ifndef APB_INTERFACE_SV
`define APB_INTERFACE_SV

interface apb_inf(input bit P_clk);
  
  logic P_rst;
  logic [31:0] P_addr;
  logic P_selx;
  logic P_enable;
  logic P_write;
  logic [31:0] P_wdata;
  
  logic P_ready;
  logic P_slverr;
  logic [31:0] P_rdata;
  
   //---------------------------------
  // Clocking Block for DRIVER
  //---------------------------------
  clocking drv_cb @(posedge P_clk);

    output P_addr;
    output P_selx;
    output P_enable;
    output P_write;
    output P_wdata;

    input  P_rdata;
    input  P_ready;

  endclocking

  //---------------------------------
  // Clocking Block for MONITOR
  //---------------------------------
  clocking mon_cb @(posedge P_clk);

    input P_addr;
    input P_selx;
    input P_enable;
    input P_write;
    input P_wdata;
    input P_rdata;
    input P_ready;

  endclocking

  //---------------------------------
  // Modports
  //---------------------------------
  modport DRIVER  (clocking drv_cb, input P_rst);
  modport MONITOR (clocking mon_cb, input P_rst);
    
  
endinterface
    
    `endif    