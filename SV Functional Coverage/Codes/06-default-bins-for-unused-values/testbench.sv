// Code your testbench here
// or browse Examples
// to analyze the unused  value sent to dut
// default bin : implicit , i.e single if< 64 or multiple hit per bin based on the range beyond 64

// explicit bins : array , individual , range
module tb;
  reg [3:0] a;
  integer i =0 ;
  covergroup c;
    option.per_instance = 1;
    coverpoint a {
      bins a_values[] = {[0:9]};
      bins a_unused = default ;

    }
  endgroup
  c cin = new() ;

endmodule
