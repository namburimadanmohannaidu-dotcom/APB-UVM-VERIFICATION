
`timescale 1ns/1ps

 `include "apb_pkg.sv"
  
  `include "Interface.sv"

  `include "apb_test.sv"

module top;

  bit P_clk;
  bit P_resetn;

  apb_interface apb_if (
    P_clk,
    P_resetn
  );

  AMBA_APB dut (
    .P_clk     (P_clk),
    .P_resetn  (P_resetn),
    .P_addr    (apb_if.P_addr),
    .P_selx    (apb_if.P_selx),
    .P_enable  (apb_if.P_enable),
    .P_write   (apb_if.P_write),
    .P_wdata   (apb_if.P_wdata),
    .P_ready   (apb_if.P_ready),
    .P_rdata   (apb_if.P_rdata),
    .P_slverr  (apb_if.P_slverr)
  );

  // Clock generation
  initial begin
    P_clk = 0;
    forever #5 P_clk = ~P_clk;
  end

  // Reset generation
  initial begin
    P_resetn = 0;
    repeat (5) @(posedge P_clk);
    @(negedge P_clk);
    P_resetn = 1;
  end
  
  // --------------------------------
// VCD Waveform Dump
// --------------------------------

initial begin
    $dumpfile("apb_waveform.vcd");
    $dumpvars(0, top);
end

  // UVM start
  initial begin
    uvm_config_db #(virtual apb_interface)::set(
      null, "*", "vif", apb_if
    );

    run_test("apb_test");
    
    #1000; $finish;
  end

endmodule
