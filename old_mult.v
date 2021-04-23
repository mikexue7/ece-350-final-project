//
// 		// Set up 64 bit register Architecture
// 		wire[31:0] upper_reg, lower_reg;
// 		wire ie, oe, clr;
// 		assign ie = 1'b1;
// 		assign oe = 1'b1;
// 		assign clr = 1'b0;
//
// 		// Set up Control Architecture
// 		wire[2:0] ctrl, first_ctrl, master_ctrl;
//
// 		wire[63:0] input_data;
// 		wire shift, do_nothing, add_sub;
// 		wire[31:0] shifted_result, invert_result;
// 		sll_1 SHIFTER1(shifted_result, data_operandA);
// 		invert NOT(invert_result, data_operandA);
//
// 		wire[31:0] alpha, beta, delta, kappa;
// 		wire[63:0] gamma, tau;
// 		wire Ovf, Cout;
//
// 		assign input_data[31:0] = data_operandB; // Place multiplier in lower half of the register
//
// 		register UPPER(upper_reg, oe, clock, clr, input_data[63:32], ie);
// 		register LOWER(lower_reg, oe, clock, clr, input_data[31:0], ie);
//
// 		genvar i;
// 		generate
// 			for (i = 0 ; i < 16; i = i+1)
// 			begin : gen_loop
//
// 						// Decide on how the control bits are extracted
// 						assign ctrl = lower_reg[2:0];
// 						assign first_ctrl[2:1] = lower_reg[1:0];
// 						assign first_ctrl[0] = 1'b0;
// 						assign master_ctrl = ~i ? first_ctrl : ctrl;
//
// 						control CTRL(shift, do_nothing, add_sub, master_ctrl);
//
// 						assign alpha = shift ? shifted_result : data_operandA;
// 						assign beta = add_sub ? invert_result : alpha;
// 						assign kappa = do_nothing ? 32'b0 : beta;
//
// 						adder ADD(delta, Cout, Ovf, upper_reg, kappa, add_sub); // Add or Subtract
//
// 						assign gamma[63:32] = delta;
// 						assign gamma[31:0] = lower_reg;
//
// 						sra_2 SHIFTER2(tau, gamma);
//
// 						assign input_data[63:32] = tau[63:32];
// 						assign input_data[31:0] = tau[31:0];
//
//
// 			end
// 		endgenerate
//
// 		assign data_result = lower_reg;
// 		assign data_exception = 1'b1;
// 		assign data_resultRDY = 1'b1;
//
//
// endmodule
