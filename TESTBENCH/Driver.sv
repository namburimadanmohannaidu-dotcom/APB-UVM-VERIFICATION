`ifndef APB_DRIVER_SV
`define APB_DRIVER_SV

`include "apb_transaction.sv"

class apb_driver extends uvm_driver#(apb_transaction);
  
  `uvm_component_utils(apb_driver)
  
  virtual apb_inf vif;
  
  apb_transaction txn;
  
  function new(string name = "apb_driver",uvm_component parent);
    
    super.new(name,parent);
    
  endfunction
  
  function void build_phase(uvm_phase phase);
    
    super.build_phase(phase);
    
    if(!uvm_config_db#(virtual apb_inf) :: get(this,"","vif",vif))
      
      `uvm_fatal("NO VIF","DRIVER INTERFACE FAILS")
      
      endfunction
      
      task run_phase(uvm_phase phase);
    
    super.run_phase(phase);
    
    ///INITIALIZE THE SIGNALS
    
    vif.drv_cb.P_addr <= 0;
    
    vif.drv_cb.P_selx <= 0;
    
    vif.drv_cb.P_enable <= 0;
    
    vif.drv_cb.P_write <= 0;
    
    vif.drv_cb.P_wdata <= 0; 
    
    ///GET SIGNALS
    
    repeat(20)
      
      begin
        
        seq_item_port.get_next_item(txn);
        
        @(vif.drv_cb);
        
        vif.drv_cb.P_addr <= txn.P_addr;
        
        vif.drv_cb.P_selx <= 1;
        
        vif.drv_cb.P_enable <= 0;
        
        vif.drv_cb.P_write <= txn.P_write;
        
        vif.drv_cb.P_wdata <= txn.P_wdata;
        
      //---------------------------------
      // ACCESS PHASE
      //---------------------------------

      @(vif.drv_cb);

      vif.drv_cb.P_enable <= 1;

      //---------------------------------
      // Wait for ready
      //---------------------------------

        @(vif.drv_cb);

      //---------------------------------
      // Read data capture
      //---------------------------------

        if(txn.P_write == 0)
        txn.P_rdata = vif.drv_cb.P_rdata;

      //---------------------------------
      // Complete transfer
      //---------------------------------

      @(vif.drv_cb);

      vif.drv_cb.P_selx   <= 0;
      vif.drv_cb.P_enable <= 0;
        
        seq_item_port.item_done(txn);
        
        `uvm_info(get_type_name(),txn.convert2string(),UVM_LOW)
        
        `uvm_info("DRV","ACCESS PHASE",UVM_LOW)
        
      end
    
    endtask
    
    endclass
    
    `endif
    