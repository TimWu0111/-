`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:16:26 12/12/2013 
// Design Name: 
// Module Name:    vga 
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
module vga(Rout,Gout,Bout,V,H,row,column,clk,red,blue,green);
input  red;input  green;
input  blue;
input clk;output reg Rout,Gout,Bout;
output reg[10:0]row;
output reg[10:0]column;
output reg H,V;
parameter B=11'd128,C=11'd40,D=11'd800,E=11'd88;
parameter P=11'd4,Q=11'd1,R=11'd600,S=11'd23;
parameter A=B+C+D+E;
parameter O=P+Q+R+S;
reg [10:0]vertical;
reg [10:0]horizontal;
  
always@(posedge clk)
begin
  Rout<=red;
  Gout<=green;
  Bout<=blue;
      if  (horizontal < (A - 1))  
        horizontal <= horizontal + 11'd1;
      else
	begin
        	horizontal <= 11'd0;
         	if (vertical < (O - 1))   // less than oh
           		vertical <= vertical + 11'd1;
         	else
          		vertical <= 11'd0;       // is set to zero
        end 

  // define H pulse
      if  (horizontal >= (D + E) && horizontal < (D + E + B))  
        H <= 1'b0;
      else
        H <= 1'b1;

  // define V pulse
      if  (vertical >= (R + S) && vertical < (R + S + P))
        V <= 1'b0;
      else
        V <= 1'b1;

    // mapping of the variable to the signals
    // negative signs are because the conversion bits are reversed
    row <= vertical;
    column <= horizontal;
end
endmodule


module test(R,G,B,clk,H,V,rst,count,x,y,go,brick,finish);	
output H,V,R,G,B;
input clk,rst;
input [12:0]brick;
input [9:0]x;
input [9:0]y;
input [3:0]count;
input go;
input finish;
wire V,H;
wire [10:0]row;
wire [10:0]column;
wire R,G,B;
reg red;reg green;
reg blue;
reg [25:0]divclk;
reg [3:0]temp;


vga v1(R,G,B,V,H,row,column,clk,red,blue,green);

always@(row or column)
begin
	if(~rst)
		begin
			if(row > 0 && row < 600 && column > 0 && column < 800)   
			 begin
			   	blue   <= 1;
				red    <= 1;
				green  <= 1;
			 end
			else
			 begin
				blue   <= 0;
				red    <= 0;
				green  <= 0;
			 end
	   	end
		
	else

		begin
		  //------------board---------------//
			if(row > 575 && row < 600 && column > (count*50) && column < ((count*50)+200))  
				green <= 1;
			else
				green <= 0;
			//---------------brick------------//	
			if(
			   	(row >0 && row < 40 && column > 0   && column < 70  &&  (brick[0]==1))   ||
			        (row >0 && row < 40 && column > 70  && column < 130 &&  (brick[1]==1))   ||
				(row >0 && row < 40 && column > 130  && column < 190 && (brick[2]==1))   ||
				(row >0 && row < 40 && column > 190 && column < 250 &&  (brick[3]==1))   ||
				(row >0 && row < 40 && column > 250 && column < 310 &&  (brick[4]==1))   ||
				(row >0 && row < 40 && column > 310 && column < 370 &&  (brick[5]==1))   ||
				(row >0 && row < 40 && column > 370 && column < 430 &&  (brick[6]==1))   ||
				(row >0 && row < 40 && column > 430 && column < 490 &&  (brick[7]==1))   ||
				(row >0 && row < 40 && column > 490 && column < 550 &&  (brick[8]==1))   ||
			   	(row >0 && row < 40 && column > 550 && column < 610 &&  (brick[9]==1))   ||
				(row >0 && row < 40 && column > 610 && column < 670 &&  (brick[10]==1))  ||
				(row >0 && row < 40 && column > 670 && column < 730 &&  (brick[11]==1))  ||
				(row >0 && row < 40 && column > 730 && column < 800 &&  (brick[12]==1))    
			   )
           			blue <= 1;
			 else
           			blue <= 0;	

		  //--------ball--------------//	
          		if(go==1)
          		   begin	
			   	if((row > y-30  && row < y && column > x-30 && column < x) ||                      //ball move
				   (row > 575 && row < 600 && column > (count*50+70) && column < (count*50+130))   //center color of board
				  )
					red <= 1;
			        else
				   red <= 0;
					
			  end
			  
		       else
			 
			  begin
			  
				if((row > 545 && row < 575 && column > (count*50+85) && column < (count*50+115)) || 
				   (row > 575 && row < 600 && column > (count*50+70) && column < (count*50+130))) 
				  red  <= 1;
				else
				  red  <= 0; 
				 
		    	 end
			//---------µ²§ô-----------/
			 if(finish==1)
			 begin
			  if(row > 0 && row < 200)  
				green <= 1;
			  else
				green <= 0;
				
			  if(row > 200 && row < 400)  
				blue <= 1;
			  else
				blue <= 0;
				
			  if(row > 400 && row < 600)  
				red <= 1;
			  else
				red <= 0;
			 end
	  end

end

endmodule

