`timescale 1ns/1ns

module testbench;

  import uvm_pkg::*;
 `include "uvm_macros.svh"
 import apb_pkg::*;

  
   intf apb_if();
  
   apb_slave dut(
     .pclk(apb_if.pclk),
     .rst_n(apb_if.rst_n),
     .paddr(apb_if.paddr),
     .psel(apb_if.psel),
     .penable(apb_if.penable),
     .pwrite(apb_if.pwrite),
     .pready(apb_if.pready),
     .prdata(apb_if.prdata),
     .pwdata(apb_if.pwdata)
   );

   initial begin
      apb_if.pclk=0;
   end

   always begin
      #10 apb_if.pclk = ~apb_if.pclk;
   end
 
  initial begin
    apb_if.rst_n=0;
    repeat (1) @(posedge apb_if.pclk);
    apb_if.rst_n=1;
  end
 
  initial begin
    uvm_config_db#(virtual intf)::set( null, "*", "vif", testbench.apb_if);
    run_test("apb_test");
  end


  
endmodule