module spi_master_tb;

    // Testbench signals
    logic clk_i;
    logic rst_i;
    logic miso_i;
    logic [1:0] mode_i;
    logic [7:0] data_in_i;
    logic write_i;
    logic enable_i;
    logic [5:0] clk_divider_i;

    logic sclk_o;
    logic mosi_o;
    logic cs_o;
    logic [7:0] data_out_o;
    logic busy_o;
    
    logic clk_pol_0;
    logic clk_pol_1;

    // Parameters
    parameter CLK_PERIOD = 10; // Clock period in ns
    //parameter MISO_PATTERN = 8'b11001100; // MISO data pattern for testing
    parameter DIVIDER = 2;

    // Internal variables
    logic sclk_internal;
    logic [7:0] miso_shift_reg; // For MISO bit shifting
    logic [7:0] read_data;
    logic [3:0] clk_div_cnt;

    
    // Instantiate the DUT
    spi_master uut (.clk_pol_0(clk_pol_0), .clk_pol_1(clk_pol_1), .clk_i(clk_i),.rst_i(rst_i), .miso_i(miso_i), .mode_i(mode_i), .data_in_i(data_in_i), .write_i(write_i), .enable_i(enable_i), .clk_divider_i(clk_divider_i), .sclk_o(sclk_o), .mosi_o(mosi_o), .cs_o(cs_o), .data_out_o(data_out_o), .busy_o(busy_o));

    // Clock generation
    always #(CLK_PERIOD / 2) clk_i = ~clk_i;


    ///  write operation in mode = 00
    task write_mode_0();
        @(negedge clk_i)
        mode_i<=2'b00;
        data_in_i  <= 8'b00001111;
        data_in_i <= 8'b10101111;
        write_i <=1;
        enable_i <=1;
        repeat(2)
            @(posedge clk_i);
        wait (cs_o==1)
            begin
             enable_i <=0;  
             write_i <=0; 
            return;
            end
    endtask  

    ///  READ operation in mode = 00
    task read_mode_0();
        //@(posedge clk_i)
        mode_i <= 0;
        write_i <= 0;
        enable_i <= 1;

        for (int i=0; i<8;i++) begin
            @(posedge sclk_internal)
            miso_i <= miso_shift_reg[7]; // Provide the MSB first
            miso_shift_reg <= {miso_shift_reg[6:0], 1'b0};
        end  
        wait (cs_o==1)
            begin
                
            read_data <= data_out_o;

             enable_i <=0;  
             write_i <=0; 
            return;
            end        
    endtask  

    ///  WRITE operation in mode = 11
    task write_mode_3();
        @(negedge clk_i)
        mode_i <= 2'b11;
        data_in_i  <= 8'b10101010;
		  
        write_i <=1;
        enable_i <=1;
        repeat(2)
            @(posedge clk_i);
        wait (cs_o==1)
            begin
             enable_i <=0;  
             write_i <=0; 
            return;
            end
    endtask    

    ///  READ operation in mode = 11
    task read_mode_3();
        //@(posedge clk_i)
        mode_i <= 3;
        write_i <= 0;
        enable_i <= 1;

        for (int i=0; i<8;i++) begin
            @(negedge sclk_internal)
            miso_i <= miso_shift_reg[7]; // Provide the MSB first
            miso_shift_reg <= {miso_shift_reg[6:0], 1'b0};
        end  
        wait (cs_o==1)
            begin
                
            read_data <= data_out_o;

             enable_i <=0;  
             write_i <=0; 
            return;
            end        
    endtask      


////////////////////////////////////////////////////////////////////////////////////////////
//%%%%%%%%%%%%%%%%%%% TSEST CASE 1 - Start %%%%%%%%%%%%%%%%%%%%%/////////////////

 

    // // Test procedure
    // initial begin
    //     // Initialize signals
    //     clk_i <= 0;
    //     rst_i <= 1;
    //     clk_divider_i <= 6'b000010;
    //     read_data <=0;
    //     miso_i <= 1;
    //     mode_i <= 2'b00;
    //     data_in_i <= 8'b0; // Test data
    //     write_i <= 0;
    //     enable_i <= 0;
    //     miso_shift_reg <= 8'b0;;

    //     #50;
    //     rst_i <= 0;
    //     write_mode_0();
    //     #50;
    //     miso_shift_reg <= 8'b00001111;
    //     #10;
    //     read_mode_0();
    //     #100;
    //     rst_i <= 1;
    //     #50;
    //     $finish;

    // end

//////////////////////////----- TESE CASE 1 - END-----//////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////    




////////////////////////////////////////////////////////////////////////////////////////////
//%%%%%%%%%%%%%%%%%%% TSEST CASE 2 - Start %%%%%%%%%%%%%%%%%%%%%/////////////////
 

    // // Test procedure
    // initial begin
    //     // Initialize signals
    //     clk_i <= 0;
    //     rst_i <= 1;
    //     clk_divider_i <= 6'b000010;
    //     read_data <=0;
    //     miso_i <= 1;
    //     mode_i <= 2'b11;
    //     data_in_i <= 8'b0; // Test data
    //     write_i <= 0;
    //     enable_i <= 0;
    //     miso_shift_reg <= 8'b0;;

    //     #50;
    //     rst_i <= 0;
    //     write_mode_3();
    //     #50;
    //     miso_shift_reg <= 8'b00001111;
    //     #10;
    //     read_mode_3();
    //     #100;
    //     rst_i <= 1;
    //     #50;
    //     $finish;

    // end

//////////////////////////----- TESE CASE 2 - END-----//////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////




////////////////////////////////////////////////////////////////////////////////////////////
//%%%%%%%%%%%%%%%%%%% TSEST CASE 3.1 - Start %%%%%%%%%%%%%%%%%%%%%/////////////////

    // task write_mode_pattern1();
    //     @(negedge clk_i)
    //     mode_i<=2'b00;
    //     data_in_i  <= 8'b00110011;
        
    //     write_i <=1;
    //     enable_i <=1;
    //     repeat(2)
    //         @(posedge clk_i);
    //     wait (cs_o==1)
    //         begin
    //          enable_i <=0;  
    //          write_i <=0; 
    //         return;
    //         end
    // endtask

    // task write_mode_pattern2();
    //     @(negedge clk_i)
    //     mode_i<=2'b00;
    //     data_in_i <= 8'b10010110;
    //     write_i <=1;
    //     enable_i <=1;
    //     repeat(2)
    //         @(posedge clk_i);
    //     wait (cs_o==1)
    //         begin
    //          enable_i <=0;  
    //          write_i <=0; 
    //         return;
    //         end
    // endtask


    // // Test procedure
    // initial begin
    //     // Initialize signals
    //     clk_i <= 0;
    //     rst_i <= 1;
    //     clk_divider_i <= 6'b000010;
    //     read_data <=0;
    //     miso_i <= 1;
    //     mode_i <= 2'b00;
    //     data_in_i <= 8'b0; // Test data
    //     write_i <= 0;
    //     enable_i <= 0;
    //     miso_shift_reg <= 8'b0;;

    //     #50;
    //     rst_i <= 0;
    //     write_mode_pattern1();
    //     #50;
    //     // miso_shift_reg <= 8'b00001111;
    //     //#10;
    //     write_mode_pattern2();
    //     #100;
    //     rst_i <= 1;
    //     #50;
    //     $finish;

    // end

//////////////////////////----- TESE CASE 3.1 - END-----//////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////    







////////////////////////////////////////////////////////////////////////////////////////////
//%%%%%%%%%%%%%%%%%%% TSEST CASE 3.2 - Start %%%%%%%%%%%%%%%%%%%%%/////////////////

    task read_mode_pattern();
        //@(posedge clk_i)
        mode_i <= 0;
        write_i <= 0;
        enable_i <= 1;

        for (int i=0; i<8;i++) begin
            @(posedge sclk_internal)
            miso_i <= miso_shift_reg[7]; // Provide the MSB first
            miso_shift_reg <= {miso_shift_reg[6:0], 1'b0};
        end  
        wait (cs_o==1)
            begin
                
            read_data <= data_out_o;

             enable_i <=0;  
             write_i <=0; 
            return;
            end        
    endtask 



    // Test procedure
    initial begin
        // Initialize signals
        clk_i <= 0;
        rst_i <= 1;
        clk_divider_i <= 6'b000010;
        read_data <=0;
        miso_i <= 1;
        mode_i <= 2'b00;
        data_in_i <= 8'b0; // Test data
        write_i <= 0;
        enable_i <= 0;
        miso_shift_reg <= 8'b0;;

        #50;
        rst_i <= 0;
        miso_shift_reg <= 8'b00111100;
        #10;        
        read_mode_pattern();
        #50;
        miso_shift_reg <= 8'b11000011;
        #10;
        read_mode_pattern();
        #100;
        rst_i <= 1;
        #50;
        $finish;

    end

//////////////////////////----- TESE CASE 3.2 - END-----//////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////   


    //clock generation for miso generation (for read operation)
    always_ff @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            clk_div_cnt <= 0;
            if (!mode_i[1])
                sclk_internal <= 0;
            else
                sclk_internal <= 1;
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


endmodule
