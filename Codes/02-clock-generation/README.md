# Part 02 — Clock generation

EDA Playground: [https://edaplayground.com/x/gi86](https://edaplayground.com/x/gi86)

This part continues Part 01 by generating several clocks with procedural delays and observing frequency, period, duty cycle, and simulator termination.

## Complete testbench code

The complete source is rendered here and remains available as [`testbench.sv`](testbench.sv).

~~~systemverilog
// Code your testbench here
// or browse Examples
//`timescale 1ns/1ns //1 digits valid after the decimal point
`timescale 1ns/1ps //3 digits valid after the decimal point

module tb();
  //in tb we dont need a sensitivity list in the always block why ? 
  // in the design we need to evaluate for change hence in sensitivity list 
  /*
  always // ignoring sensitivity list 
    always begin
        
    end
    */ 
  reg clk ;  // x by default so i have to initialize 
  reg clk50MHZ;
  reg clk25Mhz; 
  reg clk16Mhz;
  reg clk8Mhz; 
  
  reg rst; 
  //always block to generate a clock signal 
  //100 MHZ 
  //period == 10 ns , and half clock period is 5 ns 
  // run forever 
  initial begin
    rst = 1'b0 ; 
    clk = 1'b0 ;
    clk50MHZ= 1'b0 ; // 20 ns and half is 10 ns 
    
    clk25Mhz = 1'b0 ; 
    clk16Mhz = 1'b0 ; 
    
    clk8Mhz = 1'b0 ; 
    
  end
  always begin
      #5 ; 
      clk50MHZ =1'b1; 
      //#10 clk50MHZ= ~clk50MHZ  ;
      #10 ; 
      clk50MHZ =1'b0; // this is 50 mhz
      #5; 

  end
  always begin
      #31.25 clk16Mhz = ~clk16Mhz ; 
    
  end
  always begin
      #62.5 clk8Mhz = ~clk8Mhz ; 
    
  end
  /*
  always begin
      #20 clk25Mhz = ~ clk25Mhz ;
    
  end
  */
  always begin
      #5;
      clk25Mhz= 1'b1; 
      #20 clk25Mhz = 1'b0 ;
      #5; 
    
  end
  always begin
      #5 clk = ~clk ; 
    
  end
  initial begin
   #200; 
    $finish(); // since im using always block to generate clock 
  end 
  //edges aligned for both clocks
  
  
  initial begin
    $dumpfile("demo.vcd");
    $dumpvars();
  end 
  
endmodule
~~~

## Question: Why can a testbench `always` block omit a sensitivity list?

A testbench clock generator is an intentional procedural loop. A delay inside the block advances simulation time, and after the last statement the `always` block starts again. It does not wait for an input signal to change.

Design logic normally reacts to events:

- Combinational logic uses `always_comb` (preferred SystemVerilog) or `always @*` so it is reevaluated when a read input changes.
- Sequential logic uses an explicit event such as `always_ff @(posedge clk)`.
- A delay-free `always begin ... end` is unsafe because it loops forever at the same simulation time.

## Clock calculations

- `always #5 clk = ~clk` gives a 10 ns period, or 100 MHz.
- `always #31.25 clk16Mhz = ~clk16Mhz` gives a 62.5 ns period, or 16 MHz.
- `always #62.5 clk8Mhz = ~clk8Mhz` gives a 125 ns period, or 8 MHz.
- The active `clk50MHZ` block produces a 20 ns period, or 50 MHz.
- The active `clk25Mhz` block has a 30 ns period and is therefore about 33.33 MHz, not 25 MHz. A symmetric 25 MHz clock can use `always #20 clk25Mhz = ~clk25Mhz`.
- `$finish` is required because clock-generating `always` blocks otherwise run forever.

## Detailed discussion

### Frequency comes from the complete period

For a clock that toggles after a half-period delay, the full period is twice that delay. Frequency follows $f=1/T$. With time measured in nanoseconds, a convenient conversion is $f_{MHz}=1000/T_{ns}$.

| Signal | Rising-edge period | Frequency | Duty-cycle observation |
| --- | ---: | ---: | --- |
| `clk` | 10 ns | 100 MHz | 5 ns high, 5 ns low |
| `clk50MHZ` | 20 ns | 50 MHz | 10 ns high, 10 ns low after startup |
| `clk16Mhz` | 62.5 ns | 16 MHz | Symmetric toggle clock |
| `clk8Mhz` | 125 ns | 8 MHz | Symmetric toggle clock |
| active `clk25Mhz` block | 30 ns | about 33.33 MHz | 20 ns high, 10 ns low |

The active `clk25Mhz` generator therefore does not generate 25 MHz. The commented form `always #20 clk25Mhz = ~clk25Mhz` gives a 40 ns period and the intended 25 MHz frequency.

### Why the delay prevents an infinite zero-time loop

An `always` block restarts immediately after its final statement. Each clock block contains a `#` delay, so simulation time advances before the next assignment. If the body had no delay or event control, it would execute forever at time 0 and prevent the simulator from progressing.

### Sensitivity lists belong to reactive design behavior

A testbench clock is stimulus: it creates events according to time. Combinational design logic instead reacts when an input changes, so `always_comb` or `always @*` supplies the required sensitivity. Sequential design logic reacts to a clock or reset edge, for example `always_ff @(posedge clk)`. The difference is not simply “testbench versus design”; it is whether a process generates timed stimulus or reacts to signal events.

### Points to remember

- Calculate the period between equivalent edges, such as rising edge to rising edge.
- Frequency names do not prove that generated timing is correct; verify the delays.
- Unequal high and low intervals change duty cycle as well as period.
- Free-running clocks require a separate timeout and `$finish`.
