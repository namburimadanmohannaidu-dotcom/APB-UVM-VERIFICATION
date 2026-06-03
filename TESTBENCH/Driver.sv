`ifndef APB_DRIVER_SV
`define APB_DRIVER_SV

`include "apb_transaction.sv"

class apb_driver extends uvm_driver #(apb_transaction);

`uvm_component_utils(apb_driver)

virtual apb_inf vif;

apb_transaction txn;

function new(string name="apb_driver",
uvm_component parent);


super.new(name,parent);


endfunction

//---------------------------------
// Build Phase
//---------------------------------

function void build_phase(uvm_phase phase);


super.build_phase(phase);

if(!uvm_config_db #(virtual apb_inf)::get(
    this,"","vif",vif))

  `uvm_fatal("NO_VIF",
             "Failed to get APB interface")


endfunction

//---------------------------------
// Run Phase
//---------------------------------

task run_phase(uvm_phase phase);


//---------------------------------
// Initialize Signals
//---------------------------------

vif.drv_cb.P_addr   <= 0;
vif.drv_cb.P_selx   <= 0;
vif.drv_cb.P_enable <= 0;
vif.drv_cb.P_write  <= 0;
vif.drv_cb.P_wdata  <= 0;

forever begin

  //---------------------------------
  // Get Transaction
  //---------------------------------

  seq_item_port.get_next_item(txn);

  //---------------------------------
  // SETUP PHASE
  //---------------------------------

  @(vif.drv_cb);

  vif.drv_cb.P_addr   <= txn.P_addr;
  vif.drv_cb.P_write  <= txn.P_write;
  vif.drv_cb.P_wdata  <= txn.P_wdata;

  vif.drv_cb.P_selx   <= 1;
  vif.drv_cb.P_enable <= 0;

  `uvm_info("DRV",
    "SETUP PHASE",
    UVM_LOW)

  //---------------------------------
  // ACCESS PHASE
  //---------------------------------

  @(vif.drv_cb);

  vif.drv_cb.P_enable <= 1;

  `uvm_info("DRV",
    "ACCESS PHASE",
    UVM_LOW)

  //---------------------------------
  // Wait For Ready
  //---------------------------------

  wait(vif.P_ready == 1);

  //---------------------------------
  // Read Transaction
  //---------------------------------

  if(!txn.P_write)
    txn.P_rdata = vif.P_rdata;

  //---------------------------------
  // End Transfer
  //---------------------------------

  @(vif.drv_cb);

  vif.drv_cb.P_selx   <= 0;
  vif.drv_cb.P_enable <= 0;

  //---------------------------------
  // Transaction Complete
  //---------------------------------

  seq_item_port.item_done();

  `uvm_info(get_type_name(),
            txn.convert2string(),
            UVM_LOW)

end


endtask

endclass

`endif
