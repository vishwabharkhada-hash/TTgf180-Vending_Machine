# Regression Testing

## Formal Verification
Command:
```bash
cd formal
sby -f vending_machine.sby
```

Expected result:
PASS

Waveform:
gtkwave trace.vcd

---

## Cocotb Simulation
Command:
```bash
cd test
make cocotb
```

Expected result:
All tests pass

Waveform:
gtkwave sim_build/*.vcd
