`ifndef APB_FUNCTIONAL_COVERAGE_SV
`define APB_FUNCTIONAL_COVERAGE_SV

class apb_functional_coverage extends uvm_component;

  `uvm_component_utils(apb_functional_coverage)

  virtual apb_inf vif;

  // ============================================
  // APB PROTOCOL PHASE COVERAGE
  // ============================================

  // Coverage for IDLE phase
  covergroup cg_idle_phase;
    option.per_instance = 1;
    
    idle_selx_enable : coverpoint {vif.P_selx, vif.P_enable} {
      bins idle_inactive = {2'b00};
    }
  endgroup : cg_idle_phase

  // Coverage for SETUP phase (device selected, not enabled)
  covergroup cg_setup_phase;
    option.per_instance = 1;
    
    setup_selx_enable : coverpoint {vif.P_selx, vif.P_enable} {
      bins setup_selected = {2'b10};
    }
  endgroup : cg_setup_phase

  // Coverage for ACCESS phase (device selected and enabled)
  covergroup cg_access_phase;
    option.per_instance = 1;
    
    access_selx_enable : coverpoint {vif.P_selx, vif.P_enable} {
      bins access_active = {2'b11};
    }
    
    access_write : coverpoint vif.P_write {
      bins write_access = {1};
      bins read_access  = {0};
    }
    
    access_ready : coverpoint vif.P_ready {
      bins ready_asserted = {1};
      bins ready_deasserted = {0};
    }
    
    access_cross : cross access_write, access_ready;
    
  endgroup : cg_access_phase

  // ============================================
  // RESET AND ERROR COVERAGE
  // ============================================

  // Reset behavior coverage
  covergroup cg_reset_behavior;
    option.per_instance = 1;
    
    reset_sig : coverpoint vif.P_rst {
      bins reset_active   = {1};
      bins reset_inactive = {0};
    }
  endgroup : cg_reset_behavior

  // Slave error coverage
  covergroup cg_slave_error;
    option.per_instance = 1;
    
    slverr_during_access : coverpoint vif.P_slverr {
      bins error_response   = {1};
      bins normal_response  = {0};
    }
  endgroup : cg_slave_error

  // ============================================
  // TIMING COVERAGE
  // ============================================

  // Coverage for back-to-back transactions
  bit prev_ready;
  bit consecutive_ready_count;

  covergroup cg_transaction_timing;
    option.per_instance = 1;
    
    consecutive_txns : coverpoint consecutive_ready_count {
      bins single_txn       = {1};
      bins double_txn       = {2};
      bins multiple_txn     = {[3:10]};
    }
  endgroup : cg_transaction_timing

  // ============================================
  // CROSS-FUNCTIONAL COVERAGE
  // ============================================

  // Address stability during transaction
  bit [31:0] prev_addr;
  covergroup cg_addr_stability;
    option.per_instance = 1;
    
    addr_change : coverpoint (vif.P_addr != prev_addr) {
      bins addr_stable   = {0};
      bins addr_changed  = {1};
    }
  endgroup : cg_addr_stability

  // Data validity coverage
  covergroup cg_data_validity;
    option.per_instance = 1;
    
    rdata_valid : coverpoint vif.P_ready {
      bins read_data_valid   = {1};
      bins read_data_invalid = {0};
    }
    
    write_data_driven : coverpoint vif.P_write {
      bins wdata_written = {1};
      bins rdata_read    = {0};
    }
    
    data_cross : cross rdata_valid, write_data_driven;
    
  endgroup : cg_data_validity

  // ============================================
  // STIMULUS COVERAGE
  // ============================================

  // Coverage for different address ranges with various data patterns
  covergroup cg_stimulus_space;
    option.per_instance = 1;
    
    addr_bins : coverpoint vif.P_addr {
      bins addr_0_7   = {[0:7]};
      bins addr_8_15  = {[8:15]};
      bins addr_16_23 = {[16:23]};
      bins addr_24_31 = {[24:31]};
    }
    
    data_bins : coverpoint vif.P_wdata {
      bins data_zero      = {'h0};
      bins data_all_ones  = {'hFFFFFFFF};
      bins data_pattern_1 = {['h00000001:'h00001000]};
      bins data_pattern_2 = {['h00010000:'h00100000]};
      bins data_random    = default;
    }
    
    stimulus_cross : cross addr_bins, data_bins {
      ignore_bins ignore = stimulus_cross with (vif.P_write == 0);
    }
    
  endgroup : cg_stimulus_space

  function new(string name = "apb_functional_coverage", uvm_component parent);
    super.new(name, parent);
    
    cg_idle_phase = new();
    cg_setup_phase = new();
    cg_access_phase = new();
    cg_reset_behavior = new();
    cg_slave_error = new();
    cg_transaction_timing = new();
    cg_addr_stability = new();
    cg_data_validity = new();
    cg_stimulus_space = new();
    
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(!uvm_config_db #(virtual apb_inf) :: get(this,"","vif",vif))
      `uvm_fatal("NO VIF","FUNCTIONAL COVERAGE: APB INTERFACE FAILS")
    
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    prev_ready = 0;
    consecutive_ready_count = 0;
    prev_addr = 0;
    
    forever begin
      @(posedge vif.P_clk);
      
      // Sample all covergroups
      cg_idle_phase.sample();
      cg_setup_phase.sample();
      cg_access_phase.sample();
      cg_reset_behavior.sample();
      cg_slave_error.sample();
      cg_addr_stability.sample();
      cg_data_validity.sample();
      cg_stimulus_space.sample();
      
      // Track consecutive transactions
      if(vif.P_ready && vif.P_selx && vif.P_enable) begin
        consecutive_ready_count++;
      end else if(consecutive_ready_count > 0) begin
        cg_transaction_timing.sample();
        consecutive_ready_count = 0;
      end
      
      // Update previous values
      prev_addr = vif.P_addr;
      prev_ready = vif.P_ready;
      
    end
  endtask

endclass : apb_functional_coverage

`endif
