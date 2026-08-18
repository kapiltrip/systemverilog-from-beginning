# Part 27 — Runtime Constraint Range Changes with randc

[← Part 26](../26-dynamic-range-constraints-with-post-randomize/README.md) · [Learning index](../README.md) · [Part 28 →](../28-constraint-operators-distribution-and-modes/README.md)

EDA Playground: [Runtime Constraint Range Changes with randc](https://edaplayground.com/x/Jsd4)  
EDA Playground Name: `Runtime Constraint Range Changes with randc`  
Saved code ID: `7359033`

## Why this example matters

This playground makes the legal range change between randomization phases. A `randc` variable tracks cyclic history, but a changed constraint can invalidate part of the remaining cycle and force the implementation to form a legal continuation.

That is why “no repetition” needs context: it applies to the active cyclic domain and object history, not as an unconditional promise across arbitrary runtime constraint changes. Compare each printed phase with the range that was active for that call.

## Saved playground settings

- Testbench language: SystemVerilog/Verilog
- Simulator: Siemens Questa 2025.2
- Compile options: `-timescale 1ns/1ns`
- Run options: `-voptargs=+acc=npr`
- run.do, run.bash, EPWave, output-file, and download options: off

## Testbench code

~~~systemverilog
// Code your testbench here
// or browse Examples
// Code your testbench here
// or browse Examples
//WEIGHTED DESTRIBUTION 

class generator ; 
  randc bit [3:0] a ,b ; 
  bit [3:0] y; 
  int min ; 
  int max; 
  function void pre_random(input int min , input int max);
    this.min= min ; 
    this.max=max; 
    
  endfunction 
  constraint pre_rand {
    a inside {[min:max]} ; 
    b inside {[min: max]}; 
    
  }
  function void post_randomize(); 
    $display("The value of a , and b post randomization is : %0d , %0d " , a,b );
  endfunction 
endclass
module tb; 
  generator g; 
  initial begin
    g=new(); 
    g.pre_random(3,8);
    $display("SPACE 1 ");
    for(int i =0; i<10 ; i++)begin
      //g.pre_random(3,12); 
      g.randomize(); 
      #10; 
      // I AM NOT CALLING POST RANDOMIZE RATHER ITS GETTING CALLED ITSELF 
      //rand and randc : will create a bucket and it have an idea of the constraint 
      // but if i changed the constraint in the run time we could see the repetition 
      //ALSO why am i calling it run time constraint changing 
    end
      $display("SPACE 2 ");
    g.pre_random(3,12);
    
      for(int i =0; i<10 ; i++)begin
        //g.pre_random(3,8); 
        g.randomize(); 
        #10; 
      end
    end
endmodule 
~~~

## Questions from the code, explained

### Why does `post_randomize()` run without an explicit call?

**Question in the source**

> // I AM NOT CALLING POST RANDOMIZE RATHER ITS GETTING CALLED ITSELF 

**Where it appears**

testbench.sv:36, inside the first 3–8 randomization loop.

**What the code is doing**

The class defines post_randomize() to print a and b. The first phase calls randomize() after pre_random(3,8), and the second phase does the same after changing the bounds to 3 and 12.

**Answer**

post_randomize() is a built-in callback invoked by randomize() after a successful solve and assignment. The explicit method is therefore called by the randomization mechanism, although the testbench never writes g.post_randomize().

**Why this works**

The [Accellera random-constraints proposal](https://www.accellera.org/images/eda/sv-ec/att-0248/01-Random-Constraints_Proposal.pdf) describes pre-randomization, solving and assignment, then post-randomization, and notes that a failed solve does not invoke post_randomize(). The live log contains a display line after every successful call in both phases. pre_random is explicit because its spelling differs.

**Watch for**

Automatic callback behavior depends on the exact SystemVerilog callback name and a successful randomize() call. The displays are post-solve diagnostics.

**References**

[Accellera random-constraints proposal](https://www.accellera.org/images/eda/sv-ec/att-0248/01-Random-Constraints_Proposal.pdf), [Accellera SV-EC pre/post-randomize discussion](https://www.accellera.org/images/eda/sv-ec/2202.html), and [IEEE 1800 standard page](https://standards.ieee.org/ieee/1800/7743/).

### What do `rand` and `randc` remember about the constraint?

**Question in the source**

> //rand and randc : will create a bucket and it have an idea of the constraint 

**Where it appears**

testbench.sv:37, in the first phase.

**What the code is doing**

Both a and b are randc bit [3:0]. The active constraint restricts them to min and max, and the source labels itself WEIGHTED DESTRIBUTION even though it has no dist expression.

**Answer**

There is no literal bucket. randc uses a random permutation of legal values and avoids repetition within that cycle. This is not a weighted-distribution example: it has no dist constraint, and the Accellera proposal says dist may not be applied to randc.

**Why this works**

The [Accellera random-constraints proposal](https://www.accellera.org/images/eda/sv-ec/att-0248/01-Random-Constraints_Proposal.pdf) describes randc cycles and separately describes dist mixing ratios; it also states the randc restriction. The first interval is 3–8, six values; the second is 3–12, ten values. Ten calls can therefore cross the first cycle boundary.

**Watch for**

Do not infer probability weights from the comment or a repeated value. SystemVerilog uses dist for weights and randc for cyclic behavior.

**References**

[Accellera random-constraints proposal](https://www.accellera.org/images/eda/sv-ec/att-0248/01-Random-Constraints_Proposal.pdf), [Accellera SV-EC pre/post-randomize discussion](https://www.accellera.org/images/eda/sv-ec/2202.html), and [IEEE 1800 standard page](https://standards.ieee.org/ieee/1800/7743/).

### Would changing the constraint at runtime allow repetitions?

**Question in the source**

> // but if i changed the constraint in the run time we could see the repetition 

**Where it appears**

testbench.sv:38, after the first phase's fixed-bound calls.

**What the code is doing**

This source performs the proposed change: it uses pre_random(3,8) for SPACE 1 and pre_random(3,12) before SPACE 2. The constraint text stays the same; the referenced member values change.

**Answer**

Yes. Changing those bound values changes the effective constraint set, and randc may recompute its permutation. Repetition across the phase boundary is possible even though each individual permutation avoids repeating its own values until a new permutation is needed.

**Why this works**

The [Accellera random-constraints proposal](https://www.accellera.org/images/eda/sv-ec/att-0248/01-Random-Constraints_Proposal.pdf) says randc recomputes its permutation when constraints change. Here constraint pre_rand reads min and max; assigning 3 and 12 changes the values admitted by that declared constraint. This is a runtime state change, not a textual edit of the block or a call to constraint_mode(). The live Questa log showed SPACE 1 within 3–8 and SPACE 2 extending through 12.

**Watch for**

Scope no-repeat observations to one randc permutation and one active constraint set. After the effective legal set changes, do not assume previous cycle history prevents a value from appearing in the new phase.

**References**

[Accellera random-constraints proposal](https://www.accellera.org/images/eda/sv-ec/att-0248/01-Random-Constraints_Proposal.pdf), [Accellera SV-EC pre/post-randomize discussion](https://www.accellera.org/images/eda/sv-ec/2202.html), and [IEEE 1800 standard page](https://standards.ieee.org/ieee/1800/7743/).

### Why is this called a runtime constraint change?

**Question in the source**

> //ALSO why am i calling it run time constraint changing 

**Where it appears**

testbench.sv:39, after the comment about seeing repetition.

**What the code is doing**

pre_random assigns this.min and this.max, and the constraint uses those members in two inside ranges. The first phase sets 3–8; the second sets 3–12 before randomize() again.

**Answer**

It is called a runtime constraint change because the program changes values that the active constraint reads while simulation is running, before later randomization calls. The declaration is not rewritten; its evaluated bounds differ in the second phase.

**Why this works**

The [Accellera random-constraints proposal](https://www.accellera.org/images/eda/sv-ec/att-0248/01-Random-Constraints_Proposal.pdf) describes constraint expressions as restrictions on random values and discusses dynamic constraint control and randc recomputation. This code changes min and max through an ordinary function, then calls randomize(), so the later solution space differs. That is distinct from disabling a named block with constraint_mode() or adding randomize() with constraints.

**Watch for**

Calling a helper at runtime does not by itself alter a constraint. It matters here because the helper writes members referenced by the constraint and the solver runs afterward.

**References**

[Accellera random-constraints proposal](https://www.accellera.org/images/eda/sv-ec/att-0248/01-Random-Constraints_Proposal.pdf), [Accellera SV-EC pre/post-randomize discussion](https://www.accellera.org/images/eda/sv-ec/2202.html), and [IEEE 1800 standard page](https://standards.ieee.org/ieee/1800/7743/).

## What happened when it ran

Live EDA run: Questa completed with Errors: 0 and Warnings: 5 total, including stand-alone randomize() compile warnings at testbench.sv lines 34 and 46 and optimization warnings; both SPACE 1 and SPACE 2 produced ten display lines.

The live EDA source and settings were not edited during verification.
