// Code your testbench here
// or browse Examples
module tb;
  reg [2:0] opcode;
  reg [2:0] a, b;
  reg [3:0] res;
  always_comb begin
    case (opcode)
      0: res= a + b ;
      1: res = a-b;
      2: res = a ;
      3: res= b;
      4: res = a ^b ;
      5: res = a &b ;
      default : res =0 ;

    endcase
  end
  covergroup c ;
    option.per_instance = 1;
    coverpoint opcode {
      bins valid_opcode[] = {[0:5]} ;
      illegal_bins invalid_opcode[] = {6,7} ;  // illegal states that should never occur during simulation
      ignore_bins invalid_ignor[] = {8,9};
    }
    //$display("The elements of the aray ignored is %0p " , invalid_ignor); how to print the values that, are in the ignore bin

  endgroup
  c ci ;
  initial begin
    ci = new();
    for(int i =0 ; i<10 ; i++)begin
      a = $urandom() ; // 32 bit unsigned
      b = $urandom() ;
      opcode = $urandom();
      ci.sample();
      #10 ;
    end
  end
endmodule
