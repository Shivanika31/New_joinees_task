module spi_apb_interface_tb;

 logic Pclk;
 logic Preset;
 logic  Psel;
 logic Penable;
 logic [31:0]Paddr;
 logic[31:0]Pwdata;
 logic Pwrite;
 logic Pready;
 logic[31:0]Prdata;
 

 logic cs;
 logic miso;
 logic mosi;
 logic sclk;
 //logic[7:0]shift_register;

 spi_apb_top dut (.Pclk(Pclk),
                  .Preset(Preset),
                  .Psel(Psel),
                  .Penable(Penable),
                  .Paddr(Paddr),
                  .Pwdata(Pwdata),
                  .Pwrite(Pwrite),
                  .Pready(Pready),
                  .Prdata(Prdata),
                  .cs(cs),
                  .miso(miso),
                  .mosi(mosi),
                  .sclk(sclk)
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
Pwdata=32'd0;
Pwrite=1'b0;
miso=1'b0;

endtask

task spi_config(input ps,input pe,input[7:0]pwd,input write);//control_register
begin

Psel=ps;
Penable=pe;
wait(Pready==1'b1)
@(negedge Pclk)
Paddr=4'h0;
Pwdata=pwd;
Pwrite=write;
@(negedge Pclk)
Paddr=4'h0;
Pwdata=8'd0;
Pwrite=1'b0;
end
endtask

task master_write(input ps,input pe,input [3:0]pa,input[7:0]pwd,input write);//tx register

begin

Psel=ps;
Penable=pe;

wait(Pready==1'b1)
@(negedge Pclk)
Paddr=pa;
Pwdata=pwd;
Pwrite=write;
@(negedge Pclk)
Paddr=4'h0;
Pwdata=8'd0;
Pwrite=1'b0;
end
endtask

task master_read(input ps,input pe,input[3:0]pa);//
//logic[31:0]read_data;
begin

Psel=ps;
Penable=pe;
//read_data =Prdata;
wait(Pready==1'b1)
@(negedge Pclk)
Paddr=pa;
Pwrite=1'b0;
end
endtask

/*task slave_write_mode0(input sclk,input cs,output miso);
logic[7:0]shift_register;
begin

    shift_register={$random} % 255;
    //repeat(8)
    for(int i=7;i>=0;i=i-1)
    if(cs==1'b0)
     @(negedge sclk)
     miso=shift_register[i];

     end
endtask*/

always_ff@(posedge sclk)
begin
   // repeat(8)
if(cs==1'b0)
miso=$random;
end



initial
begin
initialize;

#10
Preset=1'b0;
spi_config(1'b1,1'b1,8'b00001000,1'b1);


master_write(1'b1,1'b1,4'h8,8'd20,1'b1);

master_read(1'b1,1'b1,4'h0);
master_read(1'b1,1'b1,4'h8);


//wait(Pready==1'b1)
//mode=11,clk_divider=2
spi_config(1'b1,1'b1,8'b00010011,1'b1);

master_read(1'b1,1'b1,4'h0);

master_write(1'b1,1'b1,4'h8,8'd65,1'b1);

master_read(1'b1,1'b1,4'h8);


#5000
$finish;

end

/*initial
begin

     //shift_register={$random} % 255;
    repeat(8)
    //for(int i=7;i>=0;i=i-1)
    if(cs==1'b0)
     @(negedge sclk)
     miso<=$random;
//slave_write_mode0(.sclk(sclk),.cs(cs),.miso(miso));
end*/

initial

$monitor("Paddr=%d,Pwrite=%d,Pwdata=%d,Prdata=%d",Paddr,Pwrite,Pwdata,Prdata);
          

endmodule











 

