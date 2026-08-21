// Code your testbench here
// or browse Examples
// next time certain behaviour to hold 
// reset should be high after 5 clk tick 
module tb;
  
    
  reg clk = 0, rst = 0;
  always #5 clk = ~clk;
  
  
   initial begin
     repeat(5) @(posedge clk);
     rst = 1;
  end
  
  
  initial a1: assert property (@(posedge clk ) nexttime[5] rst ) $info("reset is high at posedge  after 5 clock tick at time %0t" ,$time ) ; 
    a2: assert property (@(negedge  clk ) nexttime[5] rst ) $info("reset is high at negedge after 5 clock tick at time %0t" ,$time ) ; 
    a3: assert property (@(posedge clk ) s_nexttime[5] rst ) $info("reset is high after 5 clock tick at time %0t" ,$time ) ; 
    a4: assert property (@(negedge  clk ) s_nexttime[5] rst ) $info("reset is high after 5 clock tick at time %0t" ,$time ) ; 
  
  initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars;
    $assertvacuousoff(0);
    #100;
    $finish();
  end 

  
endmodule
