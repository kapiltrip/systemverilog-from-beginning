// 8-bit signal: wide enough to represent every value in [1:100].
// Ignore 23, 45, 67, 89, 93 and the four unused ranges below.
module tb;
  reg [7:0] a;
  integer i = 0;

  covergroup c;
    option.per_instance = 0;
    coverpoint a {
      bins value_a[] = {[1:100]};
      ignore_bins unused_a_ignored[] = {23, 45, 67, 89, 93};
      ignore_bins unused_range_1[] = {[3:7]};
      ignore_bins unused_range_2[] = {[32:36]};
      ignore_bins unused_range_3[] = {[47:50]};
      ignore_bins unused_range_4[] = {[61:64]};
    }
  endgroup

  c ci;

  initial begin
    ci = new();

    // Visit the complete declared domain once. Ignored values are not scored.
    for (i = 1; i <= 100; i++) begin
      a = i;
      ci.sample();
      #1;
    end
  end
endmodule
