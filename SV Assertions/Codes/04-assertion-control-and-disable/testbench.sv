// Code your testbench here
// or browse Examples
module tb;
  reg a; 
  reg rst; 
  initial begin
    $assertoff(); // to turn off an assertion check 
    a =0 ; 
    #59;
    $asserton(); 
    a=1;
  end
  always @(*) begin
    a1: assert #0 (a==1) $info("success at time %0t " , $time ); else $error("Failure at time %0t" , $time);
    if(rst == 1'b1) 
      disable a1; // only for deferred immediate assertion or use if else block in immediate assertion 
  end
    initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars; 
    #300; 
    $finish; 
    
  end
endmodule
