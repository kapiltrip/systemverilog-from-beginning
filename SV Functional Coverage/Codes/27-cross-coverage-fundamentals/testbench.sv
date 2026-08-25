`timescale 1ns/1ps

// address range , wr also din and dout ranges are also covered
// lower range , mid and high range , hit during write, and read
//wr
// rd we cover all the addresses
// during write, operation we are not verifying for all the addresses wr == 1 we are not tested for addresses

module tb;
  // address 01 all ranges of din are covered ,
  reg wr ;
  reg [1:0] addr ;
  reg [3:0] din, dout ;
  integer i =0 ;
  covergroup c ;
    option.per_instance = 1 ;
    coverpoint wr {
      bins wr_low = {0} ;
      bins wr_high = {1} ;
    }
    coverpoint addr {
      bins addr_v[] = {0,1,2,3}; // i.e all values of addresses 4 bins for address array

    }
    cross wr, addr ; // to find cross bw write and address
    coverpoint din {
      bins low = {[0:3]} ;
      bins mid = {[4:11 ]} ;
      bins high = {[12:15]} ;
    }
    coverpoint dout {
      bins low = {[0:3]} ;
      bins mid = {[4:11 ]} ;
      bins high = {[12:15]} ;
    }
    cross wr , addr , din ;   // wr 1 bit , addr 4 possible values , din 3 ranges low mid and high ,
    cross wr , addr , dout ;

  endgroup
  c ci ;
  initial begin
    ci = new();
    for(i =0 ; i< 50 ; i++)begin
      addr = $urandom();
      wr =  $urandom();
      din =  $urandom();
      dout =  $urandom();
      ci.sample();
      #10 ;

    end
  end
endmodule
