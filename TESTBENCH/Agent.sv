`ifndef APB_AGENT_SV
`define APB_AGENT_SV

`include "apb_sequencer"

`include "apb_driver.sv"

`include "apb_monitor.sv"

class apb_agent extends uvm_agent;
  
  `uvm_component_utils(apb_agent)
  
  apb_sequencer seqr;
  
  apb_driver	drv;
  
  apb_monitor	mon;
  
  function new(string name = "apb_agent",uvm_component parent);
    
    super.new(name,parent);
    
  endfunction
  
  function void build_phase (uvm_phase phase);
    
    super.build_phase(phase);
    
    mon = apb_monitor :: type_id :: create("mon",this);
    
    //ACTIVE AGENT
    
    if(get_is_active() == UVM_ACTIVE)
      
      begin
        
        drv = apb_driver :: type_id :: create("drv",this);
        
        seqr = apb_sequencer :: type_id :: create("seqr",this);
        
      end
    
  endfunction
  
  function void connect_phase(uvm_phase phase);
    
    super.connect_phase(phase);
    
    //CONNECT DRIVER AND SEQUENCER
    
    if(get_is_active() == UVM_ACTIVE) begin
      
      drv.seq_item_port.connect(seqr.seq_item_export);
      
    end
    
  endfunction
  
endclass
    
`endif    