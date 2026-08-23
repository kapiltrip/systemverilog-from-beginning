// Code your testbench here
// or browse Examples
module tb;
  reg a , b, c, d;
  reg [1:0] sel ;
  wire y ;
  top dut(a,b,c,d,sel,y);
  covergroup cover_mux;
    option.per_instance = 1;
    coverpoint a {
      bins a_values[] = {0,1};
    }
    coverpoint b {
      bins b_values[] = {0,1};
    }
    coverpoint c {
      bins c_values[] = {0,1};
    }
    coverpoint d {
      bins d_values[] = {0,1};
    }
    coverpoint sel {
      bins sel_values[] = {0,1,2,3};

    }
    coverpoint y {
      bins y_values[]= {0,1};
    }

  endgroup
  cover_mux ci = new();
  initial begin
    for(int i =0 ; i<20 ; i++)begin
      a= $urandom();
      b= $urandom();
      c= $urandom();
      d= $urandom();
      sel= $urandom();
      ci.sample();
      #10 ;

    end
  end
endmodule
