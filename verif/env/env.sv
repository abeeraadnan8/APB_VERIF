class env extends uvm_env;
 
   `uvm_component_utils(env)

   agent agt;
   scoreboard scb;
  
   virtual intf vif;

  function new(string name= "env", uvm_component parent= null);
      super.new(name, parent);
   endfunction

   function void build_phase(uvm_phase phase);
     super.build_phase(phase);
     agt = agent::type_id::create("agt", this);
     scb = scoreboard::type_id::create("scb", this);
 
     if (!uvm_config_db#(virtual intf)::get(this, "", "vif", vif)) begin
       `uvm_fatal("build phase", "No virtual interface specified for this env instance")
     end
   endfunction
  
   function void connect_phase(uvm_phase phase);
     super.connect_phase(phase);
     agt.mon.port.connect(scb.mon_export);
   endfunction
endclass