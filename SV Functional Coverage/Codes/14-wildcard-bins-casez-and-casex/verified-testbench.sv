module tb;
  logic [3:0] x;
  logic [1:0] y;

  priority_encoder dut (
    .x (x),
    .y (y)
  );

  covergroup encoder_cg;
    option.per_instance = 1;

    cp_x: coverpoint x {
      bins bit0_only = {4'b0001};
      wildcard bins bit1_highest = {4'b001?};
      wildcard bins bit2_highest = {4'b01??};
      wildcard bins bit3_highest = {4'b1???};
    }

    cp_y: coverpoint y {
      bins encoded_value[] = {[0:3]};
    }
  endgroup

  encoder_cg coverage;

  function automatic logic plain_case_question_matches(
    input logic [3:0] value
  );
    case (value)
      4'b1???: plain_case_question_matches = 1'b1;
      default: plain_case_question_matches = 1'b0;
    endcase
  endfunction

  function automatic logic casez_concrete_matches(
    input logic [3:0] value
  );
    casez (value)
      4'b1001: casez_concrete_matches = 1'b1;
      default: casez_concrete_matches = 1'b0;
    endcase
  endfunction

  function automatic logic casex_concrete_matches(
    input logic [3:0] value
  );
    casex (value)
      4'b1001: casex_concrete_matches = 1'b1;
      default: casex_concrete_matches = 1'b0;
    endcase
  endfunction

  task automatic drive_and_check(
    input logic [3:0] stimulus,
    input logic [1:0] expected
  );
    x = stimulus;
    #1;
    coverage.sample();

    if (y !== expected) begin
      $error("x=%b produced y=%b; expected %b", x, y, expected);
    end
  endtask

  initial begin
    coverage = new();

    // Deterministically hit every wildcard input bin and every output bin.
    drive_and_check(4'b0001, 2'b00);
    drive_and_check(4'b0010, 2'b01);
    drive_and_check(4'b0011, 2'b01);
    drive_and_check(4'b0100, 2'b10);
    drive_and_check(4'b0111, 2'b10);
    drive_and_check(4'b1000, 2'b11);
    drive_and_check(4'b1111, 2'b11);

    // A plain case treats ? as a Z digit, not as a wildcard.
    if (plain_case_question_matches(4'b1000) !== 1'b0) begin
      $error("plain case incorrectly treated ? as a wildcard");
    end

    // This pair isolates the real expression-side difference.  casez does
    // not ignore the X in 1X01 when the item has a concrete 0 there; casex
    // does ignore it and therefore matches 1001.
    if (casez_concrete_matches(4'b1x01) !== 1'b0) begin
      $error("casez incorrectly ignored an expression-side X");
    end
    if (casex_concrete_matches(4'b1x01) !== 1'b1) begin
      $error("casex did not wildcard an expression-side X");
    end

    x = 4'b0000;
    #1;
    if (y !== 2'bzz) begin
      $error("no-request input should select the default branch");
    end

    $display("plain case: 1000 versus 1??? -> %0b",
             plain_case_question_matches(4'b1000));
    $display("casez:      1X01 versus 1001 -> %0b",
             casez_concrete_matches(4'b1x01));
    $display("casex:      1X01 versus 1001 -> %0b",
             casex_concrete_matches(4'b1x01));
    $display("PASS: encoder checks and wildcard-semantics checks completed");
  end
endmodule
