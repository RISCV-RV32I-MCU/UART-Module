`timescale 1ns/1ps

module TxD_tb;

    // Declare signals
    reg clk;
    reg [7:0] data;
    reg transmit;
    reg reset;
    wire TxD;
	 reg [7:0] received_data;
	 wire t_done;
	integer i;

    // Instantiate the transmitter module
    TxD uut (
        .clk(clk),
        .data(data),
        .transmit(transmit),
        .reset(reset),
        .TxD(TxD),
		  .transmission_done(t_done)
		  
    );

    // Clock generation: 50 MHz (20 ns period)
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // Toggle every 10 ns
    end

    // Test sequence
    initial begin
        // Initialize signals
        reset = 1;
        transmit = 0;
        data = 8'h00;

        // Apply reset for 100 ns
        #100;
        reset = 0;

        // Wait a bit after reset

        // Set data to transmit
        data = 8'h5A; // 10100101

        // Pulse transmit for one clock cycle (20 ns)
        transmit = 1;
        #20;
        transmit = 0;

        // Wait for start bit (TxD goes low)
			 wait(TxD == 0);
			$display("Start bit detected at time %t", $time);
			// Wait 1.5 bit periods to the center of bit0
			repeat(7812) @(posedge clk);
			for (i = 0; i < 8; i = i + 1) begin
				 received_data[i] = TxD;      // Sample TxD
				 $display("Sampled bit %d = %b at time %t", i, TxD, $time);
				 if (i < 7) repeat(5208) @(posedge clk); // Wait one bit period for next bit
			end
			// Optionally check the stop bit
			repeat(5208) @(posedge clk);
			if (TxD != 1) begin
				 $display("Error: Stop bit not received at time %t", $time);
			end else begin
				 $display("Stop bit received correctly at time %t", $time);
			end

        // Verify received data
        if (received_data == data) begin
            $display("Transmission successful: received %h, expected %h", received_data, data);
				$display("Transmission flag: %b", t_done);
        end else begin
            $display("Transmission error: received %h, expected %h", received_data, data);
        end

        // Run a bit longer, then finish
        //#10000;
        $stop;
    end

endmodule