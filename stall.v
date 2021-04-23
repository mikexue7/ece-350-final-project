module stall (nop_select, Rwd_DX, rd_DX, rs_FD, rt_FD, DMwe_FD, mul_DX, div_DX);

   //Inputsa
   input Rwd_DX, DMwe_FD, mul_DX, div_DX;
   input [4:0] rd_DX, rs_FD, rt_FD;

   output nop_select;

   wire [4:0] temp1, temp3;
   wire temp2, temp4, temp5, temp6;

   wire nop_select_temp;

   assign temp1 = rs_FD ^ rd_DX;
   assign temp2 = ~|temp1;

   assign temp3 = rt_FD ^ rd_DX;
   assign temp4 = ~|temp3;


   and AND1(temp5, temp4, ~DMwe_FD);

   or OR1(temp6, temp2, temp5);

   and AND2(nop_select_temp, Rwd_DX, temp6);

   or OR3(nop_select, nop_select_temp);



endmodule
