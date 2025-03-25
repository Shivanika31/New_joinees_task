module spi_master
(input logic Pclk,
 input logic Preset,
 input logic [5:0]clk_div,
 input logic [1:0]mode,

 //APB INTERFACE
 input logic [7:0] write_data,
 input logic write_en,
 output logic[7:0] read_data,
 input logic enable,
 
 
 //SPI INTERFACE
 output logic cs,
 input logic miso,
 output logic mosi,
 output logic sclk,

 output logic pos_edge,
 output logic neg_edge,
 output logic busy
 
);

logic[5:0] clk_counter;
logic sig_delay;
logic[7:0] count_reg;
logic[7:0]shift_register;
logic sclk_;

typedef enum{IDLE,SHIFT,DONE}state_t;
state_t state,state_next;

always_ff @(posedge Pclk or posedge Preset) begin

if(Preset)
begin
clk_counter<=6'b000000;
//sclk_<=1'b0;
end
else if(enable)
	begin
      if (clk_counter>=(clk_div-1'b1))
       begin
       clk_counter<=0;
	//sclk_ <= (clk_counter < clk_div/2)? 1'b1: 1'b0;
        end
       else
       begin
	//sclk_ <= (clk_counter < clk_div/2)? 1'b1: 1'b0;
       clk_counter<=clk_counter+1;
       end
	end
else
begin
       clk_counter<=0;
	//sclk_<=1'b0;
       end

end

assign sclk_ = (clk_counter < clk_div/2)? 1'b1: 1'b0;//50 percent duty cycle
//assign sclk = (cs == 1'b0)? sclk_ : 1'b0;

// posedge and negedge detection block
always_ff @(posedge Pclk or posedge Preset)

begin
if(Preset)
sig_delay<=1'b0;
else
sig_delay<=sclk_;
end

assign pos_edge= ~sig_delay & sclk_;
assign neg_edge= sig_delay & ~sclk_;

/*always_ff @(posedge Pclk or posedge Preset)

begin
if(Preset)
sig_delay<=1'b0;
else
sig_delay<=sclk;
end*/



//fsm for writing and reading data

always_ff @(posedge Pclk or posedge Preset)
begin
if(Preset)
state<=IDLE;
//else if(cs ==1'b1)
//state<=IDLE;
else
state<=state_next;
end

always_comb begin

state_next=IDLE;
case(state)
IDLE:begin
     if(enable && write_en)
     state_next =SHIFT;
     end
SHIFT:begin
      if(count_reg == 8'd8)
      state_next =DONE;
      else
      state_next=state;
      end
DONE:begin
     state_next =IDLE;
     end
endcase

end

always_ff @(posedge Pclk or posedge Preset)

begin
case(state)
IDLE:begin
     cs<=1'b1;
     sclk <= 1'b0;
     mosi<=1'b0;
     busy<=1'b0;
     count_reg<=8'd0;
     if(enable && write_en)
     begin
     shift_register<=write_data;
     busy<=1'b1;
     end
     end
SHIFT:begin
       sclk <= 1'b0;
      case(mode)// mode 0 cpol 0,cpha 0

      2'b00:begin
              if(enable)
               begin
          
                 if(neg_edge)//sending data at negedge of sclk
                 begin
                 busy<=1'b1;
                 cs<=1'b0;
                 sclk <= sclk_;
                 mosi<=shift_register[7];
                 shift_register<={shift_register[6:0],1'b0};
                 count_reg<=count_reg+1;
                 end
               end

                if(pos_edge)//sampling data at posedge of sclk
                begin
                busy<=1'b1;
                cs<=1'b0;
                sclk <= sclk_;
                read_data<={read_data[6:0],miso};
                end
            end
        2'b11:begin
              if(enable)
               begin
                if(pos_edge)
                 begin
                 busy<=1'b1;
                 sclk <= sclk_;
                 cs<=1'b0;
                 mosi<=shift_register[7];
                shift_register<={shift_register[6:0],1'b0};
                count_reg<=count_reg+1;
                end
              end
                if(neg_edge)
                begin
                busy<=1'b1;
                sclk <= sclk_;
                cs<=1'b0;
                read_data<={read_data[6:0],miso};
                end
              end
       default:begin
              
	     //  cs<=1'b0;
             //  mosi<=1'b0;
             //  shift_register<=8'd0;
             //  count_reg<=8'd0;
             //  busy<=1'b0;
              end
     endcase
   end
DONE:begin
     read_data<=shift_register;
     cs<=1'b1;
     busy<=1'b0;
     sclk <= 1'b0;
     end
endcase
end

endmodule
                
              


