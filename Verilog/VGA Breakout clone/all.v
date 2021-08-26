`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:34:45 12/27/2013 
// Design Name: 
// Module Name:    all 
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
module all(clk,rst,swL,swR,R,G,B,H,V,start);
input rst;
input swR;
input swL;
input clk;
input start;
output R,G,B,H,V;
wire [3:0]count;
wire [9:0]x;
wire [9:0]y;
wire go;
wire [12:0]brick;

final f1(clk,rst,swR,swL,x,y,start,count,go,brick,finish);
test t1(R,G,B,clk,H,V,rst,count,x,y,go,brick,finish);


endmodule
