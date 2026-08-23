`timescale 1ns/1ps

// Video 085: remember ref for variables and input for constant values.
module tb;
  logic [3:0] address;

  covergroup window_cg(
    ref logic [3:0] live_value,
    input int first_value,
    input int last_value,
    input string instance_name
  );
    option.per_instance = 1;
    option.name = instance_name;
    cp_window: coverpoint live_value {
      bins requested_window = {[first_value:last_value]};
    }
  endgroup

  window_cg cg;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);

    cg = new(address, 0, 5, "starter window");
    repeat (16) begin
      address = $urandom;
      cg.sample();
      #10;
    end

    // TODO: add more instances with different windows and names.
  end
endmodule
