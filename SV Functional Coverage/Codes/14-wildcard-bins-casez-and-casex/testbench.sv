// wild card bins
// multiple value will give same output
// priority encoder
// 000001?? // any values for ?
// 4 t0 2 priority encoder
module tb;
  reg [3:0] x ;
  wire [1:0] y ;

  priorityEncoder dut (x,y);

  covergroup c;
    option.per_instance = 1;
    coverpoint x{
      bins zero = {4'b0001};
      wildcard bins one = {4'b001?  };
      wildcard bins two = {4'b01?? };
      wildcard bins three = {4'b1??? };
    }
    coverpoint y {
      bins undef_atOP[] = {2'bxx, 2'bx0, 2'b1x, 2'bx1 , 2'bzz, 2'bz0 , 2'b0z ,2'b1z , 2'bz1 };
      bins valid_at0p[] = {0,1,2,3}; // undefined hits also there

    }
  endgroup
  c ci ;

  initial begin
    ci  = new();

    for(int i =0 ; i<15 ; i++)begin
      x= $urandom();
      #10;
      $display("The value of x in binary is %4b " , x );
      ci.sample();
      #10 ;
    end
  end
endmodule
