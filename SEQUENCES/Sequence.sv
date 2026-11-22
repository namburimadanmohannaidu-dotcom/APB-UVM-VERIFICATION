
`ifndef APB_SEQUENCE_SV
`define APB_SEQUENCE_SV

// ===================================
// APB WRITE SEQUENCE
// ===================================


class apb_write_sequence extends uvm_sequence #(apb_transaction);

  `uvm_object_utils(apb_write_sequence)

  function new(string name = "apb_write_sequence");
    super.new(name);
  endfunction

  task body();

    apb_transaction req;

    `uvm_info("APB_WRITE_SEQ", "Sequence body started", UVM_LOW)

    req = apb_transaction::type_id::create("req");

    `uvm_info("APB_WRITE_SEQ", "Starting start_item", UVM_LOW)

    start_item(req);

    `uvm_info("APB_WRITE_SEQ", "start_item completed", UVM_LOW)

    if (!req.randomize() with {
      P_write == 1'b1;
    }) begin
      `uvm_fatal("APB_WRITE_SEQ", "Transaction randomization failed")
    end

    `uvm_info("APB_WRITE_SEQ", "Randomization completed", UVM_LOW)

    finish_item(req);

    `uvm_info("APB_WRITE_SEQ", "finish_item completed", UVM_LOW)

  endtask

endclass

// ===================================
// APB READ SEQUENCE
// ===================================

class apb_read_sequence extends uvm_sequence #(apb_transaction);

  `uvm_object_utils(apb_read_sequence)

  function new(string name = "apb_read_sequence");
    super.new(name);
  endfunction

  task body();

    apb_transaction req;

    repeat (10) begin

      req = apb_transaction::type_id::create("req");

      start_item(req);

      if (!req.randomize() with {
        P_write == 0;
        P_addr inside {[0:1023]};
        P_addr[1:0] == 0;
      }) begin
        `uvm_error("APB_READ", "Randomization failed")
      end

      finish_item(req);

    end

  endtask

endclass


// ===================================
// APB RANDOM READ/WRITE SEQUENCE
// ===================================

class apb_random_sequence extends uvm_sequence #(apb_transaction);

  `uvm_object_utils(apb_random_sequence)

  function new(string name = "apb_random_sequence");
    super.new(name);
  endfunction

  task body();

    apb_transaction req;

    repeat (20) begin

      req = apb_transaction::type_id::create("req");

      start_item(req);

      if (!req.randomize() with {
        P_addr inside {[0:1023]};
        P_addr[1:0] == 0;
      }) begin
        `uvm_error("APB_RANDOM", "Randomization failed")
      end

      finish_item(req);

    end

  endtask

endclass

`endif
