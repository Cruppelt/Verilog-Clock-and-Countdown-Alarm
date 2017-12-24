module secondsClk(clk_in, reset, clk_out);
	input clk_in, reset;
	output clk_out;
	
	reg clk_out;
	reg [25:0] counter;
	
	always @(posedge clk_in or posedge reset) begin
		if (reset) begin 
			counter <= 26'b0;
			clk_out <= 1'b0;
		end
		else begin
				counter <= counter + 1'b1;
			if (counter == 26'd49999999)
				clk_out <= 1'b1;
			else
			clk_out <= 1'b0;
		end
	end
endmodule 