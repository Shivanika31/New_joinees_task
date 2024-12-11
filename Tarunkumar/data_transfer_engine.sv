`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2024 05:14:40 PM
// Design Name: 
// Module Name: data_transfer_engine
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


module data_transfer_engine #(
    parameter DATA_WIDTH = 8,   // Width of each data chunk (1 byte)
    parameter DATA_SIZE = 32    // Total number of data chunks (32 bytes, 256 bits)
)(
    input logic clk_i,
    input logic resetn_i,                       // Active-low reset signal
    input logic start_i,                        // Start signal for data transfer
    input logic [15:0] src_address_i,           // Source address
    input logic [15:0] dst_address_i,           // Destination address
    input logic [DATA_SIZE*DATA_WIDTH-1:0] data_in_i, // Full data packet (256 bits)
    output logic [DATA_WIDTH-1:0] data_out_o,   // Data output (1 byte at a time)
    output logic done_o,                        // Transfer completion signal
    output logic error_o                        // Error signal for invalid transfers
);

    // Internal signals
    logic [$clog2(DATA_SIZE):0] data_counter;  // Counter for tracking data chunks

    // Error handling and data transfer logic
    always_ff @(posedge clk_i or negedge resetn_i) begin
        if (!resetn_i) begin
            data_counter <= 0;
            data_out_o <= 0;
            done_o <= 0;
            error_o <= 0;
        end else begin
            if (start_i) begin
                // Error if the size of data_in_i is not the expected size
                if (data_in_i[DATA_SIZE*DATA_WIDTH-1:0] === {DATA_SIZE*DATA_WIDTH{1'bx}}) begin
                    error_o <= 1;
                    done_o <= 1;
                end else begin
                    // Initialize for new transfer
                    data_counter <= 0;
                    done_o <= 0;
                    error_o <= 0;
                end
            end else if (!done_o && !error_o) begin
                // Perform data transfer
                if (data_counter < DATA_SIZE) begin
                    data_out_o <= data_in_i[data_counter * DATA_WIDTH +: DATA_WIDTH];
                    data_counter <= data_counter + 1;
                end

                // Check for completion
                if (data_counter == DATA_SIZE - 1) begin
                    done_o <= 1;
                end
            end
        end
    end

    // Error detection if reset occurs during transfer
    always_ff @(posedge clk_i or negedge resetn_i) begin
        if (!resetn_i && data_counter > 0) begin
            error_o <= 1; // Error if reset occurs during transfer
            done_o <= 1;
        end
    end
endmodule





