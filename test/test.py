import cocotb
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock


async def reset_dut(dut):
    dut.reset_n.value = 0
    dut.onlinepayment_selected.value = 0
    dut.selected_product_number.value = 0
    dut.online_payment_success.value = 0
    dut.timeout.value = 0

    await Timer(20, unit="ns")
    dut.reset_n.value = 1
    await Timer(20, unit="ns")


@cocotb.test()
async def test_reset(dut):
    """Test reset behavior"""

    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    await reset_dut(dut)

    assert dut.show_product_number.value == 0, \
        "Machine should return to product selection after reset"


@cocotb.test()
async def test_product_selection(dut):
    """Valid product selection"""

    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    await reset_dut(dut)

    dut.selected_product_number.value = 1
    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    assert dut.show_payment_status.value == 1, \
        "Machine should move to payment state"


@cocotb.test()
async def test_successful_payment(dut):
    """Payment success -> dispense product"""

    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    await reset_dut(dut)

    dut.selected_product_number.value = 2
    await RisingEdge(dut.clk)

    dut.onlinepayment_selected.value = 1
    dut.online_payment_success.value = 1

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")


    assert dut.show_output_status.value == 1, \
        "Product should be dispensed after successful payment"


@cocotb.test()
async def test_timeout(dut):
    """Timeout should reset machine"""

    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    await reset_dut(dut)

    dut.selected_product_number.value = 3
    await RisingEdge(dut.clk)

    dut.timeout.value = 1
    await RisingEdge(dut.clk)

    assert dut.show_product_number.value == 0, \
        "Timeout should return machine to selection state"