`timescale 1ns/1ps

// Video 108: starter for comparing independent and cross-coverage closure.
module tb;
  logic write;
  logic [1:0] address;
  logic [3:0] din, dout;

  covergroup closure_cg;
    option.per_instance = 1;
    cp_write: coverpoint write;
    cp_address: coverpoint address;
    cp_din: coverpoint din {
      bins low = {[0:3]}; bins mid = {[4:10]}; bins high = {[11:15]};
    }
    cp_dout: coverpoint dout {
      bins low = {[0:3]}; bins mid = {[4:10]}; bins high = {[11:15]};
    }
    x_write_address: cross cp_write, cp_address;
    x_write_data: cross cp_write, cp_address, cp_din;
    x_read_data: cross cp_write, cp_address, cp_dout;
  endgroup

  closure_cg cg;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    cg = new();

    // TODO: vary this count and predict the missing cross bins before rerunning.
    repeat (40) begin
      {write, address, din, dout} = $urandom;
      cg.sample();
      #10;
    end
  end
endmodule
