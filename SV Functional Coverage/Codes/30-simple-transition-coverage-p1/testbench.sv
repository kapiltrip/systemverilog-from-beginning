`timescale 1ns/1ps

// Video 121: legal toggles and illegal same-state behavior while d is high.
module tb;
  reg clk =0 ;
  reg reset = 0 ;
  reg d =0 ;
  wire d_out;


  two_state_fsm dut (clk , reset , d , d_out );

  initial  repeat (50) #5 clk = ~ clk ;
  initial begin
    repeat (4) @(posedge clk ) {reset  , d }= 2'b10 ;
    repeat (4) @(posedge clk ) {reset , d }= 2'b01 ;
    repeat (4) @(posedge clk ) {reset , d }= 2'b10 ;
    repeat (1) @(posedge clk ) {reset , d }= 2'b10 ;
    repeat (4) @(posedge clk ) {reset , d }= 2'b00 ;

  end
  covergroup c1 @(posedge clk ) ;
    option.per_instance = 1;

    coverpoint reset {
      bins reset_high = {1};
      bins reset_low = {0};
    }
    coverpoint d{
      bins d_high = {1};
    }
    coverpoint d_out {
      bins d_out_high = {1};
      bins d_out_low = {0};

    }
    coverpoint dut.state iff(d == 1'b1){
      bins transition_s0_s1 = (dut.s0 => dut.s1) ;
      bins transition_s1_s0 = (dut.s1 => dut.s0) ;
      illegal_bins same_state = (dut.s0 => dut.s0 , dut.s1 => dut.s1 );

    }
    cross reset , d, dut.state {
      ignore_bins reset_is_high = binsof(reset) intersect {1} ;
    }
  endgroup

    covergroup c2 @(posedge clk ) ;
      option.per_instance = 1;


    coverpoint d{
      bins d_low  = {0};
    }

     coverpoint dut.state iff(d == 1'b0){
       bins transition_s0_s0 = (dut.s0 => dut.s0) ;
       bins transition_s1_s1 = (dut.s1 => dut.s1) ;
       illegal_bins same_state = (dut.s0 => dut.s1 , dut.s1 => dut.s0 );

    }
    cross reset , d, dut.state {
      ignore_bins reset_is_high = binsof(reset) intersect {1} ;
    }
  endgroup
  c1 ci;
  c2 ci2 ;
  initial begin
    ci = new();
    ci2 = new();

  end
endmodule
