# Project 01 — FSM Verification with SVA

[SV Assertions home](../../README.md) · [Projects index](../README.md) · [Project 02 →](../02-counter-assertions-with-bind/README.md)

| Playground field | Value |
|---|---|
| EDA Playground Name | Blank in the captured browser field |
| Stable playground | [8hjZ](https://edaplayground.com/x/8hjZ) |
| EDA code ID | `7378241` |
| Simulator | Siemens Questa 2025.2 |
| Compile / run options | `-timescale 1ns/1ns` / `-voptargs=+acc=npr` |
| Verified live result | 0 compile errors; assertion failures at 5 ns (`state_enconding`) and 85 ns (`din_high`); finish at 180 ns |
| Open EPWave after run | Disabled |

This is a project rather than another numbered syntax lesson because it combines a substantive three-state RTL design with a verification testbench. Both browser panes are preserved exactly. The fresh run intentionally remains evidence-bearing: the two assertion failures are analyzed below instead of being hidden by editing the captured source.

## Exact browser design

~~~systemverilog
// Code your design here
// Code your design here 
module fsm( 
  input wire clk ,rst,  
  input wire x, 
  output reg y 
); 
  
  /*
  // 3 states  
  reg [2:0] state, next_state;  
  parameter idle= 3'b000; 
  parameter s0 = 3'b001; 
  parameter s1 = 3'b010;  
   */
  typedef enum bit [2:0] {
    idle = 3'b001, 
    s0= 3'b010, 
    s1= 3'b100 
    
  } state_a; 
  state_a state,next_state;  // similar to int a , b; 
  // present state logic  
  always @(posedge clk )begin 
    if(rst)begin 
      state<= idle;   
    end else  
      state<= next_state;  
  end 

  always @(*)begin 
    next_state = state ;  
    y=1'b0;  

    case (state) 
      idle : next_state = s0 ; 
      
      s0: next_state= (x)? s1:s0;  

      s1: begin 
        if(x)begin 
          next_state = s0;  
          y= 1'b1;  
        end else begin 
          next_state = s1;  
        end 
      end 

      default : next_state = idle ;  
    endcase 
  end 
endmodule
~~~

Local source: [design.sv](design.sv).

## Exact browser testbench

~~~systemverilog
// Code your testbench here
// or browse Examples
module tb;
  reg clk =0; 
  reg x=0; 
  reg rst=0; 
  wire y; 
  fsm dut(
    .clk (clk ), 
    .rst(rst),
    .x(x),
    .y(y)
  );
  always #5 clk = ~clk ; 
  initial begin
    #3;
    rst=1; 
    #30; 
    rst=0; 
    x=1; 
    #45; 
    x=0; 
    #25;
    rst=1;
    #40;
    rst=0;
    
  end
      initial begin
      $dumpfile("dump.vcd");
      $dumpvars; 
      $assertvacuousoff(0); 
      #180; 
      $finish();
    end
  // states are one hot encoded
  state_enconding : assert property (@(posedge clk) 1'b1|-> $onehot(dut.state))  $info("ALL THE STATES ARE ONE HOT ENCODED ");
    // if reset assert system stays in idle state 
    resetRelated : assert property (@(posedge clk) $rose(rst) |=> (dut.state == dut.idle)) $info("SUCCESS the state is idle when rst asserted at time %0t" , $time ); // since synchronous reset
      resetHigh: assert property (@(posedge clk) $rose(rst) |=> (dut.state == dut.idle) [*1:18] within rst[*1:18] ##1 !rst ) $info("checking for the whole duration of time i.e 180 ns and the clock period is of 10 ns hence 18 clock ticks  "); 
         // within rhs is reference sequence 
        //if reset deasserted system transit to correct state based on value of din 
    //    3)
      //so for the behaviour of din we must develop sequences 
        // behaviour for din == 1 
        sequence s1;
          (dut.next_state == dut.idle ) ##1 (dut.next_state == dut.s0); 
        endsequence 
        
        sequence s2;
          (dut.next_state == dut.s0 ) ##1 (dut.next_state == dut.s1); 
        endsequence 
        
        sequence s3;
          (dut.next_state == dut.s1 ) ##1 (dut.next_state == dut.s0); 
        endsequence 
        
        
        din_high: assert property (@(posedge clk) disable iff(rst) x |-> (s1 or s2 or s3)) $info("verified for x == 1 i.e high "); 
          
        
        sequence s4;
          (dut.next_state == dut.idle ) ##1 (dut.next_state == dut.idle); 
        endsequence 
        
        sequence s5;
          (dut.next_state == dut.s0 ) ##1 (dut.next_state == dut.s0); 
        endsequence 
        
        sequence s6;
          (dut.next_state == dut.s1 ) ##1 (dut.next_state == dut.s1); 
        endsequence    
        
          din_low: assert property (@(posedge clk) disable iff(rst) !x |-> (s4 or s5 or s6)) $info("verified for x being low ") ; 
        
        
        // I can also use property similarly 
         // all the states are covered or not 
            initial assert property (@(posedge clk) (dut.state == dut.idle) [->1] |-> ##[1:18] (dut.state == dut.s0) ##[1:18] (dut.state==dut.s1 )) ; 
              
        // idle then s0 then s1 , 
        
        
        // if we get and expected o/p if rst is deasserted 
              assert property (@(posedge clk) disable iff(rst) ((dut.next_state== dut.s0) && ($past(dut.next_state) == dut.s1)) |-> (y == 1'b1)); 
                
            

endmodule 
~~~

Local source: [testbench.sv](testbench.sv).

## Design behavior

The active state encoding is one-hot:

| State | Encoding |
|---|---:|
| `idle` | `3'b001` |
| `s0` | `3'b010` |
| `s1` | `3'b100` |

`rst` is an active-high **synchronous** reset because it is read only inside `always @(posedge clk)`. State changes use a nonblocking assignment. The combinational next-state and output behavior is:

| Current state | `x` | Next state | `y` |
|---|---:|---|---:|
| `idle` | 0 or 1 | `s0` | 0 |
| `s0` | 0 | `s0` | 0 |
| `s0` | 1 | `s1` | 0 |
| `s1` | 0 | `s1` | 0 |
| `s1` | 1 | `s0` | 1 |

Because `y` depends on both the present state and current input, it is a combinational Mealy-style output.

## Assertion inventory

| Check | Intended purpose | What the captured property actually observes |
|---|---|---|
| `state_enconding` | State is always one-hot | `$onehot(dut.state)` on every positive edge, including startup/reset |
| `resetRelated` | Reset leads to `idle` | A sampled reset rise implies `idle` one clock later |
| `resetHigh` | State remains idle during a reset pulse | An idle repetition of length 1–18 must fit somewhere inside a reset-high sequence of length 1–18 |
| `din_high` | Correct transitions while `x=1` | A two-sample sequence of values on `next_state` chosen from `s1`/`s2`/`s3` |
| `din_low` | Correct transitions while `x=0` | A two-sample same-value sequence on `next_state` |
| procedural `initial assert property` | Visit `idle`, then `s0`, then `s1` | A one-time assertion attempt; it is not coverage |
| final unlabeled assertion | Assert `y` for the apparent `s1→s0` path | Compares current and `$past` values of combinational `next_state` |

## Verified run

Questa compiled and optimized both panes. The fresh browser run reached `$finish` at 180 ns.

| Time | Finding |
|---:|---|
| 5 ns | `state_enconding` failed |
| 15 ns | First synchronous-reset check passed |
| 35 ns | First `resetHigh` attempt passed |
| 45, 55, 65, 75 ns | `din_high` attempts passed |
| 85 ns | One `din_high` attempt failed |
| 95 ns onward | Observed `din_low` attempts passed |
| 115 ns | Second synchronous-reset check passed |
| 145 ns | Second `resetHigh` attempt passed |
| 180 ns | Simulation finished |

The summary was 0 `qrun`/`vlog` errors and 2 `vsim` assertion errors. The one additional total warning was the Questa optimization warning associated with `+acc`, not a source compile error.

## Q&A and verification findings

### Q: Why does the one-hot assertion fail at 5 ns?

The enum is declared with a two-state base type:

~~~systemverilog
typedef enum bit [2:0] { ... } state_a;
~~~

Before the first state-register assignment takes effect, `state` has the two-state startup value `3'b000`. That is not one-hot. Reset is already high at the 5 ns positive edge, but `state <= idle` is a nonblocking assignment, so the assertion samples the old `000` value before the NBA update becomes visible.

A startup-aware invariant can abort while reset is active:

~~~systemverilog
state_encoding: assert property (@(posedge clk)
  disable iff (rst)
  $onehot(dut.state)
);
~~~

That is stronger than changing to `$onehot0`, which would permanently allow the all-zero encoding even after initialization.

### Q: Why does `din_high` fail at 85 ns?

The failing attempt starts at 75 ns while `x` is high. At that sample, `next_state` is `s0`, so only sequence `s2` can match:

~~~systemverilog
(next_state == s0) ##1 (next_state == s1)
~~~

The testbench changes `x` from 1 to 0 at 78 ns. At the next positive edge, 85 ns, the FSM is in `s0` and the low input makes `next_state` stay at `s0`. The expected second endpoint `s1` is therefore false.

This is not a compile problem, and it does not by itself prove an RTL bug. The property samples `x` only at the attempt's start but assumes the high-input transition pattern will still hold one clock later. The input is allowed to change between those samples.

### Q: How can the next-state checks match the RTL more directly?

Check the current state, current input, and combinational next state on the **same** sampled edge:

~~~systemverilog
din_high_direct: assert property (@(posedge clk)
  disable iff (rst)
  x |-> (
    (dut.state == dut.idle && dut.next_state == dut.s0) ||
    (dut.state == dut.s0   && dut.next_state == dut.s1) ||
    (dut.state == dut.s1   && dut.next_state == dut.s0)
  )
);

din_low_direct: assert property (@(posedge clk)
  disable iff (rst)
  !x |-> (
    (dut.state == dut.idle && dut.next_state == dut.s0) ||
    (dut.state == dut.s0   && dut.next_state == dut.s0) ||
    (dut.state == dut.s1   && dut.next_state == dut.s1)
  )
);
~~~

These forms encode the transition table without requiring `x` to retain its old value through another clock. Notice especially that `idle` goes to `s0` for either input value; the captured `din_low` sequence named `s4` instead describes `next_state: idle→idle`.

### Q: Why is nonoverlapped implication appropriate for the synchronous reset check?

At a clock edge with `rst=1`, the register schedules `state <= idle` in the NBA region. A concurrent assertion samples before that update. `|=>` checks at the next property clock, when the reset assignment from the initiating edge is observable:

~~~systemverilog
$rose(rst) |=> dut.state == dut.idle
~~~

The run confirmed this at 15 ns for the reset rise sampled at 5 ns, and at 115 ns for the rise sampled at 105 ns.

### Q: Does `resetHigh` prove that state stays idle for the entire reset pulse?

Not exactly. With:

~~~systemverilog
(state == idle)[*1:18] within rst[*1:18] ##1 !rst
~~~

the left sequence may choose a match as short as one clock and only needs to fit inside the right sequence. A pass therefore proves that a qualifying idle run was contained in the reset pulse; it does not necessarily require every reset-high sample to be idle.

A direct synchronous invariant is clearer:

~~~systemverilog
reset_holds_idle: assert property (@(posedge clk)
  rst |=> dut.state == dut.idle
);
~~~

Every sampled high-reset edge then creates an obligation that checks the state produced by that reset edge.

### Q: Is the “all states are covered” line actually coverage?

No. It uses `assert property`, so it is a correctness check and a successful match has no default pass print. Coverage requires `cover property`:

~~~systemverilog
cover_all_states: cover property (@(posedge clk)
  disable iff (rst)
  dut.state == dut.idle ##1
  dut.state == dut.s0   ##[1:18]
  dut.state == dut.s1
);
~~~

An assertion asks whether required behavior ever fails. A cover property records whether an interesting behavior occurred. Those are different verification questions.

### Q: How can the output be checked more precisely?

The RTL defines `y` as 1 exactly when present state is `s1` and `x` is 1. An equivalence checks both directions:

~~~systemverilog
output_decode: assert property (@(posedge clk)
  disable iff (rst)
  y == ((dut.state == dut.s1) && x)
);
~~~

The captured property only checks one implication based on a current/past pattern of `next_state`. It can miss an illegal extra pulse because it does not require `y=0` everywhere else.

### Q: Why are internal enum literals written as `dut.idle`, `dut.s0`, and `dut.s1`?

The assertions live in the testbench and reach into the DUT hierarchically. That is convenient for a small unit-level exercise. In reusable verification code, exposing an abstract state indication, placing assertions in an interface, or binding an assertion module is usually less coupled to the RTL hierarchy.

### Q: Does `disable iff(rst)` behave like the synchronous design reset?

Not exactly. `disable iff` is an asynchronous abort condition for active assertion attempts; it is not sampled as an ordinary sequence term. That is useful for suppressing checks while reset is active, but the design's state register still responds to reset only on `posedge clk`. Keep those two semantics distinct.

## Suggested verification split

A maintainable FSM checker usually separates:

1. **Encoding invariant** — legal/one-hot present state after reset.
2. **Reset behavior** — reset produces and holds the reset state.
3. **Transition relation** — each `(state, input)` pair maps to the correct `next_state`.
4. **State-register update** — without reset, sampled `next_state` becomes the next sampled `state`.
5. **Output decode** — outputs equal their specified state/input function.
6. **Coverage** — important states and transitions are actually exercised.

This separation makes a failure point to one rule instead of asking a long temporal sequence to prove several ideas at once.

## Revision checks

1. Why is the startup value `000` even though the enum lists only one-hot values?
2. Why is the reset assignment not visible to the 5 ns one-hot sample?
3. What input change causes the `din_high` attempt from 75 ns to fail at 85 ns?
4. Why are same-sample transition-table assertions tighter here?
5. What does `within` prove, and why is a one-sample left match weaker than “idle for the whole pulse”?
6. When should `cover property` replace `assert property`?
7. Why is an output equivalence stronger than a one-way implication?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [IEEE Std 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F24/documentation/1800-2017.pdf) — Clauses 6.19 (Enumerations), 9 (Processes), and 16 (Assertions)
- [Accellera SystemVerilog Assertions tutorial](https://www.accellera.org/resources/videos/systemverilog-assertions-tutorial-2016)
