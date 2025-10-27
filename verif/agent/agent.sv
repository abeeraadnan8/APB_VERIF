class agent extends uvm_agent;
  `uvm_component_utils(agent)
  
   driver drv;
   monitor mon;
  uvm_sequencer#(sequence_item) sqr;

   virtual intf  vif;
   
  function new(string name ="agent", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
     sqr = uvm_sequencer#(sequence_item)::type_id::create("sqr", this);
      drv = driver::type_id::create("drv", this);
      mon = monitor::type_id::create("mon", this);
      
     if (!uvm_config_db#(virtual intf)::get(this, "", "vif", vif)) begin
       `uvm_fatal("build phase", "No virtual interface specified for this agent instance")
      end
   endfunction

   virtual function void connect_phase(uvm_phase phase);
      drv.seq_item_port.connect(sqr.seq_item_export);
     uvm_report_info("APB_AGENT", "connect_phase, Connected driver to sequencer");
   endfunction
endclass