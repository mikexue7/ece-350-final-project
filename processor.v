/**
 * READ THIS DESCRIPTION!
 *
 * This is your processor module that will contain the bulk of your code submission. You are to implement
 * a 5-stage pipelined processor in this module, accounting for hazards and implementing bypasses as
 * necessary.
 *
 * Ultimately, your processor will be tested by a master skeleton, so the
 * testbench can see which controls signal you active when. Therefore, there needs to be a way to
 * "inject" imem, dmem, and regfile interfaces from some external controller module. The skeleton
 * file, Wrapper.v, acts as a small wrapper around your processor for this purpose. Refer to Wrapper.v
 * for more details.
 *
 * As a result, this module will NOT contain the RegFile nor the memory modules. Study the inputs
 * very carefully - the RegFile-related I/Os are merely signals to be sent to the RegFile instantiated
 * in your Wrapper module. This is the same for your memory elements.
 *
 *
 */
module processor(
    // Control signals
    clock,                          // I: The master clock
    reset,                          // I: A reset signal

    // Imem
    address_imem,                   // O: The address of the data to get from imem
    q_imem,                         // I: The data from imem

    // Dmem
    address_dmem,                   // O: The address of the data to get or put from/to dmem
    data,                           // O: The data to write to dmem
    wren,                           // O: Write enable for dmem
    q_dmem,                         // I: The data from dmem

    // Regfile
    ctrl_writeEnable,               // O: Write enable for RegFile
    ctrl_writeReg,                  // O: Register to write to in RegFile
    ctrl_readRegA,                  // O: Register to read from port A of RegFile
    ctrl_readRegB,                  // O: Register to read from port B of RegFile
    data_writeReg,                  // O: Data to write to for RegFile
    data_readRegA,                  // I: Data from port A of RegFile
    data_readRegB                   // I: Data from port B of RegFile

	);

	// Control signals
	input clock, reset;

	// Imem
  output [31:0] address_imem;
	input [31:0] q_imem;

	// Dmem
	output [31:0] address_dmem, data;
	output wren;
	input [31:0] q_dmem;

	// Regfile
	output ctrl_writeEnable;
	output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	output [31:0] data_writeReg;
	input [31:0] data_readRegA, data_readRegB;

	/* YOUR CODE STARTS HERE */

  wire nop_select;
  wire multdiv_nop_select;
  wire flush;

  //------------------- Decode Instructions and Assign Control ----------------
  // FD Pipeline Latch
  wire [31:0] FD_PC_out, FD_IM_out, FD_IM_in, FD_PC;
  wire [31:0] PC_output, PC_plus_one;
  wire isMultDivOn;
  assign FD_PC = flush ? 32'b0 : PC_plus_one;
  assign FD_IM_in = flush ? 32'b0 : q_imem;
  assign multdiv_nop_select = isMultDivOn ? 1'b0 : ~nop_select;
  FD_pipeline FD(FD_IM_out, FD_PC_out, clock, reset, FD_IM_in, FD_PC, multdiv_nop_select);

  // FD Decode Stage
  wire [4:0] Opcode_FD, rd_FD, rs_FD, rt_FD, shamt_FD, ALU_op_FD;
  wire [16:0] Immediate_FD;
  wire [26:0] Target_FD;
  wire BLT_FD, JP_FD, JR_FD, JAL_FD, BNE_FD, DMwe_FD, Rwd_FD, ALUinB_FD, Rwe_FD, read_rd_FD, branch_FD, bex_FD, setx_FD, bexeq_FD;

  control FD_CTRL(FD_IM_out, Opcode_FD, ALU_op_FD, rd_FD, rs_FD, rt_FD, shamt_FD, Immediate_FD, Target_FD,
    BLT_FD, JP_FD, JR_FD, JAL_FD, BNE_FD, DMwe_FD, Rwd_FD, ALUinB_FD, Rwe_FD, read_rd_FD, branch_FD, bex_FD, setx_FD, bexeq_FD);



  assign ctrl_readRegA = (bex_FD || bexeq_FD) ? 5'd30 : rs_FD;

  wire [4:0] ctrl_readRegB_temp;
  assign ctrl_readRegB_temp = read_rd_FD ? rd_FD : rt_FD;
  assign ctrl_readRegB = (bex_FD || bexeq_FD) ? 5'd0 : ctrl_readRegB_temp;

  wire status;
  wire [4:0] temp_ctrl_writeReg;
  wire JAL_MW;
  wire [4:0] rd_MW;
  assign temp_ctrl_writeReg = JAL_MW ? 5'd31 : rd_MW; // the $rd register
  assign ctrl_writeReg = status ? 5'd30 : temp_ctrl_writeReg;

  wire Rwe_MW;
  assign ctrl_writeEnable = Rwe_MW;


  // -------------------- Output from Register to ALU Stage ---------------------
  // DX Pipeline Latch
  wire [31:0] DX_PC_out, DX_IM_out, A_out_DX, B_out_DX, DX_PC, DX_IM_temp, DX_IM;
  assign DX_PC = flush ? 32'b0 : FD_PC_out;
  assign DX_IM_temp = (nop_select || isMultDivOn ) ? 32'b0 : FD_IM_out;
  assign DX_IM = flush ? 32'b0 : DX_IM_temp;
  wire [31:0] alpha, beta;
  assign alpha = isMultDivOn ? A_out_DX : data_readRegA;
  assign beta = isMultDivOn ? B_out_DX : data_readRegB;
  DX_pipeline DX(DX_IM_out, DX_PC_out, A_out_DX, B_out_DX, clock, reset, DX_IM, DX_PC, alpha, beta);

  wire [4:0] Opcode_DX, rd_DX, rs_DX, rt_DX, shamt_DX, ALU_op_DX;
  wire [16:0] Immediate_DX;
  wire [26:0] Target_DX;
  wire BLT_DX, JP_DX, JR_DX, JAL_DX, BNE_DX, DMwe_DX, Rwd_DX, ALUinB_DX, Rwe_DX, read_rd_DX, branch_DX, bex_DX, setx_DX, bexeq_DX;
  control DX_CTRL(DX_IM_out, Opcode_DX, ALU_op_DX, rd_DX, rs_DX, rt_DX, shamt_DX, Immediate_DX, Target_DX,
     BLT_DX, JP_DX, JR_DX, JAL_DX, BNE_DX, DMwe_DX, Rwd_DX, ALUinB_DX, Rwe_DX, read_rd_DX, branch_DX, bex_DX, setx_DX, bexeq_DX);

  wire add_DX, addi_DX, sub_DX, and_op_DX, or_op_DX, sll_DX, sra_DX, mul_DX, div_DX;
  alu_control DX_ALU_CTRL(Opcode_DX, ALU_op_DX, add_DX, addi_DX, sub_DX, and_op_DX, or_op_DX, sll_DX, sra_DX, mul_DX, div_DX);

  wire [31:0] SE_Target_DX; // sign-extended immediate
  sign_extend_target SET(SE_Target_DX, Target_DX);
  // Handle Overflow -----------------------------------------------------------------
  wire [31:0] ovf_data;
  wire [31:0] ALU_output;
  wire [2:0] special_Ovf_ALU_select;
  assign special_Ovf_ALU_select = addi_DX ? 3'b011 : ALU_op_DX[2:0];
  mux_8 MUX3(ovf_data, special_Ovf_ALU_select, 1, 3, ALU_output, 2, ALU_output, ALU_output, 4, 5);

  // -----------------------------------------------------------------------------------

  wire [31:0] B;
  wire Ovf, isNotEqual, isLessThan;

  wire [31:0] SE_Immediate_DX; // sign-extended immediate
  sign_extend_immediate SEI(SE_Immediate_DX, Immediate_DX);

  wire[31:0] A_bypass, B_bypass;
  wire [1:0] ALUinA_select, ALUinB_select;
  wire DMinB_select;
  wire [31:0] O_out_XM;
  mux_4 MUX1(A_bypass, ALUinA_select, O_out_XM, data_writeReg, A_out_DX, A_out_DX);
  mux_4 MUX2(B, ALUinB_select, O_out_XM, data_writeReg, B_out_DX, B_out_DX);

  wire[31:0] B_bexeq;
  assign B_bexeq[4:0] = rd_DX;
  assign B_bexeq[31:5] = 27'b0;
  assign B_bypass = bexeq_DX ? B_bexeq : (ALUinB_DX ? SE_Immediate_DX : B);
  alu ALU1(A_bypass, B_bypass, ALU_op_DX, shamt_DX, ALU_output, isNotEqual, isLessThan, Ovf);

  wire [31:0] A_bypass_out, B_bypass_out;
  wire MD_latched;
  register32 ABP(A_bypass_out, 1'b1, clock, reset, A_bypass, ~MD_latched);
  register32 BBP(B_bypass_out, 1'b1, clock, reset, B_bypass, ~MD_latched);

  wire [31:0] muldiv_A, muldiv_B;

  assign muldiv_A = isMultDivOn ? A_bypass_out : A_bypass;
  assign muldiv_B = isMultDivOn ? B_bypass_out : B_bypass;

  // BNE and BLT Control logic ------------------------------------
  wire Bless_than_A;
  and AND44(Bless_than_A, ~isLessThan, isNotEqual);

  wire branch_green_light, take_branch;
  assign branch_green_light = BLT_DX ? Bless_than_A : isNotEqual;

  and AND55(take_branch, branch_DX, branch_green_light);

  // MULT DIV UNIT ------------------------------------------------------------------
  wire [31:0] multdiv_result_temp; // MD CHECKPOINT
  wire data_exception_temp, data_resultRDY_temp;
  multdiv MULTDIV(muldiv_A, muldiv_B, mul_DX, div_DX,	clock, multdiv_result_temp, data_exception_temp, data_resultRDY_temp);

  wire mul_xor_div_DX;
  xor XOR778(mul_xor_div_DX, mul_DX, div_DX);

  register_1 REG_MD(MD_latched, 1'b1, clock, data_resultRDY_temp, mul_xor_div_DX, mul_xor_div_DX);
  //out, output_enable, clk, clr, in, input_enable

  wire [31:0] multdiv_result;
  wire data_exception, data_resultRDY;

  assign multdiv_result = data_resultRDY_temp ? multdiv_result_temp : 32'b0;
  assign data_exception = data_resultRDY_temp ? data_exception_temp : 1'b0;
  assign data_resultRDY = data_resultRDY_temp ? data_resultRDY_temp : 1'b0;

  // wire [31:0] multdiv_result_latched;
  // register32 REG_MD_RESULT(multdiv_result_latched, 1'b1, clock, 1'b0, multdiv_result, data_resultRDY);

  wire [31:0] multdiv_result_out;
  wire [31:0] PW_IM_out;
  PW_pipeline PW(PW_IM_out, multdiv_result_out, clock, reset, DX_IM_out, multdiv_result, data_resultRDY);



  // --------------------------- POST ALU + MULT DIV STAGE -----------------------------
  wire [31:0] O_in_XM, O_in_XM_temp, O_in_XM_temp2;

  wire Ovf_or_Exception;
  or OR56(Ovf_or_Exception, Ovf, data_exception); // MD CHECKPOINT

  // CHANGE ALU_output to MUX either ALU or MULTI DIV OUTPUT WHEN MULT-DIV UNIT IS ADDED
  assign O_in_XM_temp2 = Ovf_or_Exception ? ovf_data : ALU_output;
  assign O_in_XM_temp = JAL_DX ? DX_PC_out : O_in_XM_temp2;

  assign O_in_XM = setx_DX ? SE_Target_DX : O_in_XM_temp;

  wire ovf_write;
  wire ovf_write_temp1;
  or OR20(ovf_write_temp1, add_DX, addi_DX, sub_DX, mul_DX, div_DX); // MD CHECKPOINT
  and AND20(ovf_write, Ovf, ovf_write_temp1);

  // XM Pipeline Latch
  wire [31:0] XM_IM_out, B_out_XM;
  wire did_Ovf_Occur;
  wire XM_latch_enable;
  assign XM_latch_enable = ~MD_latched;
  XM_pipeline XM(XM_IM_out, O_out_XM, B_out_XM, did_Ovf_Occur, clock, reset, DX_IM_out, O_in_XM, B, ovf_write, XM_latch_enable);

  wire [4:0] Opcode_XM, rd_XM, rs_XM, rt_XM, shamt_XM, ALU_op_XM;
  wire [16:0] Immediate_XM;
  wire [26:0] Target_XM;
  wire BLT_XM, JP_XM, JR_XM, JAL_XM, BNE_XM, DMwe_XM, Rwd_XM, ALUinB_XM, Rwe_XM, read_rd_XM, branch_XM, bex_XM, setx_XM, bexeq_XM;
  control XM_CTRL(XM_IM_out, Opcode_XM, ALU_op_XM, rd_XM, rs_XM, rt_XM, shamt_XM, Immediate_XM, Target_XM,
     BLT_XM, JP_XM, JR_XM, JAL_XM, BNE_XM, DMwe_XM, Rwd_XM, ALUinB_XM, Rwe_XM, read_rd_XM, branch_XM, bex_XM, setx_XM, bexeq_XM);


  assign address_dmem = O_out_XM;
  assign data = DMinB_select ? data_writeReg : B_out_XM;

  assign wren = DMwe_XM;

  // MW Pipeline Latch
  wire [31:0] MW_IM_out, O_out_MW, D_out_MW;
  wire finalOvf;
  // assign MW_IM_in = isMultDivOn ? 32'b0 : XM_IM_out;
  MW_pipeline MW(MW_IM_out, O_out_MW, D_out_MW, finalOvf, clock, reset, XM_IM_out, O_out_XM, q_dmem, did_Ovf_Occur);


  wire [4:0] Opcode_MW, rs_MW, rt_MW, shamt_MW, ALU_op_MW;
  wire [16:0] Immediate_MW;
  wire [26:0] Target_MW;
  wire BLT_MW, JP_MW, JR_MW, BNE_MW, DMwe_MW, Rwd_MW, ALUinB_MW, read_rd_MW, branch_MW, bex_MW, setx_MW, bexeq_MW;
  control MW_CTRL(MW_IM_out, Opcode_MW, ALU_op_MW, rd_MW, rs_MW, rt_MW, shamt_MW, Immediate_MW, Target_MW,
    BLT_MW, JP_MW, JR_MW, JAL_MW, BNE_MW, DMwe_MW, Rwd_MW, ALUinB_MW, Rwe_MW, read_rd_MW, branch_MW, bex_MW, setx_MW, bexeq_MW);

  wire add_MW, addi_MW, sub_MW, and_op_MW, or_op_MW, sll_MW, sra_MW, mul_MW, div_MW;
  alu_control MW_ALU_CTRL(Opcode_MW, ALU_op_MW, add_MW, addi_MW, sub_MW, and_op_MW, or_op_MW, sll_MW, sra_MW, mul_MW, div_MW);

  or OR666(status, finalOvf, setx_MW);
  wire [31:0] data_writeReg_temp;
  assign data_writeReg_temp = Rwd_MW ? D_out_MW : O_out_MW;

  wire mul_or_div_MW; // MD CHECKPOINT
  or OR777(mul_or_div_MW, mul_MW, div_MW);
  assign data_writeReg = mul_or_div_MW ? multdiv_result_out : data_writeReg_temp;

  // ------------------------ Instruction Memory Processing ------------------
  wire [31:0] PC_plus_one_2, PC_plus_one_3, PC_plus_one_4, PC_plus_one_5;
  register PC_REG(PC_output, 1'b1, clock, reset, PC_plus_one_5, multdiv_nop_select);

  wire Cout, PC_Ovf;
  adder ADD1(PC_plus_one, Cout, PC_Ovf, PC_output, 1, 1'b0);

  wire change_in_pc;
  wire rstatus_not_0; // check if $r30 != 0, perform a bex
  or OR24(change_in_pc, JR_DX, JP_DX, JAL_DX, take_branch, rstatus_not_0);
  assign flush = change_in_pc;

  wire useAddressinPC;
  // Incorporate BEX into use Address for PC logic
  and AND66(rstatus_not_0, bex_DX, isNotEqual);
  or OR23(useAddressinPC, JP_DX, JAL_DX, rstatus_not_0);

  // New PC determined from branch instruction
  wire Cout_branch, Branch_Ovf;
  wire [31:0] branch_PC;
  // DX_PC_out is considered to be PC + 1
  adder ADD2(branch_PC, Cout_branch, Branch_Ovf, DX_PC_out, SE_Immediate_DX , 1'b0);

  assign PC_plus_one_2 = take_branch ? branch_PC : PC_plus_one;
  assign PC_plus_one_3 = useAddressinPC ? SE_Target_DX : PC_plus_one_2;
  assign PC_plus_one_4 = JR_DX ? B : PC_plus_one_3;
  assign PC_plus_one_5 = (bexeq_DX && ~isNotEqual) ? SE_Target_DX : PC_plus_one_4;

  assign address_imem = PC_output;

  // -------------- End PC Processing ---------------------------------------
  wire [4:0] rs2_DX;
  assign rs2_DX = read_rd_DX ? rd_DX : rt_DX;
  or OR1234(isMultDivOn, MD_latched, mul_xor_div_DX);
  stall ST(nop_select, Rwd_DX, rd_DX, rs_FD, rt_FD, DMwe_FD, mul_DX, div_DX);
  bypass BP(ALUinA_select, ALUinB_select, DMinB_select, rs_DX, rs2_DX, rd_XM, rd_MW, DMwe_XM, BNE_XM, BLT_XM, DMwe_MW, BNE_MW, BLT_MW, did_Ovf_Occur,
    finalOvf, JAL_XM, JAL_MW, JR_DX, JR_XM, JR_MW, branch_DX, JP_XM, JP_MW, bex_DX, setx_DX, bex_XM, setx_XM, bex_MW, setx_MW);
	/* END CODE */

endmodule
