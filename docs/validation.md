# Validation

## V1 Online Payment Only Validation

**Requirement:** R1

**Objective:** Verify that the vending machine supports only online payment.

**Method:**

* Review the RTL implementation.
* Confirm that no cash payment signals, coin inputs, banknote inputs, balance accumulation, or change calculation logic exist.

**Expected Result:**

* Only `onlinepayment_selected` and `online_payment_success` are used for payment processing.
* No cash-payment functionality is implemented.

**Related Requirement**
[R1](specification.md#r1)

---

## V2 Product Dispensing Validation

**Requirement:** R2

**Objective:** Verify that a product is dispensed only after successful payment.

**Procedure:**

1. Select a valid product.
2. Enter the payment state.
3. Assert `onlinepayment_selected`.
4. Assert `online_payment_success`.

**Expected Result:**

* `online_payment_complete` becomes active.
* FSM transitions to `STATE_OUTPUT_PRODUCT`.
* `show_output_status` becomes active.

**Related Requirement**
[R2](specification.md#r2)

---

## V3 Cash Payment Removal Validation

**Requirement:** R3

**Objective:** Verify that cash payment is not supported.

**Method:**

* Inspect the RTL implementation.

**Expected Result:**

* No coin inputs.
* No banknote inputs.
* No balance accumulation.
* No change calculation.
* No cash payment completion logic.

**Related Requirement**
[R3](specification.md#r3)

---

## V4 Timeout Reset Validation

**Requirement:** R4

**Objective:** Verify automatic reset after timeout.

**Procedure:**

1. Select a valid product.
2. Enter payment state.
3. Assert `timeout`.

**Expected Result:**

* FSM transitions back to `STATE_SELECT_PRODUCT`.

**Related Requirement**
[R4](specification.md#r4)

---

## V5 Product Selection Validation

**Requirement:** R5

**Objective:** Verify that valid product selection initiates the purchase process.

**Procedure:**

1. Apply a valid product number (`0000`–`0111`).

**Expected Result:**

* `product_selected = 1`
* `product_available = 1`
* FSM transitions to `STATE_PAYMENT`.

**Related Requirement**
[R5](specification.md#r5)

---

## V6 Online Payment Validation

**Requirement:** R6

**Objective:** Verify successful online payment handling.

**Procedure:**

1. Enter payment state.
2. Set `onlinepayment_selected = 1`.
3. Set `online_payment_success = 1`.

**Expected Result:**

* `online_payment_complete = 1`
* FSM transitions to `STATE_OUTPUT_PRODUCT`.

**Related Requirement**
[R6](specification.md#r6)

---

## V7 Automatic Reset After Dispensing Validation

**Requirement:** R7

**Objective:** Verify automatic return to product selection state.

**Procedure:**

1. Complete payment.
2. Enter output state.
3. Complete dispensing process.

**Expected Result:**

* FSM returns to `STATE_SELECT_PRODUCT`.

**Related Requirement**
[R7](specification.md#r7)

---

## V8 Manual Reset Validation

**Requirement:** R8

**Objective:** Verify manual reset functionality.

**Procedure:**

1. Place FSM in any operating state.
2. Drive `reset_n = 0`.

**Expected Result:**

* FSM returns to `STATE_SELECT_PRODUCT`.
* Internal payment flags are cleared.

**Related Requirement**
[R8](specification.md#r8)
