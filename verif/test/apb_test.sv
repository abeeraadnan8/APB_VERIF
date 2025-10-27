class apb_test extends uvm_test;
  `uvm_component_utils(apb_test)

  // Handles to environment and sequence
  env   apb_env;
  seque apb_seq;

  // --------------------------------------------------------
  // Constructor
  // --------------------------------------------------------
  function new(string name = "apb_test", uvm_component parent = null);
    super.new(name, parent);
    `uvm_info("APB_TEST", "Inside Constructor!", UVM_HIGH)
  endfunction 

  // --------------------------------------------------------
  // Build Phase
  // --------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("APB_TEST", "Build Phase!", UVM_HIGH)

    // Create the environment
    apb_env = env::type_id::create("apb_env", this);
  endfunction : build_phase

  // --------------------------------------------------------
  // Connect Phase
  // --------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("APB_TEST", "Connect Phase!", UVM_HIGH)
  endfunction 

  // --------------------------------------------------------
  // Run Phase
  // --------------------------------------------------------
  task run_phase(uvm_phase phase);
    `uvm_info("APB_TEST", "Run Phase Started!", UVM_HIGH)
    phase.raise_objection(this);

    // Create and start sequence 
    apb_seq = seque::type_id::create("apb_seq");
    apb_seq.start(apb_env.agt.sqr);

    phase.drop_objection(this);
    `uvm_info("APB_TEST", "Run Phase Completed!", UVM_HIGH)
  endtask : run_phase

endclass