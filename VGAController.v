`timescale 1 ns/ 100 ps
module VGAController(
	input clk, 			// 100 MHz System Clock
	input reset, 		// Reset Signal
	input up,
	input left,
	input down,
	input right,
	input [5:0] score,
	output score_flag,
	output isEaten,
	output hSync, 		// H Sync Signal
	output vSync, 		// Veritcal Sync Signal
	output[3:0] VGA_R,  // Red Signal Bits
	output[3:0] VGA_G,  // Green Signal Bits
	output[3:0] VGA_B,  // Blue Signal Bits
	output [7:0] whichLED,
	output [6:0] LED_out,
	inout ps2_clk,
  inout ps2_data);

	// Lab Memory Files Location
	localparam FILES_PATH = "D:/alternateC/snake_processor/";

	// Clock divider 100 MHz -> 25 MHz
	wire clk25; // 25MHz clock

	reg[1:0] pixCounter = 0;      // Pixel counter to divide the clock
    assign clk25 = pixCounter[1]; // Set the clock high whenever the second bit (2) is high
	always @(posedge clk) begin
		pixCounter <= pixCounter + 1; // Since the reg is only 3 bits, it will reset every 8 cycles
	end


	// VGA Timing Generation for a Standard VGA Screen
	localparam
		VIDEO_WIDTH = 640,  // Standard VGA Width
		VIDEO_HEIGHT = 480; // Standard VGA Height

	wire active, screenEnd;
	wire[9:0] x;
	wire[8:0] y;

	VGATimingGenerator #(
		.HEIGHT(VIDEO_HEIGHT), // Use the standard VGA Values
		.WIDTH(VIDEO_WIDTH))
	Display(
		.clk25(clk25),  	   // 25MHz Pixel Clock
		.reset(reset),		   // Reset Signal
		.screenEnd(screenEnd), // High for one cycle when between two frames
		.active(active),	   // High when drawing pixels
		.hSync(hSync),  	   // Set Generated H Signal
		.vSync(vSync),		   // Set Generated V Signal
		.x(x), 				   // X Coordinate (from left)
		.y(y)); 			   // Y Coordinate (from top)

	// Image Data to Map Pixel Location to Color Address
	localparam
		PIXEL_COUNT = VIDEO_WIDTH*VIDEO_HEIGHT, 	             // Number of pixels on the screen
		PIXEL_ADDRESS_WIDTH = $clog2(PIXEL_COUNT) + 1,           // Use built in log2 command
		BITS_PER_COLOR = 12, 	  								 // Nexys A7 uses 12 bits/color
		PALETTE_COLOR_COUNT = 256, 								 // Number of Colors available
		PALETTE_ADDRESS_WIDTH = $clog2(PALETTE_COLOR_COUNT) + 1; // Use built in log2 Command

	wire[PIXEL_ADDRESS_WIDTH-1:0] imgAddress;  	 // Image address for the image data
	wire[PALETTE_ADDRESS_WIDTH-1:0] colorAddr; 	 // Color address for the color palette
	assign imgAddress = x + 640*y;				 // Address calculated coordinate

	RAM_VGA #(
		.DEPTH(PIXEL_COUNT), 				     // Set RAM depth to contain every pixel
		.DATA_WIDTH(PALETTE_ADDRESS_WIDTH),      // Set data width according to the color palette
		.ADDRESS_WIDTH(PIXEL_ADDRESS_WIDTH),     // Set address with according to the pixel count
		.MEMFILE({FILES_PATH, "image.mem"})) // Memory initialization
	ImageData(
		.clk(clk), 						 // Falling edge of the 100 MHz clk
		.addr(imgAddress),					 // Image data address
		.dataOut(colorAddr),				 // Color palette address
		.wEn(1'b0)); 						 // We're always reading

	// Color Palette to Map Color Address to 12-Bit Color
	wire[BITS_PER_COLOR-1:0] colorData; // 12-bit color data at current pixel

	RAM_VGA #(
		.DEPTH(PALETTE_COLOR_COUNT), 		       // Set depth to contain every color
		.DATA_WIDTH(BITS_PER_COLOR), 		       // Set data width according to the bits per color
		.ADDRESS_WIDTH(PALETTE_ADDRESS_WIDTH),     // Set address width according to the color count
		.MEMFILE({FILES_PATH, "colors.mem"}))  // Memory initialization
	ColorPalette(
		.clk(clk), 							   	   // Rising edge of the 100 MHz clk
		.addr(colorAddr),					       // Address from the ImageData RAM
		.dataOut(colorData),				       // Color at current pixel
		.wEn(1'b0)); 						       // We're always reading


	// Assign to output color from register if active
	wire[BITS_PER_COLOR-1:0] colorOut, colorOut2, colorOut3, colorOut4; 			  // Output color

  assign colorOut3 = isFood ? 12'b111100000000 : colorData; // red for apple
	assign colorOut2 = (isWithin) ? 12'd0 : colorOut3;
	assign colorOut4 = ~displayInBounds ? 12'b100101000000 : colorOut2;
	assign colorOut = active ? colorOut4 : 12'd0; // When not active, output black

	// Quickly assign the output colors to their channels using concatenation
	assign {VGA_R, VGA_G, VGA_B} = colorOut;


	reg[9:0] refX_out, foodX;
	reg[8:0] refY_out, foodY;

	wire[9:0] foodX_temp;
	wire [8:0] foodY_temp;

	wire[9:0] foodX_temp2;
	wire [8:0] foodY_temp2;

	lsfr_x FOODX(clk, isEaten, 1'b0, 10'd241, foodX_temp2);
	lsfr_y FOODY(clk, isEaten, 1'b0, 10'd242, foodY_temp2);


	assign foodX_temp = foodX_temp2 % 10'd601 + 15;
	assign foodY_temp = foodY_temp2 % 10'd441 + 15;


	reg [1:0] prevMotion;

	initial
	begin
			refX_out = 320;
			refY_out = 240;
			foodX = 250;
			foodY = 300;
			prevMotion = 2'b01;
			// score_flag = 1'b0;
	end


	wire [9:0] L, R;
	wire [8:0] T, B;

	assign L = refX_out;
	assign R = refX_out + 50;

	assign T = refY_out;
	assign B = refY_out + 50;

	// _______________________________________________

	wire [9:0] L_food, R_food;
	wire [8:0] T_food, B_food;

	assign L_food = foodX;
	assign R_food = foodX + 10;

	assign T_food = foodY;
	assign B_food = foodY + 10;


	wire isEaten;
	assign isEaten = L <= L_food && R >= R_food && T <= T_food && B >= B_food;


	wire isWithin;
	assign isWithin = x >= L & x <= R & y >= T & y <= B;

	wire isFood;
	assign isFood = x >= L_food & x <=R_food & y>= T_food & y <= B_food;


	wire displayInBounds;
	assign displayInBounds = x >= 15 && x <= 625 && y >= 15 && y <= 465;

	wire inBounds;
	assign inBounds = L >= 15 && R <= 625 && T >= 15 && B <= 465;

	assign score_flag = (isEaten & screenEnd) ? 1'b1 : 1'b0;

	integer i;
	//Set value of q on positive edge of the clock or clear
	always @(posedge clk) begin
			// Read in input of the FPGA directions
			if (reset | ~inBounds) begin
					refX_out <= 320;
					refY_out <= 240;
					foodX <= 250;
					foodY <= 250;
					prevMotion <= 2'b01;
					// score_flag = 1'b0;
			end else if (up) begin
					prevMotion <= 2'b00;
			end	else if (down) begin
					prevMotion <= 2'b01;
			end else if (left) begin
					prevMotion <= 2'b10;
			end else if (right) begin
					prevMotion <= 2'b11;
			end

			// once food is eaten, randomize food location and increase size of snake by 1
			if (isEaten & screenEnd) begin
				foodX <= foodX_temp;
				foodY <= foodY_temp;
				// score_flag <= 1'b1;
			// end else if (~isEaten & screenEnd) begin
			// 	score_flag <= 1'b0;
			end

			// control next pixel movement
			if (prevMotion == 2'b00 & screenEnd) begin
					refY_out <= refY_out - 1;
			end	else if (prevMotion == 2'b01 & screenEnd) begin
					refY_out <= refY_out + 1;
			end else if (prevMotion == 2'b10 & screenEnd) begin
					refX_out <= refX_out - 1;
			end else if (prevMotion == 2'b11 & screenEnd) begin
					refX_out <= refX_out + 1;
			end

	end


	SS_Controller C(clk, reset, score, whichLED, LED_out);

endmodule
