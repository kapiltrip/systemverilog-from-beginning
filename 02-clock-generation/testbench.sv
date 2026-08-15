// Code your testbench here
// or browse Examples
//`timescale 1ns/1ns //1 digits valid after the decimal point
`timescale 1ns/1ps //3 digits valid after the decimal point

module tb();
  //in tb we dont need a sensitivity list in the always block why ? 
  // in the design we need to evaluate for change hence in sensitivity list 
  /*
  always // ignoring sensitivity list 
    always begin
        
    end
    */ 
  reg clk ;  // x by default so i have to initialize 
  reg clk50MHZ;
  reg clk25Mhz; 
  reg clk16Mhz;
  reg clk8Mhz; 
  
  reg rst; 
  //always block to generate a clock signal 
  //100 MHZ 
  //period == 10 ns , and half clock period is 5 ns 
  // run forever 
  initial begin
    rst = 1'b0 ; 
    clk = 1'b0 ;
    clk50MHZ= 1'b0 ; // 20 ns and half is 10 ns 
    
    clk25Mhz = 1'b0 ; 
    clk16Mhz = 1'b0 ; 
    
    clk8Mhz = 1'b0 ; 
    
  end
  always begin
      #5 ; 
      clk50MHZ =1'b1; 
      //#10 clk50MHZ= ~clk50MHZ  ;
      #10 ; 
      clk50MHZ =1'b0; // this is 50 mhz
      #5; 

  end
  always begin
      #31.25 clk16Mhz = ~clk16Mhz ; 
    
  end
  always begin
      #62.5 clk8Mhz = ~clk8Mhz ; 
    
  end
  /*
  always begin
      #20 clk25Mhz = ~ clk25Mhz ;
    
  end
  */
  always begin
      #5;
      clk25Mhz= 1'b1; 
      #20 clk25Mhz = 1'b0 ;
      #5; 
    
  end
  always begin
      #5 clk = ~clk ; 
    
  end
  initial begin
   #200; 
    $finish(); // since im using always block to generate clock 
  end 
  //edges aligned for both clocks
  
  
  initial begin
    $dumpfile("demo.vcd");
    $dumpvars();
  end 
  
endmodule
