`timescale 1ns/1ps

// Video 089: reuse one address-window covergroup for three memory regions.
module tb;
  logic [3:0] address;

  covergroup address_region_cg(
    ref logic [3:0] live_address,
    input int first_address,
    input int last_address,
    input string region_name
  );
    option.per_instance = 1;
    option.name = region_name;
    cp_region: coverpoint live_address {
      bins region = {[first_address:last_address]};
    }
  endgroup

  address_region_cg cg_low, cg_mid, cg_high;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);

    cg_low  = new(address, 0, 3, "low addresses");
    cg_mid  = new(address, 4, 11, "mid addresses");
    cg_high = new(address, 12, 15, "high addresses");

    repeat (20) begin
      address = $urandom;
      cg_low.sample();
      cg_mid.sample();
      cg_high.sample();
      #10;
    end
    // TODO: match the low/middle/high windows to your memory map.
  end
endmodule
