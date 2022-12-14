![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg)

# David's Stack Calculator

This TinyTapeout submission is a 4-bit stack calculator.

<img width="684" alt="スクリーンショット 2022-12-26 10 49 35" src="https://user-images.githubusercontent.com/874280/209491582-deb740fd-c6ce-480c-bb9d-6e2377068d6e.png">


Features:
- 8-nibble deep stack
- 16 nibbles of RAM
- multiply/divide circuit
- fully writable output

<img width="827" alt="diff" src="https://user-images.githubusercontent.com/874280/205480274-25656a90-3983-454c-b499-7193c94a0262.png">

## Links

- [3D Viewer](https://gds-viewer.tinytapeout.com/?model=https://davidsiaw.github.io/tt02-davidsiaw-stackcalc/tinytapeout.gds.gltf)
- [Test Waveform](https://davidsiaw.github.io/vcdrom/?url=davidsiaw.github.io/tt02-davidsiaw-stackcalc/test-result/tb.vcd)
- [Gate-level Test Waveform](https://davidsiaw.github.io/vcdrom/?url=davidsiaw.github.io/tt02-davidsiaw-stackcalc/gatelevel-result/tb.vcd)

## Pinouts

- `io_in[0]` clock (c)
- `io_in[1]` reset (let the clock tick a few times while reset is high)
- `io_in[5:2]` Inputs (opcodes and input go here)
- `io_in[6:7]` output mode
- `io_out[7:0]` output depends on the Output Mode (not clocked)

## Opcodes

It implements the following opcodes

- 0x1 PUSH - 3 cycles - push, value, wait
- 0x2 POP  - 3 cycles - pop, wait, wait
- 0x3 OUTL - 2 cycles - outl, wait
- 0x4 OUTH - 2 cycles - outh, wait
- 0x5 SWAP - 3 cycles - swap, wait, wait
- 0x6 PUSF - 3 cycles - peek/dupl/flag, wait, wait
- 0x7 REPL - 3 cycles - not/neg/incr/decr/shr1/shl1/ror1/rol1, wait, wait
- 0x8 BINA - 3 cycles - add/and/not/xor/addc/mull/mulh, wait, wait
- 0x9 MULT - 4 cycles - mult, wait, wait, wait
- 0xA IDIV - 4 cycles - idiv, wait, wait, wait
- 0xB CLFL - 2 cycles - clfl, wait, wait, wait
- 0xC SAVE - 4 cycles - save, wait, wait, wait
- 0xD LOAD - 4 cycles - load, wait, wait, wait

## Output Modes
- 0x0 output register
- 0x1 top of stack as 7segment
- 0x2 below top of stack as 7segment
- 0x3 top two values on the stack, top of stack is low nibble and below is high nibble

## FPGA Testing

You can test the design yourself if you do not have the ASIC, by using an FPGA.
Currently I only test on a cheap GOWIN FGPA, the Tang Nano 9k.

You will need docker installed.

<img width="827" alt="dff2" src="https://user-images.githubusercontent.com/874280/205480277-2fad5593-4efd-4341-b398-af2b32d342a2.png">

## FPGA Test commands

`make gowin`

If you already have the Tang Nano 9k connected and can use [openFPGALoader](https://github.com/trabucayre/openFPGALoader), you can go

`make upload_gowin`

# What is Tiny Tapeout?

TinyTapeout is an educational project that aims to make it easier and cheaper than ever to get your digital designs manufactured on a real chip!

Go to https://tinytapeout.com for instructions!

## How to change the Wokwi project

Edit the [info.yaml](info.yaml) and change the wokwi_id to match your project.

## How to enable the GitHub actions to build the ASIC files

Please see the instructions for:

* [Enabling GitHub Actions](https://tinytapeout.com/faq/#when-i-commit-my-change-the-gds-action-isnt-running)
* [Enabling GitHub Pages](https://tinytapeout.com/faq/#my-github-action-is-failing-on-the-pages-part)

## How does it work?

When you edit the info.yaml to choose a different ID, the [GitHub Action](.github/workflows/gds.yaml) will fetch the digital netlist of your design from Wokwi.

After that, the action uses the open source ASIC tool called [OpenLane](https://www.zerotoasiccourse.com/terminology/openlane/) to build the files needed to fabricate an ASIC.

## Resources

* [FAQ](https://tinytapeout.com/faq/)
* [Digital design lessons](https://tinytapeout.com/digital_design/)
* [Join the community](https://discord.gg/rPK2nSjxy8)

## What next?

* Share your GDS on Twitter, tag it [#tinytapeout](https://twitter.com/hashtag/tinytapeout?src=hashtag_click) and [link me](https://twitter.com/matthewvenn)!
