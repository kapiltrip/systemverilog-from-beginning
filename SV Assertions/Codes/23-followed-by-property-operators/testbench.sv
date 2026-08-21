// Code your testbench here
// or browse Examples
//follow by operator 
//#-# and #=# antecedant true then evaluate to true , also it doesnt give a vacuous success 
module tb;
  
  reg clk = 0, rst = 0, ce = 0;
  always #5 clk = ~clk;
  
  
  initial begin
    rst = 0;
    #20;
    ce = 1;
    rst = 0;
    #20;
    ce = 0;
  end
  
  
  
  
  initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars;
   // $assertvacuousoff(0);
    #50;
    $finish();
  end
  
  initial A1 : assert property (@(posedge clk) rst[*2] |-> ##1 ce[*2]) $info("A1 Suc at %0t",$time); 
  
  initial A2 : assert property (@(posedge clk) rst[*2] |=> ce[*2]) $info("A2 Suc at %0t",$time);  
 
    initial A3 : assert property (@(posedge clk) rst[*2] #=# ce[*2])$info("A3 Suc at %0t",$time);  //overlapping operator 
  
  initial A4 : assert property (@(posedge clk) rst[*2] #-# ##1 ce[*2])$info("A4 Suc at %0t",$time); 
    
    
endmodule
