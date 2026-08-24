`timescale 1ns/1ps

// Video 083: pass constant range limits by value with input arguments.
module tb;
  reg [3:0] a, b; // low 0 to 3 mid 4 to 10 and high 11 to 15
  integer i = 0;

  covergroup c (ref reg [3:0] variable, input string variableId, input int low, input int mid, input int high);
    option.per_instance = 1;
    option.name = variableId;
    coverpoint variable {
      bins lower_value = {[0:low]};
      bins mid_value = {[low+1:mid]};
      bins high_value = {[mid+1:high]}; // we create 3 bins
    }
  endgroup
  c cia = new(a, "Variable a ", 3, 10, 15);
  c cib = new(b, "Variable b ", 3, 10, 15);
  initial begin
    for(i = 0; i < 10; i++)begin
      a = $urandom();
      b = $urandom();
      cia.sample();
      cib.sample();
      #10;

    end
  end
endmodule
