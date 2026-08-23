// Code your testbench here
// or browse Examples
// explicit bins
module tb;
  //reg [1:0] a ;  // 00 01 10 11 no of unique value is < 64
 // reg [5:0] a; // 64 independent value for each value
  reg [6:0] a;  // 128 / 64 =2 values hit will be put on a single bin
  reg [7:0] b ;
  integer i ;

  covergroup cover_a ;
    option.per_instance=1 ;

    coverpoint a {
      /*
      bins zero = {0}; // keep the track of value 0
      bins one = {1};
      bins two = {2};
      bins three = {3}; // explicit bins
      bins bin0 = {0,1}; // [min: max]
      bins bin1 = {[2:3]};
      */
      // bins bin0nlyA = {[1:3]}; use array to create a specific bins
      //bins binArrayDynamic[] = {[0:127]}; // ok done array concept
      bins binArrayDynamic[64] = {[0:127]}; // build an array , 2 values will be tracked by single bin
      // EXPLICIT BINS
      // bins a = {0,1,2,3}
      // or
    }
    coverpoint b ;

  endgroup
  cover_a ci = new() ;
  initial begin
    for(i=0; i<10 ; i++)begin
      a = $urandom() ;
      ci.sample();
      #10 ;

    end
  end
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
endmodule
