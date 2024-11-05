# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

async def seriallyInput(DUT, dataType, data, clockDelay):
    dataString = str(data)
    await ClockCycles(DUT.clk, clockDelay)
    if(dataType == 1): #This means that we are inputting a message
        for x in range(64):
            DUT.ui_in[0].value = int(dataString[x])
            await ClockCycles(DUT.clk, clockDelay)
    else: # Otherwise we are inputting a key
        for x in range(8):
            DUT.ui_in[0].value = int(dataString[x])
            await ClockCycles(DUT.clk, clockDelay)

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 MHz)
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    await ClockCycles(dut.clk, 2)

    dut._log.info("Reset")
    dut.clk.value = 0
    dut.ena.value = 0
    dut.rst_n.value = 1
    dut.ui_in.value = 0
    await ClockCycles(dut.clk, 10)

    keyInteger = 0xA5
    messageInteger = 0xA3B1F9D2E7C6A594
    key = format(keyInteger, '0>8b')
    message = format(messageInteger, '0>64b')

    dut.ena.value = 0
    dut.rst_n.value = 0
    dut.ui_in.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    dut.ena.value = 1
    await ClockCycles(dut.clk, 1)
    # Loading in key
    dut.ui_in[1].value = 1
    await seriallyInput(DUT=dut, dataType=0, data=key, clockDelay=1)
    dut.ui_in[1].value = 0
    dut.ui_in[2].value = 1
    await seriallyInput(DUT=dut, dataType=1, data=message, clockDelay=1)
    dut.ui_in[2].value = 0
    await ClockCycles(dut.clk, 10)

    #Reset
    # dut._log.info("Reset")
    # dut.ena.value = 1
    # dut.ui_in.value = 0
    # dut.uio_in.value = 0
    # dut.rst_n.value = 0
    # await ClockCycles(dut.clk, 10)
    # dut.rst_n.value = 1
    # dut._log.info("Test project behavior")

    # # Set the input values you want to test
    # dut.ui_in.value = 20
    # dut.uio_in.value = 30

# @cocotb.test()
# async def test_project(dut):
#     dut._log.info("Start")

#     # Set the clock period to 10 us (100 KHz)
#     clock = Clock(dut.clk, 10, units="us")
#     cocotb.start_soon(clock.start())

#     # Reset
#     dut._log.info("Reset")
#     dut.ena.value = 1
#     dut.ui_in.value = 0
#     dut.uio_in.value = 0
#     dut.rst_n.value = 0
#     await ClockCycles(dut.clk, 10)
#     dut.rst_n.value = 1

#     dut._log.info("Test project behavior")

#     # Set the input values you want to test
#     dut.ui_in.value = 20
#     dut.uio_in.value = 30

#     # Wait for one clock cycle to see the output values
#     await ClockCycles(dut.clk, 1)

#     # The following assersion is just an example of how to check the output values.
#     # Change it to match the actual expected output of your module:
#     assert dut.uo_out.value == 50

#     # Keep testing the module by changing the input values, waiting for
#     # one or more clock cycles, and asserting the expected output values.
