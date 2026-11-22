
`ifndef APB_ENV_SV
`define APB_ENV_SV

class apb_env extends uvm_env;

  `uvm_component_utils(apb_env)

  apb_agent      agent;
  apb_scoreboard scoreboard;
  apb_coverage   coverage;

  function new(string name = "apb_env",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_info("APB_ENV", "Environment build started", UVM_MEDIUM)

    uvm_config_db #(uvm_active_passive_enum)::set(
      this, "agent", "is_active", UVM_ACTIVE
    );

    agent = apb_agent::type_id::create("agent", this);

    scoreboard = apb_scoreboard::type_id::create(
      "scoreboard", this
    );

    coverage = apb_coverage::type_id::create(
      "coverage", this
    );

    `uvm_info("APB_ENV", "Agent, Scoreboard and Coverage created", UVM_MEDIUM)
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    agent.monitor.analysis_port.connect(
      scoreboard.analysis_export
    );

    agent.monitor.analysis_port.connect(
      coverage.analysis_export
    );

    `uvm_info("APB_ENV", "Environment connections completed", UVM_MEDIUM)
  endfunction

endclass

`endif
