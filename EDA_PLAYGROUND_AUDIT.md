# EDA Playground and Source Audit

This audit records the evidence for the verbatim-source and cited-Q&A pass. The naming-pass reference is baseline commit `491f409a1a09f224e0fa2d2eca4970e9f1ead00c`; work continued on the existing branch `kapil/systemverilog-playground-backlog` without creating or switching branches.

## Identity, order, and one-to-one mapping

The queue is mapped in order 01 through 16. Each short ID is the existing EDA Playground link; no copy or fork was created. The visible titles and saved Name fields were read through the dedicated Edge browser-control binding. The repository H1, root index title, and saved EDA Name agree semantically (parts 01–06 retain their established `SV 0X - ...` names).

| Part | Short ID/link | Exact saved EDA Name | Visible browser-tab title | Code ID | Folder slug | Folder README H1 | Root index title | Source files | Settings |
|---:|---|---|---|---:|---|---|---|---|---|
| 01 | [Ucnp](https://edaplayground.com/x/Ucnp) | SV 01 - Simulation Basics | SV 01 - Simulation Basics - EDA Playground | 7356115 | `01-simulation-basics` | Part 01 — SV 01 - Simulation Basics | SV 01 - Simulation Basics | design.sv, testbench.sv | Riviera Pro 2025.04; `-timescale 1ns/1ns`; `+access+r` |
| 02 | [gi86](https://edaplayground.com/x/gi86) | SV 02 - Clock Generation | SV 02 - Clock Generation - EDA Playground | 7356140 | `02-clock-generation` | Part 02 — SV 02 - Clock Generation | SV 02 - Clock Generation | design.sv, testbench.sv | Riviera Pro 2025.04; `-timescale 1ns/1ns`; `+access+r` |
| 03 | [gi8n](https://edaplayground.com/x/gi8n) | SV 03 - Phase-Shifted Clocks | SV 03 - Phase-Shifted Clocks - EDA Playground | 7356180 | `03-phase-shifted-clocks` | Part 03 — SV 03 - Phase-Shifted Clocks | SV 03 - Phase-Shifted Clocks | design.sv, testbench.sv | Riviera Pro 2025.04; `-timescale 1ns/1ns`; `+access+r` |
| 04 | [giAN](https://edaplayground.com/x/giAN) | SV 04 - Data Types and Time | SV 04 - Data Types and Time - EDA Playground | 7356270 | `04-data-types-and-time` | Part 04 — SV 04 - Data Types and Time | SV 04 - Data Types and Time | design.sv, testbench.sv | Riviera Pro 2025.04; `-timescale 1ns/1ns`; `+access+r` |
| 05 | [8k9Q](https://edaplayground.com/x/8k9Q) | SV 05 - Fixed Arrays and For Loop | SV 05 - Fixed Arrays and For Loop - EDA Playground | 7356341 | `05-fixed-arrays-and-for-loop` | Part 05 — SV 05 - Fixed Arrays and For Loop | SV 05 - Fixed Arrays and For Loop | design.sv, testbench.sv | Riviera Pro 2025.04; `-timescale 1ns/1ns`; `+access+r` |
| 06 | [GK3p](https://edaplayground.com/x/GK3p) | SV 06 - Array Iteration | SV 06 - Array Iteration - EDA Playground | 7356382 | `06-array-iteration` | Part 06 — SV 06 - Array Iteration | SV 06 - Array Iteration | design.sv, testbench.sv | Riviera Pro 2025.04; `-timescale 1ns/1ns`; `+access+r` |
| 07 | [CafY](https://edaplayground.com/x/CafY) | Whole-Array Copying | Whole-Array Copying - EDA Playground | 7356412 | `07-array-copying` | Part 07 — Whole-Array Copying | Whole-Array Copying | design.sv, testbench.sv | Riviera Pro 2025.04; `-timescale 1ns/1ns`; `+access+r` |
| 08 | [bKTC](https://edaplayground.com/x/bKTC) | Queue Operations | Queue Operations - EDA Playground | 7356536 | `08-queue-operations` | Part 08 — Queue Operations | Queue Operations | design.sv, testbench.sv | Riviera Pro 2025.04; `-timescale 1ns/1ns`; `+access+r` |
| 09 | [qLDu](https://edaplayground.com/x/qLDu) | Class Object Basics | Class Object Basics - EDA Playground | 7356678 | `09-class-object-basics` | Part 09 — Class Object Basics | Class Object Basics | design.sv, testbench.sv | Riviera Pro 2025.04; `-timescale 1ns/1ns`; `+access+r` |
| 10 | [ecCx](https://edaplayground.com/x/ecCx) | Tasks and Functions | Tasks and Functions - EDA Playground | 7356696 | `10-tasks-and-functions` | Part 10 — Tasks and Functions | Tasks and Functions | design.sv, testbench.sv | Riviera Pro 2025.04; `-timescale 1ns/1ns`; `+access+r` |
| 11 | [Ua2v](https://edaplayground.com/x/Ua2v) | Pass by Reference | Pass by Reference - EDA Playground | 7357015 | `11-pass-by-reference` | Part 11 — Pass by Reference | Pass by Reference | design.sv, testbench.sv | Riviera Pro 2025.04; `-timescale 1ns/1ns`; `+access+r` |
| 12 | [ADYn](https://edaplayground.com/x/ADYn) | Array Reference Passing | Array Reference Passing - EDA Playground | 7357071 | `12-array-reference-passing` | Part 12 — Array Reference Passing | Array Reference Passing | design.sv, testbench.sv | Riviera Pro 2025.04; `-timescale 1ns/1ns`; `+access+r` |
| 13 | [Ud7M](https://edaplayground.com/x/Ud7M) | Constructor Arguments | Constructor Arguments - EDA Playground | 7357115 | `13-constructor-arguments` | Part 13 — Constructor Arguments | Constructor Arguments | design.sv, testbench.sv | Riviera Pro 2025.04; `-timescale 1ns/1ns`; `+access+r` |
| 14 | [EasK](https://edaplayground.com/x/EasK) | Class Composition and Scope | Class Composition and Scope - EDA Playground | 7357152 | `14-class-composition-and-scope` | Part 14 — Class Composition and Scope | Class Composition and Scope | design.sv, testbench.sv | Riviera Pro 2025.04; `-timescale 1ns/1ns`; `+access+r` |
| 15 | [sVdz](https://edaplayground.com/x/sVdz) | Class Shallow Copy | Class Shallow Copy - EDA Playground | 7357619 | `15-class-shallow-copy` | Part 15 — Class Shallow Copy | Class Shallow Copy | design.sv, testbench.sv | Riviera Pro 2025.04; `-timescale 1ns/1ns`; `+access+r` |
| 16 | [X4c6](https://edaplayground.com/x/X4c6) | Class Custom Copy Method | Class Custom Copy Method - EDA Playground | 7357655 | `16-class-custom-copy-method` | Part 16 — Class Custom Copy Method | Class Custom Copy Method | design.sv, testbench.sv, editor_testbench.sv | Riviera Pro 2025.04; `-timescale 1ns/1ns`; `+access+r` |

Every mapped page had a nonblank, unique saved Name. Parts 07–16 were rechecked in Edge during the naming audit; the final rescan also included the agent-created same-link inspection tab and left all original tabs open. No page code or simulator setting was edited during this documentation pass.

## Normalized source fingerprints

SHA-256 values below are computed from the captured live pane after normalizing CRLF to LF. The common design pane is the literal `// Code your design here` source. A repository comparison must normalize the same way; a final newline difference is not treated as a source change.

| Part | Design SHA-256 | Testbench SHA-256 | README Q&A entries | Unique authoritative URLs used in Q&A |
|---:|---|---|---:|---:|
| 01 | `d2c99ccc005b1f9d188df2479be15a08b6fd8a9ad4e05568c2b02a9fc1a30553` | `6b2c4b610dea4841d4560ac795858976c7ed3208f217e8e0a394efc2cad90434` | 2 | 2 |
| 02 | `d2c99ccc005b1f9d188df2479be15a08b6fd8a9ad4e05568c2b02a9fc1a30553` | `db1f520df21efa383911b818845504e155e7a4fe83618bdfba3aa4386ed4d042` | 3 | 2 |
| 03 | `d2c99ccc005b1f9d188df2479be15a08b6fd8a9ad4e05568c2b02a9fc1a30553` | `90bffe4f701269b7a8530a81f04b2f5be76aae1d9bf94a265349c4cf91098ef6` | 0 | 0 |
| 04 | `d2c99ccc005b1f9d188df2479be15a08b6fd8a9ad4e05568c2b02a9fc1a30553` | `06ab68f7307231c22792892f918aa6fefcf0ee91868e79afb419b829d28e0ff0` | 3 | 2 |
| 05 | `d2c99ccc005b1f9d188df2479be15a08b6fd8a9ad4e05568c2b02a9fc1a30553` | `5c32b4d2c481d6b10b6fe59b2a4720a0424908800b92cb27a41d1d6ce71da1c3` | 4 | 2 |
| 06 | `d2c99ccc005b1f9d188df2479be15a08b6fd8a9ad4e05568c2b02a9fc1a30553` | `e650ea0a71aff866595dc1f34f1759d9db1f7f0082c82544c1a4dab34393673a` | 1 | 2 |
| 07 | `d2c99ccc005b1f9d188df2479be15a08b6fd8a9ad4e05568c2b02a9fc1a30553` | `165c3ea6c682060bd0baa531feb2bc884b5336e629c4c5f898ad4691e266f2d7` | 4 | 1 |
| 08 | `d2c99ccc005b1f9d188df2479be15a08b6fd8a9ad4e05568c2b02a9fc1a30553` | `89b81f57c11680cc769a2bd8e8a8f410e483c01248b6447b445df5ec2a456a8d` | 1 | 1 |
| 09 | `d2c99ccc005b1f9d188df2479be15a08b6fd8a9ad4e05568c2b02a9fc1a30553` | `4b0e5fda69292c76bcc6a5a732c2743d2cd8693f06f04a3bebc92667f00c022b` | 6 | 2 |
| 10 | `d2c99ccc005b1f9d188df2479be15a08b6fd8a9ad4e05568c2b02a9fc1a30553` | `aface8e08127cff0e8452c52666a7822fee1bf7ad15152b4851522abb0c1930b` | 5 | 1 |
| 11 | `d2c99ccc005b1f9d188df2479be15a08b6fd8a9ad4e05568c2b02a9fc1a30553` | `caa1ca96d3dda901cea47642919c66b2c672a86b145bb06edbb4301d697c22a1` | 2 | 1 |
| 12 | `d2c99ccc005b1f9d188df2479be15a08b6fd8a9ad4e05568c2b02a9fc1a30553` | `c17d97e8e1749b9bcdcbeffd099f9b29295808acf371aac873c6ba28340104b7` | 1 | 2 |
| 13 | `d2c99ccc005b1f9d188df2479be15a08b6fd8a9ad4e05568c2b02a9fc1a30553` | `4a717365c4d2e60b9acfe4d7ab122404628c7dde35dde3bbbfe21e69f84d8f14` | 2 | 1 |
| 14 | `d2c99ccc005b1f9d188df2479be15a08b6fd8a9ad4e05568c2b02a9fc1a30553` | `69d664edd1fe77a581e8e4919fbe5ded085862e74800925821c5c132e0196481` | 5 | 1 |
| 15 | `d2c99ccc005b1f9d188df2479be15a08b6fd8a9ad4e05568c2b02a9fc1a30553` | `ad20eaf89338c897636500b6c8832c53176877302b3029e72371903ddfc590af` | 5 | 1 |
| 16 | `d2c99ccc005b1f9d188df2479be15a08b6fd8a9ad4e05568c2b02a9fc1a30553` | `7702edb27e40b1d73df848185fd5ac82ddf311ee52afd70df88e0704b79fcc60` | 5 | 1 |

The Q&A total is 49 entries: 2+3+0+3+4+1+4+1+6+5+2+1+2+5+5. Part 03 has zero natural-language questions, but its complete source and timing comments remain documented.

## Question coverage ledger

Each exact source comment/question below has one matching entry under `## Questions and Answers from the Code` in its part README. The line numbers refer to the captured `testbench.sv`; p08's question spans two adjacent comment lines and p09's constructor explanation spans two adjacent comment lines.

| Part | Source line(s) | Exact source wording or captured comment |
|---:|---|---|
| 01 | 10 | will start from time 0 (start of the simulation ) ; 16: variable will hold the value =0 till the end of the simulation |
| 02 | 7 | in tb we dont need a sensitivity list in the always block why ? ; 8: in the design we need to evaluate for change hence in sensitivity list ; 15: x by default so i have to initialize |
| 03 | — | No natural-language question/doubt found; timing comments retained in source |
| 04 | 26 | 4 state initial value will be x ; 58: cant use wire here ; 103: here, reg cant be allowed in the output of ha1 |
| 05 | 10 | compiler will make the size ==4 ; 17: if the array is not initialize or given size i cant put any element inside ; 22: to initialize with unique values , or repetitive value or default value ; 56: need a procedural block |
| 06 | 6 | why j is going from 0 to 9 cause im not specifying anything , is it because of foreach loop ? |
| 07 | 3 | compare element in scoreboard , golden data + dut response compare elememnt by element and copy used here, ; 28: should return true ; 48: why its not having default value printed xxxx cause i deleted and its a 4 state logic ; 62: have to use new keyword when i want to add elements |
| 08 | 6–7 | SO I HAVE TO DEFINE DATA HERE, FOR USING IT LATEER ? ALSO TELL ME WHY CANT I DEFINTE LIKE THIS IN / THE INITIAL BLOCK , int data = q.pop_front() |
| 09 | 11–12 | f is a handler wont able to access the class ; class are dynamic object ? meaning ; Do not keep that object throughout life of the simulation ; constructor to the handler allocate the memory space to all the data members of the class and also assigns the default values ; Once i call the constructor / f now points to that, object ; Try to add a value |
| 10 | 9 | so no need to make the result initialized by 0 ; 12: i can rather pass ain, bin to the function ; 24: cannot add delay in function , ; 50: 32 bit unsigned value will be generated ; 80: passby value task add (reg int x, y ) |
| 11 | 21–22 | wont be reflected to the varaibles outside the task ; WHY PASS BY VALUE IN TERMS OF SCALAR HE IS SAYING |
| 12 | 3 | Copying an array to stack is not an optimum choice |
| 13 | 8 | constructor cannot add a void to a constructor ; 26: f1 will have address of the class now |
| 14 | 3 | scope is public be default ; 6: local int data = 34; ; 14: a return type needed for getter () ; 26: this or i can use initial begin block itself ?? ; 41: $display("The value of the data , fron getter task is %0d" , s.f1.getter()) ; WILL NOT WORK CAUSE TASK DOES NOT RETURN A VALUE |
| 15 | 3 | Copy the data somethimes ; 13: constructor copy from 1 object to another object ; 15: p1 =new(f1); // Copy all the data of the object handle f1 to f2 (shallow copy) ; 18: if i change in p1 object handle , it wont reflect on f1 ; 23: task creating copy , just to copy data members attributes |
| 16 | 7 | custom methods to copy ; 10: why am i not using this here, ; 19: to store copy of f1 to f2 ; 25: copy of the data members of f1 to f2 ; 39: automatically copies  why i havent used f1.copy() |

No question is answered by an unrelated part. The normalized headings in the READMEs are only for navigation; the blockquotes preserve the source wording.

## Capture and preservation method

1. Git baseline, branch, HEAD, status, and complete diff were inspected before source work. The baseline was clean at the naming-pass reference above.
2. The dedicated Edge binding was used to inspect each existing EDA Playground page. For editor panes whose backing textarea was not populated, CodeMirror lines were paged through with line numbers and merged; this avoided truncated DOM snippets. Both Design and Testbench pane text were captured, along with the saved Name, short link, visible title, simulator, compile options, and run options.
3. Stable normalized SHA-256 fingerprints were computed before repository restoration. Repository source was compared to the captured source; parts 01–03 and 06 already matched, while parts 04–05 and 07–16 had captured testbench differences from older normalized or corrected versions. The captured live text is now the repository `testbench.sv` source.
4. README code blocks were generated from the captured source values. Part 16 retains both existing repository filenames as the same captured pane; no alternate code was invented.
5. The Luna-only `self_checking_testbench.sv` files were removed because they were not user-authored EDA panes and conflicted with the verbatim-source requirement. No source logic was corrected. `.gitattributes` disables whitespace-error classification for captured panes and their README renderings so their trailing spaces remain intact.

## Research basis

Q&A claims about language semantics link directly to the IEEE/Accellera SystemVerilog material, principally the [IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf) and the [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/). EDA Playground settings and option claims link to its [settings documentation](https://eda-playground.readthedocs.io/en/latest/settings.html) and [compile/run option documentation](https://eda-playground.readthedocs.io/en/latest/compile_run_options.html). Simulator-specific run outcomes are not asserted in the Q&A unless directly observed; malformed or race-prone source is described as source behavior rather than silently repaired.

## Verification result to record at handoff

- Source-to-capture parity: PASS for all 16 Design panes, all 16 Testbench panes, and the additional p16 `editor_testbench.sv` capture after LF/final-newline normalization.
- README/source parity: PASS for all 33 `~~~systemverilog` blocks against their corresponding source files.
- Question coverage: PASS — 49 discovered entries, 49 exact source quotes, and 49 matching answers; no Q&A entry is intended to represent a question absent from its source.
- Final Edge rescan: the dedicated original Edge instance reported one existing EDA inspection tab (`109821722`, `8k9Q`) plus non-EDA GitHub/ChatGPT tabs and no new EDA Playground URL. No browser tab was closed or edited by this task; all 16 pages had already been captured and identity-verified before the rescan.
- Git checks: `git diff --check` PASS, full diff reviewed, intended-file staging only, one commit on the current branch, and push to the existing upstream only.

## Incremental ingestion pass: parts 17–22

This section records the rolling ingestion pass after baseline commit `390a45a558dec830ff4729753c4d70856981dff9`. The baseline highest part was 16; the final highest part in this pass is 22. The five pages first identified in the initial incremental scan were `gchG`, `9FTS`, `uVqk`, `sPne`, and `bpmE`. A later rolling scan found the additional stable page `Fqxx`; it was processed as part 22 and the stability cycle was restarted.

### Checkpoint A1 inventory

Checkpoint A1 was the restarted valid initial scan after the late `Fqxx` page was processed: `2026-08-16T19:15:35.167Z` (UTC; `2026-08-17` local Asia/Calcutta). The dedicated original Edge binding reported 14 open tabs, 13 EDA Playground tabs, and 6 unique EDA short IDs after deduplication:

| Part | EDA short ID/link | Exact saved EDA Name | Saved code ID | Reloaded visible page title | Repository folder / README H1 | Source panes | Simulator / options | Status / normalized source fingerprints |
|---:|---|---|---:|---|---|---|---|---|
| 17 | [`gchG`](https://edaplayground.com/x/gchG) | `Class Deep Copy with Nested Objects` | 7358337 | `Class Deep Copy with Nested Objects - EDA Playground` (the original open tab also showed `Edit code - EDA Playground`) | `17-class-deep-copy-with-nested-objects` / `Part 17 — Class Deep Copy with Nested Objects` | `design.sv`, `testbench.sv` | Riviera Pro 2025.04; `-timescale 1ns/1ns`; `+access+r`; optional run/output flags off | new; design `4ea061f5a179c83078440b12a1797902abf41fa4fc73f4ea46783a5da6d0b24e`; testbench `b498050d46fd4d290d4f9a6f4832800a253a9f2234793d27b870bd876a6759d6` |
| 18 | [`9FTS`](https://edaplayground.com/x/9FTS) | `Class Shallow Copy with Nested Handle` | 7358251 | `Class Shallow Copy with Nested Handle - EDA Playground` (the original open tab also showed `Edit code - EDA Playground`) | `18-class-shallow-copy-with-nested-handle` / `Part 18 — Class Shallow Copy with Nested Handle` | `design.sv`, `testbench.sv` | Riviera Pro 2025.04; `-timescale 1ns/1ns`; `+access+r`; optional run/output flags off | new; design `4ea061f5a179c83078440b12a1797902abf41fa4fc73f4ea46783a5da6d0b24e`; testbench `5fbb28755077589700adc8db2f76bacb8fe3fc95244ea169aa76429d4793345c` |
| 19 | [`uVqk`](https://edaplayground.com/x/uVqk) | `Class Inheritance Basics` | 7358359 | `Class Inheritance Basics - EDA Playground` (the original open tab also showed `Edit code - EDA Playground`) | `19-class-inheritance-basics` / `Part 19 — Class Inheritance Basics` | `design.sv`, `testbench.sv` | Riviera Pro 2025.04; `-timescale 1ns/1ns`; `+access+r`; optional run/output flags off | new; design `4ea061f5a179c83078440b12a1797902abf41fa4fc73f4ea46783a5da6d0b24e`; testbench `0514b146b3b2445748af89bcad4006e4af8c5b393d3757693d3688031a9e6ee6` |
| 20 | [`sPne`](https://edaplayground.com/x/sPne) | `Polymorphism with Virtual Methods` | 7358419 | `Polymorphism with Virtual Methods - EDA Playground` (the original open tab also showed `Edit code - EDA Playground`) | `20-polymorphism-with-virtual-methods` / `Part 20 — Polymorphism with Virtual Methods` | `design.sv`, `testbench.sv` | Riviera Pro 2025.04; `-timescale 1ns/1ns`; `+access+r`; optional run/output flags off | new; design `4ea061f5a179c83078440b12a1797902abf41fa4fc73f4ea46783a5da6d0b24e`; testbench `aefb293ae3e522c4f87d2ea49a58e06e9839f531d78253d5d8d9c636bd3200f9` |
| 21 | [`bpmE`](https://edaplayground.com/x/bpmE) | `Constructor Arguments and Super Keyword` | 7358446 | `Constructor Arguments and Super Keyword - EDA Playground` (the original open tab also showed `Edit code - EDA Playground`) | `21-constructor-arguments-and-super-keyword` / `Part 21 — Constructor Arguments and Super Keyword` | `design.sv`, `testbench.sv` | Riviera Pro 2025.04; `-timescale 1ns/1ns`; `+access+r`; optional run/output flags off | new; design `4ea061f5a179c83078440b12a1797902abf41fa4fc73f4ea46783a5da6d0b24e`; testbench `5eedc2934c3a9cf940157a8d074bac8fef2fa4062e82ba031a70c087c41a777a` |
| 22 | [`Fqxx`](https://edaplayground.com/x/Fqxx) | `Constrained Randomization with randc` | 7358472 | `Constrained Randomization with randc - EDA Playground` after reload (the original open tab initially showed `Edit code - EDA Playground`) | `22-constrained-randomization-with-randc` / `Part 22 — Constrained Randomization with randc` | `design.sv`, `testbench.sv` | Riviera Pro 2025.04; `-timescale 1ns/1ns`; `+access+r`; optional run/output flags off | new; design `33faabf3088dd61f22d7acf06d696479199f5b36b2ef7c892fb54d239848ce6d`; testbench `69141a96b7b7829e62cd8deba0cacff6fb3572dd5a40e8a7ffb7ac8c1cceb39f` |

The six names above were saved directly in each existing EDA Playground Name field and verified after reload. No copy, fork, duplicate playground, or alternate short ID was created. All six names are nonblank, unique, specific to the live code, and semantically aligned with the folder slug, folder README H1, and root index title. The original open-tab title behavior was recorded exactly: before/without the inspected reload it was `Edit code - EDA Playground`; after the saved-name reload the title reflected the saved name for these inspection views.

### Duplicate tabs deduplicated by short ID at Checkpoint A1

The unique-ID set was `{gchG, 9FTS, uVqk, sPne, bpmE, Fqxx}`. Duplicate user-visible EDA tabs were retained and not closed: `Fqxx` tab `109821827`; `gchG` tab `109821816`; `9FTS` tab `109821715`; `gchG` tab `109821766`; `uVqk` tab `109821773`; `sPne` tab `109821780`; and `bpmE` tab `109821795`. The first-seen order for the new queue was parts 17–21 in `gchG`, `9FTS`, `uVqk`, `sPne`, `bpmE` order; `Fqxx` was discovered later and assigned part 22 without renumbering.

### Complete editor fingerprints

The fingerprints above are SHA-256 values over UTF-8 source text after CRLF-to-LF normalization and removal of one terminal file newline only for comparison. The full CodeMirror editor panes were captured by paging through each editor and merging the numbered visible rows, not by relying on a truncated viewport DOM snippet. The post-save/reload captures for parts 17–21 matched their pre-save captures; `Fqxx` matched two complete pre-save reads and two complete post-save reads. Source line counts were: p17 2/112, p18 2/47, p19 2/31, p20 2/33, p21 2/26, p22 8/35 (design/testbench).

### Question coverage ledger for parts 17–22

Each row below is one exact natural-language question or question-like doubt extracted from the current source comments. The Q&A heading is the destination in the matching part README; code blocks embedded in a question remain reproduced verbatim in that README.

| Part / file / line(s) | Exact source question or doubt | Q&A destination |
|---|---|---|
| 17 / testbench.sv:64 | `1. **Shallow copy:** In a shallow copy, is only the handle different while the nested object it points to remains the same/shared object?` | `Does a shallow copy duplicate the nested object?` |
| 17 / testbench.sv:66–73 | `2. In this code, **what exactly am I doing?**` | `What exactly does the custom first.copy method do?` |
| 17 / testbench.sv:75 | `3. Why am I using a custom copy() function instead of simply using function new() and initializing the class members there?` | `Why use copy() instead of only new()?` |
| 17 / testbench.sv:77–83 | `4. What is this called?` | `What is function new() called?` |
| 17 / testbench.sv:85 | `5. Are both function new() and function first copy() constructors?` | `Are function new() and function first copy() both constructors?` |
| 17 / testbench.sv:87 | `6. If they are not both constructors, what exactly is the difference between a constructor and a copy() method?` | `What is the difference between a constructor and a copy method?` |
| 17 / testbench.sv:89 | `7. Why can't I use new() and copy() interchangeably?` | `Why cannot new() and copy() be used interchangeably?` |
| 17 / testbench.sv:91–101 | `8. What is the difference between:` followed by the exact source examples `f2 = new();` and `f2 = f1.copy();` | `What is the difference between f2 = new() and f2 = f1.copy()?` |
| 17 / testbench.sv:103 | `9. Why does new() give me a fresh/default object, while f1.copy() gives me a new object containing the values of f1?` | `Why does new() create a fresh object while f1.copy() preserves f1 values?` |
| 17 / testbench.sv:105–110 | `10. More generally, what is the relationship between:` followed by the exact four source bullets about function new(), f1 = new(), function first copy(), and copy = new() | `What is the relationship between the constructor and copy-method lines?` |
| 17 / testbench.sv:27 | `// why copy called without ()` | `Why does the comment say copy is called without parentheses?` |
| 18 / testbench.sv:3–4 | `// Shallow copy copies data members or methods ? verify this` and `// but it cant copy` | `Does a shallow copy copy data members or methods?` |
| 18 / testbench.sv:4 | `// but it cant copy` | `What does the note “but it cant copy” mean here?` |
| 18 / testbench.sv:5 | `// Whats wrong with shallow copy cause it is copying the data members and its not copying the variables that are in the heap` | `What is wrong with shallow copy when a nested object is on the heap?` |
| 18 / testbench.sv:24 | `*/ // i cant have a initial begin in class` | `Can an initial block be declared inside a class?` |
| 18 / testbench.sv:38 | `//ahh so so only handler is different the object its pointing to is 1 only i.e class first, in our case cause its a dynamically created class` | `Are only the handles different while the nested object is the same?` |
| 19 / testbench.sv:13 | `// it has access to the attributes and methods of class 1` | `Does the derived class inherit the attributes and methods of first?` |
| 19 / testbench.sv:23 | `// ohh actually i have access to all the things without using handler` | `Can the derived handle access inherited members without another handler?` |
| 20 / testbench.sv:5 | `// IF I EXTEND IT IN second class the overridden method will be executed` | `Will extending first cause the overridden display method to execute?` |
| 20 / testbench.sv:30 | `// getting parent class display I NEED DIFFERENT BEHAVIOUR` | `Why does the source need different behavior through f.display?` |
| 20 / testbench.sv:31 | `// display hence will have different behaviour same name different behaviour polymorphism` | `What does same name and different behavior mean here?` |
| 21 / testbench.sv:3 | `// DISTINGUISH BETWEEN CUSTOM CONSTRUCTOR WE NEED  A KEYWORD ITS SUPER KEYWORD` | `Which keyword calls the parent constructor?` |
| 21 / testbench.sv:13 | `// can i have an output direction in a constructor` | `Can a constructor have an output-direction argument?` |
| 21 / testbench.sv:25 | `// constructor name is always new in sv` | `Is the constructor name always new in SystemVerilog?` |
| 22 / testbench.sv:4 | `// How to generate complex sequences` | `How can this playground generate complex sequences?` |

Question coverage for the incremental pages is 25 discovered entries and 25 matching README answers: p17 11, p18 5, p19 2, p20 3, p21 3, p22 1. The baseline audit covered 49 entries, so the repository now documents 74 questions in total. No Q&A heading in these six READMEs is intended to represent a question absent from its corresponding source.

### Incremental preservation and research evidence

- Source-to-live parity: PASS for all 12 new source files. Each repository source was compared with the complete live editor capture using the normalized fingerprints above; only CRLF/LF and one terminal newline were ignored.
- README/source parity: PASS for all 12 new `~~~systemverilog` blocks. The existing 33 baseline README blocks remain unchanged by this incremental pass; combined checked coverage is 45 blocks.
- Q&A/source parity: PASS for all 25 exact quotes. Each quote was checked against its indicated source line/context, and each matching answer is under `## Questions and Answers from the Code` in the same part README.
- Authoritative research: p17 used 4 unique authoritative technical sources, p18 3, p19 3, p20 3, p21 4, and p22 3, excluding each EDA Playground link. The Q&As use opened IEEE/Accellera primary material; the new p22 randomization answer uses the opened [Accellera random-constraints proposal](https://www.accellera.org/images/eda/sv-ec/att-0248/01-Random-Constraints_Proposal.pdf), with the current [IEEE 1800 standard overview](https://standards.ieee.org/ieee/1800/7743/) and repository LRM link.
- Name audit: PASS. All six final names are nonblank, unique, directly saved on the existing short IDs, and semantically synchronized across EDA Name, folder slug, README H1, and root index.
- No code was corrected, reformatted, made self-checking, or edited in EDA. The p22 design pane is intentionally a commented-out module and the p22 testbench retains the unsatisfiable `a>16` constraint exactly as captured.

### Rolling stability checkpoints

- Checkpoint A1: `2026-08-16T19:15:35.167Z`, 6 unique IDs `{gchG, 9FTS, uVqk, sPne, bpmE, Fqxx}`.
- Checkpoint B: `2026-08-16T19:18:34.576Z`, 6 unique IDs with the same set. Complete source/name/settings reads for all six matched Checkpoint A1 fingerprints and saved metadata.
- Checkpoint C: `2026-08-16T19:23:02.132Z`, 6 unique IDs with the same set. Complete source/name/settings reads for all six matched Checkpoint A1 and B fingerprints; this was the final pre-stage scan.
- Checkpoint D1: `2026-08-16T19:24:51.700Z`, the staged 20-file diff was in place and the Edge unique-ID set remained `{gchG, 9FTS, uVqk, sPne, bpmE, Fqxx}`. Complete post-stage reads for all six matched Checkpoint C; the audit timestamp update required a final restage.
- Checkpoint D2: `2026-08-16T19:26:25.519Z`, after the final audit restage, the Edge unique-ID set remained `{gchG, 9FTS, uVqk, sPne, bpmE, Fqxx}` and complete post-stage reads for all six matched the same names, code IDs, settings, line counts, and fingerprints. A final D3 read was performed immediately before commit after this audit-only restage.

### Simulator verification for the incremental sources

The repository's available Icarus Verilog 0.0.0.0 check was run with `-g2012 -t null -s tb` against each new `design.sv`/`testbench.sv` pair, without changing source files. Parts 19 and 21 exited 0. Parts 17 and 18 triggered Icarus internal assertion failures while elaborating the preserved class-copy source (exit 3); part 20 produced Icarus's base/derived assignment diagnostic at the preserved `f=s` line (exit 1); and part 22 reported Icarus's documented `Constraint declarations not supported` limitation (exit 1). These are verification results for the unchanged learning examples, not corrections or substitutions. No compiler artifacts were added or staged by this pass; pre-existing ignored artifacts were left untouched.

No EDA tab was closed. Inspection tabs opened on the same existing short links were retained only to read the canonical panes and were deduplicated by short ID in the scans.
