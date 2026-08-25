`timescale 1ns/1ps

// Video 112: compact cross filtering with binsof(...) intersect {...}.
// ranges and values in the intersact

module tb;
  // b/w wr and addr when write,is 0
  reg wr ;
  reg [1:0] addr ;
  reg [3:0] din , dout ;

  integer i =0 ;
  covergroup c;
    option.per_instance = 1;
    coverpoint wr {
      bins wr_low = {0};
      bins wr_high = {1};

    }
    coverpoint addr {
      bins addr_values[] = {0,1,2,3};

    }
    cross wr , addr
    {  // wr and address ,
      ignore_bins wr_low_unused = binsof (wr) intersect {0}; // bins of signal wr intersace with a value 0 . wr == 0

    } // ignore bins to exclude the coverage from report
    coverpoint din {                    // wr == 1
      bins low = {[0:3]} ;
      bins mid = {[4:11]};
      bins high = {[12:15]} ;
    }
    coverpoint dout {                   // wr == 0
      bins low = {[0:3]} ;
      bins mid = {[4:11]};
      bins high = {[12:15]} ;
    }
    cross wr,addr , din {
      ignore_bins wr_low_unused_din_dout = binsof(wr) intersect {0};

    }
  endgroup

  c ci ;
  initial begin
    ci = new();
    for(i =0 ; i< 50 ; i ++)begin
      wr = $urandom() ;
      addr = $urandom();
      din  = $urandom();
      dout = $urandom();
      ci.sample();
      #10 ;

    end
  end
endmodule
