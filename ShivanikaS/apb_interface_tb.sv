module apb_interface_tb;

logic Pclk;
logic Preset;
logic Psel;
logic Penable;
logic[31:0]Paddr;
logic Pwrite;
logic[31:0]Pwdata;
logic busy_i;//from spi master
logic [7:0]data_i;//input from spi master
 
 
 logic Pready;
 logic[31:0]Prdata;
 //output to spi
 logic[5:0]clk_div;
 logic[1:0]mode;
 logic[7:0]data_o;
 logic write_enable;
 logic enable_o;

 apb_interface uut(.Pclk(Pclk),
                   .Preset(Preset),
                   .Psel(Psel),
                   .Penable(Penable),
                   .Paddr(Paddr),
                   .Pwrite(Pwrite),
                   .Pwdata(Pwdata),
                   .busy_i(busy_i),
                   .data_i(data_i),
                   .Pready(Pready),
                   .Prdata(Prdata),
                   .clk_div(clk_div),
                   .mode(mode),
                   .data_o(data_o),
                   .write_enable(write_enable),
                   .enable_o(enable_o)
                   );

initial
begin
    Pclk=1'b0;
    forever #5 Pclk=~Pclk;
end

task initialize;

Preset=1'b1;
Psel=1'b0;
Penable=1'b0;
Paddr=32'd0;
Pwrite=1'b0;
Pwdata=32'd0;
busy_i=1'b0;
data_i=8'd0;

endtask

task apb_write(input ps,input pe,input[3:0]pa,input pw,input [7:0]pwd,input busy,input [7:0]data);

begin
  
Psel=ps;
Penable=pe;
Paddr=pa;
Pwrite=pw;
Pwdata=pwd;
busy_i=busy;
data_i=data;
end

endtask

task apb_read(input ps,input pe,input[3:0]pa,input pw,input busy);
begin

Psel=ps;
Penable=pe;
Paddr=pa;
Pwrite=pw;
busy_i=busy;

end
endtask

initial
begin
initialize;
#10

Preset=1'b0;
apb_write(1'b1,1'b1,4'h0,1'b1,8'b00001000,1'b0,8'd4);
#10
apb_write(1'b1,1'b1,4'h8,1'b1,8'b00110000,1'b0,8'd65);
#10
apb_write(1'b1,1'b1,4'h0,1'b1,8'b00110011,1'b0,8'd45);
//#10
//apb_write(1'b1,1'b1,4'hC,1'b1,8'b00110011,1'b0,8'd26);
#10
apb_read(1'b1,1'b1,4'h0,1'b0,1'b0);
#10
apb_read(1'b1,1'b1,4'h4,1'b0,1'b0);
#10
apb_read(1'b1,1'b1,4'h8,1'b0,1'b0);
#10
apb_read(1'b1,1'b1,4'hC,1'b0,1'b0);
#2000
$finish;

end

initial
$monitor("Preset=%b,Psel=%b,Penable=%b,Pwrite=%b,Paddr=%b,Pwdata=%b,busy_i=%b,data_i=%b,clk_div=%b,mode=%b, Pready=%b,Prdata=%b,data_o=%b,write_enable=%b,enable_o=%b",Preset,Psel,Penable,Pwrite,Paddr,Pwdata,busy_i,data_i,
          clk_div,mode, Pready,Prdata,data_o,write_enable,enable_o);



    
endmodule







