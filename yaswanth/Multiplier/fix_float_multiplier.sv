
////////////////////////////////////////////////////////
//// RTL Design : 32-bit Fixed and Floating Point Multiplier
//// Author     : Yaswanth Kumar Panthangi
//// Date       : 12/12/2024
////////////////////////////////////////////////////////

module fix_float_multiplier (
    input   logic clk_i,
    input   logic rstn_i,
    input   logic mode, 
    input   logic [31:0]  a_i,
    input   logic [31:0]  b_i,
    output  logic [31:0] y_o
);


    logic [7:0]     a_exponent, b_exponent, y_exponent;
    logic [23:0]    a_mantissa, b_mantissa, y_mantissa;
    logic           a_sign_bit, b_sign_bit, y_sign_bit;
    logic [47:0]    product;

    logic           guard_bit;
    logic           round_bit;
    logic           sticky_bit;



    logic [3:0] counter;


    always_ff @(posedge clk_i or negedge rstn_i)
        begin
            if (~rstn_i)
                counter <= 0;
            else
                counter <= counter + 1;
        end

    always_ff @(posedge clk_i or negedge rstn_i)
        begin
            if(mode) begin
                case (counter)
                    3'b001: begin
                        a_sign_bit <= a_i[31];
                        b_sign_bit <= b_i[31];

                        a_exponent <= a_i[30:23];
                        b_exponent <= b_i[30:23];

                        a_mantissa <= {{1'b1},a_i[22:0]};
                        b_mantissa <= {{1'b1},b_i[22:0]};
                        end
                    
                    3'b010: begin
                        // used for defining special exponent values like denormalize, zero, infinity
                        if ((a_exponent== 0)  && (a_mantissa == 0))   // Denormlize number
                            y_exponent <= 8'b0;
                            y_mantissa <= 24'b0;
                        else if((a_exponent== 0) && (a_mantissa != 0))    // close to zero (Denormalize number)
                            y_exponent <= 8'b0;
                            y_mantissa <= 24'b0;                            
                        end

                    3'b011: begin
                        y_exponent  <= a_exponent + b_exponent - 127;
                        y_sign_bit  <= a_sign_bit ^ b_sign_bit;
                        product     <= a_mantissa * b_mantissa;

                        end
                    3'b100: begin
                            if(~product [47]) begin
                                product <= product >> 1;
                                y_exponent <= y_exponent + 1;
                            end
                            else 
                                product <= product;
                        end
                    3'b100: begin
	                    if(counter == 3'b101) begin
		                    z_m <= product[46:23];
       	                    guard_bit <= product[22];
      		                round_bit <= product[21];
      		                sticky_bit <= (product[20:0] != 0);
	end                        
                    end   
                    end 

                endcase
            end
        end
endmodule
