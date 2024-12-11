`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2024 03:05:33 PM
// Design Name: 
// Module Name: descriptor_memory
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


module descriptor_memory #(
    parameter NUM_DESCRIPTORS = 16 // Number of descriptors
)(
    input logic clk_i,             // Clock signal (input)
    input logic resetn_i,          // Reset signal (input)
    input logic [3:0] addr_i,      // Address for accessing descriptors (4 bits for 16 descriptors) (input)
    input logic write_enable_i,    // Write enable signal (input)
    input logic [63:0] write_data_i, // Data to write (input)
    output logic [15:0] src_address_o, // Source address of the descriptor (output)
    output logic [15:0] dst_address_o, // Destination address of the descriptor (output)
    output logic [31:0] payload_ptr_o  // Payload pointer of the descriptor (output)
);

    // Define descriptor structure
    typedef struct packed {
        logic [15:0] src_address;   // 2 bytes
        logic [15:0] dst_address;   // 2 bytes
        logic [31:0] payload_ptr;   // 4 bytes
    } descriptor_t;

    // Memory array to store descriptors
    descriptor_t memory_array [NUM_DESCRIPTORS];

    // Internal register for reading data
    descriptor_t read_data;

    // Sequential write logic
    always_ff @(posedge clk_i or negedge resetn_i) begin
        if (!resetn_i) begin
            integer i;
            for (i = 0; i < NUM_DESCRIPTORS; i = i + 1) begin
                memory_array[i] <= '{default:0}; // Reset all descriptors
            end
        end else if (write_enable_i) begin
            memory_array[addr_i] <= '{src_address: write_data_i[63:48], 
                                    dst_address: write_data_i[47:32], 
                                    payload_ptr: write_data_i[31:0]}; // Write new descriptor
        end
    end

    // Sequential read logic
    always_ff @(posedge clk_i or negedge resetn_i) begin
        if (!resetn_i) begin
            read_data <= '{default:0}; // Reset read data
        end else begin
            read_data <= memory_array[addr_i]; // Read descriptor
        end
    end

    // Assign read data fields to outputs
    assign src_address_o = read_data.src_address;
    assign dst_address_o = read_data.dst_address;
    assign payload_ptr_o = read_data.payload_ptr;

endmodule

