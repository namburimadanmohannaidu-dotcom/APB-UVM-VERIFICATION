
`ifndef APB_COVERAGE_SV
`define APB_COVERAGE_SV

class apb_coverage extends uvm_subscriber #(apb_transaction);

  `uvm_component_utils(apb_coverage)

  // Temporary variables for coverage sampling
  bit        sample_write;
  bit        sample_slverr;
  bit [31:0] sample_addr;

  // Functional coverage group
  covergroup apb_cg;

    // Read and write coverage
    cp_operation: coverpoint sample_write {
      bins READ  = {0};
      bins WRITE = {1};
    }

    // Address coverage: 1 KB address space
    cp_address: coverpoint sample_addr[9:2] {
      bins LOW_ADDRESS  = {[0:63]};
      bins MID_ADDRESS  = {[64:191]};
      bins HIGH_ADDRESS = {[192:255]};
    }

    // Error response coverage
    cp_slverr: coverpoint sample_slverr {
      bins NO_ERROR = {0};
      bins ERROR    = {1};
    }

    // Operation and error cross coverage
    operation_error_cross:
      cross cp_operation, cp_slverr;

  endgroup


  // Constructor
  function new(string name = "apb_coverage",
               uvm_component parent = null);

    super.new(name, parent);

    apb_cg = new();

  endfunction


  // Receive transaction from monitor
  function void write(apb_transaction trans);

    sample_write  = trans.P_write;
    sample_slverr = trans.P_slverr;
    sample_addr   = trans.P_addr;

    // Sample coverage
    apb_cg.sample();

    `uvm_info("APB_COVERAGE",
      $sformatf(
        "Coverage sampled: ADDR=%0h WRITE=%0b SLVERR=%0b",
        sample_addr,
        sample_write,
        sample_slverr
      ),
      UVM_MEDIUM
    )

  endfunction


  // Report coverage
  function void report_phase(uvm_phase phase);

    super.report_phase(phase);

    `uvm_info("APB_COVERAGE",
      $sformatf(
        "APB Functional Coverage = %0.2f%%",
        apb_cg.get_coverage()
      ),
      UVM_NONE
    )

  endfunction

endclass

`endif
