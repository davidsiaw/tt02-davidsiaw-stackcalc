import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles

async def select_cpu(dut):
    dut.select.value = 0x1

async def select_stack_register(dut):
    dut.select.value = 0x2

async def reset_for_start(dut):
    dut._log.info("start")
    clock = Clock(dut.globclk, 1, units="us")
    cocotb.fork(clock.start())

    await ClockCycles(dut.globclk, 1)
    
    dut._log.info("reset")
    dut.rst.value = 1

    for n in range(3):
        dut.clk.value = 0
        await ClockCycles(dut.globclk, 5)
        dut.clk.value = 1
        await ClockCycles(dut.globclk, 5)

    dut.io_ins.value = 0
    dut.rst.value = 0

async def latch_input(dut, input4):
    dut.clk.value = 0
    await ClockCycles(dut.globclk, 5)

    dut.clk.value = 1

    dut.io_ins.value = input4
    await ClockCycles(dut.globclk, 5)

async def wait_one_cycle(dut):
    dut.clk.value = 0
    await ClockCycles(dut.globclk, 5)

    dut.clk.value = 1
    await ClockCycles(dut.globclk, 5)


@cocotb.test()
async def push_op(dut):
    dut.testnumber.value = 1
    await select_cpu(dut)
    await reset_for_start(dut)

    await latch_input(dut, 0x1) # PUSH
    await latch_input(dut, 0x5) # 0x5
    await wait_one_cycle(dut)
    await latch_input(dut, 0x3) # OUTL
    await wait_one_cycle(dut)

    assert int(dut.io_outs.value) == 0x5


@cocotb.test()
async def push2_op(dut):
    dut.testnumber.value = 2
    await select_cpu(dut)
    await reset_for_start(dut)

    await latch_input(dut, 0x1) # PUSH
    await latch_input(dut, 0x5) # 0x5
    await wait_one_cycle(dut)
    await latch_input(dut, 0x1) # PUSH
    await latch_input(dut, 0x7) # 0x7
    await wait_one_cycle(dut)
    await latch_input(dut, 0x3) # OUTL
    await wait_one_cycle(dut)

    assert int(dut.io_outs.value) == 0x7


@cocotb.test()
async def pop_op(dut):
    dut.testnumber.value = 3
    await select_cpu(dut)
    await reset_for_start(dut)

    await latch_input(dut, 0x1) # PUSH
    await latch_input(dut, 0x5) # 0x5
    await wait_one_cycle(dut)
    await latch_input(dut, 0x1) # PUSH
    await latch_input(dut, 0x7) # 0x7
    await wait_one_cycle(dut)
    await latch_input(dut, 0x2) # POP
    await wait_one_cycle(dut)
    await wait_one_cycle(dut)
    await latch_input(dut, 0x3) # OUTL
    await wait_one_cycle(dut)

    assert int(dut.io_outs.value) == 0x5

@cocotb.test()
async def outh_op(dut):
    dut.testnumber.value = 4
    await select_cpu(dut)
    await reset_for_start(dut)

    # result available immediately
    await latch_input(dut, 0x1) # PUSH
    await latch_input(dut, 0x5) # 0x5
    await wait_one_cycle(dut)
    await latch_input(dut, 0x4) # OUTH
    await wait_one_cycle(dut)

    assert int(dut.io_outs.value) == 0x50

@cocotb.test()
async def swap_op1(dut):
    dut.testnumber.value = 5
    await select_cpu(dut)
    await reset_for_start(dut)

    await latch_input(dut, 0x1) # PUSH
    await latch_input(dut, 0x5) # 0x5
    await wait_one_cycle(dut)
    await latch_input(dut, 0x1) # PUSH
    await latch_input(dut, 0x7) # 0x7
    await wait_one_cycle(dut)
    await latch_input(dut, 0x5) # SWAP
    await wait_one_cycle(dut)
    await wait_one_cycle(dut)
    await latch_input(dut, 0x3) # OUT
    await wait_one_cycle(dut)

    assert int(dut.io_outs.value) == 0x5


@cocotb.test()
async def swap_op2(dut):

    dut.testnumber.value = 6
    await select_cpu(dut)
    await reset_for_start(dut)

    await latch_input(dut, 0x1) # PUSH
    await latch_input(dut, 0x5) # 0x5
    await wait_one_cycle(dut)
    await latch_input(dut, 0x1) # PUSH
    await latch_input(dut, 0x7) # 0x7
    await wait_one_cycle(dut)
    await latch_input(dut, 0x5) # SWAP
    await wait_one_cycle(dut)
    await wait_one_cycle(dut)
    await latch_input(dut, 0x3) # OUT
    await wait_one_cycle(dut)

    assert int(dut.io_outs.value) == 0x5

    await latch_input(dut, 0x2) # POP
    await wait_one_cycle(dut)
    await wait_one_cycle(dut)
    await latch_input(dut, 0x3) # OUT
    await wait_one_cycle(dut)

    assert int(dut.io_outs.value) == 0x7


@cocotb.test()
async def peek_op(dut):

    dut.testnumber.value = 7
    await select_cpu(dut)
    await reset_for_start(dut)

    await latch_input(dut, 0x1) # PUSH
    await latch_input(dut, 0x5) # 0x5
    await wait_one_cycle(dut)
    await latch_input(dut, 0x1) # PUSH
    await latch_input(dut, 0x8) # 0x8
    await wait_one_cycle(dut)
    await latch_input(dut, 0x6) # PUSF
    await latch_input(dut, 0x1) # PEEK
    await wait_one_cycle(dut)
    await latch_input(dut, 0x3) # OUT
    await wait_one_cycle(dut)

    assert int(dut.io_outs.value) == 0x5

    await latch_input(dut, 0x2) # POP
    await wait_one_cycle(dut)
    await wait_one_cycle(dut)
    await latch_input(dut, 0x3) # OUT
    await wait_one_cycle(dut)

    assert int(dut.io_outs.value) == 0x8

    await latch_input(dut, 0x2) # POP
    await wait_one_cycle(dut)
    await wait_one_cycle(dut)
    await latch_input(dut, 0x3) # OUT
    await wait_one_cycle(dut)

    assert int(dut.io_outs.value) == 0x5


@cocotb.test()
async def dupl_op(dut):

    dut.testnumber.value = 8
    await select_cpu(dut)
    await reset_for_start(dut)

    await latch_input(dut, 0x1) # PUSH
    await latch_input(dut, 0x5) # 0x5
    await wait_one_cycle(dut)
    await latch_input(dut, 0x1) # PUSH
    await latch_input(dut, 0x8) # 0x8
    await wait_one_cycle(dut)
    await latch_input(dut, 0x6) # PUSF
    await latch_input(dut, 0x0) # DUPL
    await wait_one_cycle(dut)
    await latch_input(dut, 0x3) # OUT
    await wait_one_cycle(dut)

    assert int(dut.io_outs.value) == 0x8

    await latch_input(dut, 0x2) # POP
    await wait_one_cycle(dut)
    await wait_one_cycle(dut)
    await latch_input(dut, 0x3) # OUT
    await wait_one_cycle(dut)

    assert int(dut.io_outs.value) == 0x8

    await latch_input(dut, 0x2) # POP
    await wait_one_cycle(dut)
    await wait_one_cycle(dut)
    await latch_input(dut, 0x3) # OUT
    await wait_one_cycle(dut)

    assert int(dut.io_outs.value) == 0x5


@cocotb.test()
async def and_op(dut):

    dut.testnumber.value = 9
    await select_cpu(dut)
    await reset_for_start(dut)

    await latch_input(dut, 0x1)    # PUSH
    await latch_input(dut, 0b1111)
    await wait_one_cycle(dut)
    await latch_input(dut, 0x1) # PUSH
    await latch_input(dut, 0b1100)
    await wait_one_cycle(dut)
    await latch_input(dut, 0x8) # BIN
    await latch_input(dut, 0x1) # ADD
    await wait_one_cycle(dut)
    await latch_input(dut, 0x3) # OUT
    await wait_one_cycle(dut)

    assert int(dut.io_outs.value) == 0b1100

    await latch_input(dut, 0x2) # POP
    await wait_one_cycle(dut)
    await wait_one_cycle(dut)
    await latch_input(dut, 0x3) # OUT
    await wait_one_cycle(dut)

    assert int(dut.io_outs.value) == 0x0


@cocotb.test()
async def or_op(dut):

    dut.testnumber.value = 10
    await select_cpu(dut)
    await reset_for_start(dut)

    await latch_input(dut, 0x1)    # PUSH
    await latch_input(dut, 0b0010)
    await wait_one_cycle(dut)
    await latch_input(dut, 0x1) # PUSH
    await latch_input(dut, 0b1100)
    await wait_one_cycle(dut)
    await latch_input(dut, 0x8) # BIN
    await latch_input(dut, 0x2) # OR
    await wait_one_cycle(dut)
    await latch_input(dut, 0x3) # OUT
    await wait_one_cycle(dut)

    assert int(dut.io_outs.value) == 0b1110

    await latch_input(dut, 0x2) # POP
    await wait_one_cycle(dut)
    await wait_one_cycle(dut)
    await latch_input(dut, 0x3) # OUT
    await wait_one_cycle(dut)

    assert int(dut.io_outs.value) == 0x0


@cocotb.test()
async def add_op(dut):

    dut.testnumber.value = 11
    await select_cpu(dut)
    await reset_for_start(dut)

    await latch_input(dut, 0x1) # PUSH
    await latch_input(dut, 0x5) # 0x5
    await wait_one_cycle(dut)
    await latch_input(dut, 0x1) # PUSH
    await latch_input(dut, 0x8) # 0x8
    await wait_one_cycle(dut)
    await latch_input(dut, 0x8) # BIN
    await latch_input(dut, 0x0) # ADD
    await wait_one_cycle(dut)
    await latch_input(dut, 0x3) # OUT
    await wait_one_cycle(dut)

    assert int(dut.io_outs.value) == 0xd

    await latch_input(dut, 0x2) # POP
    await wait_one_cycle(dut)
    await wait_one_cycle(dut)
    await latch_input(dut, 0x3) # OUT
    await wait_one_cycle(dut)

    assert int(dut.io_outs.value) == 0x0

@cocotb.test()
async def not_op(dut):

    dut.testnumber.value = 12
    await select_cpu(dut)
    await reset_for_start(dut)

    await latch_input(dut, 0x1)  # PUSH
    await latch_input(dut, 0b1100) # 0x5
    await wait_one_cycle(dut)
    await latch_input(dut, 0x1) # PUSH
    await latch_input(dut, 0b0110) # 0x8
    await wait_one_cycle(dut)
    await latch_input(dut, 0x7) # REPL
    await latch_input(dut, 0x0) # NOT of top
    await wait_one_cycle(dut)
    await latch_input(dut, 0x3) # OUT
    await wait_one_cycle(dut)

    assert int(dut.io_outs.value) == 0b1001

    await latch_input(dut, 0x2) # POP
    await wait_one_cycle(dut)
    await wait_one_cycle(dut)
    await latch_input(dut, 0x3) # OUT
    await wait_one_cycle(dut)

    assert int(dut.io_outs.value) == 0b1100

@cocotb.test()
async def mul_op(dut):

    dut.testnumber.value = 13
    await select_cpu(dut)
    await reset_for_start(dut)

    await latch_input(dut, 0x1) # PUSH
    await latch_input(dut, 5) # 5
    await wait_one_cycle(dut)
    await latch_input(dut, 0x1) # PUSH
    await latch_input(dut, 6) # 6
    await wait_one_cycle(dut)
    await latch_input(dut, 0x9) # MUL
    await wait_one_cycle(dut)
    await wait_one_cycle(dut)
    await wait_one_cycle(dut)
    await latch_input(dut, 0x3) # OUTL
    await wait_one_cycle(dut)

    assert int(dut.io_outs.value) == 0xe

    await latch_input(dut, 0x2) # POP
    await wait_one_cycle(dut)
    await wait_one_cycle(dut)
    await latch_input(dut, 0x4) # OUTH
    await wait_one_cycle(dut)

    assert int(dut.io_outs.value) == 0x1e
