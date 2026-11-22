
`ifndef APB_AGENT_SV
`define APB_AGENT_SV

class apb_agent extends uvm_agent;

  `uvm_component_utils(apb_agent)

  // APB components
  apb_sequencer sequencer;
  apb_driver    driver;
  apb_monitor   monitor;

  // Agent mode
  uvm_active_passive_enum is_active = UVM_ACTIVE;


  // Constructor
  function new(string name = "apb_agent",
               uvm_component parent = null);

    super.new(name, parent);

  endfunction


  // BUILD PHASE
  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    // Create monitor in both active and passive modes
    monitor = apb_monitor::type_id::create(
                  "monitor", this);

    // Create driver and sequencer only in active mode
    if (is_active == UVM_ACTIVE) begin

      sequencer = apb_sequencer::type_id::create(
                      "sequencer", this);

      driver = apb_driver::type_id::create(
                   "driver", this);

    end

  endfunction


  // CONNECT PHASE
  /*function void connect_phase(uvm_phase phase);

    super.connect_phase(phase);

    if (is_active == UVM_ACTIVE) begin

      driver.seq_item_port.connect(
          sequencer.seq_item_export
      );

    end

  endfunction*/
  
  function void connect_phase(uvm_phase phase);

  super.connect_phase(phase);

  if (is_active == UVM_ACTIVE) begin

    driver.seq_item_port.connect(
      sequencer.seq_item_export
    );

    `uvm_info("APB_AGENT", "Driver connected to Sequencer", UVM_LOW)

  end

endfunction


endclass

`endif
