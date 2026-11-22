
`ifndef APB_SCOREBOARD_SV
`define APB_SCOREBOARD_SV

class apb_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(apb_scoreboard)

  // Analysis implementation port
  uvm_analysis_imp #(apb_transaction, apb_scoreboard)
      analysis_export;

  // Reference memory model
  bit [31:0] ref_mem [bit [31:0]];

  // Counters
  int total_transactions;
  int write_count;
  int read_count;
  int pass_count;
  int error_count;


  // Constructor
  function new(string name = "apb_scoreboard",
               uvm_component parent = null);

    super.new(name, parent);

  endfunction


  // BUILD PHASE
  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    analysis_export =
        new("analysis_export", this);

    total_transactions = 0;
    write_count        = 0;
    read_count         = 0;
    pass_count         = 0;
    error_count        = 0;

  endfunction


  // WRITE METHOD
  // Called automatically when monitor publishes a transaction

  function void write(apb_transaction trans);

    bit [31:0] expected_data;

    total_transactions++;

    // Check slave error response
    if (trans.P_slverr !== 1'b0) begin

      error_count++;

      `uvm_error("APB_SCOREBOARD",
        $sformatf(
          "Unexpected PSLVERR! ADDR=%0h SLVERR=%0b",
          trans.P_addr,
          trans.P_slverr
        )
      )

      return;

    end


    // WRITE TRANSACTION
    if (trans.P_write == 1'b1) begin

      write_count++;

      // Update reference memory
      ref_mem[trans.P_addr] = trans.P_wdata;

      pass_count++;

      `uvm_info("APB_SCOREBOARD",
        $sformatf(
          "WRITE PASS: ADDR=%0h WDATA=%0h",
          trans.P_addr,
          trans.P_wdata
        ),
        UVM_MEDIUM
      )

    end


    // READ TRANSACTION
    else begin

      read_count++;

      // Get expected data
      if (ref_mem.exists(trans.P_addr))
        expected_data = ref_mem[trans.P_addr];
      else
        expected_data = 32'h00000000;


      // Compare expected and actual data
      if (trans.P_rdata === expected_data) begin

        pass_count++;

        `uvm_info("APB_SCOREBOARD",
          $sformatf(
            "READ PASS: ADDR=%0h EXPECTED=%0h ACTUAL=%0h",
            trans.P_addr,
            expected_data,
            trans.P_rdata
          ),
          UVM_MEDIUM
        )

      end

      else begin

        error_count++;

        `uvm_error("APB_SCOREBOARD",
          $sformatf(
            "READ FAIL: ADDR=%0h EXPECTED=%0h ACTUAL=%0h",
            trans.P_addr,
            expected_data,
            trans.P_rdata
          )
        )

      end

    end

  endfunction


  // REPORT PHASE
  function void report_phase(uvm_phase phase);

    super.report_phase(phase);

    `uvm_info("APB_SCOREBOARD",
      "========== APB SCOREBOARD SUMMARY ==========",
      UVM_NONE
    )

    `uvm_info("APB_SCOREBOARD",
      $sformatf("Total Transactions = %0d",
                total_transactions),
      UVM_NONE
    )

    `uvm_info("APB_SCOREBOARD",
      $sformatf("Write Transactions = %0d",
                write_count),
      UVM_NONE
    )

    `uvm_info("APB_SCOREBOARD",
      $sformatf("Read Transactions = %0d",
                read_count),
      UVM_NONE
    )

    `uvm_info("APB_SCOREBOARD",
      $sformatf("PASS Count = %0d",
                pass_count),
      UVM_NONE
    )

    `uvm_info("APB_SCOREBOARD",
      $sformatf("ERROR Count = %0d",
                error_count),
      UVM_NONE
    )

    `uvm_info("APB_SCOREBOARD",
      "============================================",
      UVM_NONE
    )

  endfunction

endclass

`endif
