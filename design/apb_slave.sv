module apb_slave (
  input  logic        pclk,
  input  logic        rst_n,
  input  logic [31:0] paddr,
  input  logic        psel,
  input  logic        penable,
  input  logic        pwrite,
  input  logic [31:0] pwdata,
  output logic        pready,
  output logic [31:0] prdata
);

  // 256 x 32-bit internal memory
  logic [31:0] mem [0:255]; 

  typedef enum logic [1:0] {
    IDLE     = 2'b00,
    SETUP    = 2'b01,
    ACCESS   = 2'b10
  } state_t;

  state_t state, next_state;

  // Temporary "next" signals 
  logic        pready_next;
  logic [31:0] prdata_next;

  // ------------------------------------------------------------------
  // Sequential Logic
  // ------------------------------------------------------------------
  always_ff @(posedge pclk or negedge rst_n) begin
    if (!rst_n) begin
      state  <= IDLE;
      pready <= 0;
      prdata <= 0;
for (int i = 0; i < 256; i++) begin
  mem[i] <= i;  // Initialize memory
  $display("Captured Transaction: i=0x%0d mem=0x%0h", i, mem[i]);
end
    end
    else begin
      state  <= next_state;
      pready <= pready_next;
      prdata <= prdata_next;

      // Write operation occurs on clock edge
      if (state == ACCESS && pwrite && psel && penable)
        mem[paddr[7:0]] <= pwdata;
    end
  end

  // ------------------------------------------------------------------
  // Combinational Logic
  // ------------------------------------------------------------------
  always_comb begin
  next_state   = state;
  pready_next  = 1'b0;
  prdata_next  = prdata;  
 

  case (state)
    IDLE: begin
      pready_next = 1'b0;
      if (psel && !penable)
        next_state = SETUP;
      else 
        next_state = IDLE;
        
    end

    SETUP: begin
      if (psel && penable)
        pready_next = 1'b1;
            if (!pwrite)  begin
      prdata_next = mem[paddr[7:0]];  
                    $display("read_data : pr_data=0x%0h", prdata_next);
            end
       next_state = ACCESS;
    end

    ACCESS: begin
      pready_next = 1'b0;
      next_state = IDLE;
      end
  endcase
end

endmodule