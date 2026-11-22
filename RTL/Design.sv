
module AMBA_APB #(
    parameter WAIT_CYCLES = 0
)(
    input  logic        P_clk,
    input  logic        P_resetn,

    input  logic [31:0] P_addr,
    input  logic        P_selx,
    input  logic        P_enable,
    input  logic        P_write,
    input  logic [31:0] P_wdata,

    output logic        P_ready,
    output logic        P_slverr,
    output logic [31:0] P_rdata
);

    // Internal memory
    logic [31:0] mem [0:31];

    // FSM states
    typedef enum logic [1:0] {
        IDLE   = 2'b00,
        SETUP  = 2'b01,
        ACCESS = 2'b10
    } state_t;

    state_t present_state, next_state;

    // Wait counter
    localparam COUNT_WIDTH =
        (WAIT_CYCLES < 1) ? 1 : $clog2(WAIT_CYCLES + 1);

    logic [COUNT_WIDTH-1:0] wait_count;

    // Address validation
    logic addr_valid;

    assign addr_valid =
        (P_addr[31:7] == 0) &&
        (P_addr[1:0] == 0);

    // P_READY generation
    always_comb begin
        P_ready = 1'b0;

        if (present_state == ACCESS &&
            wait_count >= WAIT_CYCLES)
            P_ready = 1'b1;
    end

    // Transfer completion
    logic transfer_complete;

    assign transfer_complete =
        (present_state == ACCESS) &&
        P_selx &&
        P_enable &&
        P_ready;

    // FSM state register: active-low reset
    always_ff @(posedge P_clk or negedge P_resetn) begin
        if (!P_resetn)
            present_state <= IDLE;
        else
            present_state <= next_state;
    end

    // FSM next-state logic
    always_comb begin

        next_state = present_state;

        case (present_state)

            IDLE: begin
                if (P_selx && !P_enable)
                    next_state = SETUP;
            end

            SETUP: begin
                if (!P_selx)
                    next_state = IDLE;
                else if (P_enable)
                    next_state = ACCESS;
            end

            ACCESS: begin
                if (transfer_complete) begin
                    if (P_selx)
                        next_state = SETUP;
                    else
                        next_state = IDLE;
                end
            end

            default: next_state = IDLE;

        endcase

    end

    // Wait counter
    always_ff @(posedge P_clk or negedge P_resetn) begin

        if (!P_resetn)
            wait_count <= '0;

        else if (present_state != ACCESS)
            wait_count <= '0;

        else if (!P_ready)
            wait_count <= wait_count + 1'b1;

    end

    // Write operation
    always_ff @(posedge P_clk or negedge P_resetn) begin

        if (!P_resetn) begin
            // Memory is not reset
        end

        else if (transfer_complete &&
                 P_write &&
                 addr_valid) begin

            mem[P_addr[6:2]] <= P_wdata;

        end

    end

    // Read data
    always_comb begin

        P_rdata = 32'b0;

        if (present_state == ACCESS &&
            P_selx &&
            P_enable &&
            !P_write &&
            addr_valid) begin

            P_rdata = mem[P_addr[6:2]];

        end

    end

    // Slave error
    always_comb begin

        P_slverr = 1'b0;

        if (transfer_complete && !addr_valid)
            P_slverr = 1'b1;

    end

endmodule
