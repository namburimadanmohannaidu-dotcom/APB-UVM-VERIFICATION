`ifndef APB_SEQUENCE_SV
`define APB_SEQUENCE_SV

`include "apb_transaction.sv"

////  WRITE SEQUENCE  //////

class apb_wr_seq extends uvm_sequence#(apb_transaction);
  
  `uvm_object_utils(apb_wr_seq)
  
  apb_transaction txn;
  
  function new(string name = "apb_wr_seq");
    
    super.new(name);
    
  endfunction
  
  task body();
    
    repeat(20)
      
      begin
        
        txn = apb_transaction :: type_id :: create("txn");
        
        start_item(txn);
    
        assert(txn.randomize() with {P_write == 1;});
        
        finish_item(txn);
        
        `uvm_info(get_type_name(),txn.convert2string(),UVM_LOW)
        
      end
    
  endtask
  
endclass

///    READ SEQUENCE     /////

class apb_rd_seq extends uvm_sequence#(apb_transaction);
  
  `uvm_object_utils(apb_rd_seq)
  
  apb_transaction txn;
  
  function new(string name = "apb_rd_seq");
    
    super.new(name);
    
  endfunction
  
  task body();
    
    repeat(20)
      
      begin
        
        txn = apb_transaction :: type_id :: create("txn");
        
        start_item(txn);
    
        assert(txn.randomize() with {P_write == 0;});
        
        finish_item(txn);
        
        `uvm_info(get_type_name(),txn.convert2string(),UVM_LOW)
        
      end
    
  endtask
  
endclass

`endif