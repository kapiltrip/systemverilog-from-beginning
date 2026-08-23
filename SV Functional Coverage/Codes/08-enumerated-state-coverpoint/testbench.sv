// Code your testbench here
// or browse Examples
module tb;
  typedef enum bit [1:0] {  // option.auto_bin_max is not allowed in enum
    s0 = 2'b00,
    s1= 2'b01,
    s2= 2'b10,
    s3= 2'b11

  } fsm_states;
  fsm_states var1;

  covergroup coverFsm ;
    option.per_instance = 1;

    coverpoint var1;

  endgroup
  initial begin
    coverFsm ci = new();

    $cast(var1 , 2'b00);

    ci.sample();
  end
endmodule
