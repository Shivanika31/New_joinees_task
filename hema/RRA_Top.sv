module RRA_Top #(
    parameter NUM_REQUESTS = 256 // Total number of requests/pixels
) (
    input  logic Pclk_i,                     // Clock signal
    input  logic PResetn_i,                   // Reset signal (active low)
    input  logic PWrite_i,                   // Write enable signal for register writes
    input  logic [7:0] PAddr_i,  
    input  logic PSel_i,                     // 32-bit address for register access
    input  logic [31:0] PWData_i,            // Data to be written to the registers
    output logic [31:0] PRData_o,            // Data read from the registers
    input  logic [NUM_REQUESTS-1:0] req_i,   // Requests from clients
    output logic [NUM_REQUESTS-1:0] gnt_o    // Grant signals
);

    // Register map declarations
    logic [31:0] ARB_CTRL = 0;    // Control register
    logic [31:0] ARB_STATUS = 0;

    localparam ARB_STATUS_ADDR = 8'h04;
    localparam ARB_CTRL_ADDR = 8'h00;

    // Fields in ARB_CTRL register
    logic [3:0] timeout_period;   // Timeout period in clock cycles
    logic [3:0] enable;           // Enable/disable arbiter (1 = enabled, 0 = disabled)

    // Fields in ARB_STATUS register
    logic [7:0] current_grant, pending_requests;

    // Internal signals for RRA
    //logic [7:0] grant_pointer=0;            // Pointer for round-robin arbitration
    logic [7:0] timeout_counter=0;         // Timeout counter
    logic [NUM_REQUESTS-1:0] rra_gnt;      // Internal grant signal

    // Instantiate the RRA module
    RRA #(.NUM_REQUESTS(NUM_REQUESTS)) rra_inst
   (
        .clk_i(Pclk_i),
        .rstn_i(PResetn_i),
        .req_i(req_i),
        .timeoutperiod_i(timeout_period),
	.gnt_o(rra_gnt)
                                          // RRA module drives internal rra_gnt
    );

                                          // Register write/read logic
    always_ff @(posedge Pclk_i or negedge PResetn_i) 
	   begin
        if (!PResetn_i) 
		    begin
            PRData_o <= 32'h0;            // Clear the read data during reset
          end 
		  else if (PSel_i)
		    begin
            if (PWrite_i) 
				  begin
                                                             // Write operation: Store data into the registers at specified address
                case (PAddr_i)
                    ARB_CTRL_ADDR: 
						  begin
                        timeout_period <= PWData_i[7:4];
                        enable <= PWData_i[3:0];
                    end
                    default:
						  begin
                        timeout_period <= 4'h0;
                        enable <= 4'h0;
                    end
                 endcase
               end 
			else
		  	 begin
                                                              // Read operation: Output data from registers at specified address
                case (PAddr_i)
                    ARB_CTRL_ADDR: PRData_o <= ARB_CTRL;      // Read from ARB_CTRL
                    ARB_STATUS_ADDR: PRData_o <= ARB_STATUS;  // Read from ARB_STATUS
                    default: PRData_o <= 32'h0;               // Default read value for invalid address
                endcase
          end
        end
    end
                                           // Generate ARB_STATUS register
    always_comb 
	    begin
         if (!PResetn_i) 
			   begin
             ARB_STATUS = 32'h0;
             pending_requests = 8'h0;
             current_grant = 8'h0;
            end 
			else
		    	begin
                                          // Count pending requests
            pending_requests = 0;
            for (int i = 0; i < NUM_REQUESTS; i++) 
				 begin
                if (req_i[i])
                    pending_requests += 1 ;
             end
				        pending_requests = pending_requests-8'h1; 


                                         // Find the current grant index
            current_grant = 8'h0;
            for (int i = 0; i < NUM_REQUESTS; i++) 
				    begin
                  if (rra_gnt[i]) 
						 begin
                     current_grant = (i + 1) % 256; 
                     break;
                   end
                end

                                        // Update ARB_STATUS with 32-bit concatenation
            ARB_STATUS = {16'b0, current_grant, pending_requests[7:0]};
        end
    end

                                       // Update ARB_CTRL dynamically
    always_comb begin
        ARB_CTRL = {16'b0, timeout_period, enable};
    end
	 always_comb 
	 begin
        
            if (&enable) 
                gnt_o = rra_gnt;       // Forward the grants when enabled
            else 
                gnt_o = 0;             // Disable grant signals if arbiter is disabled
        end 
	 
endmodule
