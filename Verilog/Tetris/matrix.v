module matrix(row,column,rst,clk,print,address,column1);
output reg[7:0]column;
output [7:0]column1;
output reg [15:0]row;
input rst,clk;
input [7:0]print;
input [3:0]address;
reg [7:0]mem[15:0];
integer i;
assign column1=column;
reg [25:0]divclk;

always@(posedge clk or negedge rst)
begin
 if(~rst)
  divclk<=26'd0;  
 else 
  divclk<=divclk+1;               
end

always@(posedge clk or negedge rst)begin
	if(~rst)
	 begin
	  for(i=0;i<16;i=i+1)
       mem[i]<=8'd0;
	 end
	else 
		mem[address]<=print;
end

always@(posedge clk or negedge rst)begin
	if(~rst)
	  row<=16'd1;
	else 
	   row<={row[14:0],row[15]};
end
	
always@(row)begin
  case(row)
  16'd1:    column<=mem[0];
  16'd2:    column<=mem[1];
  16'd4:    column<=mem[2];
  16'd8:    column<=mem[3];
  16'd16:   column<=mem[4];
  16'd32:   column<=mem[5];
  16'd64:   column<=mem[6];
  16'd128:  column<=mem[7];
  16'd256:  column<=mem[8];
  16'd512:  column<=mem[9];
  16'd1024: column<=mem[10];
  16'd2048: column<=mem[11];
  16'd4096: column<=mem[12];
  16'd8192: column<=mem[13];
  16'd16384:column<=mem[14];
  16'd32768:column<=mem[15];
  default:column<=8'd0;
  endcase
end
endmodule
