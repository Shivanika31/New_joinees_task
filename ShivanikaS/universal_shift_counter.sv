module universal_shift_counter
#(parameter N=8)
(input logic clk,rst,sync_clear,load,pause,en,up,
 input logic[N-1:0]d,
 output logic[N-1:0]q
);

always_ff @(posedge clk or posedge rst)begin
if(rst)
q<='0;
else if(sync_clear)
q<='0;
else if(load)
q<=d;
else if(pause)
q<=q;
else if(en)
begin
if(up)
q<=q+1'b1;
else
q<=q-1'b1;
end
end

endmodule