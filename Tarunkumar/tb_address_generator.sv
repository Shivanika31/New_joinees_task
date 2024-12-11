`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2024 03:36:24 PM
// Design Name: 
// Module Name: tb_address_generator
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

module tb_address_generator;
    // Testbench signals
    logic clk_i;
    logic resetn_i;
    logic start_i;
    logic [15:0] src_address_in_i, dst_address_in_i;
    logic [15:0] src_address_out_o, dst_address_out_o;
    logic done_o;

    // Instantiate the address generator module
    address_generator #(
        .ADDR_WIDTH(16)
    ) uut (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .start_i(start_i),
        .src_address_in_i(src_address_in_i),
        .dst_address_in_i(dst_address_in_i),
        .src_address_out_o(src_address_out_o),
        .dst_address_out_o(dst_address_out_o),
        .done_o(done_o)
    );

    // Clock generation: 10ns clock period (50 MHz)
    always #5 clk_i = ~clk_i;

    // Testbench logic
    initial begin
        // Initialize signals
        clk_i = 0;
        resetn_i = 0;
        start_i = 0;
        src_address_in_i = 16'hA1B2; // Example source address
        dst_address_in_i = 16'hC3D4; // Example destination address

        // Apply reset
        #10 resetn_i = 1;
        
        // Test 1: Trigger address generation (start)
        #10 start_i = 1;
            src_address_in_i = 16'h1111;
            dst_address_in_i = 16'h2222;
        #10 start_i = 0; // Disable start signal

        // Test 2: Check generated addresses
        #10 $display("Generated Source Address: %h, Destination Address: %h", 
                     src_address_out_o, dst_address_out_o);
        
        // Test 3: Trigger address generation with different addresses
        #10 start_i = 1;
            src_address_in_i = 16'h3333;
            dst_address_in_i = 16'h4444;
        #10 start_i = 0; // Disable start signal

        // Test 4: Check new generated addresses
        #10 $display("Generated Source Address: %h, Destination Address: %h", 
                     src_address_out_o, dst_address_out_o);

        // Test 5: Check done signal
        #10 $display("Done signal: %b", done_o);

        // Test 6: Reset the system
        #10 resetn_i = 0;  // Apply reset again
        #10 resetn_i = 1;  // Release reset
        #10 $display("After reset, Source Address: %h, Destination Address: %h", 
                     src_address_out_o, dst_address_out_o);

        // End the simulation
        #10 $stop;
    end
endmodule


