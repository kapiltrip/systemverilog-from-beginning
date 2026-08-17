# Part 26 — Dynamic Range Constraints with post_randomize

EDA Playground: [Dynamic Range Constraints with post_randomize](https://edaplayground.com/x/Zw3t)  
EDA Playground Name: `Dynamic Range Constraints with post_randomize`  
Saved code ID: `7358906`

This README documents the exact source currently saved in the linked EDA Playground. The source panes are preserved verbatim; the explanations below do not replace, correct, or improve the code.

## Saved playground settings

- Testbench language: SystemVerilog/Verilog
- Simulator: Siemens Questa 2025.2
- Compile options: `-timescale 1ns/1ns`
- Run options: `-voptargs=+acc=npr`
- run.do, run.bash, EPWave, output-file, and download options: off

## Verbatim design.sv

~~~systemverilog
// Code your design here
~~~

## Verbatim testbench.sv

~~~systemverilog
// Code your testbench here
// or browse Examples
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
    for(int i =0; i<10 ; i++)begin
      g.pre_random(3,8); 
      g.randomize(); 
      #10; 
      // I AM NOT CALLING POST RANDOMIZE RATHER ITS GETTING CALLED ITSELF 
      //rand and randc : will create a bucket and it have an idea of the constraint 
      // but if i changed the constraint in the run time we could see the repetition 
      //
    end
  end
endmodule 
~~~

## Source fidelity
The two code blocks above are rendered from the corresponding live EDA Playground editor panes for short ID Zw3t. No corrected, reformatted, or self-checking replacement is included. The linked short ID, saved name, and simulator settings are retained for running the original experiment.

## Questions and Answers from the Code

### Why does `post_randomize()` run when the source never calls it?

**Original code question**

> // I AM NOT CALLING POST RANDOMIZE RATHER ITS GETTING CALLED ITSELF 

**Where it appears**

testbench.sv:30, after g.randomize() and #10.

**Context in this playground**

The class defines an ordinary pre_random helper that copies 3 and 8 into min and max, plus a method named post_randomize. The initial block explicitly calls pre_random, then g.randomize(); it never explicitly calls post_randomize.

**Answer**

SystemVerilog automatically invokes the built-in post_randomize() callback after a successful randomize() call. The method here overrides that callback, so its $display runs after the solver assigns a and b.

**Deep explanation**

The [Accellera random-constraints proposal](https://www.accellera.org/images/eda/sv-ec/att-0248/01-Random-Constraints_Proposal.pdf) says classes have built-in pre_randomize() and post_randomize() functions automatically called by randomize() before and after new values are computed; a failed randomization does not call post_randomize(). The name pre_random in this source is different, so it is an ordinary function that runs only because the testbench calls it. The Questa run printed ten post-randomization lines.

**Practical implication or pitfall**

Automatic callback behavior depends on the exact names pre_randomize and post_randomize and on a successful randomize() call. The source's pre_random method is explicit setup code.

**Sources**

[Accellera random-constraints proposal](https://www.accellera.org/images/eda/sv-ec/att-0248/01-Random-Constraints_Proposal.pdf), [Accellera SV-EC pre/post-randomize discussion](https://www.accellera.org/images/eda/sv-ec/2202.html), and [IEEE 1800 standard page](https://standards.ieee.org/ieee/1800/7743/).

### What do `rand` and `randc` remember about the constraint?

**Original code question**

> //rand and randc : will create a bucket and it have an idea of the constraint 

**Where it appears**

testbench.sv:31, immediately after the first randomize() call.

**Context in this playground**

The class declares a and b as randc bit [3:0] and constrains each to the current min–max interval. The source calls randomize() ten times with the same interval, 3 through 8.

**Answer**

The language does not define a literal bucket. randc traverses a random permutation of legal values without repeating within that permutation; the constraint limits the legal values, and the permutation is recomputed when the effective constraints change or remaining values cannot satisfy them.

**Deep explanation**

The [Accellera random-constraints proposal](https://www.accellera.org/images/eda/sv-ec/att-0248/01-Random-Constraints_Proposal.pdf) distinguishes rand from randc and states that randc walks a random permutation, starts a new permutation after a cycle, and recomputes when constraints change. Here each interval has six values, while the loop makes ten calls, so a repeat after a cycle boundary is compatible with randc. No bucket or weighted dist construct appears.

**Practical implication or pitfall**

randc means no repeat within a cycle, not never repeat for the whole simulation. Changing state used by the constraint can change the relevant permutation.

**Sources**

[Accellera random-constraints proposal](https://www.accellera.org/images/eda/sv-ec/att-0248/01-Random-Constraints_Proposal.pdf), [Accellera SV-EC pre/post-randomize discussion](https://www.accellera.org/images/eda/sv-ec/2202.html), and [IEEE 1800 standard page](https://standards.ieee.org/ieee/1800/7743/).

### Would changing the constraint at runtime allow repetitions?

**Original code question**

> // but if i changed the constraint in the run time we could see the repetition 

**Where it appears**

testbench.sv:32, after the unchanged g.pre_random(3,8) call.

**Context in this playground**

This saved source does not actually change the range: every iteration calls g.pre_random(3,8), so the same min and max feed constraint pre_rand. The comment describes a possible experiment rather than an operation performed here.

**Answer**

If values used by the constraint changed between randomize() calls, the effective legal set would change and a randc permutation could be recomputed, allowing a value from the previous set to appear again. In this saved source, no such change occurs; observed repetition comes from completing cycles.

**Deep explanation**

The constraint reads class state min and max, which pre_random assigns before each solve. The [Accellera random-constraints proposal](https://www.accellera.org/images/eda/sv-ec/att-0248/01-Random-Constraints_Proposal.pdf) says randomize() solves active variables under active constraints and that randc recomputes when constraints change. The observed Questa values are run evidence, not a language guarantee.

**Practical implication or pitfall**

Do not call this exact saved source a dynamic-constraint demonstration: pre_random(3,8) repeats with the same arguments. The repository preserves the live code without adding the varying-bounds experiment.

**Sources**

[Accellera random-constraints proposal](https://www.accellera.org/images/eda/sv-ec/att-0248/01-Random-Constraints_Proposal.pdf), [Accellera SV-EC pre/post-randomize discussion](https://www.accellera.org/images/eda/sv-ec/2202.html), and [IEEE 1800 standard page](https://standards.ieee.org/ieee/1800/7743/).

## Verification observed

Live EDA run: Questa completed with Errors: 0 and Warnings: 3 total, including the stand-alone randomize() compile warning and optimization warnings; ten post-randomization display lines were observed.

The live EDA source and settings were not edited during verification.
