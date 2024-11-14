# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: MIT

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles
from cocotb.triggers import RisingEdge
    
@cocotb.test()
async def test_project(dut):
    MSG_SIZE = 64
    KEY_SIZE = 8
    DEBUG_SIZE = 30

    rebuilt_debug = [None] * (DEBUG_SIZE)
    key = [None] * (KEY_SIZE)              
    message = [None] * (MSG_SIZE)           
    rebuilt_ciphertext = [None] * (MSG_SIZE)
    ciphertext = [None] * (MSG_SIZE)

    dut._log.info("Start")
    dut.clk.value = 0
    dut.rst_n.value = 1
    dut.ena.value = 0
    dut.ui_in.value = 0
    dut.uio_in.value = 0

    keyHex = 0xA5
    messageHex = 0xA3B1F9D2E7C6A594
    key = format(keyHex, '0>8b')
    message = format(messageHex, '0>64b')
    keyString = str(key)
    messageString = str(message)

    # Set the clock period to 10 us (100 MHz)
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    dut.ena.value = 1
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 1)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)

    for x in range(10):
        dut.rst_n.value = 0
        await ClockCycles(dut.clk, 1)
        dut.rst_n.value = 1


    dut.ui_in[1].value = 1
    for x in (KEY_SIZE-1, -1, -1):
        dut.ui_in[0].value = int(keyString[x])
        await ClockCycles(dut.clk, 1)

    dut.ui_in[1].value = 0
    dut.ui_in[0].value = 0

    await ClockCycles(dut.clk, 1)
    
    dut.ui_in[3].value = 0
    dut.ui_in[4].value = 0
    dut.ui_in[5].value = 0
    dut.ui_in[6].value = 1
    dut.ui_in[7].value = 1

    dut.ui_in[1].value = 1
    for x in (KEY_SIZE-1, -1, -1):
        dut.ui_in[0].value = int(keyString[x])
        await ClockCycles(dut.clk, 1)

    dut.ui_in[1].value = 0
    dut.ui_in[0].value = 0
    
    await ClockCycles(dut.clk, 5)
    dut.ui_in[2].value = 1
    for x in (MSG_SIZE-1, -1, -1 ):
        dut.ui_in[0].value = int(messageString[x])
        await ClockCycles(dut.clk, 1)
    
    dut.ui_in[2].value = 0
    dut.ui_in[0].value = 0

    # Wait until ciphertext output is ready (assuming uo_out[1] as a flag) 
    for x in range(MSG_SIZE-1, -1, -1):
        await RisingEdge(dut.clk)
        rebuilt_ciphertext[x] = dut.uo_out[0].value
    
    # Capture 24-bit debug output serially from uo_out[7]
    for x in range(DEBUG_SIZE-1, 0, -1):
        await RisingEdge(dut.clk)
        rebuilt_debug[x] = dut.uo_out[7].value

    # Perform XOR operation on each 8-bit chunk of the message with the key
    for x in (0, MSG_SIZE-1, 1):
        ciphertext[x] = int(message[x]) ^ int(key[x%8])

    rebuiltCipherTextHex = hex(int(''.join(map(str, rebuilt_ciphertext))))  #hex((rebuilt_ciphertext[0:MSG_SIZE-1]))
    cipherTextHex = hex(int(''.join(map(str, ciphertext))))                 #hex((ciphertext[0:MSG_SIZE-1]))
    rebuiltDebugHex = hex(int(''.join(map(str, rebuilt_debug))))            #hex((rebuilt_debug[0:MSG_SIZE-1]))

    # Display the results
    print("Key:                   :", keyHex)
    print("Message:               :", messageHex)
    print("Computed Ciphertext:   :", cipherTextHex)
    print("Rebuilt Ciphertext:    :", rebuiltCipherTextHex)
    print("Debug Output (24 bits) :", rebuiltDebugHex)

    
    # Compare computed ciphertext with rebuilt_ciphertext
    if cipherTextHex == rebuiltCipherTextHex:
        print("Test Passed: Ciphertext matches rebuilt_ciphertext")
    elif 0x0f1d557e4b6a0938 == rebuiltCipherTextHex:
        print("Test Passed: Ciphertext matches XOR with key AC - ui_in[3] - Always Active.")
    elif 0x07f6d250e3b1a7948 == rebuiltCipherTextHex:
        print("Test Passed: Ciphertext matches XOR with key AC - ui_in[4] - Reset Active.")
    elif (messageHex == rebuiltCipherTextHex):
        print("Test Passed: Ciphertext matches message (no encryption) - ui_in[5] - No key.")
    else:
        print("Test Failed: Ciphertext does not match any expected result.")


    
