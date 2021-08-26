module FSM(Down,Left,Right,Spin,clk,rst,value,print,address,score);
input clk,rst;
input Down;
input Left;
input Right;
input Spin;
input [1:0]value;
output [7:0]print;
output reg[3:0]address;
output reg[3:0]score;
reg [3:0]state;
reg [3:0]count;
reg [7:0]delay;
reg [7:0]speed;
reg [7:0]stoptemp[16:0];
reg [7:0]movetemp[16:0];
reg [3:0]tempck;
reg [3:0]tempmv;
integer i;
parameter init=4'd0,start=4'd1,left=4'd2,right=4'd3,down=4'd4,spin=4'd5,bottom=4'd6,check=4'd7,move=4'd8;
assign print=(movetemp[address]|stoptemp[address]);
//------------------meely-----------------------//
always @(posedge clk or negedge rst)
begin
 if(~rst)
  begin
   state<=init;
	address<=4'd0;
  end
 else begin
   case(state)		
	 init:
	  begin
	  if(address == 4'd15)begin
	  	  if(tempmv>4'd2)
		    state<=move;
		 else begin
		    state<=start;
	       address<=0;
		 end
		end
		else begin
	    address<=address+1;
		end
	  end
	  
	 start:
	  begin
	  if(address == 4'd15)begin
	    if(Left==1 && (movetemp[count+1]&8'b10000000)!=8'b10000000)
		   state<=left;
		 else if(Right==1 && (movetemp[count+1]&8'b00000001)!=8'b00000001)
		   state<=right;	  
		 else if(Down==1)
		   state<=down;
		 else if(Spin==1)
		   state<=spin;
		 else if(((movetemp[count+1]&stoptemp[count+2])!=8'd0)) //&& ((movetemp[count+1]&stoptemp[count+3])!=8'd0))/*|| (count==14)*/
		   state<=bottom;
		 else begin
		   state<=state;
		   address<=0;
		 end
		end
	  else begin
	  address<=address+1;
	   end
	 end
	  
	  left:
	  begin
	   if(address == 4'd15)begin
		  state<=start;
		  address<=0; 
		  end
	   else begin
		  address<=address+1;
		end
	  end
	  
	  right:
	  begin
	    if(address == 4'd15)begin
	      state<=start;
		   address<=0;
		 end
	    else begin
		   address<=address+1;
		end
	  end
 
     down:
      begin
	    if(address == 4'd15)begin
	      state<=start;
		   address<=0;
		 end
	    else begin
		   address<=address+1;
		end
	  end	  
	 
	 bottom:
	 begin
	    if(address == 4'd15)begin
	      state<=check;
		   address<=0;
		 end
	    else begin
		   address<=address+1;
		end
	  end	  

   check:
	 begin
	    if(address == 4'd15)begin
		  if(tempck<4'd15)
	       state<=check;
		   else 
		    begin
		     state<=init;
		     address<=0;
		    end
		 end
	    else begin
		   address<=address+1;
		end
	  end
	  
   move:
	begin
	    if(address == 4'd15)begin
		  if(tempmv>4'd2)
		   begin
			 state<=move;
			end
			else begin
	       state<=start;
		    address<=0;
			end
		 end
	    else begin
		   address<=address+1;
		end
	  end	  
	  
   endcase	
 end
end
//-----------------mooore----------------------//
always @(posedge clk or negedge rst)
begin
 if(~rst)
  begin
   count<=4'd0;
	delay<=8'd0;
	speed<=8'd255;
   stoptemp[16]<=8'b11111111;
	tempck<=4'd0;
	tempmv<=4'd0;
	score<=4'd0;
   for(i=0;i<16;i=i+1)
	begin
    movetemp[i]<=8'd0;
	 stoptemp[i]<=8'd0;
	end
  end
 else 
  begin
	case(state)
	init:
	 begin
	   speed<=8'd255;
		//temp<=4'd0;
	   case(value)
        2'd0:
         begin
          movetemp[count]  <=8'b00011000;
          movetemp[count+1]<=8'b00011000;
         end
        2'd1:
         begin
          movetemp[count]  <=8'b00000000;
          movetemp[count+1]<=8'b00111100;
         end
        2'd2:
         begin
          movetemp[count]  <=8'b00000100;
          movetemp[count+1]<=8'b00011100;
         end
       2'd3:
         begin
          movetemp[count]  <=8'b00010000;
          movetemp[count+1]<=8'b00111000;
         end 
     endcase
	 end
	
	start:
	 begin
		if(delay==speed)begin
		 count<=count+1;
		 delay<=0;
		 movetemp[count]<=8'd0;
		 movetemp[count+1]<=movetemp[count];
		 movetemp[count+2]<=movetemp[count+1];
		end
		else
		 delay<=delay+1;
	 end
  
  	left:
	 begin
	   movetemp[count]  <=(movetemp[count]<<1);
		movetemp[count+1]<=(movetemp[count+1]<<1);
	 end
	 
	 right:
	 begin
	   movetemp[count]  <=(movetemp[count]>>1);
		movetemp[count+1]<=(movetemp[count+1]>>1);
	 end
	 
	down:
	 begin
     speed<=8'd64;
	 end
	 
	bottom:
	begin
	 for(i=2;i<16;i=i+1)
	  begin
	   stoptemp[i]<=(movetemp[i]|stoptemp[i]);
	   movetemp[i]<=8'd0;
	  end
	 count<=4'd0;
   end
	
	check:
	begin
	  tempck<=tempck+1;
	  if(stoptemp[tempck]==8'hFF)
	   begin
	      stoptemp[tempck]<=8'd0;
			tempmv<=tempck;
			 score<=score+1;
	   end
 	end
	
	move:
	 begin
      stoptemp[tempmv]<=stoptemp[tempmv-1];
	   tempmv<=tempmv-1;
	end
	
  endcase
  end
  
end

endmodule
