module bypass (ALUinA_select, ALUinB_select, DMinB_select, rs_DX, rt_DX, rd_XM, rd_MW, DMwe_XM, BNE_XM, BLT_XM, DMwe_MW, BNE_MW, BLT_MW, Ovf_XM_out,
  Ovf_MW_out, JAL_XM, JAL_MW, JR_DX, JR_XM, JR_MW, branch_DX, JP_XM, JP_MW, bex_DX, setx_DX, bex_XM, setx_XM, bex_MW, setx_MW);

   //Inputs
   input [4:0] rs_DX, rt_DX, rd_XM, rd_MW;
   input DMwe_XM, BNE_XM, BLT_XM, DMwe_MW, BNE_MW, BLT_MW, Ovf_XM_out, Ovf_MW_out, JAL_XM, JAL_MW, JR_DX, JR_XM, JR_MW;
   input branch_DX, JP_XM, JP_MW, bex_DX, setx_DX, bex_XM, setx_XM, bex_MW, setx_MW;

   output [1:0] ALUinA_select, ALUinB_select;
   output DMinB_select;

   wire [4:0] temp1, temp2, temp3, temp4, temp5;
   wire temp6;


   // Bypass A Logic --------------------------------------------------------------

   // Deciding Select Bit 0 ----------------------------------------------------
   wire equal1, xm_select;
   wire [1:0] select;

   wire [4:0] rd_XM_temp1, rd_XM_temp2;
   wire rd_XM_select;

   or OR110(rd_XM_select, Ovf_XM_out, setx_XM);
   assign rd_XM_temp1 = rd_XM_select ? 5'd30 : rd_XM; // or Overflow with setx
   assign rd_XM_temp2 = JAL_XM ? 5'd31 : rd_XM_temp1;

   wire [4:0] rs_DX_temp1;
   assign rs_DX_temp1 = bex_DX ? 5'd30 : rs_DX;

   assign temp1 = rs_DX_temp1 ^ rd_XM_temp2;
   assign equal1 = ~|temp1;  // D/X.IR.RS1 == X/M.IR.RD

   wire XM_rd_0, XM_rd_final;
   assign XM_rd_0 = ~|rd_XM;
   and AND21(XM_rd_final, XM_rd_0, ~JAL_XM, ~setx_XM);
   or OR1(xm_select, DMwe_XM, BNE_XM, BLT_XM, XM_rd_final, JR_XM, JP_XM, bex_XM);

   assign select[0] = xm_select ? 1'b0 : equal1;

    // Deciding Select Bit 1  ----------------------------------------------------

   wire equal2, mw_select;

   wire [4:0] rd_MW_temp1, rd_MW_temp2;
   wire rd_MW_select;

   or OR111(rd_MW_select, Ovf_MW_out, setx_MW);
   assign rd_MW_temp1 = rd_MW_select ? 5'd30 : rd_MW;
   assign rd_MW_temp2 = JAL_MW ? 5'd31 : rd_MW_temp1;

   assign temp2 = rs_DX_temp1 ^ rd_MW_temp2;
   assign equal2= ~|temp2;  // D/X.IR.RS1 == M/W.IR.RD

   wire MW_rd_0, MW_rd_final;
   assign MW_rd_0 = ~|rd_MW;
   and AND22(MW_rd_final, MW_rd_0, ~JAL_MW, ~setx_MW);
   or OR2(mw_select, DMwe_MW, BNE_MW, BLT_MW, MW_rd_final, JR_MW, JP_MW, bex_MW);

   assign select[1] = mw_select ? 1'b0 : equal2;

   mux_4_2 MUX1(ALUinA_select, select, 2'b10, 2'b00, 2'b01, 2'b00);

  // Bypass B Logic -------------------------------------------------------------------------------------------------------------------------------------
  // ----------------------------------------------------------------------------------------------------------------------------------------------------

  // Deciding Select Bit 0 ----------------------------------------------------

   wire equal3;
   wire [1:0] select2;

   assign temp3 = rt_DX ^ rd_XM_temp2;
   assign equal3 = ~|temp3;  // D/X.IR.RS2 == X/M.IR.RD

   assign select2[0] = xm_select ? 1'b0 : equal3;

  // Deciding Select Bit 1 ----------------------------------------------------

   wire equal4, mw_select2;

   assign temp4 = rt_DX ^ rd_MW_temp2;
   assign equal4 = ~|temp4;


   assign select2[1] = mw_select ? 1'b0 : equal4;


   mux_4_2 MUX2(ALUinB_select, select2, 2'b10, 2'b00, 2'b01, 2'b00);


   wire [4:0] rd_MW_temp3;
   assign rd_MW_temp3 = rd_MW_select ? 5'd30 : rd_MW;
   assign temp5 = rd_XM ^ rd_MW_temp3;
   assign temp6 = ~|temp5;  // X/M.IR.RD == M/W.IR.RD


   and AND1(DMinB_select, temp6, ~mw_select, DMwe_XM); // (X/M.IR.RD == M/W.IR.RD) && X/M.IR.OP == STORE


endmodule
