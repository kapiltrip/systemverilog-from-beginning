// Code your testbench here
// or browse Examples
module tb;
 
 reg clk = 0;
 
 reg req = 0;
 reg ack = 0;
 
 always #5 clk = ~clk;
 
 initial begin
 #2;
 req = 1;
 #5;
 req = 0;
 end
 
 initial begin
 #120;
 ack = 0;
 #10;
 ack = 0;
 
 end
  a1: assert property (@(posedge clk) $rose(req) |-> strong( ##[1:$] $rose(ack))) $info("success at %0t", $time); 
    else $error("cant find any ack in the total time "); 
    //unbounded delay is weak in nature so simulater will not say anything , related to that 
    
 initial begin 
 $dumpfile("dump.vcd");
 $dumpvars;
 $assertvacuousoff(0);
 #140;
 $finish();
 end
 
endmodule
