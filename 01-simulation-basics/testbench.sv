// Code your testbench here
// or browse Examples
//Types of signals global , data , control 
`timescale 1ns/1ps  // time unit  / time precision 

/*

module tb();
  reg a =0;
  initial begin  // will start from time 0 (start of the simulation ) 
    
    a =1; 
    #10;
    a=0; 
    
  end   //variable will hold the value =0 till the end of the simulation 
  
endmodule
*/
module tb();
  reg clk ; 
  reg [3:0] temp ; 
  // coulld be used to initialize a golbal varialbe 
  // to generate random signal for data / control signal 
  // 
  initial begin
    temp=4'b0100;
    #10; // 10 * 1ns (time unit )
    temp = 4'b0011;
    temp=4'b0100;
    #10; // 10 * 1ns (time unit )
    temp = 4'b0011;
    
  end
  reg reset; 
  initial begin
    clk =1'b0;  //single bit value in the binary format 
    reset=1'b0 ; 
    
  end
  // at the start of simuation 
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
  // to analyse the values of the variabl es from the beginning of the time 
  initial begin
    $monitor( "Temp : %0d at time %0t  " , temp , $time);
  end
  // analyzing values of variable in console 
  // stop simulation by forcefully calling finish 
  
  initial begin
      #200 ; 
    $finish();
  end
  initial begin
      reset=1'b1; 
    #10;
    reset = 1'b0;
  end
endmodule
