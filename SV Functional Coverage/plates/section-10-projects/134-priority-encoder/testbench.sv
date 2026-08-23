`timescale 1ns/1ps

// Video 134: wildcard bins match requests that share the same winner.
module tb;
  logic [7:0] request;
  logic [2:0] code;
  logic       valid;

  priority_encoder dut (.*);

  covergroup encoder_cg;
    option.per_instance = 1;
    cp_request: coverpoint request {
      wildcard bins priority_7 = {8'b1???????};
      wildcard bins priority_6 = {8'b01??????};
      wildcard bins priority_5 = {8'b001?????};
      wildcard bins priority_4 = {8'b0001????};
      wildcard bins priority_3 = {8'b00001???};
      wildcard bins priority_2 = {8'b000001??};
      wildcard bins priority_1 = {8'b0000001?};
      wildcard bins priority_0 = {8'b00000001};
      bins no_request = {8'b0};
    }
  endgroup

  encoder_cg cg;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    cg = new();
    repeat (40) begin
      request = $urandom;
      cg.sample();
      #10;
    end
    request = '0; cg.sample(); #10;
    // TODO: add an expected-code function and self-check every request.
  end
endmodule
