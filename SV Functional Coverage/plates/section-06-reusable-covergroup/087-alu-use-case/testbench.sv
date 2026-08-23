`timescale 1ns/1ps

// Video 087: reuse one data-range covergroup and one opcode-range covergroup.
module tb;
  logic [3:0] a, b;
  logic [2:0] op;
  logic [4:0] y;

  alu_stub dut(.*);

  covergroup data_cg(ref logic [3:0] value, input string instance_name);
    option.per_instance = 1;
    option.name = instance_name;
    cp_data: coverpoint value {
      bins low  = {[0:3]};
      bins mid  = {[4:10]};
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

  data_cg cg_a, cg_b;
  opcode_cg cg_arithmetic, cg_logical;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);

    cg_a = new(a, "ALU input A");
    cg_b = new(b, "ALU input B");
    cg_arithmetic = new(op, 0, 3, "arithmetic opcodes");
    cg_logical = new(op, 4, 7, "logical opcodes");

    repeat (32) begin
      {a, b, op} = $urandom;
      cg_a.sample();
      cg_b.sample();
      cg_arithmetic.sample();
      cg_logical.sample();
      #10;
    end
    // TODO: refine the arithmetic/logical opcode ranges for the final ALU.
  end
endmodule
