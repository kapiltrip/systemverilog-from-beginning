# Part 03 — Phase-shifted clocks

EDA Playground: [https://edaplayground.com/x/gi8n](https://edaplayground.com/x/gi8n)

The example creates a 100 MHz reference clock and a separately controlled 50 MHz clock using real-valued phase, on-time, and off-time parameters.

## Answers and notes

- `clk100Mhz` toggles every 5 ns, so its period is 10 ns.
- The second generator waits `phase` before producing its first rising edge, then alternates its high and low intervals.
- The low interval currently uses `#ton`; use `#toff` after driving the clock low when independent duty-cycle control is intended.
- Phase should be defined relative to a particular edge. Here the reference clock's first rising edge is at 5 ns, while the second clock's first rising edge is at 10 ns, so the rising-edge offset is 5 ns—not 10 ns.
- The `while (1)` loop runs forever. Add a separate timeout block with `$finish` when running this standalone.

