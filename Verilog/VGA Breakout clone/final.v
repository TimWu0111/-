`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:33:14 12/27/2013 
// Design Name: 
// Module Name:    final 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module final(clk,rst,R,L,x,y,start,count,go,brick,finish);
output reg[9:0]x;
output reg[9:0]y;
output reg[3:0]count;
output reg [12:0]brick;
output reg finish; 
output reg go;
input clk,rst;
input R,L;
input start;
reg [25:0]divclk;
reg [3:0]state;
wire flag;
reg temp;
assign flag=temp;
parameter init=4'd0,straight=4'd1,slashL=4'd2,slashR=4'd3,back=4'd4,slashRdown=4'd5,slashLdown=4'd6,over=4'd7;

//--------------------------------
always@(posedge clk or negedge rst)
begin
 if(~rst)
  divclk<=26'd0;  
 else 
  divclk<=divclk+1;               
end

//---------------FSM------------------//
always@(posedge clk or negedge rst)
begin
 if(~rst)
   begin 
      state<=init;
   end
 else
  begin
  
   case(state) 
	
	 init:
	 begin
	 if(start==0)
	  state<=straight;
	 else
	    state<=state;
	 end
	 
	 straight:
	  begin
      		if(y<55)
		begin
		   temp<=1;
		   state<=back;
		end
	  end
	  
	 back:
      	   begin
		 temp<=0;
		 if      (y>575 && (count*50+70) <   (x-15)  && (x-15) < (count*50+130))        state<=straight;   //yellow
		 else if (y>575 && (count*50)    <=  (x-15)  && (x-15) <= (count*50+70))         state<=slashL;    //Lgreen
		 else if (y>575 && (count*50+130)<=  (x-15)  && (x-15) <= (count*50+200))        state<=slashR;    //Rgreen
		 else if (y>600) state<=over;             //miss
	   end
		
	 slashR:
	   begin
		if(y<55 && (x)<800)                       //normal
		 begin
		  state<=slashRdown;
		  temp<=1;
		 end 
		else if(x>800)                             //wall
		 state<=slashL;
		else if(x==800 && (y+30)==0)               //upper-right
		 state<=slashLdown;
		end
		
	 slashL:
	   begin
		if(y<55 && (x-30)>0)                      //normal
		 begin
		   state<=slashLdown;
			temp<=1;
		 end
		else if((x-30)<5)                         //wall
		 state<=slashR;
		else if((x-30)==0 && (y+30)==0)            //upper-left
		 state<=slashRdown;
		end
		
	 slashLdown:
	   begin
		 temp<=0;
		 if((x-30)<5)state<=slashRdown;         //wall
		 else if (y>575)
		  state<=back;
		 else if (y>595)                        //miss
		  state<=over;
		end
		
	 slashRdown:
	   begin
		temp<=0;
		 if(x>800)state<=slashLdown;           //wall
		 else if (y>575)
		  state<=back;
		 else if (y>595)                       //miss
		  state<=over;
		end
	 
	 over:
	  begin
	   state<=init;
		
	  end
		
	 endcase
  end
end
//-------------------------------------------//
always@(posedge divclk[17] or negedge rst)
begin
	if(~rst)
		begin
		 go<=0;
		 x<=0;
		 
		end
	else
		begin
		case(state)	
			 
			init:
          		  begin
           			x<=((count*50)+115); // ball column
	        		y<=575;
	       		  end		
			
			straight:
			  begin
				go<=1;              //start
		      		y<=y-3;            //up
			  end  
				
			back:
			  begin
				 y<=y+3;           //down
			  end
			
			slashR:
			  begin
			        x<=x+1;
				y<=y-3;
			  end
			
			slashL:
			   begin
			       x<=x-1;
			       y<=y-3;
				  
			   end
				 
			slashLdown:
			  begin
			       x<=x-1;
			       y<=y+3;
			  end
			  
			slashRdown:
			  begin
				x<=x+1;
				y<=y+3;
			  end

		endcase
		end 
end
//------------block disappear----------///
always@(posedge flag or negedge rst)
if(~rst)begin brick<=13'b1111111111111; finish<=0; end
else
	begin    
	if(0<(x-15) && (x-15)<=70)
	  begin
		 brick[0]<=0;
	  end
						
	else if(70<(x-15) && (x-15)<=130)
	   begin
  		 brick[1]<=0;
	   end
						
	else if(130<(x-15) && (x-15)<=190)
	   begin
		 brick[2]<=0;
		end
		
	else if(190<(x-15) && (x-15)<=250)
	   begin
		 brick[3]<=0;
		end	
		
	else if(250<(x-15) && (x-15)<=310)
	   begin
		 brick[4]<=0;
		end
		
	else if(310<(x-15) && (x-15)<=370)
	   begin
		 brick[5]<=0;
		end
		
	else if(370<(x-15) && (x-15)<=430)
	   begin
		 brick[6]<=0;
		end
	
	else if(430<(x-15) && (x-15)<=490)
	   begin
		 brick[7]<=0;
		end
		
	else if(490<(x-15) && (x-15)<=550)
	   begin
		 brick[8]<=0;
		end
		
	else if(550<(x-15) && (x-15)<=610)
	   begin
		 brick[9]<=0;
		end
		
	else if(610<(x-15) && (x-15)<=670)
	   begin
		 brick[10]<=0;
		end
		
	else if(670<(x-15) && (x-15)<=730)
	   begin
		 brick[11]<=0;
		end
		
	else if(730<(x-15) && (x-15)<=800)
	   begin
		 brick[12]<=0;
		end
	if(brick==13'd0)
	 finish<=1;
	
end
//-------------board move---------------//
always@(posedge divclk[21] or negedge rst)
begin
 if(~rst)count<=6;
 else
  begin
   if(R==0)
      begin
	  if(count>11)count<=12;
	  else
	   count<=count+1; 
      end 
    else if(L==0)
      begin
	  if(count<1) count<=0;
	  else
	   count<=count-1;
      end
  
  end
end
endmodule
