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

  // Memory
  logic [31:0] mem [0:31];

  // States
  typedef enum logic [1:0] {
    IDLE,
    SETUP,
    ACCESS
  } state_t;

  state_t present_state, next_state;

  //---------------------------------
  // State register
  //---------------------------------
  always_ff @(posedge P_clk or posedge P_rst) begin
    if (P_rst)
      present_state <= IDLE;
    else
      present_state <= next_state;
  end

  //---------------------------------
  // Next state logic
  //---------------------------------
  always_comb begin
    next_state = present_state;

    case (present_state)

      IDLE: begin
        if (P_selx && !P_enable)
          next_state = SETUP;
      end

      SETUP: begin
        if (P_selx && P_enable)
          next_state = ACCESS;
        else
          next_state = IDLE;
      end

      ACCESS: begin
        if (!P_selx)
          next_state = IDLE;
      end

    endcase
  end

  //---------------------------------
  // Output & data logic
  //---------------------------------
  always_ff @(posedge P_clk or posedge P_rst) begin
    if (P_rst) begin
      P_ready  <= 0;
      P_slverr <= 0;
      P_rdata  <= 0;
    end
    else begin
      P_ready  <= 0;
      P_slverr <= 0;

      if (present_state == ACCESS && P_selx && P_enable) begin
        P_ready <= 1;

        if (P_write) begin
          mem[P_addr[4:0]] <= P_wdata;   // ✅ write
        end
        else begin
          P_rdata <= mem[P_addr[4:0]];   // ✅ read
        end
      end
    end
  end

endmodule