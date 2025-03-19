module counter(
    input logic clk,          // Clock input
    input logic rst_n,        // Active low reset
    output logic [3:0] count  // 4-bit counter output
);
    // Counter logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n)
            count <= 4'b0000; // Reset counter to 0
        else
            count <= count + 1; // Increment counter on each clock cycle
    end 
endmodule