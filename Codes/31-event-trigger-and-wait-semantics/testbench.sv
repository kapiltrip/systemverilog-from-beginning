// Code your testbench here
// or browse Examples
//generation , finished generation , event trigger , @ , wait
//semaphore to access resources , (interface ) get / put
// mailboxes to send transaction data , from generator to driver also b/w monitor and  socreboard
// 1 ) to conver process is finished like sending of transactions is finished
// 2)to transfer a transaction , (b/w generator adn driver and monitor and scoreboard
//event -> to convay messages b/w classes
`timescale 1ns/1ps

module tb;
  //trigger and event ->
  // to sense and event , edge sensitive and blocking @
  // to sense an event , level sensitive and non blocking wait ()
  event a ;
  initial begin
    #10;
    ->a;

  end
  initial begin
    @(a); // wait for a blockign edge sensitive
    wait(a.triggered); // level sensitive

    $display("Event received at a time %0t" , $time);
  end
endmodule
