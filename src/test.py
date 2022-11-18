import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles

async def reset_for_start(dut):
    dut._log.info("start")
    clock = Clock(dut.globclk, 1, units="us")
    cocotb.fork(clock.start())

    await ClockCycles(dut.globclk, 1)
    
    dut._log.info("reset")
    dut.rst.value = 1
    dut.clk.value = 1

    for n in range(3):
        await ClockCycles(dut.globclk, 5)
        dut.clk.value = 0
        await ClockCycles(dut.globclk, 5)
        dut.clk.value = 1

    dut.rst.value = 0

@cocotb.test()
async def push_op(dut):
    await reset_for_start(dut)

    await ClockCycles(dut.globclk, 5)
    dut.clk.value = 0

    await ClockCycles(dut.globclk, 4)

    dut._log.info("setup push opcode")
    dut.io_ins.value = 0x1

    dut._log.info("tick up")
    await ClockCycles(dut.globclk, 1)
    dut.clk.value = 1

    await ClockCycles(dut.globclk, 5)
    dut.clk.value = 0

    await ClockCycles(dut.globclk, 4)

    dut._log.info("setup operand")
    dut.io_ins.value = 0x5

    dut._log.info("tick up")
    await ClockCycles(dut.globclk, 1)
    dut.clk.value = 1

    await ClockCycles(dut.globclk, 5)
    dut.clk.value = 0


    dut.io_ins.value = 0x0
    assert int(dut.io_outs.value) == 0x5

