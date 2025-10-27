class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)
  
  // --------------------------
  // Analysis port from monitor
  // --------------------------
  uvm_analysis_imp#(sequence_item, scoreboard) mon_export;

  // --------------------------
  // Queue for incoming transactions
  // --------------------------
  sequence_item exp_queue[$];

  // --------------------------
  // Simple reference model memory
  // --------------------------
  logic [31:0] memory [0:255];
  
  sequence_item expdata;
  int unsigned addr_idx;

  // --------------------------
  // Counters for summary
  // --------------------------
  int unsigned read_match_count;
  int unsigned read_mismatch_count;
  int unsigned write_match_count;
  int unsigned write_mismatch_count;

  // --------------------------
  // Constructor
  // --------------------------
  function new(string name = "scoreboard", uvm_component parent = null);
    super.new(name, parent);
    mon_export = new("mon_export", this);
  endfunction

  // --------------------------
  // Build Phase
  // --------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Initialize memory 
    for (int i = 0; i < 256; i++) begin
      memory[i] = i;  // Initialize memory with index
    end
    read_match_count    = 0;
    read_mismatch_count = 0;
    write_match_count   = 0;
    write_mismatch_count= 0;
  endfunction

  // --------------------------
  // Write: Called automatically
  // when monitor sends a transaction
  // --------------------------
  function void write(sequence_item tr);
    exp_queue.push_back(tr);
  endfunction

  // --------------------------
  // Run Phase
  // --------------------------
  virtual task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Scoreboard Started", UVM_LOW)

    forever begin
      wait (exp_queue.size() > 0);
      expdata = exp_queue.pop_front();
      addr_idx = expdata.paddr[7:0];

      // ------------------------------------------------------
      // WRITE Transaction
      // ------------------------------------------------------
      if (expdata.pwrite) begin
        memory[addr_idx] = expdata.pwdata;

        // check valid data (avoid X/Z)
        if (^expdata.pwdata !== 1'bx && ^expdata.pwdata !== 1'bz) begin
          write_match_count++;
          `uvm_info("APB_WRITE_SUCCESSFUL",
                    $sformatf("WRITE @0x%0h <= 0x%0h",
                              expdata.paddr, expdata.pwdata),
                    UVM_MEDIUM)
        end 
        else begin
          write_mismatch_count++;
          `uvm_error("APB_WRITE_FAIL",
                     $sformatf("WRITE CONTAINS INVALID DATA @0x%0h <= 0x%0h",
                               expdata.paddr, expdata.pwdata))
        end 
      end

      // ------------------------------------------------------
      // READ Transaction
      // ------------------------------------------------------
      else begin
        bit [31:0] expected = memory[addr_idx];
        bit [31:0] actual   = expdata.prdata;

        if (expected === actual) begin
          read_match_count++;
          `uvm_info("APB_READ_MATCH",
                    $sformatf("READ MATCH @0x%0h | Expected: 0x%0h | Actual: 0x%0h",
                              expdata.paddr, expected, actual),
                    UVM_LOW)
        end
        else begin
          read_mismatch_count++;
          `uvm_error("APB_READ_FAIL",
                     $sformatf("READ MISMATCH @0x%0h | Expected: 0x%0h | Actual: 0x%0h",
                               expdata.paddr, expected, actual))
        end
      end
    end
  endtask

  // -----------------------------------------------------------------
  // Final Phase Summary
  // -----------------------------------------------------------------
  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
    `uvm_info("SCOREBOARD_SUMMARY",
              $sformatf("Total Matches: %0d | Total Mismatches: %0d\nRead Matches: %0d | Read Mismatches: %0d\nWrite Matches: %0d | Write Mismatches: %0d",
                        read_match_count + write_match_count,
                        read_mismatch_count + write_mismatch_count,
                        read_match_count, read_mismatch_count,
                        write_match_count, write_mismatch_count),
              UVM_NONE)
  endfunction

endclass