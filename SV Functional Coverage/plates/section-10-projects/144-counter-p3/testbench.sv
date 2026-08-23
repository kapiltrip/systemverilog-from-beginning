`timescale 1ns/1ps

// Video 144: monitor-owned coverage collector for the layered counter TB.
interface counter_if(input logic clk);
  logic reset, enable, load;
  logic [3:0] load_value;
  logic [3:0] count;
endinterface

class counter_sample;
  bit       reset;
  bit       enable;
  bit       load;
  bit [3:0] load_value;
  bit [3:0] count;
endclass

class counter_coverage;
  bit       reset;
  bit       enable;
  bit       load;
  bit [3:0] load_value;
  bit [3:0] count;

  covergroup counter_cg;
    option.per_instance = 1;
    cp_reset: coverpoint reset;
    cp_enable: coverpoint enable;
    cp_load: coverpoint load;
    cp_load_value: coverpoint load_value { bins each_value[] = {[0:15]}; }
    cp_count: coverpoint count { bins each_value[] = {[0:15]}; }
    x_control: cross cp_enable, cp_load;
  endgroup

  function new();
    counter_cg = new();
  endfunction

  function void sample(counter_sample item);
    reset = item.reset;
    enable = item.enable;
    load = item.load;
    load_value = item.load_value;
    count = item.count;
    counter_cg.sample();
  endfunction
endclass

class counter_monitor;
  virtual counter_if vif;
  counter_coverage coverage;

  function new(virtual counter_if vif, counter_coverage coverage);
    this.vif = vif;
    this.coverage = coverage;
  endfunction

  task run();
    forever begin
      counter_sample item = new();
      @(posedge vif.clk);
      item.reset = vif.reset;
      item.enable = vif.enable;
      item.load = vif.load;
      item.load_value = vif.load_value;
      item.count = vif.count;
      coverage.sample(item);
      // TODO: send the same item to the scoreboard.
    end
  endtask
endclass

module tb;
  logic clk = 0;
  counter_if counter_vif(clk);
  counter_coverage coverage;
  counter_monitor monitor;

  counter dut (
    .clk(clk), .reset(counter_vif.reset), .enable(counter_vif.enable),
    .load(counter_vif.load), .load_value(counter_vif.load_value),
    .count(counter_vif.count)
  );

  always #5 clk = ~clk;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    coverage = new();
    monitor = new(counter_vif, coverage);
    counter_vif.reset = 1;
    counter_vif.enable = 0;
    counter_vif.load = 0;
    counter_vif.load_value = '0;
    fork monitor.run(); join_none
    repeat (2) @(posedge clk);
    counter_vif.reset = 0;
    repeat (40) begin
      @(negedge clk);
      {counter_vif.enable, counter_vif.load, counter_vif.load_value} = $urandom;
    end
    // TODO: add coverage-driven constraints until all legal bins are closed.
    repeat (2) @(posedge clk);
    $finish;
  end
endmodule
