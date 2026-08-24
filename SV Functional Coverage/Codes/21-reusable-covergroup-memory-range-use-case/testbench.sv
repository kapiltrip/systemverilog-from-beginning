`timescale 1ns/1ps

// Video 089: reuse one address-window covergroup for three memory regions.
module tb;
  // to check memory range ok
  reg [3:0] address;
  integer i;

  // low is 0 to 3 , mid 4 to 11 , high 12 to 15
  covergroup checkAddress (ref logic [3:0] addressCall, input int lower, input int high, input string instanceName);
    option.per_instance = 1;
    option.name = instanceName;
    coverpoint addressCall {
      bins f[] = {[lower:high]};

    }
  endgroup
  initial begin
    checkAddress cLow = new(address, 0, 3, "checking lower range address ");
    checkAddress cMid = new(address, 4, 11, "checking mid range address ");
    checkAddress cHigh = new(address, 12, 15, "checking higher range address ");
    for(i = 0; i < 20; i++)begin
      address = $urandom();
      cLow.sample();
      cMid.sample();
      cHigh.sample();
      #10;

    end
  end
endmodule
