`timescale 1ns/1ps

// Video 114: keep DIN combinations for writes and DOUT combinations for reads.
module tb;
  logic write;
  logic [1:0] address;
  logic [3:0] din, dout;

  covergroup memory_operation_cg;
    option.per_instance = 1;
    cp_write: coverpoint write;
    cp_address: coverpoint address;
    cp_din: coverpoint din {
      bins low = {[0:3]}; bins mid = {[4:10]}; bins high = {[11:15]};
    }
    cp_dout: coverpoint dout {
      bins low = {[0:3]}; bins mid = {[4:10]}; bins high = {[11:15]};
    }
    x_write_data: cross cp_write, cp_address, cp_din {
      ignore_bins inactive_write = binsof(cp_write) intersect {0};
    }
    x_read_data: cross cp_write, cp_address, cp_dout {
      ignore_bins inactive_read = binsof(cp_write) intersect {1};
    }
  endgroup

  memory_operation_cg cg;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    cg = new();
    repeat (64) begin
      {write, address, din, dout} = $urandom;
      cg.sample();
      #10;
    end
    // TODO: exclude the irrelevant data direction from each operation cross.
  end
endmodule
