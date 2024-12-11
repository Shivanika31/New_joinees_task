module apb_interface (
    // APB Inputs
    input  logic        pclk_i,      // APB clock
    input  logic        prst_i,      // APB reset
    input  logic [31:0] paddr_i,     // APB address
    input  logic        pwrite_i,    // APB write enable
    input  logic        penable_i,   // APB enable signal
    input  logic        psel_i,      // APB select signal
    input  logic [31:0] pwdata_i,    // APB write data
    input  logic [7:0]  data_in,     // Data received from SPI module
    input  logic        busy_i,      // Busy signal from SPI module

    // APB Outputs
    output logic [31:0] prdata_o,    // APB read data
    output logic        pready_o,    // APB ready signal

    // SPI Outputs
    output logic        clk_o,       // SPI clock
    output logic        rst_o,       // SPI reset
    output logic        write_o,     // SPI write enable
    output logic        enable_o,    // SPI enable
    output logic [7:0]  data_out_o,  // Data to SPI module
    output logic [1:0]  mode_o,      // SPI mode
    output logic [5:0]  clk_divider_o // SPI clock divider
);

    // APB FSM States
    typedef enum logic [1:0] { IDLE = 2'b00, READ = 2'b01, WRITE = 2'b10 } apb_state_t;

    apb_state_t state, next_state;

    // Registers
    logic [7:0] control_reg;         // SPI Control Register: [1:0] -> mode, [7:2] -> clock divider
    logic [7:0] status_reg;          // SPI Status Register: [0] -> busy, [7:1] -> reserved
    logic [7:0] tx_data_reg;         // SPI Transmit Data Register
    logic [7:0] rx_data_reg;         // SPI Receive Data Register

    // APB Read/Write Control Signals
    logic write_enable, read_enable;

    // Address Decode
    always_comb begin
        write_enable = (psel_i && penable_i && pwrite_i);
        read_enable = (psel_i && penable_i && !pwrite_i);
    end

    // APB FSM
    always_ff @(posedge pclk_i or posedge prst_i) begin
        if (prst_i)
            state <= IDLE;
        else
            state <= next_state;
    end

    always_comb begin
        next_state = state;
        pready_o = 0;
        case (state)
            IDLE: begin
                if (psel_i && penable_i) begin
                    if (pwrite_i)
                        next_state = WRITE;
                    else
                        next_state = READ;
                end
            end
            WRITE: begin
                pready_o = 1; // Indicate ready after write
                next_state = IDLE;
            end
            READ: begin
                pready_o = 1; // Indicate ready after read
                next_state = IDLE;
            end
        endcase
    end

    // Register Write Logic
    always_ff @(posedge pclk_i or posedge prst_i) begin
        if (prst_i) begin
            control_reg <= 8'b0;
            tx_data_reg <= 8'b0;
        end else if (write_enable) begin
            case (paddr_i[3:0]) // Address decoding based on lower 4 bits
                4'h0: control_reg <= pwdata_i[7:0];        // SPI Control Register
                4'h8: tx_data_reg <= pwdata_i[7:0];        // SPI Transmit Data Register
            endcase
        end
    end

    // Register Read Logic
    always_comb begin
        prdata_o = 32'b0;
        if (read_enable) begin
            case (paddr_i[3:0])
                4'h0: prdata_o = {24'b0, control_reg};     // SPI Control Register
                4'h8: prdata_o = {24'b0, tx_data_reg};     // SPI Transmit Data Register
                4'hC: prdata_o = {24'b0, rx_data_reg};     // SPI Receive Data Register
                4'h10: prdata_o = {24'b0, status_reg};     // SPI Status Register
            endcase
        end
    end

    // SPI Status Register Update
    always_ff @(posedge pclk_i or posedge prst_i) begin
        if (prst_i)
            status_reg <= 8'b0;
        else
            status_reg[0] <= busy_i; // Update busy bit
    end

    // SPI Receive Data Register Update
    always_ff @(posedge pclk_i or posedge prst_i) begin
        if (prst_i)
            rx_data_reg <= 8'b0;
        else if (!busy_i) // Update only when SPI is not busy
            rx_data_reg <= data_in;
    end

    // Assignments to SPI module
    assign clk_o = pclk_i;
    assign rst_o = prst_i;
    assign write_o = write_enable && (paddr_i[3:0] == 4'h8); // SPI write enable
    assign enable_o = psel_i && penable_i;                  // SPI enable signal
    assign data_out_o = tx_data_reg;                       // Transmit data to SPI module
    assign mode_o = control_reg[1:0];                      // SPI mode from control register
    assign clk_divider_o = control_reg[7:2];               // Extract clock divider value
endmodule





























// module apb_interface (
//     // APB Inputs
//     input  logic        pclk_i,      // APB clock
//     input  logic        prst_i,      // APB reset
//     input  logic [31:0] paddr_i,     // APB address
//     input  logic        pwrite_i,      // APB write enable
//     input  logic        penable_i,   // APB enable signal
//     input  logic        psel_i,      // APB select signal
//     input  logic [31:0] pwdata_i,    // APB write data
//     input  logic [7:0]  data_in,     // Data received from SPI module
//     input  logic        busy_i,      // Busy signal from SPI module

//     // APB Outputs
//     output logic [31:0] prdata_o,    // APB read data
//     output logic        pready_o,    // APB ready signal

//     // SPI Inputs
//     output logic        clk_o,       // SPI clock
//     output logic        rst_o,       // SPI reset
//     output logic        write_o,     // SPI write enable
//     output logic        enable_o,    // SPI enable
//     output logic [7:0]  data_out_o,  // Data to SPI module
//     output logic [1:0]  mode_o         // SPI mode
// );

//     typedef enum logic [1:0] { IDLE = 2'b00, READ = 2'b01, WRITE = 2'b10 } apb_state_t;

//     apb_state_t state, next_state;

//     // Registers
//     logic [7::0] control_reg;        // SPI Control Register
//     logic [7::0] status_reg;         // SPI Status Register
//     logic [7::0] tx_data_reg;        // SPI Transmit Data Register
//     logic [7::0] rx_data_reg;        // SPI Receive Data Register

//     // Internal signals
//     logic [1:0] write_strobe, read_strobe;

//     // Address Decode Logic
//     always_ff @(posedge pclk_i or posedge prst_i) begin
//         if (prst_i) begin
//             control_reg <= 8'b0;
//             tx_data_reg <= 8'b0;
//         end 
//         else begin
//             write_strobe <= (state == WRITE);
//             read_strobe <= (state == READ);
//             if (write_strobe) begin
//                 case (paddr_i[3:0]) // Address decoding based on lower 4 bits
//                     4'h0: control_reg <= pwdata_i[7:0];      // Write to SPI Control Register
//                     4'h8: tx_data_reg <= pwdata_i[7:0];      // Write to SPI Transmit Data Register
//                 endcase
//             end
//         end
//     end



//     // State Machine
//     always_ff @(posedge pclk_i or posedge prst_i) begin
//         if (prst_i)
//             state <= IDLE;
//         else
//             state <= next_state;
//     end

//     always_comb begin
//         next_state = state;
//         pready_o = 0;
//         case (state)
//             IDLE: begin
//                 if (psel_i && penable_i) begin
//                     if (pwrite_i)
//                         next_state = WRITE;
//                     else
//                         next_state = READ;
//                 end
//             end
//             READ: begin
//                 pready_o = 1;
//                 next_state = IDLE;
//             end
//             WRITE: begin
//                 pready_o = 1;
//                 next_state = IDLE;
//             end
//         endcase
//     end


//     // Status Register Update
//     always_ff @(posedge pclk_i or posedge prst_i) begin
//         if (prst_i) begin
//             status_reg <= 32'b0;
//         end 
//         else begin
//             status_reg[0] <= busy_i;       // Update busy status bit
//             // Additional status flags can be added here
//         end
//     end

//     // Receive Data Register Update
//     always_ff @(posedge pclk_i or posedge prst_i) begin
//         if (prst_i) begin
//             rx_data_reg <= 32'b0;
//         end 
//         else if (data_in) begin
//             rx_data_reg <= {24'b0, data_in}; // Update with data from SPI module
//         end
//     end

//     // Read Data 
//     always_comb begin
//         prdata_o = 32'b0;
//         if (read_strobe) begin
//             case (paddr_i[3:0])
//                 4'h0: prdata_o = control_reg; // SPI Control Register
//                 4'h4: prdata_o = status_reg;  // SPI Status Register
//                 4'h8: prdata_o = tx_data_reg; // SPI Transmit Data Register
//                 4'hC: prdata_o = rx_data_reg; // SPI Receive Data Register
//                 default: prdata_o = 32'b0;
//             endcase
//         end
//     end

//     // Assignments to SPI Module Inputs
//     assign clk_o = pclk_i;
//     assign rst_o = prst_i;
//     assign write_o = write_strobe && (paddr_i[3:0] == 4'h8);    // Write enable for SPI
//     assign enable_o = psel_i && penable_i;                      // SPI enable signal
//     assign data_out_o = tx_data_reg[7:0];                       // Transmit data to SPI module
//     assign mode_o = control_reg[1:0];                             // SPI mode_o from control register
//     //assign pready_o = ~busy_i;                                  // Pready signal for initite transfers

// endmodule
