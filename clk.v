/////////////////////////////////////////////////////////////////////
//  Filename     : clk.v
//  Author       : T. Martin
//  Date         : 09/07/04
//  Version      : 2
//  Description  :  This module functions as a simple 
//  		behavioral circuit that simulates a free-running 
//  		clock.  This module has one input and one output:
// 			enable:	input - clock runs when this is asserted.
//				clk_out: output - the clock output.
//
// 		This circuit has one parameter:
//					period: the clock period of the free-running output.
//
//  Modification History:
//  Date      By    Version   Change Description
// ========================================================
//  09/07/04	TLM	1			Original
//  08/24/05	PMA	2			Restructured for Fall 2005
//   
//
// Last modified: 8/24/05
`timescale 1 ns / 1 ps

module clk(enable, clk_out);
	parameter PERIOD = 50;		// The default period of the clock
	input enable;					// Allow clk_out to "run" when asserted
	output clk_out;				// Controlled clock out

	reg clk_out;					// Declare clk_out as a reg

	// Set initial value for clk_out on power-up
	initial clk_out = 0;

	// Produce controlled free-running clock
	always
	begin
		#(PERIOD/2) if (enable == 1) 
			clk_out = ~clk_out;
	end
endmodule





