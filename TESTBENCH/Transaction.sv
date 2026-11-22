
`ifndef APB_TRANSACTION_SV
`define APB_TRANSACTION_SV

class apb_transaction extends uvm_sequence_item;

  // UVM factory registration
  `uvm_object_utils_begin(apb_transaction)

    `uvm_field_int(P_addr,   UVM_ALL_ON)
    `uvm_field_int(P_selx,   UVM_ALL_ON)
    `uvm_field_int(P_enable, UVM_ALL_ON)
    `uvm_field_int(P_write,  UVM_ALL_ON)
    `uvm_field_int(P_wdata,  UVM_ALL_ON)
    `uvm_field_int(P_ready,  UVM_ALL_ON)
    `uvm_field_int(P_slverr, UVM_ALL_ON)
    `uvm_field_int(P_rdata,  UVM_ALL_ON)

  `uvm_object_utils_end

  // Request signals
  rand bit [31:0] P_addr;
  rand bit        P_write;
  rand bit [31:0] P_wdata;

  // Control signals
  bit P_selx;
  bit P_enable;

  // Response signals
  bit        P_ready;
  bit        P_slverr;
  bit [31:0] P_rdata;

  // Address constraint
  constraint addr_range {
    P_addr inside {[0:1023]};
  }

  // Address alignment constraint
  constraint addr_alignment {
    P_addr[1:0] == 2'b00;
  }

  // Constructor
  function new(string name = "apb_transaction");
    super.new(name);
  endfunction

  // Convert transaction into string
  function string convert2string();

    return $sformatf(
      "P_addr=%0h P_selx=%0b P_enable=%0b P_write=%0b P_wdata=%0h P_ready=%0b P_rdata=%0h P_slverr=%0b",
      P_addr, P_selx, P_enable, P_write,
      P_wdata, P_ready, P_rdata, P_slverr
    );

  endfunction

endclass

`endif
