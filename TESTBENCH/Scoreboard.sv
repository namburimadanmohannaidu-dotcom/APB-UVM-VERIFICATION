`ifndef APB_SCOREBOARD_SV
`define APB_SCOREBOARD_SV

`include "apb_transaction.sv"

class apb_scoreboard extends uvm_scoreboard;
  
  `uvm_component_utils(apb_scoreboard)
  
   apb_transaction txn;
  
  //ANALYSIS IMPLEMENTATION PORT
  
  uvm_analysis_imp #(apb_transaction,apb_scoreboard) sb_imp;
  
  //REFERENCE MEMORY
  
  bit [31:0]ref_mem[32];
  
  //CONSTRUCTOR
  
  function new(string name = "apb_scoreboard",uvm_component parent);
    
    super.new(name,parent);
    
    sb_imp = new("sb_imp",this);
    
  endfunction
  
  //WRITE METHOD
  
  function void write(apb_transaction txn);
    
    //WRITE TRANSACTION
    
    if(txn.P_write)
      
      begin
        
        ref_mem[txn.P_addr] = txn.P_wdata;
        
        `uvm_info(get_type_name(),

        $sformatf(
          
        "WRITE : ADDR=%0h DATA=%0h",
          
        txn.P_addr,
          
        txn.P_wdata),

        UVM_LOW)
        
      end
    
    //READ TRANSACTION
    
    else
      
      begin
        
        //COMPARE V/S ACTUAL
        
        if(ref_mem[txn.P_addr] == txn.P_rdata)
          
          begin
            
            `uvm_info(get_type_name(),

          $sformatf(
            
          "READ MATCH : ADDR=%0h EXPECTED=%0h ACTUAL=%0h",

          txn.P_addr,
            ref_mem[txn.P_addr],
          txn.P_rdata),

          UVM_LOW)
            
          end
        
        else begin
          
          `uvm_error(get_type_name(),

          $sformatf(
          "READ MISMATCH : ADDR=%0h EXPECTED=%0h ACTUAL=%0h",

          txn.P_addr,
            ref_mem[txn.P_addr],
          txn.P_rdata))
          
          end
      end
    
  endfunction
  
endclass

`endif
          
            
            
            
  
  