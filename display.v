// chris ruppelt
module display(display_hokie_p, fsm_input, outputs);
	input  display_hokie_p;
	input [23:0] fsm_input;
	output [23:0] outputs;
	
	reg [23:0] outputs;

	always @(*) begin				
		if (display_hokie_p)
			outputs = 24'hff0725;
		else 
			outputs = fsm_input;
	end
	
endmodule 