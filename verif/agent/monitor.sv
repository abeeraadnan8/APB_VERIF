class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)

  virtual intf vif;
  uvm_analysis_port#(sequence_item) port;
  sequence_item tr;

  // --------------------------
  // Constructor
  // --------------------------
  function new(string name = "monitor", uvm_component parent = null);
    super.new(name, parent);
    port = new("port", this);
  endfunction

  // --------------------------
  // Build Phase
  // --------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tr = sequence_item::type_id::create("tr", this);

    if (!uvm_config_db#(virtual intf)::get(this, "", "vif", vif)) begin
      `uvm_fatal("MON_NO_VIF", "Virtual interface not set for monitor")
    end
  endfunction

  // --------------------------
  // Run Phase
  // --------------------------
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info(get_type_name(), "APB Monitor started", UVM_LOW)

    forever begin
      // Wait for start of APB transfer (Setup phase)
      @(posedge vif.pclk iff (vif.psel && !vif.penable));
      tr.paddr  = vif.paddr;
      tr.pwrite = vif.pwrite;
      if (vif.pwrite == 1'b1) begin
      tr.pwdata = vif.pwdata;
      end 

      `uvm_info(get_type_name(),
                $sformatf("Setup phase detected: ADDR=0x%0h WRITE=%0b", tr.paddr, tr.pwrite),
                UVM_HIGH)

      // Wait for Enable phase
      @(posedge vif.pclk iff (vif.psel && vif.penable));

      // Wait for pready (transfer completion)
      wait (vif.pready === 1'b1);

      // Capture read data (if read)
      if (!tr.pwrite) begin
        tr.prdata = vif.prdata;
              `uvm_info("APB_MONITOR",
                        $sformatf("Captured Transaction: ADDR=0x%0h WRITE=%0b RDATA=0x%0h",
                          tr.paddr, tr.pwrite, tr.prdata),
                UVM_MEDIUM)
      end else begin

      // Report and send to analysis port
      `uvm_info("APB_MONITOR",
                $sformatf("Captured Transaction: ADDR=0x%0h WRITE=%0b WDATA=0x%0h",
                          tr.paddr, tr.pwrite, tr.pwdata),
                UVM_MEDIUM)
      end 

      port.write(tr);

      // Wait for transfer to end (psel de-assert)
      @(posedge vif.pclk iff (!vif.psel));
    end
  endtask

endclass
