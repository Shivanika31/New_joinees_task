`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2024 03:22:22 PM
// Design Name: 
// Module Name: tb_descriptor_memory
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


module tb_descriptor_memory;
    // Testbench signals
    logic clk_i;
    logic resetn_i;
    logic [3:0] addr_i;
    logic write_enable_i;
    logic [63:0] write_data_i;
    logic [15:0] src_address_o, dst_address_o;
    logic [31:0] payload_ptr_o;

    // Define descriptor structure
    typedef struct packed {
        logic [15:0] src_address;
        logic [15:0] dst_address;
        logic [31:0] payload_ptr;
    } descriptor_t;

    // Instantiate the descriptor memory module
    descriptor_memory #(.NUM_DESCRIPTORS(16)) uut (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .addr_i(addr_i),
        .write_enable_i(write_enable_i),
        .write_data_i(write_data_i),
        .src_address_o(src_address_o),
        .dst_address_o(dst_address_o),
        .payload_ptr_o(payload_ptr_o)
    );

    // Clock generation: 10ns clock period (50 MHz)
    always #5 clk_i = ~clk_i;

    // Testbench logic
    initial begin
        // Initialize signals
        clk_i = 0;
        resetn_i = 0;
        addr_i = 4'b0;
        write_enable_i = 0;
        write_data_i = 64'hAAAA_BBBB_CCCC_DDDD; // Example data

        // Reset the system
        #10 resetn_i = 1;
        
        // Test 1: Write to descriptor memory at address 0
        #10 addr_i = 4'h0;
            write_enable_i = 1;          // Enable writing
            write_data_i = 64'h1234_5678_9ABC_DEF0; // Sample descriptor data
        #10 write_enable_i = 0;          // Disable write

        // Test 2: Read from descriptor memory at address 0
        #10 addr_i = 4'h0;               // Set address to 0 to read back
        #10 $display("Read from addr 0: src_address = %h, dst_address = %h, payload_ptr = %h", 
                     src_address_o, dst_address_o, payload_ptr_o);

        // Test 3: Write to descriptor memory at address 1
        #10 addr_i = 4'h1;
            write_enable_i = 1;          // Enable writing
            write_data_i = 64'h1111_2222_3333_4444; // Another example descriptor data
        #10 write_enable_i = 0;          // Disable write

        // Test 4: Read from descriptor memory at address 1
        #10 addr_i = 4'h1;               // Set address to 1 to read back
        #10 $display("Read from addr 1: src_address = %h, dst_address = %h, payload_ptr = %h", 
                     src_address_o, dst_address_o, payload_ptr_o);

        // Test 5: Reset the system and ensure descriptors are cleared
        #10 resetn_i = 0;               // Apply reset
        #10 resetn_i = 1;               // Release reset
        #10 addr_i = 4'h0;
        #10 $display("After reset, read addr 0: src_address = %h, dst_address = %h, payload_ptr = %h", 
                     src_address_o, dst_address_o, payload_ptr_o);

        // End of test
        $stop;
    end
endmodule
