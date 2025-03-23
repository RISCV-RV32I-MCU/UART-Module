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















endmodule