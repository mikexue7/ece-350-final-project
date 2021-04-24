module AudioController(
    input        clock, 		// System Clock Input 100 Mhz
    input        micData,	// Microphone Output
    input        score_flag,
    input        isEaten,
    output       chSel,		// Channel select; 0 for rising edge, 1 for falling edge
    output       audioOut	// PWM signal to the audio jack
    );	// Audio Enable

	localparam MHz = 1000000;
	localparam SYSTEM_FREQ = 100*MHz; // System clock frequency

	assign chSel   = 1'b0;  // Collect Mic Data on the rising edge
	//assign audioEn = isEaten ? 1'b1 : 1'b0;  // Enable Audio Output

	// Initialize the frequency array. FREQs[0] = 261
	reg[10:0] FREQs[0:15];
	initial begin

		$readmemh("FREQs.mem", FREQs);
	end

  wire [3:0] switches;
  assign switches[0] = isEaten;
  assign switches[3:1] =  3'b0;
  wire[10:0] f_d = FREQs[switches];

  wire[6:0] duty_cycle;
  reg clk1MHz = 0;
  reg[31:0] counter = 0;
  wire[31:0] CounterLimit = (SYSTEM_FREQ)/(2*f_d);


  always @(posedge clock) begin
      if (counter < CounterLimit)
          counter <= counter + 1;
      else begin
          counter <= 0;
          clk1MHz <= ~clk1MHz;
      end
  end

  assign duty_cycle = clk1MHz ? 7'd90 : 7'd10;

  PWMSerializer PWM(clock, 1'b0, duty_cycle, audioOut);

endmodule
