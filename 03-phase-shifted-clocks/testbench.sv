// Code your testbench here
// or browse Examples
`timescale 1ns/1ps
module tb() ; 
  reg clk100Mhz = 0; 
  reg clk50Mhz=0;
  always #5 clk100Mhz = ~clk100Mhz ;  
  real phase = 10 ; // b/w reference and new clock is 10 ns 
  real ton =5 ; 
  real toff= 5; 
  initial begin
    #phase; 
    while(1)begin
        clk50Mhz =1; 
        #ton;
        clk50Mhz=0;
        #ton; 
      
    end
  end
  //integrate the code of demonstration part 1 here, 
  // also include demonstration part 2 of section 2 
  
  
endmodule
