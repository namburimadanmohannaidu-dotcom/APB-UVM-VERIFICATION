`ifndef APB_SEQUENCER_SV
`define APB_SEQUENCER_SV

`include "apb_transaction.sv"

class apb_sequencer extends uvm_sequencer#(apb_transaction);
  
  `uvm_component_utils(apb_sequencer)
  
  function new(string name = "apb_sequencer",uvm_component parent);
    
    super.new(name,parent);
    
  endfunction
  
endclass

`endif
