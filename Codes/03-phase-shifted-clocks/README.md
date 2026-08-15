# Part 03 — Phase-shifted clocks

EDA Playground: [https://edaplayground.com/x/gi8n](https://edaplayground.com/x/gi8n)

The example creates a 100 MHz reference clock and a separately controlled delayed clock using real-valued phase, on-time, and off-time parameters.

## Complete testbench code

The complete source is rendered here and remains available as [`testbench.sv`](testbench.sv).

~~~systemverilog
// Code your testbench here
// or browse Examples
`timescale 1ns/1ps
module tb() ; 
  reg clk100Mhz = 0; 
  reg clk50Mhz=0;
  always #5 clk100Mhz = ~clk100Mhz ;  
  real phase = 10 ; // b/w reference and new clock is 10 ns 
  real ton =5 ; 
  real toff= 5; 
  initial begin
    #phase; 
    while(1)begin
        clk50Mhz =1; 
        #ton;
        clk50Mhz=0;
        #ton; 
      
    end
  end
  //integrate the code of demonstration part 1 here, 
  // also include demonstration part 2 of section 2 
  
  
endmodule
~~~

## Answers and notes

- `clk100Mhz` toggles every 5 ns, so its period is 10 ns.
- The second generator waits `phase` before producing its first rising edge, then alternates its high and low intervals.
- The low interval currently uses `#ton`; use `#toff` after driving the clock low when independent duty-cycle control is intended.
- Phase should be defined relative to a particular edge. Here the reference clock's first rising edge is at 5 ns, while the second clock's first rising edge is at 10 ns, so the rising-edge offset is 5 ns—not 10 ns.
- The `while (1)` loop runs forever. Add a separate timeout block with `$finish` when running this standalone.

## Detailed discussion

### What frequency the second block actually generates

The signal name `clk50Mhz` states an intention, but its timing controls the real result. The clock stays high for `ton = 5 ns` and low for another 5 ns because the code uses `#ton` twice. Its period is therefore $T=5+5=10\text{ ns}$, giving $f=100\text{ MHz}$. To generate 50 MHz with a 50% duty cycle, use 10 ns high and 10 ns low.

### Phase must be measured between matching edges

The reference clock starts low at 0 ns and has positive edges at 5 ns, 15 ns, 25 ns, and so on. The delayed clock first rises after `#phase`, at 10 ns. Its first rising edge is therefore 5 ns after the reference clock's first rising edge. Saying “phase is 10 ns” only describes the delay from simulation start; edge-to-edge phase offset is 5 ns in this waveform.

For equal-frequency clocks, the corresponding phase angle is

$$
\phi = 360^\circ \frac{\Delta t}{T}
$$

With $\Delta t=5\text{ ns}$ and $T=10\text{ ns}$, the two rising-edge sequences are separated by $180^\circ$.

### Use both duty-cycle parameters

`toff` is declared but never used. The intended loop is conceptually:

~~~systemverilog
clk50Mhz = 1'b1;
#ton;
clk50Mhz = 1'b0;
#toff;
~~~

This makes the complete period $T=t_{on}+t_{off}$ and the high-duty ratio $D=t_{on}/T$. Keeping the parameters separate allows non-50% duty cycles without changing the phase delay.

### Simulation control

Both the reference `always` block and the `while (1)` loop are unbounded. A waveform run therefore needs a separate timeout block such as `#200 $finish;`. Without it, the simulator runs until an external runtime limit stops it.

### Points to remember

- Derive frequency from delays, not from the signal name.
- Define phase relative to a named reference edge.
- Use `ton` and `toff` separately when duty cycle matters.
- Add a deterministic end condition to every free-running clock testbench.
