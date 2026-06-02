`ifndef APB_MONITOR_SV
`define APB_MONITOR_SV

`include "apb_transaction.sv"

class apb_monitor extends uvm_monitor;
  
  `uvm_component_utils(apb_monitor)
  
  virtual apb_inf vif;
  
   apb_transaction txn;
  
  uvm_analysis_port #(apb_transaction) mon_ap;
  
  function new(string name = "apb_monitor",uvm_component parent);
    
    super.new(name,parent);
    
    mon_ap = new("mon_ap",this);
    
  endfunction
  
  function void build_phase(uvm_phase phase);
    
    super.build_phase(phase);
    
    if(!uvm_config_db #(virtual apb_inf) :: get(this,"","vif",vif))
      
      `uvm_fatal("NO VIF","MONITOR INTERFACE FAILS")
        
        endfunction
      
      task run_phase (uvm_phase phase);
    
    super.run_phase(phase);
   
    repeat(20) 
      
      begin
        
        @(posedge vif.P_clk);
        
        // DETECT APB VALID TRANSFER
        
        if(vif.P_selx &&
          vif.P_enable &&
          vif.P_ready)
          
          begin
            
            txn = apb_transaction :: type_id :: create("txn",this);
            
            //CAPTURE SIGNALS
            
            txn.P_addr  = vif.P_addr;
            
        	txn.P_write = vif.P_write;
            
            if(vif.P_write)
              
          		txn.P_wdata = vif.P_wdata;
            
       	 	else
          
            	txn.P_rdata = vif.P_rdata;
            
            //SEND TRANSACTION 
            
            mon_ap.write(txn);
            
            //PRINT TRANSACTION
            
            `uvm_info(get_type_name(),
          $sformatf("MONITOR : %s",
          txn.convert2string()),
          UVM_LOW)
            
            `uvm_info("MON","TRANSFER DETECTED",UVM_LOW)
            
          end
        
      end
    
    endtask
    
    endclass
      
    `endif
      
        
        