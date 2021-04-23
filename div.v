module div(data_operandA, data_operandB,	clock, reset, data_result, data_exception, data_resultRDY);

    input [31:0] data_operandA, data_operandB;
    input clock, reset;

    output [31:0] data_result;
    output data_exception, data_resultRDY;

    wire [5:0] number;
    wire init, done;
    wire temp_init;
    wire [63:0] reg_value, reg_out, alpha, beta;
    wire [31:0] A, M, new_A1, new_A2, new_A3, alu_output, new_Q, remainder;
    wire Cout1, Cout2, Cout3, Cout4, Cout5, Cout6, Ovf1, Ovf2, Ovf3, Ovf4, Ovf5, Ovf6;
    wire [31:0] notM, complementM;
    wire negative, sign1, sign2;
    wire [31:0] complementA, complementB, complementResult, notA, notB, notResult;

    // Counter
    dcounter COUNT(number, clock, reset);

    and AND1(temp_init, ~number[5], ~number[4], ~number[3], ~number[2], ~number[1], ~number[0]);
    not NOT1(init, temp_init);
    and AND2(done, number[5], ~number[4], ~number[3], ~number[2], ~number[1], ~number[0]);

    assign notM = ~M;


    // Create unsigned division case
    assign sign1 = data_operandA[31];
    assign sign2 = data_operandB[31];
    assign negative = sign1 ^ sign2;


    assign notA = ~data_operandA;
    assign notB = ~data_operandB;

    adder ADD1(complementA, Cout4, Ovf4, notA, 32'b1 , 1'b0);
    adder ADD2(complementB, Cout5, Ovf5, notB, 32'b1 , 1'b0);

    assign M = sign2 ?  complementB : data_operandB;

    wire [63:0] start_register;
    assign start_register[31:0] = sign1 ? complementA : data_operandA;
    assign start_register[63:32] = 32'b0;

    // ____________________________________________________________________

    assign A = alpha[63:32];

    // Start decision process

    mux_2_64 MUX1(reg_value, init, start_register, reg_out);

    sll_1_64 SHIFTER1(alpha, reg_value);


    adder ADD3(new_A1, Cout1, Ovf1, A, notM , 1'b1); // A = A - M
    adder ADD4(new_A2, Cout2, Ovf2, A, M , 1'b0); // A = A + M


    mux_2 MUX2(alu_output, A[31], new_A1,  new_A2); // Update upper bits of reg, and A by default

    assign new_Q = alu_output[31] ? 1'b0 : 1'b1; // alu_output has the new A value

    assign beta[63:32] = alu_output;
    assign beta[31:1] = alpha[31:1];
    assign beta[0] = new_Q;

    register64 REG(reg_out, 1'b1, clock, reset, beta, 1'b1);

    // After loop

    adder ADD5(new_A3, Cout3, Ovf3, reg_out[63:32], M , 1'b0);
    mux_2 MUX3(remainder, reg_out[63], reg_out[63:32], new_A3);


    // Reattach negative sign if necessary
    assign notResult = ~reg_out[31:0];
    adder ADD6(complementResult, Cout6, Ovf6, notResult, 32'b1 , 1'b0);

    wire[31:0] temp_data_result;
    assign temp_data_result = negative ? complementResult : reg_out[31:0]; // where the quotient is stored

    assign data_resultRDY = done;

    assign data_exception = ~|data_operandB;

    assign data_result = temp_data_result;


endmodule
