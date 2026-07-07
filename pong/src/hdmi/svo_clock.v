/*
 *  SVO Clock Display Module
 *  
 *  Displays a digital clock (HH:MM:SS) on the screen
 */

`timescale 1ns / 1ps
`include "svo_defines.vh"

module svo_clock #( `SVO_DEFAULT_PARAMS ) (
	input clk, 
	input resetn,
	input enable,

	// input stream
	//   tuser[0] ... start of frame
	input in_axis_tvalid,
	output in_axis_tready,
	input [SVO_BITS_PER_PIXEL-1:0] in_axis_tdata,
	input [0:0] in_axis_tuser,

	// output stream
	//   tuser[0] ... start of frame
	output out_axis_tvalid,
	input out_axis_tready,
	output [SVO_BITS_PER_PIXEL-1:0] out_axis_tdata,
	output [0:0] out_axis_tuser
);
	`SVO_DECLS

	// Clock counters
	reg [5:0] seconds = 0;    // 0-59
	reg [5:0] minutes = 0;    // 0-59
	reg [4:0] hours = 0;      // 0-23
	reg [5:0] frame_counter = 0; // Counter for frames @ 60Hz

	// Time keeping - increment every second (60 frames @ 60Hz)
	always @(posedge clk) begin
		if (!resetn) begin
			seconds <= 0;
			minutes <= 0;
			hours <= 0;
			frame_counter <= 0;
		end else if (in_axis_tvalid && in_axis_tready && in_axis_tuser) begin
			// Increment at start of each frame
			if (frame_counter >= 59) begin // 60 frames = 1 second @ 60Hz
				frame_counter <= 0;
				
				if (seconds >= 59) begin
					seconds <= 0;
					if (minutes >= 59) begin
						minutes <= 0;
						if (hours >= 23) begin
							hours <= 0;
						end else begin
							hours <= hours + 1;
						end
					end else begin
						minutes <= minutes + 1;
					end
				end else begin
					seconds <= seconds + 1;
				end
			end else begin
				frame_counter <= frame_counter + 1;
			end
		end
	end

	// Video pipeline
	reg [11:0] pixel_x = 0;
	reg [11:0] pixel_y = 0;
	
	reg pipe_valid = 0;
	reg [SVO_BITS_PER_PIXEL-1:0] pipe_data;
	reg [0:0] pipe_user;

	wire [3:0] hours_tens = hours / 10;
	wire [3:0] hours_ones = hours % 10;
	wire [3:0] minutes_tens = minutes / 10;
	wire [3:0] minutes_ones = minutes % 10;
	wire [3:0] seconds_tens = seconds / 10;
	wire [3:0] seconds_ones = seconds % 10;

	// Character position and size
	localparam CHAR_WIDTH = 32;
	localparam CHAR_HEIGHT = 48;
	localparam START_X = 240;  // Center for 640x480
	localparam START_Y = 216;

	// Check if pixel is in clock display area
	wire in_hours_tens = (pixel_x >= START_X) && 
	                     (pixel_x < START_X + CHAR_WIDTH) &&
	                     (pixel_y >= START_Y) && 
	                     (pixel_y < START_Y + CHAR_HEIGHT);
	
	wire in_hours_ones = (pixel_x >= START_X + CHAR_WIDTH) && 
	                     (pixel_x < START_X + 2*CHAR_WIDTH) &&
	                     (pixel_y >= START_Y) && 
	                     (pixel_y < START_Y + CHAR_HEIGHT);
	
	wire in_colon1 = (pixel_x >= START_X + 2*CHAR_WIDTH) && 
	                 (pixel_x < START_X + 2*CHAR_WIDTH + 16) &&
	                 (pixel_y >= START_Y) && 
	                 (pixel_y < START_Y + CHAR_HEIGHT);
	
	wire in_minutes_tens = (pixel_x >= START_X + 2*CHAR_WIDTH + 16) && 
	                       (pixel_x < START_X + 3*CHAR_WIDTH + 16) &&
	                       (pixel_y >= START_Y) && 
	                       (pixel_y < START_Y + CHAR_HEIGHT);
	
	wire in_minutes_ones = (pixel_x >= START_X + 3*CHAR_WIDTH + 16) && 
	                       (pixel_x < START_X + 4*CHAR_WIDTH + 16) &&
	                       (pixel_y >= START_Y) && 
	                       (pixel_y < START_Y + CHAR_HEIGHT);
	
	wire in_colon2 = (pixel_x >= START_X + 4*CHAR_WIDTH + 16) && 
	                 (pixel_x < START_X + 4*CHAR_WIDTH + 32) &&
	                 (pixel_y >= START_Y) && 
	                 (pixel_y < START_Y + CHAR_HEIGHT);
	
	wire in_seconds_tens = (pixel_x >= START_X + 4*CHAR_WIDTH + 32) && 
	                       (pixel_x < START_X + 5*CHAR_WIDTH + 32) &&
	                       (pixel_y >= START_Y) && 
	                       (pixel_y < START_Y + CHAR_HEIGHT);
	
	wire in_seconds_ones = (pixel_x >= START_X + 5*CHAR_WIDTH + 32) && 
	                       (pixel_x < START_X + 6*CHAR_WIDTH + 32) &&
	                       (pixel_y >= START_Y) && 
	                       (pixel_y < START_Y + CHAR_HEIGHT);

	// Simple 7-segment style digit rendering
	function digit_pixel;
		input [3:0] digit;
		input [11:0] x;
		input [11:0] y;
		reg [6:0] segments; // a,b,c,d,e,f,g
		reg pixel;
		begin
			// 7-segment encoding
			case (digit)
				0: segments = 7'b1111110;
				1: segments = 7'b0110000;
				2: segments = 7'b1101101;
				3: segments = 7'b1111001;
				4: segments = 7'b0110011;
				5: segments = 7'b1011011;
				6: segments = 7'b1011111;
				7: segments = 7'b1110000;
				8: segments = 7'b1111111;
				9: segments = 7'b1111011;
				default: segments = 7'b0000000;
			endcase

			pixel = 0;
			// Segment a (top)
			if (segments[6] && y < 8 && x >= 4 && x < 28) pixel = 1;
			// Segment b (top right)
			if (segments[5] && y >= 4 && y < 24 && x >= 24 && x < 32) pixel = 1;
			// Segment c (bottom right)
			if (segments[4] && y >= 24 && y < 44 && x >= 24 && x < 32) pixel = 1;
			// Segment d (bottom)
			if (segments[3] && y >= 40 && y < 48 && x >= 4 && x < 28) pixel = 1;
			// Segment e (bottom left)
			if (segments[2] && y >= 24 && y < 44 && x < 8) pixel = 1;
			// Segment f (top left)
			if (segments[1] && y >= 4 && y < 24 && x < 8) pixel = 1;
			// Segment g (middle)
			if (segments[0] && y >= 20 && y < 28 && x >= 4 && x < 28) pixel = 1;

			digit_pixel = pixel;
		end
	endfunction

	wire draw_pixel;
	assign draw_pixel = enable && (
		(in_hours_tens && digit_pixel(hours_tens, pixel_x - START_X, pixel_y - START_Y)) ||
		(in_hours_ones && digit_pixel(hours_ones, pixel_x - (START_X + CHAR_WIDTH), pixel_y - START_Y)) ||
		(in_colon1 && ((pixel_y >= START_Y + 12 && pixel_y < START_Y + 20) || 
		              (pixel_y >= START_Y + 28 && pixel_y < START_Y + 36)) && 
		              (pixel_x >= START_X + 2*CHAR_WIDTH + 4 && pixel_x < START_X + 2*CHAR_WIDTH + 12)) ||
		(in_minutes_tens && digit_pixel(minutes_tens, pixel_x - (START_X + 2*CHAR_WIDTH + 16), pixel_y - START_Y)) ||
		(in_minutes_ones && digit_pixel(minutes_ones, pixel_x - (START_X + 3*CHAR_WIDTH + 16), pixel_y - START_Y)) ||
		(in_colon2 && ((pixel_y >= START_Y + 12 && pixel_y < START_Y + 20) || 
		              (pixel_y >= START_Y + 28 && pixel_y < START_Y + 36)) && 
		              (pixel_x >= START_X + 4*CHAR_WIDTH + 20 && pixel_x < START_X + 4*CHAR_WIDTH + 28)) ||
		(in_seconds_tens && digit_pixel(seconds_tens, pixel_x - (START_X + 4*CHAR_WIDTH + 32), pixel_y - START_Y)) ||
		(in_seconds_ones && digit_pixel(seconds_ones, pixel_x - (START_X + 5*CHAR_WIDTH + 32), pixel_y - START_Y))
	);

	// Pipeline stage
	always @(posedge clk) begin
		if (!resetn) begin
			pipe_valid <= 0;
			pixel_x <= 0;
			pixel_y <= 0;
		end else if (in_axis_tready) begin
			pipe_valid <= in_axis_tvalid;
			pipe_user <= in_axis_tuser;
			
			if (in_axis_tvalid) begin
				if (in_axis_tuser) begin
					pixel_x <= 0;
					pixel_y <= 0;
				end else begin
					if (pixel_x >= SVO_HOR_PIXELS - 1) begin
						pixel_x <= 0;
						pixel_y <= pixel_y + 1;
					end else begin
						pixel_x <= pixel_x + 1;
					end
				end

				// Overlay clock on video
				if (draw_pixel) begin
					pipe_data <= {8'd0, 8'd255, 8'd255}; // Cyan color
				end else begin
					pipe_data <= in_axis_tdata;
				end
			end
		end
	end

	assign in_axis_tready = !pipe_valid || out_axis_tready;
	assign out_axis_tvalid = pipe_valid;
	assign out_axis_tdata = pipe_data;
	assign out_axis_tuser = pipe_user;

endmodule
