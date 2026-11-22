
`ifndef APB_DRIVER_SV
`define APB_DRIVER_SV

class apb_driver extends uvm_driver #(apb_transaction);

  `uvm_component_utils(apb_driver)

  // Virtual interface
  virtual apb_interface vif;

  // Constructor
  function new(string name = "apb_driver",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction


  // BUILD PHASE
  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    if (!uvm_config_db #(virtual apb_interface)::get(
          this, "", "vif", vif)) begin

      `uvm_fatal("APB_DRIVER",
                 "Virtual interface is not configured")

    end

  endfunction


  // RUN PHASE
 /* task run_phase(uvm_phase phase);

    apb_transaction req;

    // Initialize driver signals
    drive_idle();

    forever begin

      // Wait for reset release
      wait (vif.P_resetn === 1'b1);

      // Get transaction from sequencer
      seq_item_port.get_next_item(req);

      // Drive APB transaction
      drive_transfer(req);

      // Complete transaction
      seq_item_port.item_done();

    end

  endtask*/
  
  task run_phase(uvm_phase phase);

  apb_transaction req;

  drive_idle();

  `uvm_info("APB_DRIVER", "Driver run phase started", UVM_LOW)

  forever begin

    wait (vif.P_resetn === 1'b1);

    `uvm_info("APB_DRIVER", "Waiting for sequence item", UVM_LOW)

    seq_item_port.get_next_item(req);

    `uvm_info("APB_DRIVER", "Transaction received", UVM_LOW)

    drive_transfer(req);

    `uvm_info("APB_DRIVER", "Calling item_done", UVM_LOW)

    seq_item_port.item_done();

  end

endtask


  // IDLE PHASE
  task drive_idle();

    vif.P_selx   = 1'b0;
    vif.P_enable = 1'b0;
    vif.P_write  = 1'b0;
    vif.P_addr   = '0;
    vif.P_wdata  = '0;

  endtask


  // APB TRANSFER TASK
 
task drive_transfer(apb_transaction req);

  int wait_count = 0;

  `uvm_info("APB_DRIVER", "Entering drive_transfer", UVM_LOW)

  wait (vif.P_resetn === 1'b1);

  // SETUP PHASE
  @(negedge vif.P_clk);

  vif.P_selx   = 1'b1;
  vif.P_enable = 1'b0;
  vif.P_addr   = req.P_addr;
  vif.P_write  = req.P_write;
  vif.P_wdata  = req.P_wdata;

  `uvm_info("APB_DRIVER", "APB Setup Phase", UVM_LOW)

  // ACCESS PHASE
  @(negedge vif.P_clk);

  vif.P_enable = 1'b1;

  `uvm_info("APB_DRIVER", "APB Access Phase Started", UVM_LOW)

  // Wait for P_ready
  forever begin

    @(posedge vif.P_clk);

    `uvm_info("APB_DRIVER",
      $sformatf(
        "P_selx=%0b P_enable=%0b P_ready=%0b P_resetn=%0b",
        vif.P_selx,
        vif.P_enable,
        vif.P_ready,
        vif.P_resetn
      ), UVM_LOW)

    if (vif.P_resetn !== 1'b1)
      `uvm_fatal("APB_DRIVER", "Reset asserted during transfer")

    if (vif.P_ready === 1'b1)
      break;

    wait_count++;

    if (wait_count >= 20)
      `uvm_fatal("APB_DRIVER",
        "Timeout: P_ready did not become HIGH")
  end

  // Capture response
  req.P_ready  = vif.P_ready;
  req.P_rdata  = vif.P_rdata;
  req.P_slverr = vif.P_slverr;

  `uvm_info("APB_DRIVER", "APB Transfer Completed", UVM_LOW)

  @(negedge vif.P_clk);

  drive_idle();

endtask


endclass

`endif
