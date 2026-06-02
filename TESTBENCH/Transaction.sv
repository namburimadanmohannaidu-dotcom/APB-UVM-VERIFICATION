`ifndef APB_TRANSACTION_SV
`define APB_TRANSACTION_SV

class apb_transaction extends uvm_sequence_item;
  
  `uvm_object_utils(apb_transaction)
  
  rand bit[31:0] P_addr;
  
  rand bit P_selx,P_enable,P_write;
  
  rand bit [31:0] P_wdata;
  
  bit P_ready,P_slverr;
  
  bit [31:0] P_rdata;
  
  constraint addr_range {P_addr inside {[0:31]};}
  
  function new(string name = "apb_transaction");
    
    super.new(name);
    
  endfunction
  
  function string convert2string();
    
    return $sformatf("Paddr = %0h P_write = %0b P_wdata = %0h P_rdata = %0h",P_addr,P_write,P_wdata,P_rdata);
    
  endfunction
  
endclass

`endif