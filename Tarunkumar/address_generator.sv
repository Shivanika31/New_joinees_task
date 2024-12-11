`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2024 03:34:18 PM
// Design Name: 
// Module Name: address_generator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module address_generator #(
    parameter ADDR_WIDTH = 16
)(
    input logic clk_i,                      // Clock signal (input)
    input logic resetn_i,                   // Reset signal (input)
    input logic start_i,                    // Start signal to begin address generation (input)
    input logic [15:0] src_address_in_i,    // Source address from descriptor (input)
    input logic [15:0] dst_address_in_i,    // Destination address from descriptor (input)
    output logic [ADDR_WIDTH-1:0] src_address_out_o,  // Output source address (output)
    output logic [ADDR_WIDTH-1:0] dst_address_out_o,  // Output destination address (output)
    output logic done_o                     // Indicates the address generation is complete (output)
);

    // Internal state variables
    typedef enum logic [1:0] {
        IDLE = 2'b00,
        GEN_ADDR = 2'b01,
        DONE = 2'b10
    } state_t;

    state_t state, next_state;
    logic [ADDR_WIDTH-1:0] src_addr_reg, dst_addr_reg;

    // State machine to control address generation
    always_ff @(posedge clk_i or negedge resetn_i) begin
        if (!resetn_i) begin
            state <= IDLE;
            src_addr_reg <= 0;
            dst_addr_reg <= 0;
        end else begin
            state <= next_state;
            if (state == GEN_ADDR) begin
                src_addr_reg <= src_address_in_i; // Update source address
                dst_addr_reg <= dst_address_in_i; // Update destination address
            end
        end
    end

    // Next state logic
    always_ff @(state or start_i) begin
        case(state)
            IDLE: begin
                if (start_i) begin
                    next_state = GEN_ADDR;
                end else begin
                    next_state = IDLE;
                end
            end
            GEN_ADDR: begin
                next_state = DONE;
            end
            DONE: begin
                next_state = IDLE; // Back to IDLE after generation is done
            end
            default: next_state = IDLE;
        endcase
    end

    // Output assignments
    assign src_address_out_o = src_addr_reg;
    assign dst_address_out_o = dst_addr_reg;
    assign done_o = (state == DONE); // Done signal when in DONE state

endmodule


