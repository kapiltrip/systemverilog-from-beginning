`timescale 1ns/1ps

// Video 085: remember ref for variables and input for constant values.
module tb;
  reg [3:0] a;
  integer i = 0;
  //covergroup check_var (ref logic [3:0] varInput );
  //covergroup check_var (int varValue );
  covergroup check_var (ref logic [3:0] variableName, input int variableValue); // add ref and input for argument as a value ok i can search for the reason

    // this wont work object 5 cant be pass by ref
    option.per_instance = 1;
    coverpoint variableName {
      bins f[] = {[0:variableValue]};
    }
  endgroup
  initial begin
    check_var ci = new(a, 5);
    for(i = 0; i < 10; i++)begin
      a = $urandom();
      ci.sample();
      #10;

    end
  end
endmodule
