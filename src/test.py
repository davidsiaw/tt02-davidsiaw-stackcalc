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

    dut.rst.value = 0
    dut.clk.value = 0
    await ClockCycles(dut.globclk, 5)

    dut.clk.value = 1
    await ClockCycles(dut.globclk, 5)

async def latch_input(dut, input4):
    dut.clk.value = 0
    await ClockCycles(dut.globclk, 5)

    dut._log.info("tick up")
    dut.clk.value = 1

    dut._log.info("set input")
    dut.io_ins.value = input4
    await ClockCycles(dut.globclk, 5)

async def wait_one_cycle(dut):
    dut.clk.value = 0
    await ClockCycles(dut.globclk, 5)

    dut.clk.value = 1
    await ClockCycles(dut.globclk, 5)


@cocotb.test()
async def push_op(dut):
    await select_cpu(dut)
    await reset_for_start(dut)

    await latch_input(dut, 0x1) # PUSH
    await latch_input(dut, 0x5) # 0x5
    await wait_one_cycle(dut)

    assert int(dut.io_outs.value) == 0x5


@cocotb.test()
async def push2_op(dut):
    await select_cpu(dut)
    await reset_for_start(dut)

    await latch_input(dut, 0x1) # PUSH
    await latch_input(dut, 0x5) # 0x5
    await latch_input(dut, 0x1) # PUSH
    await latch_input(dut, 0x7) # 0x7
    await wait_one_cycle(dut)

    assert int(dut.io_outs.value) == 0x7


@cocotb.test()
async def pop_op(dut):
    await select_cpu(dut)
    await reset_for_start(dut)

    # result available immediately
    await latch_input(dut, 0x1) # PUSH
    await latch_input(dut, 0x5) # 0x5
    await latch_input(dut, 0x1) # PUSH
    await latch_input(dut, 0x7) # 0x7
    await latch_input(dut, 0x2) # POP

    assert int(dut.io_outs.value) == 0x5


@cocotb.test()
async def pop_op_nop(dut):
    await select_cpu(dut)
    await reset_for_start(dut)

    # result persists
    await latch_input(dut, 0x1) # PUSH
    await latch_input(dut, 0x5) # 0x5
    await latch_input(dut, 0x1) # PUSH
    await latch_input(dut, 0x7) # 0x7
    await latch_input(dut, 0x2) # POP
    await latch_input(dut, 0x0) # NOOP
    await wait_one_cycle(dut)

    assert int(dut.io_outs.value) == 0x5

