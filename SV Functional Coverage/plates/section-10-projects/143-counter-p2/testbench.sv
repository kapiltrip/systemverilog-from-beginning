`timescale 1ns/1ps

// Video 143: transaction, generator, driver, and monitor starter classes.
interface counter_if(input logic clk);
  logic reset, enable, load;
  logic [3:0] load_value;
  logic [3:0] count;
endinterface

class counter_transaction;
  rand bit       enable;
  rand bit       load;
  rand bit [3:0] load_value;
  constraint prefer_counting { load dist {0 := 3, 1 := 1}; }
endclass

class counter_generator;
  mailbox #(counter_transaction) outbox;
  event finished;

  function new(mailbox #(counter_transaction) outbox);
    this.outbox = outbox;
  endfunction

  task run(int number_of_items = 20);
    repeat (number_of_items) begin
      counter_transaction item = new();
      assert (item.randomize());
      outbox.put(item);
    end
    ->finished;
  endtask
endclass

class counter_driver;
  virtual counter_if vif;
  mailbox #(counter_transaction) inbox;

  function new(virtual counter_if vif, mailbox #(counter_transaction) inbox);
    this.vif = vif;
    this.inbox = inbox;
  endfunction

  task run();
    forever begin
      counter_transaction item;
      inbox.get(item);
      @(negedge vif.clk);
      vif.enable = item.enable;
      vif.load = item.load;
      vif.load_value = item.load_value;
    end
  endtask
endclass

class counter_monitor;
  virtual counter_if vif;

  function new(virtual counter_if vif);
    this.vif = vif;
  endfunction

  task run();
    forever begin
      @(posedge vif.clk);
      $display("count=%0d reset=%0b enable=%0b load=%0b", vif.count,
               vif.reset, vif.enable, vif.load);
      // TODO: publish a sampled transaction to scoreboard and coverage mailboxes.
    end
  endtask
endclass

module tb;
  logic clk = 0;
  counter_if counter_vif(clk);

  counter dut (
    .clk(clk), .reset(counter_vif.reset), .enable(counter_vif.enable),
    .load(counter_vif.load), .load_value(counter_vif.load_value),
    .count(counter_vif.count)
  );

  mailbox #(counter_transaction) generator_to_driver = new();
  counter_generator generator;
  counter_driver driver;
  counter_monitor monitor;

  always #5 clk = ~clk;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    counter_vif.reset = 1;
    counter_vif.enable = 0;
    counter_vif.load = 0;
    counter_vif.load_value = '0;
    generator = new(generator_to_driver);
    driver = new(counter_vif, generator_to_driver);
    monitor = new(counter_vif);
    repeat (2) @(posedge clk);
    counter_vif.reset = 0;
    fork
      generator.run();
      driver.run();
      monitor.run();
    join_none
    @generator.finished;
    repeat (3) @(posedge clk);
    $finish;
  end
endmodule
