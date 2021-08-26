module Random(value,clk,rst);
output reg [1:0]value;
input clk,rst;
reg [3:0]seedcnt;

always@(posedge clk or negedge rst)begin
if(~rst)
 seedcnt<=4'd0;
else
 seedcnt<=seedcnt+4'd1;
end
 
always@(negedge clk or negedge rst)begin
 if(~rst)
   value<=2'd0;
  else
   begin
    value[0]<=seedcnt[0]^seedcnt[2];
	 value[1]<=seedcnt[3]^seedcnt[1];
   end
end
endmodule
