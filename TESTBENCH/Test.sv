
`ifndef APB_TEST_SV
`define APB_TEST_SV

class apb_test extends uvm_test;

  `uvm_component_utils(apb_test)

  // Environment handle
  apb_env env;

  // Constructor
  function new(string name = "apb_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // BUILD PHASE
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_info("APB_TEST", "BUILD PHASE STARTED", UVM_LOW)

    // Create environment
    env = apb_env::type_id::create("env", this);

    if (env == null) begin
      `uvm_fatal("APB_TEST", "Environment creation failed")
    end

    `uvm_info("APB_TEST", "Environment created successfully", UVM_LOW)

  endfunction


  // END OF ELABORATION PHASE
  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);

    `uvm_info("APB_TEST", "Printing UVM topology", UVM_LOW)

    uvm_top.print_topology();

  endfunction


  // RUN PHASE
  task run_phase(uvm_phase phase);

    apb_write_sequence  write_seq;
    apb_read_sequence   read_seq;
    apb_random_sequence random_seq;

    // Raise objection
    phase.raise_objection(this);

    `uvm_info("APB_TEST", "APB TEST STARTED", UVM_LOW)


    // --------------------------------
    // WRITE SEQUENCE
    // --------------------------------

    `uvm_info("APB_TEST", "Creating Write Sequence", UVM_LOW)

    write_seq = apb_write_sequence::type_id::create("write_seq");

    if (write_seq == null)
      `uvm_fatal("APB_TEST", "Write sequence creation failed")

    if (env.agent == null)
      `uvm_fatal("APB_TEST", "Agent handle is NULL")

    if (env.agent.sequencer == null)
      `uvm_fatal("APB_TEST", "Sequencer handle is NULL")

    `uvm_info("APB_TEST", "Starting Write Sequence", UVM_LOW)

    write_seq.start(env.agent.sequencer);

    `uvm_info("APB_TEST", "Write Sequence Completed", UVM_LOW)


    // --------------------------------
    // READ SEQUENCE
    // --------------------------------

    `uvm_info("APB_TEST", "Creating Read Sequence", UVM_LOW)

    read_seq = apb_read_sequence::type_id::create("read_seq");

    if (read_seq == null)
      `uvm_fatal("APB_TEST", "Read sequence creation failed")

    `uvm_info("APB_TEST", "Starting Read Sequence", UVM_LOW)

    read_seq.start(env.agent.sequencer);

    `uvm_info("APB_TEST", "Read Sequence Completed", UVM_LOW)


    // --------------------------------
    // RANDOM SEQUENCE
    // --------------------------------

    `uvm_info("APB_TEST", "Creating Random Sequence", UVM_LOW)

    random_seq = apb_random_sequence::type_id::create("random_seq");

    if (random_seq == null)
      `uvm_fatal("APB_TEST", "Random sequence creation failed")

    `uvm_info("APB_TEST", "Starting Random Sequence", UVM_LOW)

    random_seq.start(env.agent.sequencer);

    `uvm_info("APB_TEST", "Random Sequence Completed", UVM_LOW)


    // --------------------------------
    // TEST COMPLETION
    // --------------------------------

    `uvm_info("APB_TEST", "ALL SEQUENCES COMPLETED", UVM_LOW)

    phase.drop_objection(this);

  endtask

endclass

`endif
