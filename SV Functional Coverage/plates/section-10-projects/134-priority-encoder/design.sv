`timescale 1ns/1ps

// Video 134: 8:3 priority encoder, bit 7 has the highest priority.
module priority_encoder (
  input  logic [7:0] request,
  output logic [2:0] code,
  output logic       valid
);
  always_comb begin
    code  = '0;
    valid = 1'b1;
    casez (request)
      8'b1???????: code = 3'd7;
      8'b01??????: code = 3'd6;
      8'b001?????: code = 3'd5;
      8'b0001????: code = 3'd4;
      8'b00001???: code = 3'd3;
      8'b000001??: code = 3'd2;
      8'b0000001?: code = 3'd1;
      8'b00000001: code = 3'd0;
      default: begin code = '0; valid = 1'b0; end
    endcase
  end
endmodule
