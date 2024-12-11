module spi_master (
    input  logic        clk_i,     // System clock
    input  logic        rst_i,     // Active-high reset
    input  logic        miso_i,      // Master-In-Slave-Out
    input  logic [1:0]  mode_i,      // SPI mode: [CPOL, CPHA]
    input  logic [7:0]  data_in_i,   // Data to write
    input  logic        write_i,     // Write enable
    input  logic        enable_i,    // Enable signal
    input  logic [5:0]  clk_divider_i, 

    output logic        sclk_o,      // Serial clock
    output logic        mosi_o,      // Master-Out-Slave-In
    output logic        cs_o,        // Chip Select (Active Low)
    output logic [7:0]  data_out_o,  // Data read
    output logic        busy_o,      // Transfer busy signal
    output logic clk_pol_0,
    output logic clk_pol_1
);

    logic [5:0] DIVIDER ;           // Configurable clock divider

    // Internal registers
    logic [7:0] shift_reg;          // Shift register for data transfer
    logic [3:0] bit_counter;        // Counter for bits being transferred
    logic [5:0] clk_div_cnt;        // Clock divider counter
    logic        sclk_internal;     // Internal SCLK for polarity/phase adjustments
    logic        cpol_0, cpol_1;    // edge detectors



    assign DIVIDER = clk_divider_i;

    // FSM States
    typedef enum logic [1:0] { IDLE = 2'b00, TRANSFER = 2'b01, DONE = 2'b10 } fsm_state_t;

    fsm_state_t state, next_state;


    // SCLK generation logic
    always_ff @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            clk_div_cnt <= 0;
            sclk_internal <= mode_i[1];
            // if (!mode_i[1])
            //     sclk_internal <= 0;
            // else
            //     sclk_internal <= 1;
        end else begin
            if(!cs_o) begin
                if (clk_div_cnt == (DIVIDER-1)) begin
                    clk_div_cnt <= 0;
                    sclk_internal <= ~sclk_internal;
                end else begin
                    clk_div_cnt <= clk_div_cnt + 1;
                end
            end
            else begin
                clk_div_cnt <= 0;
                sclk_internal <= mode_i[1];
            end

        end
    end

    // sclk 
    assign sclk_o = sclk_internal;
    
    // Edge Detectors
    assign clk_pol_0 = cpol_0;
    assign clk_pol_1 = cpol_1;

    // FSM for SPI master
    always_ff @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                if(!cs_o) begin
                    next_state = TRANSFER;
                end
            end
            TRANSFER: begin
                if (bit_counter == 9 ) begin
                    next_state = DONE;
                end
            end
            DONE: begin

                next_state = IDLE;
            end
        endcase
    end

    // Data transfer logic
    always_ff @(posedge clk_i or posedge rst_i) begin
        if (rst_i) 
            begin
                shift_reg <= 8'b0;
                bit_counter <= 3'b0;
                mosi_o <= 0;
                data_out_o <= 8'b0;
                busy_o <= 0;
                cs_o <= 1; // Chip Select is high (inactive) initially
            end 
        else begin
            case (state)
                IDLE:begin
                        busy_o <= 0;
                        cs_o <= 1;     // Deactivate chip select
                        bit_counter <= 3'b0;
                        //shift_reg <= data_in_i;
                        if (enable_i && write_i) begin
                            shift_reg <= data_in_i; // Load data to shift register for write
                            cs_o <= 0; // Activate chip select
                            busy_o <= 1;
                        end 
                        else if (enable_i && !write_i) begin
                            //shift_reg <= 'b1; // Clear shift register for read
                            cs_o <= 0; // Activate chip select
                            busy_o <= 1;
                        end
                    end

                TRANSFER:begin
                    case (mode_i)
                        2'b00: begin  // Mode 0: CPOL = 0, CPHA = 0
                            if (write_i) begin
                                if (cpol_0) begin
                                    mosi_o <= shift_reg[7];              // Transmit MSB first
                                    shift_reg <= {shift_reg[6:0], 1'b0}; // Shift left for next bit
                                    $monitor("mosi_o = %0b",mosi_o);
                                end 
                            end
                            else
                            if (cpol_1) begin
                                shift_reg <= {shift_reg[6:0], miso_i}; // Shift in received data
                            end                        
                            // if (write_i && cpol_0) begin
                            //     mosi_o <= shift_reg[7];              // Transmit MSB first
                            //     shift_reg <= {shift_reg[6:0], 1'b0}; // Shift left for next bit
                            // end 
                            // if (!write_i && cpol_1) begin
                            //     shift_reg <= {shift_reg[6:0], miso_i}; // Shift in received data
                            // end

                            if (cpol_0) begin
                                bit_counter <= bit_counter + 1; // Increment on rising edge
                            end
                        end

                        2'b11: begin  // Mode 3: CPOL = 1, CPHA = 1

                            // if (write_i) begin
                            //     if(bit_counter == 0)
                            //         mosi_o <= shift_reg[7];  
                            //     else if (cpol_0) begin
                            //         mosi_o <= shift_reg[7];              // Transmit MSB first
                            //         shift_reg <= {shift_reg[6:0], 1'b0}; // Shift left for next bit
                            //         end 
                            //     end
                            // else begin
                            // if (cpol_1) begin
                            //     shift_reg <= {shift_reg[6:0], miso_i}; // Shift in received data
                            // end   
                            // end                         
                            
                            
                            if (write_i && cpol_1) begin
                                mosi_o <= shift_reg[7];              // Transmit MSB first
                                shift_reg <= {shift_reg[6:0], 1'b0}; // Shift left for next bit
                            end 
                            if (!write_i && cpol_0) begin                                
                                shift_reg <= {shift_reg[6:0], miso_i}; // Shift in received data
                            end

                            if (cpol_1) begin
                                bit_counter <= bit_counter + 1; // Increment on falling edge
                            end
                        end

                        // Add cases for other modes if needed (Mode 1 and Mode 2)
                        default: begin
                            mosi_o <= 1'b0;
                        end
                    endcase                   

                        end

                DONE:   begin
                        $display("WORKING DATA OUT" );
                        data_out_o <= shift_reg;
                            //if (!write_i) begin
                            //data_out_o <= shift_reg;
                                 // Capturing received data
                                $monitor("SH=%0b",shift_reg);
                                //$monitor("DOUT=%0b",data_out_o);
                            //end
                            cs_o <= 1; // Deactivating chip select
                            busy_o <= 0;                            
                        end
            endcase
        end

    end


 // Posedge and negedge detection of sclk
  always@(posedge clk_i or posedge rst_i)
    begin
    if(rst_i)
        begin
            cpol_0 <= 1'b0;
            cpol_1 <= 1'b0;
        end
    else
        begin
            cpol_0 <= 0;
            cpol_1 <= 0;
            if(!cs_o)
                begin
                if(~sclk_internal)
                    begin
                    if(clk_div_cnt == (DIVIDER-1))
                        begin
                        cpol_0 <= 1;
                        end
                    end
                end
            if(!cs_o)
                begin
                if(sclk_internal)
                    begin
                    if(clk_div_cnt ==  (DIVIDER-1))
                        begin
                        cpol_1 <= 1;
                        end
                    end
                end
        end
    end


endmodule

