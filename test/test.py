import cocotb
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock

async def reset_dut(dut):
    """Puts the chip into a known starting state."""
    # 1. Initialize ALL top-level inputs to avoid 'X' states!
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    
    dut.rst_n.value = 0 # Pull reset LOW (active)
    await Timer(20, unit="ns")
    dut.rst_n.value = 1 # Pull reset HIGH (inactive)
    await Timer(20, unit="ns")


@cocotb.test()
async def test_reset(dut):
    """Test reset behavior"""
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    await reset_dut(dut)

    # uo_out[0] is show_product_number
    assert int(dut.uo_out.value) & 1 == 1, "Machine should return to product selection after reset"


@cocotb.test()
async def test_product_selection(dut):
    """Valid product selection"""
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    await reset_dut(dut)

    # Drive ui_in directly! 
    # selected_product_number is ui_in[4:1]. Value 1 is (1 << 1) = 2.
    dut.ui_in.value = 2
    
    await RisingEdge(dut.clk)
    
    # Wait 5ns for GF180 GLS propagation delay!
    await Timer(5, unit="ns")

    # uo_out[1] is show_payment_status
    assert (int(dut.uo_out.value) >> 1) & 1 == 1, "Machine should move to payment state"


@cocotb.test()
async def test_successful_payment(dut):
    """Payment success -> dispense product"""
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    await reset_dut(dut)

    # Step 1: Select product 2 (2 << 1 = 4)
    dut.ui_in.value = 4
    await RisingEdge(dut.clk)

    # Step 2: Set product 2 AND payment selected (bit 0) AND success (bit 5)
    # Binary: 0010_0101 = 37
    dut.ui_in.value = 37

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    
    # Wait 5ns for GF180 GLS propagation delay!
    await Timer(5, unit="ns")

    # uo_out[2] is show_output_status
    assert (int(dut.uo_out.value) >> 2) & 1 == 1, "Product should be dispensed after successful payment"