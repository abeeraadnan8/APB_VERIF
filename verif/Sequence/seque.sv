class seque extends uvm_sequence#(sequence_item);
  `uvm_object_utils(seque)

  // --------------------------
  // Constructor
  // --------------------------
  function new(string name = "seque");
    super.new(name);
  endfunction

  // --------------------------
  // Main sequence body
  // --------------------------
  virtual task body();
    sequence_item rw_trans;

    // Generate and send 80 random transactions
    repeat (1500) begin
      rw_trans = sequence_item::type_id::create("rw_trans");
      
      // Start the item and randomize
      start_item(rw_trans);
      if (!rw_trans.randomize()) begin
        `uvm_error("SEQUENCE", "Randomization failed for sequence_item")
      end
      finish_item(rw_trans);
    end
  endtask
endclass