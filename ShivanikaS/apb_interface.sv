module apb_interface
(
 input logic Pclk,
 input logic Preset,
 input logic  Psel,
 input logic Penable,
 input logic [31:0]Paddr,
 input logic Pwrite,
 input logic[31:0]Pwdata,

 input logic busy_i,//from spi master
 input logic [7:0]data_i,//input from spi master
 
 output logic Pready,
 output logic[31:0]Prdata,
 
 //output to spi
 output logic[5:0]clk_div,
 output logic[1:0]mode,
 output logic[7:0]data_o,
 output logic write_enable,
 output logic enable_o
);

logic[7:0]control_reg;
logic[7:0]status_reg;
logic[7:0]tx_reg;
logic[7:0]rx_reg;

always_ff @(posedge Pclk or posedge Preset)

begin

if(Preset)

begin
control_reg<=8'd0;
tx_reg<=8'd0;
Prdata<=32'd0;
//Pready<=4'd0;
end

else if(Psel && Penable )begin
//Pready<=(!busy_i);


if(Pwrite)begin
   // Pready=1'b0;
    case(Paddr[3:0])
    4'h0:control_reg<=Pwdata[7:0];
    4'h8:tx_reg<=Pwdata[7:0];
    endcase
    end
    else
    begin
    case(Paddr[3:0])
    4'h0:Prdata<={24'd0,control_reg};
    4'h4:Prdata<={24'd0,status_reg};
    4'h8:Prdata<={24'd0,tx_reg};
    4'hC:Prdata<={24'd0,rx_reg};
    endcase
    end
end

//else
//Pready<=1'b0;
end

always_comb
begin

  Pready=!busy_i;
  
if(Pwrite)
 Pready=1'b0;
end

assign clk_div=control_reg[7:2];
assign mode=control_reg[1:0];

always_ff @(posedge Pclk or posedge Preset)
begin
    if(Preset)
      status_reg<=8'd0;
    else
      status_reg[0]<=busy_i;
end

always_ff @(posedge Pclk or posedge Preset)
begin
    if(Preset)
    rx_reg<=8'd0;
    else if(Penable)
    rx_reg<=data_i;
end

always_ff @(posedge Pclk or posedge Preset)
begin
    if(Preset)
      write_enable<=1'b0;
    else if(!busy_i && Pwrite && Penable && (Paddr==4'h8))
     write_enable<=1'b1;
     else
     write_enable<=1'b0;
      
end

//assign write_enable=Psel && Penable && Pwrite && (!busy_i);
assign enable_o=Psel && Penable;
assign data_o=tx_reg;

endmodule
      








