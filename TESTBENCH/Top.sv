// Code your testbench here
// or browse Examples

`ifndef TESTBENCH_TOP_SV
`define TESTBENCH_TOP_SV

`include "Interface.sv"

`include "apb_test.sv"

`include "apb_pkg.sv"

module top();
  
  import apb_pkg::*;
    
  bit P_clk;
  
  bit P_rst;
  
  always #5 P_clk = ~P_clk;
  
  apb_inf vif(P_clk);
  
  //DUT INSTANCE

  AMBA_APB dut(
  				.P_clk     (vif.P_clk),
                .P_rst     (vif.P_rst),

                .P_addr    (vif.P_addr),
                .P_selx    (vif.P_selx),
                .P_enable  (vif.P_enable),
                .P_write   (vif.P_write),

                .P_wdata   (vif.P_wdata),

                .P_ready   (vif.P_ready),
                .P_slverr  (vif.P_slverr),
                .P_rdata   (vif.P_rdata)
  );
  
  initial 
    
    begin
      
      P_rst = 1;
      
      repeat(5)@(posedge P_clk);
      
      P_rst = 0;
      
    end
  
  initial 
    
    begin
      
      uvm_config_db #(virtual apb_inf) :: set(null,"*","vif",vif);
      
    end
  
  initial 
    
    begin
      
      run_test("apb_test");
      
    end
  
  initial begin

    $dumpfile("dump.vcd");

    $dumpvars;

  end
  
  initial 
    
    begin

      #1000;

      $display("TIMEOUT");

      $finish;

	end
  
endmodule

`endif