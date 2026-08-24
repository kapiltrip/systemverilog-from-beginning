`timescale 1ns/1ps

// Video 087: reuse one data-range covergroup and one opcode-range covergroup.
module tb;
  // use cases : alu 8 operations 4 bit input and 5 bit o/p
  // 3 ranges low mid and high ,
  // all the operations to be tested
  reg [3:0] a;
  reg [3:0] b;
  reg [2:0] opcode;
  wire [4:0] y;
  integer i = 0;
  aluWorking dut (a, b, opcode, y);

  covergroup inputVariable (ref reg [3:0] variableAorB, input string varName, input int low, input int mid, input int high);
    option.per_instance = 1;
    option.name = varName; // that user will specify
    coverpoint variableAorB {
      bins lowerVal = {[0:low]};
      bins midVal = {[low+1:mid]};
      bins highVal = {[mid+1:high]};

    }
  endgroup
  //covergroup for verifying all the possible values for opcode
  covergroup coverageOpcode (ref reg [2:0] opcodeType, input string varName, input int low, input int high);
    option.per_instance = 1;
    option.name = varName; // user assigned name will be given here,
    coverpoint opcodeType {
      bins opcodeT[] = {[low:high]};

    }
  endgroup
  // 2 things are getting checked
  inputVariable cia = new(a, "variable a ", 3, 10, 15);
  inputVariable cib = new(b, "variable b ", 3, 10, 15);
  coverageOpcode cArithmetic = new(opcode, "Arithmetic operation ", 0, 3); // according to cases
  coverageOpcode cLogical = new(opcode, "Logical Operation ", 4, 7);
  initial begin
    for(i = 0; i < 50; i++)begin
      a = $urandom();
      b = $urandom();
      opcode = $urandom();
      cia.sample();
      cib.sample();
      cArithmetic.sample();
      cLogical.sample();
      #10; // again why i write it here,
    end
  end
endmodule
