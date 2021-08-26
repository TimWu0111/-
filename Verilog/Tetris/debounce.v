module debounce(clicked,in,clk,rst);
input in,clk,rst;
output reg clicked;
reg [7:0]decnt;
parameter bound=8'd75;

always@(posedge clk or negedge rst)begin
if(~rst)
  begin
   decnt<=0;
   clicked<=0;
  end
 else 
  begin
   if(in)
    begin
     if(decnt<bound)
	  begin
	   decnt<=decnt+1;
	   clicked<=0;
	  end
	 else 
	  begin
	   decnt<=decnt;
	   clicked<=1;
	  end
    end
  else 
   begin
    decnt<=0;
	 clicked<=0;
   end
 end
end
endmodule
