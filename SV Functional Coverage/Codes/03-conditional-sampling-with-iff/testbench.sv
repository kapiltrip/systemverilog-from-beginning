// Code your testbench here
// or browse Examples
module tb ;
  reg [1:0] a =0;
  reg rst =0;
  integer i =0;
  initial begin
    rst =1;
    #30;
    rst =0 ;

  end
  covergroup c ;
    option.per_instance =1 ;
    coverpoint a iff(!rst); // all value of sample where rst low will not be taken
  endgroup

  initial begin
    c ci = new();
    for(i =0 ; i< 10 ; i++)begin
      a = $urandom();
      ci.sample(); // tell cover group to sample the value of a so that we could calculate the coverage
      #10 ;
    end
  end
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
endmodule
