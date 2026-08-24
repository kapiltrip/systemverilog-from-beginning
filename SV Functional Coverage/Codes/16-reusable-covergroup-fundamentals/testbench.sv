`timescale 1ns/1ps

module tb;
  // reusable covergroups
  // generic covergroup
  reg [3:0] a, b;
  covergroup c (reg [3:0] variable, input string varId);
    option.name = varId;
    option.per_instance = 1;
    coverpoint variable;

  endgroup
  c cia = new(a, "variable a ");
  c cib = new(b, "variable b ");
  initial begin
    for(int i = 0; i < 15; i++)begin
      a = $urandom();
      b = $urandom();
      cia.sample();
      cib.sample();
      #10;

    end
  end
  initial begin
    $dumpfile("dump.vcd ");
    $dumpvars;

  end
endmodule
