<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project implements a digital vending machine controller using a Finite State Machine (FSM) written in Verilog.

The vending machine operates in three states: product selection, payment, and product dispensing.

First, the user selects a product using a 4-bit product number input. The controller checks whether the selected product is valid and assigns the corresponding product price.

After a valid selection, the machine moves to the payment state. The user can perform online payment. If the payment is successful, the machine transitions to the output state and dispenses the product. If payment fails or times out, the machine returns to the product selection state.

The output signals indicate product selection status, payment status, and dispensing status. A 7-segment display is used to show the selected product number.

## How to test

Power the chip and apply clock signal.
2. Assert reset to initialize the vending machine.
3. Select a product using product selection inputs.
4. Trigger online payment selection.
5. Provide payment success signal.
6. Observe output status pins.
7. Verify 7-segment display shows correct product number.
8. Confirm machine returns to selection state after dispensing.


## External hardware

- Input switches
- 7-segment display
