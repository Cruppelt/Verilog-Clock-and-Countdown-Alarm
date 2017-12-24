module effect(clk_in, reset, clk_out);
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
			if (counter < 26'd24999999) begin
				counter <= counter + 1'b1;
			end
			else begin
				counter <= 26'b0;
				clk_out <= ~clk_out;
			end
		end
	end
endmodule 