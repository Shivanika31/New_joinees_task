`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2024 05:27:59 PM
// Design Name: 
// Module Name: tb_data_transfer_engine
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


module tb_data_transfer_engine;

    // Parameters
    localparam DATA_WIDTH = 8;   // 1 byte
    localparam DATA_SIZE = 32;   // 32 bytes (256 bits)

    // Inputs
    logic clk_i;
    logic resetn_i;
    logic start_i;
    logic [15:0] src_address_i;
    logic [15:0] dst_address_i;
    logic [DATA_SIZE*DATA_WIDTH-1:0] data_in_i; // 256 bits

    // Outputs
    logic [DATA_WIDTH-1:0] data_out_o; // 1 byte
    logic done_o;
    logic error_o;

    // Clock generation
    always #5 clk_i = ~clk_i; // 100 MHz clock

    // DUT instantiation
    data_transfer_engine #(
        .DATA_WIDTH(DATA_WIDTH),
        .DATA_SIZE(DATA_SIZE)
    ) dut (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .start_i(start_i),
        .src_address_i(src_address_i),
        .dst_address_i(dst_address_i),
        .data_in_i(data_in_i),
        .data_out_o(data_out_o),
        .done_o(done_o),
        .error_o(error_o)
    );

    // Test stimulus
    initial begin
        // Initialize inputs
        clk_i = 0;
        resetn_i = 0;
        start_i = 0;
        src_address_i = 16'h1000;
        dst_address_i = 16'h2000;
        data_in_i = 256'h0102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F20;

        // Reset
        #10;
        resetn_i = 1;

        // Test Case 1: Normal operation
        $display("Starting Test Case 1: Normal operation");
        start_i = 1; // Trigger the transfer
        #10 start_i = 0;

        // Wait for done signal
        wait (done_o);
        $display("Test Case 1 Complete: Data transfer completed successfully.");
        $display("Last data_out_o: %h", data_out_o);

        // Test Case 2: Reset during transfer
        $display("Starting Test Case 2: Reset during transfer");
        start_i = 1; // Trigger the transfer
        #10 start_i = 0;
        #20 resetn_i = 0; // Assert reset during transfer
        #10 resetn_i = 1;

        // Wait and check if error is raised
        #20;
        if (error_o) begin
            $display("Test Case 2 Complete: Error detected as expected during reset.");
        end else begin
            $display("Test Case 2 Failed: Error not detected during reset.");
        end

        // Test Case 3: Check error handling for incorrect transfer size
        $display("Starting Test Case 3: Incorrect transfer size");
        data_in_i = 128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF; // Less data
        start_i = 1; // Trigger the transfer
        #10 start_i = 0;

        // Wait for done signal and check error
        wait (done_o);
        if (error_o) begin
            $display("Test Case 3 Complete: Error detected for incorrect transfer size.");
        end else begin
            $display("Test Case 3 Failed: No error detected for incorrect transfer size.");
        end

        $finish;
    end

endmodule




