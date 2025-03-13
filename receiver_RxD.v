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
	 
	 
	 assign RxData = rxshift_reg[8:1]; // output the data byte
	  //UART receiver logic
	   
    always @(posedge clk) begin
        if(reset) begin
            state <=0; // idle state
            bit_counter <= 0;
            baudrate_counter <= 0;
            sample_counter <= 0;
        end
        else begin
            baudrate_counter <= baudrate_counter + 1;
            if(baudrate_counter >= div_counter - 1) begin
                // receiving state logic
                baudrate_counter <= 0;
                state <= next_state;
                if(shift) rxshift_reg <= {RxD, rxshift_reg[9:1]}; // shift the data
                if(clear_samplecounter) sample_counter <= 0;
                if(inc_samplecounter) sample_counter <= sample_counter + 1;
                if(clear_bitcounter) bit_counter <= 0;
                if(inc_bitcounter) bit_counter <= bit_counter + 1;
            end
        end
    end
	 
	 
	 // state machine logic 
	 
	 always @ (posedge clk)begin
            shift <= 0;
            clear_samplecounter <= 0;
            inc_samplecounter <= 0;
            clear_bitcounter <= 0;
            inc_bitcounter <= 0;
            next_state <= 0; // idle state

            case(state)
                0: begin
                    if(RxD) begin // if RxD is asserted
                        next_state <= 0; // stay in idle state
                    end

                    else begin
                        next_state <= 1;
                        clear_bitcounter <= 1;
                        clear_samplecounter <= 1;
                    end
                end

                1: begin
                    next_state <= 1;
							
							// mid bit sampling at 1 (4/2 = 2 but 1 since we start from 0)
                    if(sample_counter == mid_sample - 1) shift <= 1;
								
								// after a bit period i.e. 4 check if all 10 bits received
                        if(sample_counter == div_sample - 1) begin
                            if(bit_counter == div_bit - 1) begin
                                next_state <= 0;
                            end
                            inc_bitcounter <= 1;
                            clear_samplecounter <= 1;
                        end
                            else inc_samplecounter <= 1;
                end
                default: next_state <= 0;

            endcase

    end
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
 endmodule 