// Code your testbench here
// or browse Examples
//Simulation - > fixed (time) , variable (realtime)
`timescale 1ns/1ps
/*

module tb; 
  bit a = 0 ; 
  byte b=0;
  shortint c = 0 ; 
  int d =0 ; // 32 bit integer 
  longint e = 0 ; 
  bit [7:0] f = 8'b00000000;
  bit [15:0] g = 16'h0000;
  //since 4 hex digits 
  real h= 0;  // 64 bit 
  
  
  byte 
  initial begin
    a = 1'b1; 
    
  end
  // 2 state and signed type 
  //2 state initial value = 0 ; 
  //4 state initial value will be x
endmodule
*/
module tb ; 
  /*
  byte varr = -126; // -128 to + 127
  initial begin
      #10; 
    $display("Value of varr %0d" , varr );
  end 
  shortint var2 =0; 
  */ 
  time fix_time =0;        //$time
  realtime real_time =0;    //$realtime current simulation time in floating point format
  initial begin
      #12.23;
    fix_time = $time(); 
    $display ("current simulation time is %0t" , fix_time);
    real_time = $realtime(); 
    $display ("current simulation time is %0t" , real_time);    
  end
  
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars();
  end
endmodule
/*
module mux(
    input wire a,b,
    input wire sel, 
    output reg y //cant use wire here 
);
  always @(*)begin
    if(sel)
      y= b;
    else 
      y=a; 
    
  end  
endmodule
*/
/*
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.08.2026 19:08:33
// Design Name: 
// Module Name: ha
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module ha (
    input wire a,b,
    output wire cout,sum
);
  assign sum = a ^b ; 
  assign cout = a & b ; 
  
endmodule
module fa(
    input a,b,cin, 
    output wire cout,sum
);
reg f,g,h; // here, reg cant be allowed in the output of ha1 
ha ha1(
   .a(a),
   .b(b),
   .sum(f),
   .cout(g)
);
ha ha2(
   .a(cin),
   .b(f),
   .sum(sum),
   .cout(h)
);
assign cout = g|h ; 

endmodule
*/
//to verify the reg and putting logic inprefix to the wires, 

