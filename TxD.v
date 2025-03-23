module TxD (
    input clk,
    input [7:0] data,
    input transmit,
    input reset,
    output reg TxD,
	 output reg transmission_done // flag that is raised when transmission is done
);



	// Internal Variables
	
	 reg [1:0] state;           // State machine: 0 = IDLE, 1 = TRANSMIT
    reg [9:0] shiftright_register; // 10 bits: stop bit, 8 data bits, start bit
    reg [12:0] baudrate_counter;   // Counts up to 5208 for baud rate timing
    reg [3:0] bit_counter;         // Counts 10 bits (start + 8 data + stop)





	// UART Transmission Logic + State Machine Logic
	
	
	  always @(posedge clk) begin
        if (reset) begin
            state <= 0;
            baudrate_counter <= 0;
            bit_counter <= 0;
            shiftright_register <= 10'b0;
            TxD <= 1;           // Idle state: TxD is high
				transmission_done <= 0; // Reset transmission flag
        end else begin
			
            // Increment baud rate counter every clock cycle
            baudrate_counter <= (baudrate_counter == 5208) ? 0 : baudrate_counter + 1;


				  case (state)
                0: begin // IDLE
                    if (transmit) begin
                        state <= 1;
                        // Load shift register: stop bit (1), data, start bit (0)
                        shiftright_register <= {1'b1, data, 1'b0};
                        bit_counter <= 0;
                        baudrate_counter <= 0; // Reset counter to align with baud rate
                        TxD <= 0;          // Start bit begins immediately
                    end else begin
                        TxD <= 1;          // Remain idle
                    end
                end
                1: begin // TRANSMIT
                    if (baudrate_counter == 5208) begin
                        shiftright_register <= shiftright_register >> 1;
                        bit_counter <= bit_counter + 1;
                        TxD <= shiftright_register[1]; // Next bit to be sent
								if (bit_counter == 8) begin
                            transmission_done <= 1; // Set flag when stop bit starts
                        end
                        if (bit_counter == 9) begin
                            state <= 0;    // Return to IDLE after stop bit
									
                        end
                    end
                end
                default: state <= 0;
            endcase
        end
    end












endmodule