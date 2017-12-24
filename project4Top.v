//////////////////////////////////////////////////////////////////
// Filename: project4Top.v
// Author:   Tom Martin
// Date:     7 November 2017
// Revision: 1
//
// This is the top-level module for ECE 3544 Project 4.
// Do not modify the module declaration or ports in this file.
// Before downloading your design to the DE1-SoC board,
// you MUST make the pin assignments in Quartus using
// the steps described in the lab manual and the pin information
// provided in the DE1-SoC manual.  Failing to make the 
// pin assignments may damage your board.

module project4Top(CLOCK_50, KEY, SW, LED, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);
	input        CLOCK_50;
	input [3:0]  KEY;
	input [9:0]  SW;
	output [9:0] LED;
	output [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
	
	reg [1:0] select_bits;
	wire [23:0] fsm_output;
	wire [23:0] hexDigits;
	wire key0_pressed, key1_pressed, key2_pressed, key3_pressed;

	reg display_hokie_p;
	//reg [3:0] current_state, next_state;
	
// The switches (SW[9:0] and LEDs (LED[9:0] are not 
// required to implement the specification.  They are 
// included so that you can use them for debugging if you desire. 

// INSTANTIATE THE MODULES THAT IMPLEMENT YOUR TOP LEVEL MODULE STARTING HERE.
	
	// ************ This makes the clock change every second. 
	//module secondsClk(clk_in, reset, clk_out);
	//secondsClk time_clk(CLOCK_50, key0_pressed, seconds_clk);
	
	always @(KEY[0]) begin
		if (KEY[0] == 0) display_hokie_p = 1'b1;
		else display_hokie_p = 1'b0;
	end
	
	//module fsm(CLOCK_50, key0_pressed, key1_pressed, key2_pressed, key3_pressed, out);
	fsm main_fsm(CLOCK_50, key0_pressed, key1_pressed, key2_pressed, key3_pressed, fsm_output);
	
	//module display(display_hokie_p, fsm_input, outputs);
	display my_display(display_hokie_p, fsm_output, hexDigits); // should be good here
	
	// *********** Button Pressing *************
	
	keypressed U0 (.clock(CLOCK_50),				// 50 MHz FPGA Clock
						.reset(1'b1),				// KEY1 is the system reset.
						.enable_in(KEY[0]),			// KEY0 provides the enable input
						.enable_out(key0_pressed));		// Connect to the enable input port of the counter.
						
	keypressed U1 (.clock(CLOCK_50),				// 50 MHz FPGA Clock
						.reset(1'b1),				// KEY1 is the system reset.
						.enable_in(KEY[1]),			// KEY0 provides the enable input
						.enable_out(key1_pressed));		// Connect to the enable input port of the counter.
						
	keypressed U2 (.clock(CLOCK_50),				// 50 MHz FPGA Clock
						.reset(1'b1),				// KEY1 is the system reset.
						.enable_in(KEY[2]),			// KEY0 provides the enable input
						.enable_out(key2_pressed));		// Connect to the enable input port of the counter.
						
	keypressed U3 (.clock(CLOCK_50),				// 50 MHz FPGA Clock
						.reset(1'b1),				// KEY1 is the system reset.
						.enable_in(KEY[3]),			// KEY0 provides the enable input
						.enable_out(key3_pressed));		// Connect to the enable input port of the counter.
						
	// *********** End Button Pressing *************
	
	sevensegdecoder_always hex5(	.d3(hexDigits[23]),
										.d2(hexDigits[22]),
										.d1(hexDigits[21]),
										.d0(hexDigits[20]),
										.a_n(HEX5[0]),
										.b_n(HEX5[1]),
										.c_n(HEX5[2]),
										.d_n(HEX5[3]),
										.e_n(HEX5[4]),
										.f_n(HEX5[5]),
										.g_n(HEX5[6]));
	
	sevensegdecoder_always hex4(	.d3(hexDigits[19]),
										.d2(hexDigits[18]),
										.d1(hexDigits[17]),
										.d0(hexDigits[16]),
										.a_n(HEX4[0]),
										.b_n(HEX4[1]),
										.c_n(HEX4[2]),
										.d_n(HEX4[3]),
										.e_n(HEX4[4]),
										.f_n(HEX4[5]),
										.g_n(HEX4[6]));
	
	sevensegdecoder_always hex3(	.d3(hexDigits[15]),
										.d2(hexDigits[14]),
										.d1(hexDigits[13]),
										.d0(hexDigits[12]),
										.a_n(HEX3[0]),
										.b_n(HEX3[1]),
										.c_n(HEX3[2]),
										.d_n(HEX3[3]),
										.e_n(HEX3[4]),
										.f_n(HEX3[5]),
										.g_n(HEX3[6]));
										
	sevensegdecoder_always hex2(	.d3(hexDigits[11]),
										.d2(hexDigits[10]),
										.d1(hexDigits[9]),
										.d0(hexDigits[8]),
										.a_n(HEX2[0]),
										.b_n(HEX2[1]),
										.c_n(HEX2[2]),
										.d_n(HEX2[3]),
										.e_n(HEX2[4]),
										.f_n(HEX2[5]),
										.g_n(HEX2[6]));
										
	sevensegdecoder_always hex1(	.d3(hexDigits[7]),
										.d2(hexDigits[6]),
										.d1(hexDigits[5]),
										.d0(hexDigits[4]),
										.a_n(HEX1[0]),
										.b_n(HEX1[1]),
										.c_n(HEX1[2]),
										.d_n(HEX1[3]),
										.e_n(HEX1[4]),
										.f_n(HEX1[5]),
										.g_n(HEX1[6]));
										
	sevensegdecoder_always hex0(	.d3(hexDigits[3]),
										.d2(hexDigits[2]),
										.d1(hexDigits[1]),
										.d0(hexDigits[0]),
										.a_n(HEX0[0]),
										.b_n(HEX0[1]),
										.c_n(HEX0[2]),
										.d_n(HEX0[3]),
										.e_n(HEX0[4]),
										.f_n(HEX0[5]),
										.g_n(HEX0[6]));
										
	assign LED = 10'b1111111111;

endmodule
