`timescale 1ns/1ps

module tb;
  logic [3:0] a;
  logic [3:0] b;
  logic [2:0] opcode;
  logic [4:0] y;

  alu_verified dut (.*);

  covergroup input_cg(ref logic [3:0] value, input string instance_name);
    option.per_instance = 1;
    option.name = instance_name;
    cp_value: coverpoint value {
      bins low = {[0:3]};
      bins mid = {[4:10]};
      bins high = {[11:15]};
    }
  endgroup

  covergroup opcode_cg(ref logic [2:0] value, input int first_op,
                       input int last_op, input string instance_name);
    option.per_instance = 1;
    option.name = instance_name;
    cp_opcode: coverpoint value {
      bins operations[] = {[first_op:last_op]};
    }
  endgroup

  input_cg cg_a = new(a, "verified input A");
  input_cg cg_b = new(b, "verified input B");
  opcode_cg cg_arithmetic = new(opcode, 0, 3, "verified arithmetic opcodes");
  opcode_cg cg_logical = new(opcode, 4, 7, "verified logical opcodes");

  function automatic logic [4:0] expected_result(
    input logic [3:0] function_a,
    input logic [3:0] function_b,
    input logic [2:0] function_opcode
  );
    case (function_opcode)
      3'b000: expected_result = {1'b0, function_a} + {1'b0, function_b};
      3'b001: expected_result = {1'b0, function_a} - {1'b0, function_b};
      3'b010: expected_result = {1'b0, function_a} + 5'd1;
      3'b011: expected_result = {1'b0, function_b} + 5'd1;
      3'b100: expected_result = {1'b0, function_a & function_b};
      3'b101: expected_result = {1'b0, function_a | function_b};
      3'b110: expected_result = {1'b0, function_a ^ function_b};
      3'b111: expected_result = {1'b0, ~function_a};
      default: expected_result = '0;
    endcase
  endfunction

  task automatic check_operation(
    input logic [3:0] stimulus_a,
    input logic [3:0] stimulus_b,
    input logic [2:0] stimulus_opcode
  );
    a = stimulus_a;
    b = stimulus_b;
    opcode = stimulus_opcode;
    #1;

    if (y !== expected_result(a, b, opcode)) begin
      $error("opcode=%0d a=%0d b=%0d produced y=%0d expected=%0d",
             opcode, a, b, y, expected_result(a, b, opcode));
    end

    cg_a.sample();
    cg_b.sample();
    cg_arithmetic.sample();
    cg_logical.sample();
  endtask

  initial begin
    check_operation(0, 15, 0);
    check_operation(4, 10, 1);
    check_operation(11, 3, 2);
    check_operation(15, 4, 3);
    check_operation(3, 11, 4);
    check_operation(10, 0, 5);
    check_operation(4, 15, 6);
    check_operation(12, 5, 7);
    $display("PASS: all eight ALU operations and reusable coverage models verified");
  end
endmodule
