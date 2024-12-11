module RRA_tb;

    // Parameters
    parameter NUM_REQUESTS = 256;

    // Clock and reset
    logic pclk_i;
    logic prst_i;
	 logic psel_i;

    // Signals for register access
    logic pwrite_i;
    logic [7:0] paddr_i;
    logic [31:0] pwdata_i;
    logic [31:0] prdata_o;

    // Signals for requests and grants
    logic [NUM_REQUESTS-1:0] req_i;
    logic [NUM_REQUESTS-1:0] gnt_o;

    // Instantiate the RRA_Top module
    RRA_Top #(.NUM_REQUESTS(NUM_REQUESTS)) dut (
        .Pclk_i(pclk_i),
        .PResetn_i(prst_i),
        .PWrite_i(pwrite_i),
        .PAddr_i(paddr_i),
        .PWData_i(pwdata_i),
		  .PSel_i(psel_i),
        .PRData_o(prdata_o),
        .req_i(req_i),
        .gnt_o(gnt_o)
    );

    // Clock generation: 10ns clock period
    always #5 pclk_i = ~pclk_i;

    // Testbench procedure
    initial begin
        // Initialize signals
        #0  pclk_i = 0; prst_i = 0; pwrite_i = 0; paddr_i = 0; pwdata_i = 32'hF;
            req_i = 256'b00000000_00000000_00000010_00010001; psel_i=1;
        #10 prst_i = 1;  pwrite_i = 1;  ; pwdata_i = 32'b00101111; 
		      req_i = 256'b00000000_00000000_00000010_00010011;     

        #30 req_i = 256'b00000000_00000000_00000000_10000000;     

		  #40 psel_i = 1; pwrite_i = 0; paddr_i = 8'h4 ;pwdata_i = 32'b00111111;
            req_i = 256'b00000000_00000000_00000000_00101010;
				
        #20 pwdata_i = 32'b0011110;
		  
		  #10 psel_i = 1; pwrite_i = 1; paddr_i = 8'h0 ;pwdata_i = 32'b00111111;
            req_i = 256'b00000000_00000000_00000000_0000100; 
      
		  #50
        $stop;
    end
endmodule
