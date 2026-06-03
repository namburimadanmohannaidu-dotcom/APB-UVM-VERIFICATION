// Code your design here
module AMBA_APB (
input  logic        P_clk,
input  logic        P_rst,
input  logic [31:0] P_addr,
input  logic        P_selx,
input  logic        P_enable,
input  logic        P_write,
input  logic [31:0] P_wdata,

output logic        P_ready,
output logic        P_slverr,
output logic [31:0] P_rdata
);

//---------------------------------
// Memory
//---------------------------------

logic [31:0] mem [0:31];

//---------------------------------
// State Definition
//---------------------------------

typedef enum logic [1:0] {
IDLE   = 2'b00,
SETUP  = 2'b01,
ACCESS = 2'b10
} state_t;

state_t present_state, next_state;

//---------------------------------
// State Register
//---------------------------------

always_ff @(posedge P_clk or posedge P_rst) begin


if(P_rst)
  present_state <= IDLE;
else
  present_state <= next_state;


end

//---------------------------------
// Next State Logic
//---------------------------------

always_comb begin


next_state = present_state;

case(present_state)

  //---------------------------------
  // IDLE
  //---------------------------------

  IDLE: begin

    if(P_selx && !P_enable)
      next_state = SETUP;

  end

  //---------------------------------
  // SETUP
  //---------------------------------

  SETUP: begin

    if(P_selx && P_enable)
      next_state = ACCESS;
    else
      next_state = IDLE;

  end

  //---------------------------------
  // ACCESS
  //---------------------------------

  ACCESS: begin

    if(!P_selx)
      next_state = IDLE;
    else
      next_state = ACCESS;

  end

  //---------------------------------
  // Recovery
  //---------------------------------

  default:
    next_state = IDLE;

endcase


end

//---------------------------------
// Output Logic
//---------------------------------

always_ff @(posedge P_clk or posedge P_rst) begin


if(P_rst) begin

  P_ready  <= 0;
  P_slverr <= 0;
  P_rdata  <= 0;

end

else begin

  P_ready  <= 1;
  P_slverr <= 0;

  //---------------------------------
  // ACCESS STATE
  //---------------------------------

  if(present_state == ACCESS && P_selx && P_enable) begin

    P_ready <= 1;

    //---------------------------------
    // WRITE
    //---------------------------------

    if(P_write) begin

      mem[P_addr[4:0]] <= P_wdata;

    end

    //---------------------------------
    // READ
    //---------------------------------

    else begin

      P_rdata <= mem[P_addr[4:0]];

    end

  end

end


end

//---------------------------------
// Debug Prints
//---------------------------------

always @(posedge P_clk) begin


$display(
  "TIME=%0t STATE=%0d NEXT=%0d PSEL=%0b PENABLE=%0b PREADY=%0b ADDR=%0h WDATA=%0h",
   $time,
   present_state,
   next_state,
   P_selx,
   P_enable,
   P_ready,
   P_addr,
   P_wdata
);


end

endmodule
