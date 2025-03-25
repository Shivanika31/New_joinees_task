module spi_apb_top
(
 input logic Pclk,
 input logic Preset,
 input logic  Psel,
 input logic Penable,
 input logic [31:0]Paddr,
 input logic[31:0]Pwdata,
 input logic Pwrite,
 output logic Pready,
 output logic[31:0]Prdata,

 output logic cs,
 input logic miso,
 output logic mosi,
 output logic sclk
);

logic busy_i;
//logic [7:0]data_i;
//logic[7:0]data_o;
//logic write_enable, enable_o;
 logic [5:0]clk_div;
 logic [1:0]mode;


 logic [7:0] write_data;
 logic write_en;
 logic[7:0] read_data;
 logic enable;
 logic pos_edge;
 logic neg_edge;
 //logic busy;


spi_master spi( .Pclk(Pclk),
                .Preset(Preset),
                .clk_div(clk_div),
                .mode(mode),
                .write_data(write_data),
                .write_en(write_en),
                .enable(enable),
                .read_data(read_data),
                .cs(cs),
                .mosi(mosi),
                .miso(miso),
                .sclk(sclk),
                .pos_edge(pos_edge),
                .neg_edge(neg_edge),
                .busy(busy_i)
               );

apb_interface apb(  .Pclk(Pclk),
                    .Preset(Preset),
                    .Psel(Psel),
                    .Penable(Penable),
                    .Pwrite(Pwrite),
                    .Paddr(Paddr),
                    .Pwdata(Pwdata),
                    .Pready(Pready),
                    .Prdata(Prdata),
                    .data_i(read_data),
                    .busy_i(busy_i),
                    .clk_div(clk_div),
                    .mode(mode),
                    .data_o(write_data),
                    .write_enable(write_en),
                    .enable_o(enable)
                  );

endmodule
