// Code your testbench here
// or browse Examples
// Code your testbench here
// or browse Examples
//section 10 
module tb;
 reg clk = 0;
 reg start = 0;
 always #5 clk =~clk;
 initial begin
   
   #20;
   start = 1;
   #60;
   start = 0;
 end
 
  
 
 /*
 default clocking ; 
   @(posedge clk ); 
 endclocking 
 */
  
//reg in hardware , 
  //in sva property or sequence block 
  // reg temp ; if i dont add any expression local variable dont play any role 
  // triggering |-> how the value of local varialbe will be updated 
  
  property p1;
    logic [1:0] count =0 ; 
   // $rose(start) |-> ## [1:$] $rose(start) ##[1:$] $rose(start) 
    //($rose(start) , count++ , $display("COUNT value is %0d from a local varialbe ", count));  
    //3 rising edges of the clock 
    
    ($rose(start) , count=1) |-> ## [1:$] ($rose(start) , count++)   ## [1:$] ($rose(start) , count++ , $display("COUNT value is %0d from a local varialbe ", count )); 
  endproperty 
  property p2;
    logic [1:0] count2 =0 ; 
    // no of clock ticks for which start is high 
    //$rose(start) |-> start[*1:$] ##1 !start ;  // start high and then start got low 
    $rose(start) |-> (start, count2++)[*1:$] ##1 (!start , $display("The value of count through the property p2 is %0d" , count2)); 
  endproperty 
  
  a1: assert property (@(posedge clk ) p1 ) $info("success at time %0t" , $time);
    a2: assert property (@(posedge clk) p2) $info("start is high for x clock cycles at the time %0t" , $time) ; 
      
initial begin
 $dumpfile("dump.vcd");
 $dumpvars;
 $assertvacuousoff(0); 
 #120;
 $finish;
end
endmodule
