/*
until non overlapping 
until with overlapping should have a common behaviour 
*/
/*
signal 1 should remain high  true until we have sig 2 becoming true 
rst goes dowm 
ce goes high 
$fell(sig1) |-> $rose(sig2) vs sig1 until sig2
in this implication will give us truw and until will give us false 
idk the use of until how tis different its just seem like implication with delay can mimic until 
signal 1 remains high till signal 2 becomes high 
and if they are common for 1 clock tick we can call it overlapping 
signal 1 remains high until signal 2 reaches to its specified value 
  what is theuse of until im wondering 
  */
module tb;
  
  reg clk = 0, rst = 0, ce = 0;
  always #5 clk = ~clk;
  
  
  initial begin
    rst = 1;
    #30;
    rst = 1;
    #10;
    ce = 0;
    rst = 1;
    #10;
    rst = 0;
    #50;
    ce = 0;
  end
  
  
  
  
  initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars;
    $assertvacuousoff(0);
    #100;
    $finish();
  end
  
  initial A1: assert property (@(posedge clk) rst s_until ce) $info("Success at %0t",$time);

endmodule
    

