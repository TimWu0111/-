`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:51:15 06/04/2014 
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
module final(clk,rst,Down,Left,Right,Spin,row,column,column1,a,b,c,d,e,f,g,c0);
input clk,rst;
input Down;
input Left;
input Right;
input Spin;
output [7:0]column;
output [7:0]column1;
output [15:0]row;
output a,b,c,d,e,f,g,c0;
//reg [25:0]divclk;
wire [1:0]value;
wire [7:0]print;
wire [3:0]address;
wire [3:0]intemp;
Random   R1(value,clk,rst);
debounce D1(deLeft,Left,clk,rst);
debounce D2(deRight,Right,clk,rst);
debounce D3(deDown,Down,clk,rst);
FSM      F1(deDown,deLeft,deRight,Spin,clk,rst,value,print,address,intemp);
matrix   M1(row,column,rst,clk,print,address,column1);
seg7     S1(a,b,c,d,e,f,g,c0,intemp);


endmodule

