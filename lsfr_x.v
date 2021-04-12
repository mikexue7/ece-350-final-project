module lsfr_x(clk, en, clr, init_in, out); // for x axis, 640 pixels
    input clk, en, clr;
    input [9:0] init_in;
    output [9:0] out;

    dffe_ref_alt_init dffe_bit_9(out[9], init_in[9], out[9] ^ out[0], clk, en, clr);
    dffe_ref_alt_init dffe_bit_8(out[8], init_in[8], out[9], clk, en, clr);
    dffe_ref_alt_init dffe_bit_7(out[7], init_in[7], out[8], clk, en, clr);
    dffe_ref_alt_init dffe_bit_6(out[6], init_in[6], out[7], clk, en, clr);
    dffe_ref_alt_init dffe_bit_5(out[5], init_in[5], out[6], clk, en, clr);
    dffe_ref_alt_init dffe_bit_4(out[4], init_in[4], out[5], clk, en, clr);
    dffe_ref_alt_init dffe_bit_3(out[3], init_in[3], out[4], clk, en, clr);
    dffe_ref_alt_init dffe_bit_2(out[2], init_in[2], out[3], clk, en, clr);
    dffe_ref_alt_init dffe_bit_1(out[1], init_in[1], out[2], clk, en, clr);
    dffe_ref_alt_init dffe_bit_0(out[0], init_in[0], out[1], clk, en, clr);

endmodule