`ifndef APB_PROTOCOL_COVERAGE_SV
`define APB_PROTOCOL_COVERAGE_SV

class apb_protocol_coverage extends uvm_component;

  `uvm_component_utils(apb_protocol_coverage)

  virtual apb_inf vif;
  
  apb_transaction txn;
  
  uvm_analysis_export #(apb_transaction) ap_export;
  
  uvm_tlm_analysis_fifo #(apb_transaction) tlm_fifo;

  // ============================================
  // APB PROTOCOL REQUIREMENTS COVERAGE
  // ============================================

  // APB Protocol Rule 1: Device selection must be low in IDLE state
  covergroup cg_apb_rule_1;
    option.per_instance = 1;
    
    idle_selx : coverpoint vif.P_selx {
      bins selx_low_in_idle = {0};
    }
  endgroup : cg_apb_rule_1

  // APB Protocol Rule 2: Enable must be low during SETUP phase
  // This is covered by state transition coverage

  // APB Protocol Rule 3: Address must be stable during SETUP and ACCESS
  bit [31:0] saved_addr;
  int addr_stable_count;

  covergroup cg_apb_rule_3;
    option.per_instance = 1;
    
    addr_stable : coverpoint addr_stable_count {
      bins addr_stable_1_clk  = {1};
      bins addr_stable_2_clk  = {2};
      bins addr_stable_3_plus = {[3:100]};
    }
  endgroup : cg_apb_rule_3

  // APB Protocol Rule 4: Write data must be valid during write transactions
  covergroup cg_apb_rule_4;
    option.per_instance = 1;
    
    write_data_valid : coverpoint {txn.P_write, txn.P_ready} {
      bins write_with_ready = {2'b11};
    }
  endgroup : cg_apb_rule_4

  // APB Protocol Rule 5: Read data valid only when READY is asserted
  covergroup cg_apb_rule_5;
    option.per_instance = 1;
    
    read_data_ready : coverpoint {txn.P_write, txn.P_ready} {
      bins read_with_ready = {2'b01};
    }
  endgroup : cg_apb_rule_5

  // APB Protocol Rule 6: PSLVERR response coverage
  covergroup cg_apb_rule_6;
    option.per_instance = 1;
    
    slverr_response : coverpoint txn.P_slverr {
      bins okay_response = {0};
      bins error_response = {1};
    }
  endgroup : cg_apb_rule_6

  // APB Protocol Rule 7: Minimum 2-cycle operation (SETUP + ACCESS)
  bit [7:0] cycle_counter;
  
  covergroup cg_apb_rule_7;
    option.per_instance = 1;
    
    min_cycle_op : coverpoint cycle_counter {
      bins cycle_2  = {2};
      bins cycle_3  = {3};
      bins cycle_4_plus = {[4:255]};
    }
  endgroup : cg_apb_rule_7

  // ============================================
  // READ/WRITE OPERATION COVERAGE
  // ============================================

  // Write operation types
  covergroup cg_write_operations;
    option.per_instance = 1;
    
    write_addr : coverpoint txn.P_addr {
      bins write_addr_low   = {[0:7]};
      bins write_addr_mid   = {[8:15]};
      bins write_addr_high  = {[16:23]};
      bins write_addr_top   = {[24:31]};
    }
    
    write_data_pattern : coverpoint txn.P_wdata {
      bins pattern_00       = {'h00000000};
      bins pattern_FF       = {'hFFFFFFFF};
      bins pattern_AA       = {'hAAAAAAAA};
      bins pattern_55       = {'h55555555};
      bins pattern_F0       = {'hF0F0F0F0};
      bins pattern_0F       = {'h0F0F0F0F};
      default bin others;
    }
    
    write_cross : cross write_addr, write_data_pattern;
    
  endgroup : cg_write_operations

  // Read operation types
  covergroup cg_read_operations;
    option.per_instance = 1;
    
    read_addr : coverpoint txn.P_addr {
      bins read_addr_low   = {[0:7]};
      bins read_addr_mid   = {[8:15]};
      bins read_addr_high  = {[16:23]};
      bins read_addr_top   = {[24:31]};
    }
  endgroup : cg_read_operations

  // ============================================
  // TRANSACTION SEQUENCING COVERAGE
  // ============================================

  // Write followed by read to same address
  covergroup cg_write_read_sequence;
    option.per_instance = 1;
    
    wr_rd_sequence : coverpoint 1 {
      bins write_read_same_addr = default;
    }
  endgroup : cg_write_read_sequence

  // Multiple writes to same address
  covergroup cg_write_sequence;
    option.per_instance = 1;
    
    multiple_writes : coverpoint 1 {
      bins write_write_same_addr = default;
    }
  endgroup : cg_write_sequence

  // Back-to-back transactions
  covergroup cg_back_to_back;
    option.per_instance = 1;
    
    back_to_back : coverpoint 1 {
      bins b2b_transactions = default;
    }
  endgroup : cg_back_to_back

  // ============================================
  // SIGNAL TRANSITION COVERAGE
  // ============================================

  bit prev_selx, prev_enable, prev_ready;

  covergroup cg_signal_transitions;
    option.per_instance = 1;
    
    selx_transitions : coverpoint {prev_selx, vif.P_selx} {
      bins idle_to_setup  = {2'b01};
      bins setup_to_idle  = {2'b10};
      bins setup_stable   = {2'b11};
      bins idle_stable    = {2'b00};
    }
    
    enable_transitions : coverpoint {prev_enable, vif.P_enable} {
      bins setup_to_access = {2'b01};
      bins access_to_idle  = {2'b10};
      bins access_stable   = {2'b11};
      bins setup_stable2   = {2'b00};
    }
    
    ready_transitions : coverpoint {prev_ready, vif.P_ready} {
      bins ready_pulse = {2'b01};
      bins ready_release = {2'b10};
      bins ready_stable_high = {2'b11};
      bins ready_stable_low = {2'b00};
    }
  endgroup : cg_signal_transitions

  function new(string name = "apb_protocol_coverage", uvm_component parent);
    super.new(name, parent);
    
    cg_apb_rule_1 = new();
    cg_apb_rule_3 = new();
    cg_apb_rule_4 = new();
    cg_apb_rule_5 = new();
    cg_apb_rule_6 = new();
    cg_apb_rule_7 = new();
    cg_write_operations = new();
    cg_read_operations = new();
    cg_write_read_sequence = new();
    cg_write_sequence = new();
    cg_back_to_back = new();
    cg_signal_transitions = new();
    
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(!uvm_config_db #(virtual apb_inf) :: get(this,"","vif",vif))
      `uvm_fatal("NO VIF","PROTOCOL COVERAGE: APB INTERFACE FAILS")
    
    ap_export = new("ap_export", this);
    tlm_fifo = new("tlm_fifo", this);
    
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    ap_export.connect(tlm_fifo.analysis_export);
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    prev_selx = 0;
    prev_enable = 0;
    prev_ready = 0;
    addr_stable_count = 0;
    saved_addr = 0;
    cycle_counter = 0;
    
    forever begin
      tlm_fifo.get(txn);
      
      // Sample protocol rules
      cg_apb_rule_1.sample();
      cg_apb_rule_4.sample();
      cg_apb_rule_5.sample();
      cg_apb_rule_6.sample();
      
      // Sample read/write operations
      if(txn.P_write) begin
        cg_write_operations.sample();
      end else begin
        cg_read_operations.sample();
      end
      
      // Sample sequence coverage
      cg_write_read_sequence.sample();
      cg_write_sequence.sample();
      cg_back_to_back.sample();
      
    end
    
  endtask

  // Clock domain sampling for address stability and transitions
  task monitor_clock_domain();
    forever begin
      @(posedge vif.P_clk);
      
      // Track address stability
      if(vif.P_selx && vif.P_enable) begin
        if(addr_stable_count == 0) begin
          saved_addr = vif.P_addr;
        end
        
        if(vif.P_addr == saved_addr) begin
          addr_stable_count++;
        end else begin
          if(addr_stable_count > 0) begin
            cg_apb_rule_3.sample();
            addr_stable_count = 0;
          end
        end
      end else begin
        if(addr_stable_count > 0) begin
          cg_apb_rule_3.sample();
          addr_stable_count = 0;
        end
      end
      
      // Track cycle count for min 2-cycle rule
      if(vif.P_selx || vif.P_enable) begin
        cycle_counter++;
      end else begin
        if(cycle_counter >= 2) begin
          cg_apb_rule_7.sample();
        end
        cycle_counter = 0;
      end
      
      // Sample signal transitions
      cg_signal_transitions.sample();
      prev_selx = vif.P_selx;
      prev_enable = vif.P_enable;
      prev_ready = vif.P_ready;
      
    end
  endtask

endclass : apb_protocol_coverage

`endif
