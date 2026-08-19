// Code your testbench here
// or browse Examples
// system task 
// $info reactive region 
// $sample preoponed value 
// $rose positive edge 2 clock tick available then it will tell 1 otherwise 0 
// in case of 1 clock tick , default values are considered default i.e x to 1 or 0 to 1 in reg or z to 1 or 0 to 1 in wire 
module tb;
  reg a =1; 
  reg clk = 0 ; 
  always #5 clk = ~ clk ; 
  always #5 a = ~a ; 
  always @(posedge clk) begin
    $info("Value of a is %0b in reactive region and $sampled(a) in preponed region is " , a, $sampled(a));  // monitor strobe  from a reactive region 
    
  end                                                                 ///sampled will tell preopned region value
  assert property (@(posedge clk) (a == $sampled(a))) $info("Sampled time is %0t with a value preopned region val  %0b" , $time , $sampled(a)); 
    
    initial begin
      $dumpfile("dump.vcd");
      $dumpvars; 
      $assertvacuousoff(0); // to filter vacuous success
      //repeat (20) @(posedge clk) ; 
      #50;
      $finish();
    end
endmodule
