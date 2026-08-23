`timescale 1ns/1ps

// Video 098: decode a transaction in functions, then sample the enum result.
module tb;
  typedef enum logic [1:0] {NOP, WRITE, READ, ERROR} op_state_e;

  logic enable, read, write;

  covergroup operation_cg with function sample(input op_state_e observed_state);
    option.per_instance = 1;
    cp_state: coverpoint observed_state;
  endgroup

  operation_cg cg;

  function automatic op_state_e decode_state(
    input logic enable_i,
    input logic read_i,
    input logic write_i
  );
    if (!enable_i)                 return NOP;
    if (write_i && !read_i)       return WRITE;
    if (read_i && !write_i)       return READ;
    return ERROR;
  endfunction

  function automatic void check_coverage;
    op_state_e decoded;
    decoded = decode_state(enable, read, write);
    cg.sample(decoded);
  endfunction

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    cg = new();

    repeat (16) begin
      {enable, read, write} = $urandom;
      check_coverage();
      #10;
    end
    // TODO: sample only the combinations accepted by your checking function.
  end
endmodule
