module mult(data_operandA, data_operandB,	clock, reset, data_result, data_exception, data_resultRDY);

    input [31:0] data_operandA, data_operandB;
    input clock, reset;

    output [31:0] data_result;
    output data_exception, data_resultRDY;

    wire [4:0] number;
    wire init, done;
    wire temp_init;
    wire [64:0] start_register;
    wire[31:0] shifted_result, invert_result;
    wire shift, do_nothing, add_sub;
    wire [31:0] post_shift, post_donothing, post_add_sub, prod, alu_output;
    wire [32:0] current_product;
    wire [64:0] alpha, beta, reg_value, reg_out;
    wire the_sign, except;
    wire Cout, Ovf;


    // Counter
    mcounter COUNT(number, clock, reset);

    // Logic for initial and done states
    and AND1(temp_init, ~number[4], ~number[3], ~number[2], ~number[1], ~number[0]);
    not NOT1(init, temp_init);
    and AND2(done, number[4], ~number[3], ~number[2], ~number[1], number[0]);


    // Setup the starting point of register
    assign start_register[0] = 1'b0;
    assign start_register[32:1] = data_operandB;
    assign start_register[64:33] = 32'b0;


    sll_1 SHIFTER1(shifted_result, data_operandA);
    invert NOT(invert_result, post_donothing);

    mux_2 MUX1(post_shift, shift, data_operandA,  shifted_result);
    mux_2 MUX2(post_donothing, do_nothing, post_shift, 32'b0);
    mux_2 MUX3(post_add_sub, add_sub, post_donothing, invert_result);

    adder ADD(alu_output, Cout, Ovf, prod, post_add_sub, add_sub); // Add or Subtract


    assign alpha[64:33] = alu_output;
    assign alpha[32:0] = current_product;

    sra_2_65 SHIFTER2(beta, alpha);

    mux_2_65 MUX4(reg_value, init, start_register, beta);

    register65 REG(reg_out, 1'b1, clock, reset, reg_value, 1'b1);

    assign prod = reg_out[64:33];
    assign current_product = reg_out[32:0];

    booth_control CTRL(shift, do_nothing, add_sub, current_product[2:0]);


    assign data_result = reg_out[32:1];

    wire ovf1, ovf2, ovf3, ovf4;

    assign ovf1 = |reg_out[64:32]; // check for all 0's
    assign ovf2 = ~&reg_out[64:32]; // check for all 1's
    and AND5(ovf3, data_operandA[31], data_operandB[31], data_result[31]); // All negatives is overflow case

    and AND3(ovf4, ovf1, ovf2); // ovf3 = 1 means bits of upper reg are not all 1's or 0's

    or OR10(data_exception, ovf3, ovf4);

    assign data_resultRDY = done;
endmodule
