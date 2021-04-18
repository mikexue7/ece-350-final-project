`timescale 1ns/100ps
module lsfr_x_tb;

	//inputs to the module (wire)
	wire[31:0] instruction;
	//outputs of the module (wire)
  wire clk, en, clr;
  wire [9:0] init_in, out;

	//Instantiate the module to test
  lsfr_x L(clk, en, clr, init_in, out);

	integer i;

  assign {en} = i[1];
  assign {clk} = i[0];
  assign {clr} = 1'b0;
  assign {init_in} = 10'd240;
	initial begin
		for(i = 0; i < 20; i = i + 1) begin
			#20
			//Display
			$display("Clock:%b, Enable:%b, Clear:%b, Input:%b => Output:%b", clk, en, clr, init_in, out);
		end

		$finish;
	end

endmodule
