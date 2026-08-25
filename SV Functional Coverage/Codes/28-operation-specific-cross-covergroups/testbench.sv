`timescale 1ns/1ps

// Video 107: construct address and data-range crosses for a memory-like DUT.
module tb;
  // wr = 1 , wr =0 all of the addresses are covered once
  // address = all of the ranges of din are checked
  // din ranges for write, operations
  // dout / address cross filter
  // wr addr and din
  // wr 0 , addr , dout
  // we will consider 2 covergroup
  reg wr ;
  reg [1:0] addr ;
  reg [3:0] din , dout ;
  integer i ;
  /*
  covergroup c ;
    option.per_instance = 1;
    coverpoint wr {
      bins wr_low = {0};
      bins wr_high = {1};

    }
    coverpoint addr {
      bins addr_values = {0,1 ,2,3};

    }
    cross wr , addr ;
    coverpoint din {
      bins low = {[0:3]} ;
      bins mid = {[4:11]};
      bins high = {[12:15]} ;
    }
    coverpoint dout {
      bins low = {[0:3]} ; // i wont make low an array i.e low[]
      bins mid = {[4:11]};
      bins high = {[12:15]} ;
    }
    cross wr , addr , din ;
    cross wr , addr , dout ;

  endgroup
  */
  covergroup wr_din_addr ;
    option.per_instance = 1;
    coverpoint wr {
      bins wr_high = {1};
    }
    coverpoint addr {
      bins addr_values = {0,1,2,3};
    }
    coverpoint din {
      bins low = {[0:3]} ; // i wont make low an array i.e low[]
      bins mid = {[4:11]};
      bins high = {[12:15]} ;
    }
    cross addr , wr, din ;

  endgroup
  covergroup wr_low_dout_address;
    option.per_instance = 1;
    coverpoint wr {
      bins wr_low = {0};
    }
    coverpoint addr  {
      bins addr_value[] = {0,1,2,3};
    }
    coverpoint dout {
      bins low = {[0:3]} ; // i wont make low an array i.e low[]
      bins mid = {[4:11]};
      bins high = {[12:15]} ;
    }
    cross addr, dout , wr ;

  endgroup
  wr_din_addr ci1 ;
  wr_low_dout_address ci2 ;
  initial begin
    ci1 = new();
    ci2 = new();

  for(i =0 ; i< 50 ; i++)begin
    wr = $urandom();
    addr  = $urandom();
    din  = $urandom();
    dout  = $urandom();
    ci1.sample();
    ci2.sample();

    #10 ;
  end
  end
endmodule
