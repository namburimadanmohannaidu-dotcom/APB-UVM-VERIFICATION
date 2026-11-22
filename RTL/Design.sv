
module AMBA_APB #(
    parameter WAIT_CYCLES = 0
)(
    input  logic        P_clk,
    input  logic        P_rst,

    // APB Master inputs
    input  logic [31:0] P_addr,
    input  logic        P_selx,
    input  logic        P_enable,
    input  logic        P_write,
    input  logic [31:0] P_wdata,

    // APB Slave outputs
    output logic        P_ready,
    output logic        P_slverr,
    output logic [31:0] P_rdata
);

    // --------------------------------
    // 1. Internal memory
    // --------------------------------
    logic [31:0] mem [0:31];

    // --------------------------------
    // 2. FSM state declaration
    // --------------------------------
    typedef enum logic [1:0] {
        IDLE   = 2'b00,
        SETUP  = 2'b01,
        ACCESS = 2'b10
    } state_t;

    state_t present_state, next_state;

    // --------------------------------
    // 3. Wait-state counter
    // --------------------------------
    localparam COUNT_WIDTH =
        (WAIT_CYCLES < 1) ? 1 : $clog2(WAIT_CYCLES + 1);

    logic [COUNT_WIDTH-1:0] wait_count;

    // --------------------------------
    // 4. Address validation
    // --------------------------------
    logic addr_valid;

    assign addr_valid =
        (P_addr[31:7] == 0) &&
        (P_addr[1:0]  == 0);

    // --------------------------------
    // 5. APB ready generation
    // --------------------------------
    always_comb begin
        P_ready = 1'b0;

        if (present_state == ACCESS &&
            wait_count >= WAIT_CYCLES)
            P_ready = 1'b1;
    end

    // --------------------------------
    // 6. Transfer completion
    // --------------------------------
    logic transfer_complete;

    assign transfer_complete =
        (present_state == ACCESS) &&
        P_selx &&
        P_enable &&
        P_ready;

    // --------------------------------
    // 7. FSM state register
    // --------------------------------
    always_ff @(posedge P_clk or posedge P_rst) begin
        if (P_rst)
            present_state <= IDLE;
        else
            present_state <= next_state;
    end

    // --------------------------------
    // 8. FSM next-state logic
    // --------------------------------
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

            default: begin
                next_state = IDLE;
            end

        endcase
    end

    // --------------------------------
    // 9. Wait counter logic
    // --------------------------------
    always_ff @(posedge P_clk or posedge P_rst) begin

        if (P_rst) begin
            wait_count <= '0;
        end
        else if (present_state != ACCESS) begin
            wait_count <= '0;
        end
        else if (!P_ready) begin
            wait_count <= wait_count + 1'b1;
        end
    end

    // --------------------------------
    // 10. Write operation
    // --------------------------------
    always_ff @(posedge P_clk or posedge P_rst) begin

        if (P_rst) begin
            // Memory contents are not reset
        end
        else if (transfer_complete &&
                 P_write &&
                 addr_valid) begin

            mem[P_addr[6:2]] <= P_wdata;

        end
    end

    // --------------------------------
    // 11. Read data generation
    // --------------------------------
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

    // --------------------------------
    // 12. Slave error generation
    // --------------------------------
    always_comb begin

        P_slverr = 1'b0;

        if (transfer_complete && !addr_valid)
            P_slverr = 1'b1;

    end

endmodule
