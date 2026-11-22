
`ifndef APB_MONITOR_SV
`define APB_MONITOR_SV

class apb_monitor extends uvm_monitor;

  `uvm_component_utils(apb_monitor)

  // Virtual interface
  virtual apb_interface vif;

  // Analysis port
  uvm_analysis_port #(apb_transaction) analysis_port;

  // Constructor
  function new(string name = "apb_monitor",
               uvm_component parent = null);

    super.new(name, parent);

  endfunction


  // BUILD PHASE
  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    analysis_port =
        new("analysis_port", this);

    if (!uvm_config_db #(virtual apb_interface)::get(
          this, "", "vif", vif)) begin

      `uvm_fatal("APB_MONITOR",
                 "Virtual interface not found")

    end

  endfunction


  // RUN PHASE
  task run_phase(uvm_phase phase);

    apb_transaction trans;

    forever begin

      @(posedge vif.P_clk);

      // Wait for reset release
      if (vif.P_resetn !== 1'b1)
        continue;

      // Detect completed APB transfer
      if ((vif.P_selx   === 1'b1) &&
          (vif.P_enable === 1'b1) &&
          (vif.P_ready  === 1'b1)) begin

        trans = apb_transaction::type_id::create("trans");

        // Capture transaction
        trans.P_addr   = vif.P_addr;
        trans.P_selx   = vif.P_selx;
        trans.P_enable = vif.P_enable;
        trans.P_write  = vif.P_write;
        trans.P_wdata  = vif.P_wdata;
        trans.P_ready  = vif.P_ready;
        trans.P_rdata  = vif.P_rdata;
        trans.P_slverr = vif.P_slverr;

        // Publish transaction
        analysis_port.write(trans);

        `uvm_info("APB_MONITOR",
          $sformatf(
            "ADDR=%0h WRITE=%0b WDATA=%0h RDATA=%0h READY=%0b SLVERR=%0b",
            trans.P_addr,
            trans.P_write,
            trans.P_wdata,
            trans.P_rdata,
            trans.P_ready,
            trans.P_slverr
          ),
          UVM_MEDIUM
        )

      end

    end

  endtask

endclass

`endif
