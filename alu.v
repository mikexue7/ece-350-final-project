module alu(data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt, data_result, isNotEqual, isLessThan, overflow);

    input [31:0] data_operandA, data_operandB;
    input [4:0] ctrl_ALUopcode, ctrl_shiftamt;

    output [31:0] data_result;
    output isNotEqual, isLessThan, overflow;

    wire [31:0] add_result, sub_result, and_result, or_result, sll_result, sra_result, invert_result;
    wire Cin;
    wire Cout;
    wire [31:0] new_B;
    wire tempLessThan, notTempLessThan;

    // Set carry-in based on addition or subtraction
    assign Cin = ctrl_ALUopcode[0] ? 1 : 0;

    // Compute !B for input in case of subtraction
    invert NOT(invert_result, data_operandB);
    assign new_B = ctrl_ALUopcode[0] ? invert_result : data_operandB;

    // Perform either addition or subtraction
    adder ADD(add_result, Cout, overflow, data_operandA, new_B, Cin);

    assign sub_result = add_result;

    // Bitwise AND, OR
    or_function OR(or_result, data_operandA, data_operandB);
    and_function AND(and_result, data_operandA, data_operandB);

    // Shifters
    sll_function SLL(sll_result, data_operandA, ctrl_shiftamt);
    sra_function SRA(sra_result, data_operandA, ctrl_shiftamt);

    // Checking if A is less than B
    wire[31:0] less_result;
    wire Cout_less, ovf_less;
    adder ADD2(less_result, Cout_less, ovf_less, data_operandA, invert_result, 1'b1);

    assign tempLessThan = less_result[31];
    not NOT2(notTempLessThan, tempLessThan);

    assign isLessThan = overflow ? notTempLessThan : tempLessThan;



    not_equal NE(isNotEqual, data_operandA, data_operandB);

    mux_8 ALU_MUX(data_result, ctrl_ALUopcode[2:0], add_result, sub_result, and_result, or_result, sll_result, sra_result, 0, 0);

endmodule
