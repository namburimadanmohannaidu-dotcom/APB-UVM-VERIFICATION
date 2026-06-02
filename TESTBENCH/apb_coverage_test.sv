`ifndef APB_COVERAGE_TEST_SV
`define APB_COVERAGE_TEST_SV

// ============================================
// Sample Coverage Test Template
// ============================================
// This file demonstrates how to run tests 
// with coverage collection enabled

class apb_coverage_test extends uvm_test;
  
  `uvm_component_utils(apb_coverage_test)
  
  apb_env env;
  
  apb_transaction txn;
  
  apb_sequencer sequencer;
  
  function new(string name = "apb_coverage_test", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = apb_env::type_id::create("env", this);
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    phase.raise_objection(this);
    
    sequencer = env.agent.sqr;
    
    // ============================================
    // SEQUENCE 1: Basic Read/Write Coverage
    // ============================================
    `uvm_info("COVERAGE_TEST", "Starting basic read/write sequence", UVM_LOW)
    repeat(50) begin
      txn = apb_transaction::type_id::create("txn");
      assert(txn.randomize());
      sequencer.send_item(txn);
      sequencer.wait_item_done();
    end
    
    // ============================================
    // SEQUENCE 2: Address Range Coverage
    // ============================================
    `uvm_info("COVERAGE_TEST", "Starting address range coverage sequence", UVM_LOW)
    for(int addr = 0; addr < 32; addr++) begin
      txn = apb_transaction::type_id::create("txn");
      txn.P_addr = addr;
      assert(txn.randomize_with {P_addr == addr;});
      sequencer.send_item(txn);
      sequencer.wait_item_done();
    end
    
    // ============================================
    // SEQUENCE 3: Data Pattern Coverage
    // ============================================
    `uvm_info("COVERAGE_TEST", "Starting data pattern coverage sequence", UVM_LOW)
    
    // All zeros
    repeat(10) begin
      txn = apb_transaction::type_id::create("txn");
      assert(txn.randomize_with {P_wdata == 32'h00000000;});
      sequencer.send_item(txn);
      sequencer.wait_item_done();
    end
    
    // All ones
    repeat(10) begin
      txn = apb_transaction::type_id::create("txn");
      assert(txn.randomize_with {P_wdata == 32'hFFFFFFFF;});
      sequencer.send_item(txn);
      sequencer.wait_item_done();
    end
    
    // Alternating patterns
    repeat(10) begin
      txn = apb_transaction::type_id::create("txn");
      assert(txn.randomize_with {P_wdata == 32'hAAAAAAAA;});
      sequencer.send_item(txn);
      sequencer.wait_item_done();
    end
    
    repeat(10) begin
      txn = apb_transaction::type_id::create("txn");
      assert(txn.randomize_with {P_wdata == 32'h55555555;});
      sequencer.send_item(txn);
      sequencer.wait_item_done();
    end
    
    // ============================================
    // SEQUENCE 4: Write/Read to Same Address
    // ============================================
    `uvm_info("COVERAGE_TEST", "Starting write/read sequence", UVM_LOW)
    repeat(20) begin
      int addr = $urandom_range(0, 31);
      
      // Write
      txn = apb_transaction::type_id::create("txn");
      assert(txn.randomize_with {
        P_addr == addr;
        P_write == 1;
      });
      sequencer.send_item(txn);
      sequencer.wait_item_done();
      
      // Read
      txn = apb_transaction::type_id::create("txn");
      assert(txn.randomize_with {
        P_addr == addr;
        P_write == 0;
      });
      sequencer.send_item(txn);
      sequencer.wait_item_done();
    end
    
    // ============================================
    // SEQUENCE 5: Back-to-Back Transactions
    // ============================================
    `uvm_info("COVERAGE_TEST", "Starting back-to-back transactions", UVM_LOW)
    repeat(20) begin
      // Multiple consecutive transactions
      repeat(3) begin
        txn = apb_transaction::type_id::create("txn");
        assert(txn.randomize());
        sequencer.send_item(txn);
        sequencer.wait_item_done();
      end
    end
    
    // ============================================
    // SEQUENCE 6: Address Range with Data Patterns
    // ============================================
    `uvm_info("COVERAGE_TEST", "Starting cross-coverage sequence", UVM_LOW)
    for(int addr = 0; addr < 32; addr++) begin
      // Write all zeros to each address
      txn = apb_transaction::type_id::create("txn");
      assert(txn.randomize_with {
        P_addr == addr;
        P_write == 1;
        P_wdata == 32'h00000000;
      });
      sequencer.send_item(txn);
      sequencer.wait_item_done();
      
      // Read from same address
      txn = apb_transaction::type_id::create("txn");
      assert(txn.randomize_with {
        P_addr == addr;
        P_write == 0;
      });
      sequencer.send_item(txn);
      sequencer.wait_item_done();
      
      // Write all ones to each address
      txn = apb_transaction::type_id::create("txn");
      assert(txn.randomize_with {
        P_addr == addr;
        P_write == 1;
        P_wdata == 32'hFFFFFFFF;
      });
      sequencer.send_item(txn);
      sequencer.wait_item_done();
    end
    
    `uvm_info("COVERAGE_TEST", "Coverage test completed", UVM_LOW)
    
    phase.drop_objection(this);
    
  endtask
  
endclass

// ============================================
// Minimal Write/Read Sanity Test
// ============================================
class apb_sanity_test extends uvm_test;
  
  `uvm_component_utils(apb_sanity_test)
  
  apb_env env;
  
  apb_transaction txn;
  
  apb_sequencer sequencer;
  
  function new(string name = "apb_sanity_test", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = apb_env::type_id::create("env", this);
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    phase.raise_objection(this);
    
    sequencer = env.agent.sqr;
    
    // Simple write and read test
    repeat(100) begin
      txn = apb_transaction::type_id::create("txn");
      assert(txn.randomize());
      sequencer.send_item(txn);
      sequencer.wait_item_done();
    end
    
    phase.drop_objection(this);
    
  endtask
  
endclass

// ============================================
// Directed Coverage-Focused Test
// ============================================
class apb_directed_coverage_test extends uvm_test;
  
  `uvm_component_utils(apb_directed_coverage_test)
  
  apb_env env;
  
  apb_transaction txn;
  
  apb_sequencer sequencer;
  
  function new(string name = "apb_directed_coverage_test", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = apb_env::type_id::create("env", this);
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    phase.raise_objection(this);
    
    sequencer = env.agent.sqr;
    
    // Target specific uncovered bins identified in coverage reports
    `uvm_info("DIRECTED_COV", "Running directed test for coverage gaps", UVM_LOW)
    
    // Example: Focus on high addresses (16-31)
    repeat(50) begin
      txn = apb_transaction::type_id::create("txn");
      assert(txn.randomize_with {
        P_addr inside {[16:31]};
      });
      sequencer.send_item(txn);
      sequencer.wait_item_done();
    end
    
    // Example: Focus on error responses
    repeat(30) begin
      txn = apb_transaction::type_id::create("txn");
      assert(txn.randomize());
      sequencer.send_item(txn);
      sequencer.wait_item_done();
    end
    
    phase.drop_objection(this);
    
  endtask
  
endclass

`endif
