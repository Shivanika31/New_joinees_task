module RRA#(
    parameter NUM_REQUESTS = 256              // Total number of requests/pixels
) (
    input logic clk_i,                        // Clock signal
    input logic rstn_i,                       // Reset signal (active low)
    input logic [NUM_REQUESTS-1:0] req_i,     // Active requests for each pixel
    input logic [3:0] timeoutperiod_i,        // Timeout period for granting the same request
    output logic [NUM_REQUESTS-1:0] gnt_o = 0 // Grant signal to one pixel
);

    logic [8:0] pointer;                      // Pointer to track the current request index (9-bit to accommodate 256 requests)
    int index;                                // Index variable for looping through requests
    logic [3:0] counter;                      // Counter to track consecutive grants to the same request
    int last_granted_index = -1;              // Index of the last granted request

    // Process block to manage round-robin arbitration
    always_ff @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            pointer <= 0;                     // Reset pointer to the first request
            gnt_o <= 0;                       // Clear the grant signal
            counter <= 0;                     // Reset the counter
            last_granted_index <= -1;         // Initialize last granted index to -1
        end else begin
            gnt_o <= 0;                       // Clear the previous grant signal

            // Iterate starting from the last granted position to find the next active request
            for (int i = 0; i < NUM_REQUESTS; i = i + 1) begin
                // Calculate the index to check the next request
                index = (pointer + i) % NUM_REQUESTS;

                if (req_i[index]) begin
                    // Check if the same request is granted consecutively
                    if (last_granted_index == index) begin
                        if (counter == timeoutperiod_i) begin
                            gnt_o[index] <= 0;      // Clear the grant signal after timeout period
                            counter <= 0;            // Reset the counter
                            pointer <= (index + 1) % NUM_REQUESTS; // Move to the next request
                        end else begin
                            gnt_o[index] <= 1;      // Continue granting the same request
                            counter <= counter + 1;  // Increment the counter
                        end
                    end else begin
                        gnt_o[index] <= 1;         // Grant access to the new request
                        counter <= 1;               // Reset counter for the new request
                        last_granted_index <= index; // Update the last granted index
                        pointer <= (index + 1) % NUM_REQUESTS; // Update the pointer
                    end
                    break; // Exit the loop after granting
                end else begin
                    gnt_o[index] <= 0;             // If no active request, set grant to 0
                end
            end
        end
    end
endmodule
