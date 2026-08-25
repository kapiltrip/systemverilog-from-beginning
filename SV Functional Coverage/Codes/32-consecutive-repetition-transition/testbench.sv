`timescale 1ns/1ps

// Video 124: consecutive repetition and the deliberate endpoint value.
module tb;
  reg clk = 0 ;
  reg data[] = {1,1,1,1,1, 0};
  reg state = 0 ;
  integer i = 0 ;
  initial repeat (90) #5 clk = ~ clk ;
  initial begin
    for(i=0 ; i< 5; i++)begin
      @(posedge clk );
      state = data[i];
    end
  end
  covergroup c @(posedge clk );
    option.per_instance = 1;
    coverpoint state {
      bins transitions = (1[*4]); // 4 consecutive repetition of 1
          // some sort of overlapping consecutive operation , happening her e,
    }    // {1,1,1,1} if repetition count is 4 its, so we need a endpoint
  endgroup
  c ci ;
  initial begin
    ci = new() ;
    //#         bin transitions                                    41          1          -    Covered
 // coming out to be 41 due to overlapping nature of this in the array
    // important is to end the stimulus
    // or to remember the starting point 0 => 1[*4]

  end
endmodule
