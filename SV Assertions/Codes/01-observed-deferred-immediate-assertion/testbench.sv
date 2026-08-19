// Code your testbench here
// or browse Examples
//assertions working on non temporal domain 
// assertions working on temporal domain 
//OBSERVED / FINAL DEFFERED ASSERTIONS 
// HOW THEY ARE ABLE TO REMOVE GLITCHES, WRT THE VARIOUS REGIONS 

module tb;
  reg am=0;
  reg bm=0; 
  wire a,b; 
  assign a= am;  //active region 
  assign b=bm;
  initial begin
    am=1;
    bm=1;
    #10;
    am=0;
    bm=1;
    #10;
    am=1;
    bm=0;
    #10;
  end
  always_comb begin
    a1: assert #0 (a==b) $info("a and b are equal at %0t" , $time) ; 
    else $info("assertion failed at time %0t" , $time);
  end
endmodule 
