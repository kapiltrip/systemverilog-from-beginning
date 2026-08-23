// Code your testbench here
// or browse Examples
// instance coverage is diff from cover pint coverage
module tb;
  reg [1:0] a ;
  reg [1:0] b ;

  covergroup coverA;
    option.per_instance =1;
    option.goal= 75;  // this is not true for coverage type
    type_option.goal = 75;
    coverpoint a {
      option.weight = 3;
      option.goal = 75;
    }
    coverpoint b {
      option.weight = 5 ;
      option.goal= 75;
    }

  endgroup
  coverA ca = new();
  initial begin
    for(int i =0 ; i<5 ; i++)begin
      a = $urandom();
      b= $urandom();;
      ca.sample();
      #10  ;

    end
  end
endmodule
//weight * coverage for coverpoint for a + weight for b * coverage for coverpoint b / weight1 + weight2
// coverage type -> multiple cover -> multiple cover point
//type for coverage
// option . is for -> coverpoint
