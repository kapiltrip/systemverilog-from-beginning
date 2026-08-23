module tb;

  reg [2:0] a;

  covergroup c;
    option.per_instance  = 1;
    coverpoint a {

      bins a_Valid[] = {[0:5]};
      illegal_bins a_invalid[] = {[5:7]}; // illegal bins have precidence


    }



  endgroup


  c ci;

  initial begin
     ci = new();



    for (int i = 0; i <15; i++) begin
      a = $urandom();
      ci.sample();
      #10;
    end


  end




  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    #400;
    $finish();
  end





endmodule
