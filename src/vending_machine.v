module vending_machine_fsm (
    input  wire clk,
    input  wire reset_n,

    input  wire onlinepayment_selected,
    input  wire [3:0] selected_product_number,
    input  wire online_payment_success,

    output reg show_product_number,
    output reg show_payment_status,
    output reg show_output_status,

    output reg seg_a,
    output reg seg_b,
    output reg seg_c,
    output reg seg_d,
    output reg seg_e,
    output reg seg_f,
    output reg seg_g
);

    localparam STATE_SELECT_PRODUCT = 2'b00;
    localparam STATE_PAYMENT        = 2'b01;
    localparam STATE_OUTPUT_PRODUCT = 2'b10;

    reg [1:0] current_state;
    reg [1:0] next_state;

    reg product_selected;
    reg product_available;

    reg [11:0] product_price;
   //eg timeout = 0;

    reg online_payment_complete;
    reg payment_incomplete;
    reg dispense_finished;

    // ==========================================
    // State Register
    // ==========================================
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            current_state <= STATE_SELECT_PRODUCT;
        else
            current_state <= next_state;
    end

    // ==========================================
    // Product Price Storage
    // ==========================================
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            product_price <= 12'd0;
        end
        else if (current_state == STATE_SELECT_PRODUCT &&
                 product_selected &&
                 product_available) begin

            case (selected_product_number)
                4'b0000: product_price <= 12'd0; // Free product for testing
                4'b0001: product_price <= 12'd200;
                4'b0010: product_price <= 12'd250;
                4'b0011: product_price <= 12'd300;
                4'b0100: product_price <= 12'd350;
                4'b0101: product_price <= 12'd400;
                4'b0110: product_price <= 12'd450;
                4'b0111: product_price <= 12'd500;
                4'b1000: product_price <= 12'd550;
                default: product_price <= 12'd0;
            endcase
        end
    end

    // ==========================================
    // Next State Logic
    // ==========================================
    always @(*) begin
        next_state = current_state;

        case (current_state)

            STATE_SELECT_PRODUCT: begin
                if (product_selected && product_available)
                    next_state = STATE_PAYMENT;
            end

            STATE_PAYMENT: begin
               //(timeout)
               //   next_state = STATE_SELECT_PRODUCT;
                if (online_payment_complete)
                    next_state = STATE_OUTPUT_PRODUCT;
            end

            STATE_OUTPUT_PRODUCT: begin
                if (dispense_finished)
                    next_state = STATE_SELECT_PRODUCT;
            end

            default: begin
                next_state = STATE_SELECT_PRODUCT;
            end
        endcase
    end

    // ==========================================
    // Moore Output Logic
    // ==========================================
    always @(*) begin
        show_product_number = 1'b0;
        show_payment_status = 1'b0;
        show_output_status  = 1'b0;

        product_selected  = 1'b0;
        product_available = 1'b0;

        case (current_state)

            STATE_SELECT_PRODUCT: begin
                show_product_number = 1'b1;

                case (selected_product_number)
                    4'b0000,
                    4'b0001,
                    4'b0010,
                    4'b0011,
                    4'b0100,
                    4'b0101,
                    4'b0110,
                    4'b0111: begin
                        product_selected  = 1'b1;
                        product_available = 1'b1;
                    end

                    default: begin
                        product_selected  = 1'b0;
                        product_available = 1'b0;
                    end
                endcase
            end

            STATE_PAYMENT: begin
                show_payment_status = 1'b1;
            end

            STATE_OUTPUT_PRODUCT: begin
                if (online_payment_complete)
                    show_output_status = 1'b1;
            end

            default: begin
                show_product_number = 1'b1;
            end
        endcase
    end

    // ==========================================
    // Dispense Completion Logic
    // ==========================================
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            dispense_finished <= 1'b0;
        else if (current_state == STATE_OUTPUT_PRODUCT)
            dispense_finished <= 1'b1;
        else
            dispense_finished <= 1'b0;
    end

    // ==========================================
    // Payment Logic
    // ==========================================
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            online_payment_complete <= 1'b0;
            payment_incomplete      <= 1'b0;
        end
        else begin
            payment_incomplete <= 1'b0;

            if (current_state == STATE_PAYMENT) begin

                if (onlinepayment_selected) begin
                    if (online_payment_success==1'b1) begin
                        online_payment_complete <= 1'b1;
                    end
                    else begin
                        payment_incomplete <= 1'b1;
                    end
                end
                else begin
                    payment_incomplete <= 1'b1;
                end
            end

            else if (current_state == STATE_OUTPUT_PRODUCT &&
                     dispense_finished) begin
                online_payment_complete <= 1'b0;
                payment_incomplete <= 1'b0;
            end
        end
    end
`ifdef FORMAL
    reg f_past_valid = 0;

initial assume(reset_n == 0);

always @(posedge clk) begin
    f_past_valid <= 1;

    if (f_past_valid) begin

        // --------------------------
        // ASSERTIONS (BMC)
        // --------------------------

        // R8: After reset machine must return to select state
        if ($past(reset_n) == 0)
           _a_prove_reset_ : assert(current_state == STATE_SELECT_PRODUCT);

        // R4: Timeout in payment state returns to select state
        if ($past(current_state) == STATE_PAYMENT && $past(timeout))
           _a_timeout_ : assert(current_state == STATE_SELECT_PRODUCT);

        // R2: Output only allowed in output state
        if (show_output_status)
            _a_output_ : assert(current_state == STATE_OUTPUT_PRODUCT);

        // --------------------------
        // COVER PROPERTIES
        // --------------------------

        // Can machine reach payment state?
        _c_payment_ : cover(current_state == STATE_PAYMENT);

        // Can machine reach output state?
        _c_output_ : cover(current_state == STATE_OUTPUT_PRODUCT);
    end
end

`endif 

always @(*) begin
    case(selected_product_number)
4'b0000: begin // 0
    seg_a=0; seg_b=0; seg_c=0; seg_d=0;
    seg_e=0; seg_f=0; seg_g=1;
end

4'b0001: begin // 1
    seg_a=1; seg_b=0; seg_c=0; seg_d=1;
    seg_e=1; seg_f=1; seg_g=1;
end

4'b0010: begin // 2
    seg_a=0; seg_b=0; seg_c=1; seg_d=0;
    seg_e=0; seg_f=1; seg_g=0;
end

4'b0011: begin // 3
    seg_a=0; seg_b=0; seg_c=0; seg_d=0;
    seg_e=1; seg_f=1; seg_g=0;
end

4'b0100: begin // 4
    seg_a=1; seg_b=0; seg_c=0; seg_d=1;
    seg_e=1; seg_f=0; seg_g=0;
end

4'b0101: begin // 5
    seg_a=0; seg_b=1; seg_c=0; seg_d=0;
    seg_e=1; seg_f=0; seg_g=0;
end

4'b0110: begin // 6
    seg_a=0; seg_b=1; seg_c=0; seg_d=0;
    seg_e=0; seg_f=0; seg_g=0;
end

4'b0111: begin // 7
    seg_a=0; seg_b=0; seg_c=0; seg_d=1;
    seg_e=1; seg_f=1; seg_g=1;
end

default: begin
    seg_a=1; seg_b=1; seg_c=1; seg_d=1;
    seg_e=1; seg_f=1; seg_g=1;
end
    endcase
end

wire _unused = &{product_price, payment_incomplete, 1'b0};

endmodule

module cocotb_iverilog_dump();
    initial begin
        $dumpfile ( "sim_build/vending_machine_fsm.vcd" ) ;
        $dumpvars (0 , vending_machine_fsm);
        #1;
    end
endmodule
