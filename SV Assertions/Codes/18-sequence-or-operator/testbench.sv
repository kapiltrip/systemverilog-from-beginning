// Code your testbench here
// or browse Examples
// boolean operator and throughout operator adn within operator 
// 3 boolean operator and or not 
// if both sequence behave same throughout the simulation 
// and or(smallest sequence become true ) not 
// if start asserted then both a and b should remain high for two consecutive clock ticks 
// b becomes high in the next clock tick after a become high 
module tb;
 reg clk = 0,a,b,start,done;
 
 always #5 clk = ~clk;
 
 initial begin
 start = 0;
 #20;
 start = 1;
 #10;
 start = 0;
 end
 
 initial begin
 done = 0;
 #60;
 done = 1;
 #10;
 done = 0;
 end
 
 
 
 
 initial begin
 a = 0;
 #30;
 a = 1;
 #20;
 a = 0;
 end
 
 initial begin
 b = 0;
 #40;
 b = 1;
 #20;
 b = 0;
 end

sequence s1;
  a[*2];
endsequence
  sequence s2;
    ##1 b[*2]; 
  endsequence
  assert property (@(posedge clk) $rose(start) |-> s1 or s2 ) $info("sequence behaves the same at time %0t", $time ) ; 
    
 initial begin
 #100;
 $finish;
 end

 
endmodule
