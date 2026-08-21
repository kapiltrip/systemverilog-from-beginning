// Code your testbench here
// or browse Examples
//eventually and seventually 
//property occured during simulation 
// seventually ce; somewhere during the simulation we r ecpecting that, ce goes high the we will get the failure 
//eventually ce 
/*
ce asserted eventually 
rst must go down within 3 to 10 clock ticks 
ce assert eventually and then stay high 
rst deasserted eventually and stay low 
eventually we must know a range 
  eventually [min: max]
  seventually with and without a range (must hold within)
  // strong vs weak property 
  if 5 clock ticks 
    eventually [3:10] ce; 
    only once it may trigger so we need initial block  initial seventually and always 
*/
module tb;
  
    
  reg clk = 0, rst = 1,  ce = 0;
  always #5 clk = ~clk;
  
  
  initial begin
    #20;
    rst = 1;
  #40;
    rst = 0;
    ce = 1;
    #50;
    rst = 0;
    #10;
    ce = 0;
    
    
  end
  // do not have a range use seventually 
  initial a1:  assert property (@(posedge clk ) s_eventually !rst ) $into("success at %0t" , $time); 
  // reset become low eventually and stayed low 
  initial a2:  assert property (@(posedge clk ) s_eventually always  !rst ) $into("success at %0t" , $time); 
  // reset must go down withing 3to 10 clock ticks 
  initial a3:  assert property (@(posedge clk ) eventually [3:10] !rst ) $into("success at %0t" , $time); 
  
  initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars;
    $assertvacuousoff(0);
    #120;
    $finish();
  end 
 

endmodule
