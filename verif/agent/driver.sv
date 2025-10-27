class driver extends uvm_driver#(sequence_item);
  `uvm_component_utils(driver)
  
  virtual intf vif;
  sequence_item request;
  
  // --------------------------
  // Constructor
  // --------------------------
  function new(string name = "driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // --------------------------
  // Build Phase
  // --------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    request = sequence_item::type_id::create("request", this);

    if (!uvm_config_db#(virtual intf)::get(this, "", "vif", vif)) begin
      `uvm_fatal("DRV_NO_VIF", "Virtual interface not found in driver")
    end
  endfunction

  // --------------------------
  // Run Phase
  // --------------------------
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info(get_type_name(), "Run Phase Started", UVM_LOW)

    // Initialize signals
    vif.psel    <= 1'b0;
    vif.penable <= 1'b0;
    vif.pwrite  <= 1'b0;
    vif.paddr   <= 32'b0;
    vif.pwdata  <= 32'b0;


    @(posedge vif.rst_n);
    `uvm_info(get_type_name(), "Reset De-asserted, Starting Transactions", UVM_LOW)

    // Drive transactions
    forever begin
      seq_item_port.get_next_item(request);
      drive_item(request);
      seq_item_port.item_done();
    end
  endtask

  // --------------------------
  // Drive a Single APB Item
  // --------------------------
  virtual task drive_item(sequence_item req);
    `uvm_info(get_type_name(),
              $sformatf("Driving Transaction: ADDR=0x%0h WRITE=%0b WDATA=0x%0h",
                        req.paddr, req.pwrite, req.pwdata),
              UVM_MEDIUM)

    // ----------- Setup Phase -----------
    @(posedge vif.pclk);
    vif.psel    <= 1'b1;
    vif.penable <= 1'b0;
    vif.paddr   <= req.paddr;
    vif.pwrite  <= req.pwrite;
    if (req.pwrite == 1'b1) begin
    vif.pwdata  <= req.pwdata;
    end else begin
      vif.pwdata <= '0;
    end

    // ----------- Enable Phase -----------
    @(posedge vif.pclk);
    vif.penable <= 1'b1;

    // ----------- Wait for Ready -----------
    wait (vif.pready === 1'b1);
    @(posedge vif.pclk);

    // ----------- Capture Read Data (if read) -----------
    if (!req.pwrite) begin
      req.prdata = vif.prdata;
      `uvm_info(get_type_name(),
                $sformatf("Read Data from DUT: 0x%0h", req.prdata),
                UVM_MEDIUM)
    end

    // ----------- Complete Transfer -----------
    vif.psel    <= 1'b0;
    vif.penable <= 1'b0;
    vif.pwrite  <= 1'b0;
    vif.paddr   <= 32'b0;
    vif.pwdata  <= 32'b0;

    `uvm_info(get_type_name(), "Transaction Complete", UVM_LOW)
  endtask

endclass
