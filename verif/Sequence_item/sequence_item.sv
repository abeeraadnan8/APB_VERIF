class sequence_item extends uvm_sequence_item;
  `uvm_object_utils(sequence_item)

  // -------------------------------------------------------
  // APB Transaction Fields
  // -------------------------------------------------------
  rand bit [31:0] paddr;     // Address
  rand bit [31:0] pwdata;    // Write data
       bit [31:0] prdata;    // Read data (from DUT)
  rand bit         pwrite;   // 1 = Write, 0 = Read


  // -------------------------------------------------------
  // Constructor
  // -------------------------------------------------------
  function new(string name = "sequence_item");
    super.new(name);
  endfunction

  // -------------------------------------------------------
  // Convert to String (for printing/logging)
  // -------------------------------------------------------
  function string convert2string();
    return $sformatf("pwrite=%0b paddr=0x%0h pwdata=0x%0h prdata=0x%0h",
                     pwrite, paddr, pwdata, prdata);
  endfunction


endclass
