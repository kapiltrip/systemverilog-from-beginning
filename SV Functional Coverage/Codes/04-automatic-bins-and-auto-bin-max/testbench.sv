// Code your testbench here
// or browse Examples
// bins not beans  hihi
// implicit beans
/*
covergroup cover_a_b ;
  coverpoint a ;  // reg [1:0] a a may take 00 01 10 11 //
endgroup
auto_bin_max = 64 ; // bins keep track of no of time we apply a specific value to a dut */
// if i have a variable that has a size of <= 6 bit ,
// what if we have variable having a size of 7 bit
// i.e 128 beans
// 128 / 64 =2 each bin will take 2 values , i.e bean[0] will take a value of 0/1 will calc hit of these, 2 values
// if reg [7:0] a ; // 256 / 64 , we will track 4 diff values in a single value :
// bin [0] can take accout for 0,1,2,3, being hit
// of option_bin_max = 256;
module tb;
  //reg [1:0] a ;  // 00 01 10 11 no of unique value is < 64
 // reg [5:0] a; // 64 independent value for each value
  reg [6:0] a;  // 128 / 64 =2 values hit will be put on a single bin
  reg [7:0] b ;
  integer i ;

  covergroup cover_a ;
    option.per_instance=1 ;

    coverpoint a {
          option.auto_bin_max = 256 ; // can be restricted to a specific coverpoint

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
