// Code your testbench here
// or browse Examples
// edge sensitive @ and level sensitive wait
/*
module tb ;
  event a1,a2;
  initial begin
    ->a1; // triggering an event a1
    #10;
    ->a2;

  end
  initial begin
    @(a1);  // -> showing blocking behaviour edge sensitive
            // if i didnt sense a1 it will go to blocking state

    $display("Event a1 triggered ");
    @(a2);
    $display("event a2 triggered ");
  end
endmodule
*/
module tb ;
  event a1,a2;
  initial begin
    ->a1; // triggering an event a1
    //#10;
    ->a2;

  end
  initial begin
    wait(a1.triggered);  // -> showing blocking behaviour edge sensitive level sensitive but what is the level actually ?


    $display("Event a1 triggered ");
    wait(a2.triggered);
    $display("event a2 triggered ");
  end
endmodule

//generator multiple stimulai task _ gen to generate random value
// to send that value to the driver
// generator -> driver take out the data -> applying it to dut transaction to dut ->
// to hold simulation -> all task operating in parallel
