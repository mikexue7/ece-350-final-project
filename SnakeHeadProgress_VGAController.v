`timescale 1 ns/ 100 ps
module VGAController(
	input clk, 			// 100 MHz System Clock
	input reset, 		// Reset Signal
	input up,
	input left,
	input down,
	input right,
	output hSync, 		// H Sync Signal
	output vSync, 		// Veritcal Sync Signal
	output[3:0] VGA_R,  // Red Signal Bits
	output[3:0] VGA_G,  // Green Signal Bits
	output[3:0] VGA_B,  // Blue Signal Bits
	inout ps2_clk,
	inout ps2_data);

	// Lab Memory Files Location
	localparam FILES_PATH = "D:/Duke Junior Year/ECE_350/Lab5/";

	// Clock divider 100 MHz -> 25 MHz
	wire clk25; // 25MHz clock

	reg[1:0] pixCounter = 0;      // Pixel counter to divide the clock
    assign clk25 = pixCounter[1]; // Set the clock high whenever the second bit (2) is high
	always @(posedge clk) begin
		pixCounter <= pixCounter + 1; // Since the reg is only 3 bits, it will reset every 8 cycles
	end

	reg onUpdate;
	reg [21:0] count;

	always@(posedge clk)
	begin
		count <= count + 1;
		if(count == 10000000)
		begin
			onUpdate <= ~onUpdate;
			count <= 0;
		end
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

	RAM #(
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

	RAM #(
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
	wire[BITS_PER_COLOR-1:0] colorOut, colorOut2; 			  // Output color

	assign colorOut2 = (isWithin | isFood) ? 12'd0 : colorData;
	assign colorOut = active ? colorOut2 : 12'd0; // When not active, output black

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

	assign foodX_temp = foodX_temp2 % 10'd640;
	assign foodY_temp = foodY_temp2 % 10'd480;

	reg [1:0] prevMotion;

	initial
	begin
			refX_out = 0;
			refY_out = 0;
			foodX = foodX_temp;
			foodY = foodY_temp;
			prevMotion = 2'b01;
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


	reg isWithin = 0;
	// assign isWithin = x >= L & x <= R & y >= T & y <= B;

	reg [9:0] sL, sR;
	reg [8:0] sT, sB;


	integer j;
	reg [4:0] size = 1;


	wire isFood;
	assign isFood = x >= L_food & x <=R_food & y>= T_food & y <= B_food;
	reg [9:0] snakeX[0:31];
	reg [8:0] snakeY[0:31];

	integer i;
	//Set value of q on positive edge of the clock or clear
	always @(posedge clk) begin
			// Read in input of the FPGA directions
			if (reset) begin
					refX_out <= 0;
					refY_out <= 0;
					foodX <= 250;
					foodY <= 250;
					prevMotion <= 2'b01;
			end else if (up) begin
					//refY_out <= refY_out - 1;
					prevMotion <= 2'b00;
			end	else if (down) begin
					//refY_out <= refY_out + 1;
					prevMotion <= 2'b01;
			end else if (left) begin
					//refX_out <= refX_out - 1;
					prevMotion <= 2'b10;
			end else if (right) begin
					//refX_out <= refX_out + 1;
					prevMotion <= 2'b11;
			end

			// once food is eaten, randomize food location and increase size of snake by 1
			if (isEaten & screenEnd) begin
				foodX <= foodX_temp;
				foodY <= foodY_temp;
				size <= size + 1;
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

			// Set snake head to be location registered on FPGA
			snakeY[0] <= refY_out;
			snakeX[0] <= refX_out;


	end

	always @(posedge clk25) begin

		// every element of the snake body follows the element before it
		for(i = size - 1; i > 0; i=i-1)begin
					snakeX[i] <= snakeX[i - 1];
					snakeY[i] <= snakeY[i - 1];
		end

		// For each snake body piece, draw pixel boundary and determine if its within to display a black pixel where
		// the snake is
		for(j = 0; j < size; j=j+1)begin
				sL <= snakeX[j];
				sR <= snakeX[j] + 20;
				sT <= snakeY[j];
				sB <= snakeY[j] + 20;
				isWithin <= isWithin || (x >= sL & x <= sR & y >= sT & y <= sB);

		end

	end

endmodule
