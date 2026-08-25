`timescale 1ns/1ps

// Video 098: decode a transaction in functions, then sample the enum result.
module tb;
  reg rd, wr, en;
  reg [1:0] din;
  integer i = 0;
  typedef enum int
    {
      write,
      read,
      NOP,
      error
    } opstate;
  opstate o1, o2;

  function opstate detect_state (input rd, input wr, input en);
    if(en == 0)
      return NOP;
    else if (en == 1 && wr == 1 && rd == 0)
      return write;
    else if (en == 1 && wr == 0 && rd == 1)
      return read;
    else
      return error;

  endfunction
  function bit [1:0] decode_state (input opstate oin);
    if(oin == NOP)
      return 2'b00;
    else if(oin == write)
      return 2'b01;
    else if (oin == read)
      return 2'b10;
    else if (oin == error)
      return 2'b11;

  endfunction

  function void check_coverage (input bit rd, input bit wr, input bit en);
    o1 = detect_state(rd, wr, en);
    //din = decode_state(o1);  // 2 bit value , now i will see the coverage of that 2 bit value
    ci.sample(o1);  // cause o1 holds the state
  endfunction
  //covergroup c with function sample(input bit [1:0] cin );
  covergroup c with function sample(input opstate cin); // opstate is the enum type

    option.per_instance = 1;
    coverpoint cin;

  endgroup
  c ci;
  initial begin
    ci = new();
    for(i = 0; i < 10; i++)begin
      wr = $urandom();
      rd = $urandom();
      en = $urandom();
      check_coverage(rd, wr, en);  // the main function
      #10;
    end
  end
endmodule
