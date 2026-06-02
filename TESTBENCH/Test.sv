`ifndef APB_TEST_SV
`define APB_TEST_SV

`include "apb_env.sv"

`include "apb_sequence.sv"

class apb_test extends uvm_test;
  
  `uvm_component_utils(apb_test)
  
  apb_env envh;
  
  apb_wr_seq wr_seq;
  
  apb_rd_seq rd_seq;
  
  function new(string name = "apb_test",uvm_component parent);
    
    super.new(name,parent);
    
  endfunction
  
  function void build_phase(uvm_phase phase);
    
    super.build_phase(phase);
    
    envh = apb_env :: type_id :: create("envh",this);
    
  endfunction
  
  function void end_of_elaboration_phase(
               uvm_phase phase);

  super.end_of_elaboration_phase(phase);

  //---------------------------------
  // Print UVM Topology
  //---------------------------------

  uvm_top.print_topology();

  endfunction
  
  task run_phase(uvm_phase phase);
    
    super.run_phase(phase);
    
    phase.raise_objection(this);
    
    wr_seq = apb_wr_seq :: type_id :: create("wr_seq");
    
    rd_seq = apb_rd_seq :: type_id :: create("rd_seq");
    
    wr_seq.start(envh.agent.seqr);
    
    rd_seq.start(envh.agent.seqr);
    
    phase.drop_objection(this);
    
  endtask
  
endclass
    
`endif    