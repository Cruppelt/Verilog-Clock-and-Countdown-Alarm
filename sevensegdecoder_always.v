////////////////////////////////////////////////////////////////////////////////////////////////////
// Filename:    sevensegdecoder_always.v
// Author:   
// Date:        30 September 2017
// Version:     1
// Description: Procedural dataflow module for seven segment display


module sevensegdecoder_always(d3, d2, d1, d0, a_n, b_n, c_n, d_n, e_n,
f_n, g_n);
 input d3, d2, d1, d0; // active high inputs
 output a_n, b_n, c_n, d_n, e_n, f_n, g_n; // active low outputs
 reg a_n, b_n, c_n, d_n, e_n, f_n, g_n;

    always @(d3 or d2 or  d1 or d0) begin
		case ({d3, d2, d1, d0})
			4'b1111: begin					// if all input bits are on, the display is nothing
							a_n = 1'b1;
							b_n = 1'b1;
							c_n = 1'b1;
							d_n = 1'b1;
							e_n = 1'b1;
							f_n = 1'b1;
							g_n = 1'b1;
						end
			default: begin					// else show the regular number
							a_n = (~d3 & ~d2 & ~d1 & d0) | (~d3 & d2 & ~d1 & ~d0) | (d3 & ~d2 & d1 & d0) | (d3 & d2 & ~d1 & d0);
							b_n = (~d3 & d2 & ~d1 & d0) | (~d3 & d2 & d1 & ~d0) | (d3 & ~d2 & d1 & d0) | (d3 & d2 & ~d1 & ~d0) | (d3 & d2 & d1 & ~d0) | (d3 & d2 & d1 & d0);
							c_n = (~d3 & ~d2 & d1 & ~d0) | (d3 & d2 & ~d1 & ~d0) | (d3 & d2 & d1 & ~d0) | (d3 & d2 & d1 & d0);
							d_n = (~d3 & ~d2 & ~d1 & d0) | (~d3 & d2 & ~d1 & ~d0) | (~d3 & d2 & d1 & d0) | (d3 & ~d2 & ~d1 & d0) | (d3 & ~d2 & d1 & ~d0) | (d3 & d2 & d1 & d0);
							e_n = (~d3 & ~d2 & ~d1 & d0) | (~d3 & ~d2 & d1 & d0) | (~d3 & d2 & ~d1 & ~d0) | (~d3 & d2 & ~d1 & d0) | (~d3 & d2 & d1 & d0) | (d3 & ~d2 & ~d1 & d0);
							f_n = (~d3 & ~d2 & ~d1 & d0) | (~d3 & ~d2 & d1 & ~d0) | (~d3 & ~d2 & d1 & d0) | (~d3 & d2 & d1 & d0) | (d3 & d2 & ~d1 & d0);
							g_n = (~d3 & ~d2 & ~d1 & ~d0) | (~d3 & ~d2 & ~d1 & d0) | (~d3 & d2 & d1 & d0) | (d3 & d2 & ~d1 & ~d0);
						end
		endcase	
   end 
endmodule 