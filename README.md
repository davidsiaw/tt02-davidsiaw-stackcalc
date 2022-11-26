![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg)

# David's Stack Calculator

This TinyTapeout submission is a 4-bit stack machine.

doc still in progress

## Opcodes

It implements the following opcodes

- 0x1 PUSH - 3 cycles - push, value, wait
- 0x2 POP  - 3 cycles - pop, wait, wait
- 0x3 OUTL - 2 cycles - outl, wait
- 0x4 OUTH - 2 cycles - outh, wait
- 0x5 SWAP - 3 cycles - swap, wait, wait
- 0x6 PUSF - 3 cycles - peek/dupl/flag, wait, wait
- 0x7 REPL - 3 cycles - not/neg/incr/decr/shr1/shr2/ror1/rol1/flip, wait, wait
- 0x8 BINA - 3 cycles - add/and/not/xor/addc/mull/mulh, wait, wait
- 0x9 MULT - 4 cycles - mult, wait, wait, wait
- 0x9 IDIV - 4 cycles - idiv, wait, wait, wait

## Pinouts

INPUT0 clock (c)
INPUT1 reset (let the clock tick a few times while reset is high)
INPUT2-5 Inputs (opcodes and input go here)
INPUT6-7 debug (0 - output dff contents, 1 - stack top 7-segment hex, 2 - tbd, 3 - tbd)

OUTPUT0-7 depends on the mode

## Wishlist

- make pop output to the dff maybe as a param?
- make longer opcodes for less useful operations

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
