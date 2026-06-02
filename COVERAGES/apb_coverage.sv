`ifndef APB_COVERAGE_SV
`define APB_COVERAGE_SV

class apb_coverage extends uvm_component;

  `uvm_component_utils(apb_coverage)

  virtual apb_inf vif;
  
  apb_transaction txn;
  
  uvm_analysis_export #(apb_transaction) ap_export;
  
  uvm_tlm_analysis_fifo #(apb_transaction) tlm_fifo;

  // ============================================
  // SIGNAL COVERAGE
  // ============================================
  
  // Address coverage (range 0-31)
  covergroup cg_apb_address;
    
    option.per_instance = 1;
    
    address : coverpoint txn.P_addr {
      bins addr_low   = {[0:7]};
      bins addr_mid   = {[8:15]};
      bins addr_high  = {[16:23]};
      bins addr_top   = {[24:31]};
    }
    
  endgroup : cg_apb_address

  // Write/Read operations
  covergroup cg_apb_write_read;
    
    option.per_instance = 1;
    
    write_op : coverpoint txn.P_write {
      bins write_en  = {1};
      bins read_en   = {0};
    }
    
  endgroup : cg_apb_write_read

  // Write data coverage (sample different data patterns)
  covergroup cg_apb_wdata;
    
    option.per_instance = 1;
    
    wdata : coverpoint txn.P_wdata {
      bins all_zeros     = {'h0};
      bins all_ones      = {'hFFFFFFFF};
      bins low_byte      = {['h00:0xFF]};
      bins low_word      = {['h00:0xFFFF]};
      bins high_word     = {['h0000:0xFFFFFFFF]};
      default bin others;
    }
    
  endgroup : cg_apb_wdata

  // Ready signal coverage
  covergroup cg_apb_ready;
    
    option.per_instance = 1;
    
    ready : coverpoint txn.P_ready {
      bins ready_high = {1};
      bins ready_low  = {0};
    }
    
  endgroup : cg_apb_ready

  // Slave error signal coverage
  covergroup cg_apb_slverr;
    
    option.per_instance = 1;
    
    slverr : coverpoint txn.P_slverr {
      bins error_high = {1};
      bins error_low  = {0};
    }
    
  endgroup : cg_apb_slverr

  // ============================================
  // PROTOCOL STATE COVERAGE
  // ============================================
  
  // APB Protocol state transitions (IDLE -> SETUP -> ACCESS -> IDLE)
  covergroup cg_apb_states;
    
    option.per_instance = 1;
    
    selx   : coverpoint txn.P_selx {
      bins selx_active   = {1};
      bins selx_inactive = {0};
    }
    
    enable : coverpoint txn.P_enable {
      bins enable_active   = {1};
      bins enable_inactive = {0};
    }
    
    state_transition : cross selx, enable {
      // IDLE State: selx=0, enable=0
      bins idle = binsof(selx) intersect {0} && binsof(enable) intersect {0};
      
      // SETUP State: selx=1, enable=0
      bins setup = binsof(selx) intersect {1} && binsof(enable) intersect {0};
      
      // ACCESS State: selx=1, enable=1
      bins access = binsof(selx) intersect {1} && binsof(enable) intersect {1};
    }
    
  endgroup : cg_apb_states

  // ============================================
  // FUNCTIONAL COVERAGE
  // ============================================
  
  // Read/Write with specific addresses
  covergroup cg_apb_addr_rw;
    
    option.per_instance = 1;
    
    addr_write : cross txn.P_addr, txn.P_write {
      bins write_operations;
      bins read_operations;
    }
    
  endgroup : cg_apb_addr_rw

  // Ready response during ACCESS
  covergroup cg_apb_response;
    
    option.per_instance = 1;
    
    ready_write : cross txn.P_ready, txn.P_write {
      bins ready_on_write;
      bins ready_on_read;
    }
    
  endgroup : cg_apb_response

  // Data path coverage: Writing specific patterns and reading them back
  covergroup cg_apb_data_patterns;
    
    option.per_instance = 1;
    
    pattern : coverpoint txn.P_wdata {
      bins pattern_zeros        = {'h00000000};
      bins pattern_ones         = {'hFFFFFFFF};
      bins pattern_alt_lo       = {'hAAAAAAAA};
      bins pattern_alt_hi       = {'h55555555};
      bins pattern_low_byte     = {['h00:0xFF]};
      bins pattern_high_byte    = {['hFFFFFF00:0xFFFFFFFF]};
      default bin other_patterns;
    }
    
  endgroup : cg_apb_data_patterns

  // Address range and write operation combination
  covergroup cg_apb_addr_range_write;
    
    option.per_instance = 1;
    
    addr_range : coverpoint txn.P_addr {
      bins low_addr   = {[0:7]};
      bins mid_addr   = {[8:15]};
      bins high_addr  = {[16:23]};
      bins top_addr   = {[24:31]};
    }
    
    wr_op : coverpoint txn.P_write {
      bins write = {1};
      bins read  = {0};
    }
    
    addr_wr_cross : cross addr_range, wr_op;
    
  endgroup : cg_apb_addr_range_write

  function new(string name = "apb_coverage", uvm_component parent);
    super.new(name, parent);
    
    cg_apb_address = new();
    cg_apb_write_read = new();
    cg_apb_wdata = new();
    cg_apb_ready = new();
    cg_apb_slverr = new();
    cg_apb_states = new();
    cg_apb_addr_rw = new();
    cg_apb_response = new();
    cg_apb_data_patterns = new();
    cg_apb_addr_range_write = new();
    
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(!uvm_config_db #(virtual apb_inf) :: get(this,"","vif",vif))
      `uvm_fatal("NO VIF","COVERAGE: APB INTERFACE FAILS")
    
    ap_export = new("ap_export", this);
    tlm_fifo = new("tlm_fifo", this);
    
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    ap_export.connect(tlm_fifo.analysis_export);
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    forever begin
      tlm_fifo.get(txn);
      
      // Sample all covergroups
      cg_apb_address.sample();
      cg_apb_write_read.sample();
      cg_apb_wdata.sample();
      cg_apb_ready.sample();
      cg_apb_slverr.sample();
      cg_apb_states.sample();
      cg_apb_addr_rw.sample();
      cg_apb_response.sample();
      cg_apb_data_patterns.sample();
      cg_apb_addr_range_write.sample();
      
    end
    
  endtask

endclass : apb_coverage

`endif
