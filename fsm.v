//chris Ruppelt

module fsm(CLOCK_50, key0_pressed, key1_pressed, key2_pressed, key3_pressed, out);
	input CLOCK_50, key0_pressed, key1_pressed, key2_pressed, key3_pressed;
	output [23:0] out;
	
	reg [23:0] out;
	
	wire seconds_clock, effect_clk;
	
	reg [3:0] current_state;
	reg [3:0] next_state;
	
	parameter [3:0] clock_mode = 4'd1, clock_sec = 4'd2, clock_min = 4'd3, clock_hr = 4'd4, alarm_off = 4'd5,
											alarm_hr = 4'd6, alarm_min = 4'd7, alarm_ringing = 4'd8, alarm_running = 4'd9, alarm_mode = 4'd10;
											
	reg [7:0] clock_seconds;
	reg [15:8] clock_minutes;
	reg [23:16] clock_hours;
	reg [7:0] clock_seconds_next;
	reg [15:8] clock_minutes_next;
	reg [23:16] clock_hours_next;
	
	reg [7:0] alarm_seconds;
	reg [7:0] alarm_minutes;
	reg [7:0] alarm_hours;
	
	reg [7:0] alarm_seconds_next;
	reg [7:0] alarm_minutes_next;
	reg [7:0] alarm_hours_next;
	
	reg [7:0] alarm_start_minutes;
	reg [7:0] alarm_start_hours;
	
	reg [7:0] alarm_start_minutes_next;
	reg [7:0] alarm_start_hours_next;
	
	reg alarm_going_off;
	reg alarm_going_off_next;
	reg alarm_going_down;
	reg alarm_going_down_next;

	//module secondsClk(clk_in, reset, clk_out);
	secondsClk my_clock(CLOCK_50, key0_pressed, seconds_clock);
	effect my_effect(CLOCK_50, key0_pressed, effect_clk);
	
	// handles changing states?
	always @(posedge CLOCK_50 or posedge key0_pressed) begin
		if (key0_pressed) begin 
			current_state <= clock_mode;
		end
		else
			current_state <= next_state;
	end
	
	always @(current_state or key1_pressed or key2_pressed or key3_pressed or alarm_going_off or alarm_going_down) begin
		next_state = current_state; // should stop from being a latch
		
		if (alarm_going_off) begin
			next_state = alarm_ringing;
			if (key1_pressed)
				next_state = alarm_mode;
			else if (key2_pressed)
				next_state = alarm_mode;
			else if (key3_pressed)
				next_state = alarm_mode;
		end

		else begin 
			case (current_state)
				clock_mode: begin
									if (key1_pressed)
										next_state = clock_sec;
									else if (key3_pressed)
										next_state = alarm_mode;
								end
				clock_sec: begin
									if (key3_pressed)
										next_state = clock_min;
									else if (key1_pressed)
										next_state = clock_mode;
								end
				clock_min: begin
									if (key3_pressed)
										next_state = clock_hr;
									else if (key1_pressed)
										next_state = clock_mode;
								end
				clock_hr: begin
									if (key3_pressed)
										next_state = clock_sec;
									else if (key1_pressed)
										next_state = clock_mode;
								end
				alarm_mode: begin
									if (key3_pressed)
										next_state = clock_mode;
									else if (key1_pressed) begin
											if (alarm_going_down)
												next_state = alarm_mode;
											else
												next_state = alarm_hr;
										end
									end
				alarm_hr: begin
									if (key1_pressed)
										next_state = alarm_mode;
									else if (key3_pressed)
										next_state = alarm_min;
								end
				alarm_min: begin
									if (key1_pressed)
										next_state = alarm_mode;
									else if (key3_pressed)
										next_state = alarm_hr;
								end
				alarm_ringing: begin
									if (key1_pressed)
										next_state = alarm_mode;
									if (key2_pressed)
										next_state = alarm_mode;
									if (key3_pressed)
										next_state = alarm_mode;
								end
			endcase
		end
	end
	
	// ****************** Time of day clock ***********************

	always @(posedge CLOCK_50 or posedge key0_pressed) begin
		if (key0_pressed) begin
			clock_seconds <= 8'h00;
			clock_minutes <= 8'h00;
			clock_hours <= 8'h12;
		end
		else begin
			clock_seconds <= clock_seconds_next;
			clock_minutes <= clock_minutes_next;
			clock_hours <= clock_hours_next;
		end
	end
	
	// handles incrementing clock with key2 and every second
	always @(*) begin
		clock_seconds_next = clock_seconds;
		clock_minutes_next = clock_minutes;
		clock_hours_next	 = clock_hours;
		
		if (key2_pressed) begin
			if (current_state == clock_sec)
				clock_seconds_next = 8'h00;			// reset seconds
			// incrementing minutes
			else if(current_state == clock_min) begin
				clock_minutes_next[11:8] = clock_minutes_next[11:8] + 1'b1;					// increment first minutes digit
				if (clock_minutes_next[11:8] > 4'h9) begin
					clock_minutes_next[11:8] = 4'h0;													// set first minutes digit to 0
					clock_minutes_next[15:12] = clock_minutes_next[15:12] + 1'b1;			// increment second minutes digit
				end
				if (clock_minutes_next > 8'h59) begin
					clock_minutes_next = 8'h00;														// set minutes to 00
				end
			end
			// incrementing hours
			else if (current_state == clock_hr) begin
				if(clock_hours_next == 8'h12)
					clock_hours_next = 8'hf1;															// set hours to f1
				else begin
					clock_hours_next[19:16] = clock_hours_next[19:16] + 1'b1;				// increment first hours digit
					if (clock_hours_next[19:16] > 4'h9)
						clock_hours_next = 8'h10;												// set hours to 10
				end
			end
		end
		else if (seconds_clock) begin // new second
			clock_seconds_next[3:0] = clock_seconds_next[3:0] + 1'b1;						// increment first seconds digit
			if (clock_seconds_next[3:0] > 4'h9) begin
				clock_seconds_next[3:0] = 4'h0;														// set first seconds digit to 0
				clock_seconds_next[7:4] = clock_seconds_next[7:4] + 1'b1;					// increment second seconds digit
			end
			if (clock_seconds_next[7:0] > 8'h59) begin
				clock_seconds_next = 8'h00;																// set seconds to 0
				clock_minutes_next[11:8] = clock_minutes_next[11:8] + 1'b1;					// increment first minutes digit
			end
			if (clock_minutes_next > 8'h59) begin
					clock_minutes_next = 8'h00;														// set minutes to 00
					clock_hours_next[19:16]	= clock_hours_next[19:16] + 1'b1;				// increment first hours digit
			end
			if (clock_minutes_next[11:8] > 4'h9) begin
					clock_minutes_next[11:8] = 4'h0;													// set first minutes digit to 0
					clock_minutes_next[15:12] = clock_minutes_next[15:12] + 1'b1;			// increment second minutes digit
			end
			if (clock_minutes_next > 8'h59) begin 
				clock_minutes_next = 8'h00;															// set minutes to 00													
				clock_hours_next[19:16] = clock_hours_next[19:16] + 1'b1;					// increment first hours digit
			end
			if (clock_hours_next == 8'h13) begin
				clock_hours_next = 8'hf1;															// set hours to f1
			end
			else if (clock_hours_next[19:16] > 4'h9) begin
				clock_hours_next = 8'h10;																// set hours digit to 10
			end
		end
	end		// end always

	// ****************** End  Time of day clock ***************
	/*
	reg [7:0] alarm_seconds;
	reg [7:0] alarm_minutes;
	reg [7:0] alarm_hours;
	
	reg [7:0] alarm_seconds_next;
	reg [7:0] alarm_minutes_next;
	reg [7:0] alarm_hours_next;
	
	reg [7:0] alarm_start_minutes;
	reg [7:0] alarm_start_hours;
	reg alarm_going_down;
	*/
	// ****************** Alarm Handling Section ***************
	always @(posedge CLOCK_50 or posedge key0_pressed) begin
		if (key0_pressed) begin
			alarm_seconds <= 8'h00;
			alarm_minutes <= 8'h01;
			alarm_hours   <= 8'ha0;
			alarm_going_down <= 1'b0;
			alarm_start_hours <= 8'ha0;
			alarm_start_minutes <= 8'h01;
			alarm_going_off <= 1'b0;
		end
		else begin
			alarm_seconds <= alarm_seconds_next;
			alarm_minutes <= alarm_minutes_next;
			alarm_hours   <= alarm_hours_next;
			alarm_going_down <= alarm_going_down_next;
			alarm_start_hours <= alarm_start_hours_next;
			alarm_start_minutes <= alarm_start_minutes_next;
			alarm_going_off <= alarm_going_off_next;
		end
	end
	
	always @(*) begin
		alarm_going_down_next = alarm_going_down;
		alarm_seconds_next = alarm_seconds;
		alarm_minutes_next = alarm_minutes;
		alarm_hours_next = alarm_hours;
		alarm_start_minutes_next = alarm_start_minutes;
		alarm_start_hours_next = alarm_start_hours;
		alarm_going_off_next = alarm_going_off;
		
		if (key1_pressed) begin	// handles chaning the start time
			if (current_state == alarm_mode) begin
				alarm_seconds_next = 8'h00;
				alarm_minutes_next = alarm_start_minutes_next;
				alarm_hours_next = alarm_start_hours_next;
				alarm_going_down_next = 1'b0;
			end
			else if (current_state == alarm_min) begin
				alarm_start_minutes_next = alarm_minutes_next;
				alarm_start_hours_next	 = alarm_hours_next;
			end
			else if (current_state == alarm_hr) begin
				alarm_start_minutes_next = alarm_minutes_next;
				alarm_start_hours_next	 = alarm_hours_next;
			end
			else if (current_state == alarm_ringing) begin
				alarm_going_off_next = 1'b0;
			end
		end
		else if (key2_pressed) begin	// needs to start and stop alarm, and increment hrs or mins
			if (current_state == alarm_hr) begin // need to increment hours 0-9
				alarm_hours_next[3:0] = alarm_hours_next[3:0] + 1'b1;
				if (alarm_hours_next[3:0] > 4'h9)
					alarm_hours_next[3:0] = 4'h0;											// set hours to 0
			end
			else if (current_state == alarm_min) begin // need to increment minutes 1-59
				if (alarm_minutes_next == 8'h59) begin
					alarm_minutes_next = 8'h00;											// set minutes to 00
				end
				else begin
					alarm_minutes_next[3:0] = alarm_minutes_next[3:0] +1'b1;		// increment first minutes digit
					if (alarm_minutes_next[3:0] > 4'h9) begin
						alarm_minutes_next[7:4] = alarm_minutes_next[7:4] +1'b1;	// increment second minutes digit
						alarm_minutes_next[3:0] = 4'h0;									// set first minutes digit to 0
						if (alarm_minutes_next > 8'h59)
							alarm_minutes_next = 8'h00;
					end
				end
			end
			else if (current_state == alarm_mode) begin
				if (alarm_going_down)
					alarm_going_down_next = 1'b0;
				else
					alarm_going_down_next = 1'b1;
			end
			else if (current_state == alarm_ringing) begin
				alarm_going_off_next = 1'b0;
			end
		end
		else if (key3_pressed) begin
			if (current_state == alarm_ringing) begin
				alarm_going_off_next = 1'b0;
			end
		end
		else if (alarm_going_down && alarm_seconds_next == 8'h00 &&				// alarm rings when it's going down and
					alarm_minutes_next == 8'h00 && alarm_hours_next == 8'ha0) begin	// alarm is at 0
					// CHANGED THIS FROM JUST: alarm_going_off_next = 1'b1;
					if (alarm_going_off)
						alarm_going_off_next = 1'b0;
					else
						alarm_going_off_next = 1'b1;
		end
		else if (alarm_going_down && seconds_clock) begin		// this is where the alarm decreases
			if (alarm_hours_next[3:0] > 4'h0 && alarm_minutes_next == 8'h00 && alarm_seconds_next == 8'h00) begin
				alarm_hours_next[3:0] = alarm_hours_next[3:0] - 1'b1;
				alarm_minutes_next = 8'h59;
				alarm_seconds_next = 8'h59;
			end
			else if (alarm_seconds_next == 8'h00 && alarm_minutes_next[3:0] == 4'h0 && alarm_minutes_next[7:4] > 4'h0) begin // no more hours and has second minutes digit
				alarm_minutes_next[7:4] = alarm_minutes_next[7:4] - 1'b1;
				alarm_minutes_next[3:0] = 4'h9;
				alarm_seconds_next = 8'h59;
			end
			else if (alarm_seconds_next == 8'h00 && alarm_minutes_next[7:4] == 4'h0 && alarm_minutes_next[3:0] > 4'h0) begin
				alarm_minutes_next[3:0] = alarm_minutes_next[3:0] - 1'b1;
				alarm_seconds_next = 8'h59;
			end
			else if (alarm_seconds_next[3:0] == 4'h0 && alarm_seconds_next[7:4] > 4'h0) begin
				alarm_seconds_next[7:4] = alarm_seconds_next[7:4] - 1'b1;
				alarm_seconds_next[3:0] = 4'h9;
			end
			else if (alarm_seconds_next[3:0] > 4'h0) begin
				alarm_seconds_next[3:0] = alarm_seconds_next[3:0] - 1'b1;
			end
		end
	end
	
	
	// determines what is being outputted
	always @(*) begin
	
		out = {8'hff, 8'hff, 8'hff};
		
		
		if (current_state == clock_mode)
			out = {clock_hours, clock_minutes, clock_seconds};
		else if (current_state == clock_sec) begin
			if (effect_clk)
				out = {clock_hours, clock_minutes, 8'hff};		
			else
				out = {clock_hours, clock_minutes, clock_seconds};
		end
		else if (current_state == clock_min) begin
			if (effect_clk)
				out = {clock_hours, 8'hff, clock_seconds};
			else
				out = {clock_hours, clock_minutes, clock_seconds};
		end
		else if (current_state == clock_hr) begin
			if (effect_clk)
				out = {8'hff, clock_minutes, clock_seconds};
			else 
				out = {clock_hours, clock_minutes, clock_seconds};
		end
		else if (current_state == alarm_mode) begin
			out = {alarm_hours, alarm_minutes, alarm_seconds};
		end
		else if (current_state == alarm_hr) begin
			if (effect_clk)
				out = {8'hff, alarm_minutes, alarm_seconds};
			else 
				out = {alarm_hours, alarm_minutes, alarm_seconds};
		end
		else if (current_state == alarm_min) begin
			if (effect_clk)
				out = {alarm_hours, 8'hff, alarm_seconds};
			else 
				out = {alarm_hours, alarm_minutes, alarm_seconds};
		end
		else if (current_state == alarm_ringing) begin
			if (effect_clk)
				out = {8'haa, 8'haa, 8'haa};
			else
				out = {8'hff, 8'hff, 8'hff};
		end
	end
endmodule 