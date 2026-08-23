`timescale 1ns/1ps

// Video 110: filter combinations by splitting write and read concerns.
module tb;
  logic write;
  logic [1:0] address;
  logic [3:0] din, dout;

  covergroup write_cg;
    option.per_instance = 1;
    cp_write: coverpoint write { bins active = {1}; }
    cp_address: coverpoint address;
    cp_din: coverpoint din {
      bins low = {[0:3]}; bins mid = {[4:10]}; bins high = {[11:15]};
    }
    x_write: cross cp_write, cp_address, cp_din;
  endgroup

  covergroup read_cg;
    option.per_instance = 1;
    cp_read: coverpoint write { bins active = {0}; }
    cp_address: coverpoint address;
    cp_dout: coverpoint dout {
      bins low = {[0:3]}; bins mid = {[4:10]}; bins high = {[11:15]};
    }
    x_read: cross cp_read, cp_address, cp_dout;
  endgroup

  write_cg write_cov;
  read_cg read_cov;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    write_cov = new();
    read_cov = new();
    repeat (48) begin
      {write, address, din, dout} = $urandom;
      write_cov.sample();
      read_cov.sample();
      #10;
    end
    // TODO: sample the write and read covergroups only on their valid operation.
  end
endmodule
