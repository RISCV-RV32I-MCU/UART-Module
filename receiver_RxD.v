`timescale 1ns/1ps

module receiver_RxD (
    input clk, // 50 MHz clock
    input reset, // Key 0
    input RxD, // input signal - that sends the data
    output  [7:0] RxData // data that is received, LED's to test it
    );

	 // Internal Variables
    reg shift; // trigger shifting of data
    reg state, next_state; // FSM states
    reg [3:0] bit_counter; // total length of the bits is 10, 1 byte of data, 1 start bit, 1 stop bit
    reg [1:0] sample_counter; // freq = 4 * baudrate
    reg [13:0]  baudrate_counter; // baudrate = 9600 (~ 2^14 to store that number)
    reg [9:0] rxshift_reg; // data byte (10 bits) [8:1] data, [0] start bit, [9] stop bit
    reg clear_bitcounter,inc_bitcounter, inc_samplecounter, clear_samplecounter; // to clear and increment the bit & sample counters

	// Constants
    parameter clk_freq = 50_000_000; // 50 MHz;
    parameter baudrate = 9_600; // 9600 baudrate
    parameter div_sample = 4;
    parameter div_counter = clk_freq/ (baudrate*div_sample);
    parameter mid_sample = (div_sample/2); // sampling data at mid bit
    parameter div_bit = 10; 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
 endmodule 