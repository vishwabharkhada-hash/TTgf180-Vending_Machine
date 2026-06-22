import cocotb
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock


async def reset_dut(dut):
    dut.rst_n.value = 0
    
    # dut.onlinepayment_selected (bit 0), dut.selected_product_number (bits 4:1), 
    # and dut.online_payment_success (bit 5) all set to 0.
    dut.ui_in.value = 0
    # dut.timeout.value = 0

    await Timer(20, unit="ns")
    dut.rst_n.value = 1
    await Timer(20, unit="ns")


@cocotb.test()
async def test_reset(dut):
    """Test reset behavior"""

    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    await reset_dut(dut)

    # dut.show_product_number is uo_out[0]
    assert (int(dut.uo_out.value) & 1) == 1, \
        "Machine should return to product selection after reset"


@cocotb.test()
async def test_product_selection(dut):
    """Valid product selection"""

    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    await reset_dut(dut)

    # dut.selected_product_number (bits 4:1) set to 1. (1 << 1) = 2.
    dut.ui_in.value = 2
    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    # dut.show_payment_status is uo_out[1]
    assert ((int(dut.uo_out.value) >> 1) & 1) == 0, \
        "Machine should move to payment state"


@cocotb.test()
async def test_successful_payment(dut):
    """Payment success -> dispense product"""

    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    await reset_dut(dut)

    # dut.selected_product_number (bits 4:1) set to 2. (2 << 1) = 4.
    dut.ui_in.value = 4
    await RisingEdge(dut.clk)

    # selected_product_number = 2 (4), onlinepayment_selected = 1 (1), online_payment_success = 1 (32)
    # 4 + 1 + 32 = 37
    dut.ui_in.value = 37

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    # dut.show_output_status is uo_out[2]
    assert ((int(dut.uo_out.value) >> 2) & 1) == 0, \
        "Product should be dispensed after successful payment"


# @cocotb.test()
# async def test_timeout(dut):
#     """Timeout should reset machine"""
#
#     cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
#
#     await reset_dut(dut)
#
#     # dut.selected_product_number (bits 4:1) set to 3. (3 << 1) = 6.
#     dut.ui_in.value = 6
#     await RisingEdge(dut.clk)
#
#     # dut.timeout.value = 1 (Not mapped to a ui_in pin in tb.v, assuming it would be handled here)
#     await RisingEdge(dut.clk)
#
#     # dut.show_product_number is uo_out[0]
#     assert (int(dut.uo_out.value) & 1) == 0, \
#         "Timeout should return machine to selection state"