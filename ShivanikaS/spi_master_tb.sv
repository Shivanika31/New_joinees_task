module spi_master_tb;

logic Pclk;
logic Preset;
logic [5:0]clk_div;
logic [1:0]mode;
logic [7:0]write_data;
logic write_en;
logic enable;
logic miso;

logic [7:0]read_data;
logic cs;
logic mosi;
logic sclk;
logic pos_edge;
logic neg_edge;
logic busy;

spi_master dut(.Pclk(Pclk),
               .Preset(Preset),
               .clk_div(clk_div),
               .mode(mode),
               .write_data(write_data),
               .write_en(write_en),
               .enable(enable),
               .read_data(read_data),
               .miso(miso),
               .cs(cs),
               .mosi(mosi),
               .sclk(sclk),
               .pos_edge(pos_edge),
               .neg_edge(neg_edge),
               .busy(busy)

               );
 assign clk_div=6'd2;

    
    always #5 Pclk=~Pclk;

initial
begin
    Pclk=1'b0;
    Preset=1'b1;
    mode=2'b00;
    write_data=8'd0;
    write_en=1'b0;
    enable=1'b0;
    miso=1'b0;

    #30
    Preset=1'b0;
    mode=2'b00;
    write_data=8'd64;
    write_en=1'b1;
    enable=1'b1;
    miso=1'b1;

    #50
    wait(cs== 1'b1)
    Preset=1'b0;
    mode=2'b11;
    write_data=8'd128;
    write_en=1'b1;
    enable=1'b1;
    miso=1'b1;

    #10
    Preset=1'b0;
    mode=2'b11;
    write_data=8'd46;
    write_en=1'b1;
    enable=1'b1;
    miso=1'b1;
     #10
     Preset=1'b0;
    mode=2'b11;
    write_data=8'd67;
    write_en=1'b1;
    enable=1'b1;
    miso=1'b1;


    #3000
    $finish;
    $monitor("Preset=%d,clk_div=%d,mode=%d,write_data=%d,write_en=%d,enable=%d,miso=%d,mosi=%d,cs=%d,read_data=%d,busy=%d",
              Preset,clk_div,mode,write_data,write_en,enable,miso,mosi,cs,read_data,busy);

end

endmodule