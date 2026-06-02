`ifndef APB_ENV_SV
`define APB_ENV_SV

`include "apb_agent.sv"

`include "apb_scoreboard.sv"

`include "apb_coverage.sv"

`include "apb_functional_coverage.sv"

`include "apb_protocol_coverage.sv"

class apb_env extends uvm_env;
  
  `uvm_component_utils(apb_env)
  
  apb_agent agent;
  
  apb_scoreboard sb;
  
  apb_coverage cov;
  
  apb_functional_coverage func_cov;
  
  apb_protocol_coverage prot_cov;
  
  function new (string name = "apb_env",uvm_component parent);
    
    super.new(name,parent);
    
  endfunction
  
  function void build_phase(uvm_phase phase);
    
    super.build_phase(phase);
    
    agent = apb_agent :: type_id :: create("agent",this);
    
    sb	  = apb_scoreboard :: type_id :: create("sb",this);
    
    cov = apb_coverage :: type_id :: create("cov",this);
    
    func_cov = apb_functional_coverage :: type_id :: create("func_cov",this);
    
    prot_cov = apb_protocol_coverage :: type_id :: create("prot_cov",this);
    
  endfunction
  
  function void connect_phase(uvm_phase phase);
    
    super.connect_phase(phase);
    
    agent.mon.mon_ap.connect(sb.sb_imp);
    
    agent.mon.mon_ap.connect(cov.ap_export);
    
    agent.mon.mon_ap.connect(prot_cov.ap_export);
    
  endfunction 
  
endclass
    
`endif    