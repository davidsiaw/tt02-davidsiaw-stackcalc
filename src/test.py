import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles


segments = [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]

@cocotb.test()
async def test_7seg(dut):
    dut._log.info("start")
    clock = Clock(dut.clk, 10, units="us")
    cocotb.fork(clock.start())
    
    dut._log.info("reset")
    dut.rst.value = 1
    await ClockCycles(dut.clk, 10)
    dut.rst.value = 0

    dut._log.info("check all segments")
    for i in range(10):
        dut._log.info("check segment {}".format(i))
        await ClockCycles(dut.clk, 100)
        assert int(dut.segments.value) == segments[i]
