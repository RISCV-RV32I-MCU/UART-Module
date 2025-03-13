`timescale 1ns/1ps

module tb_receiver_RxD;

    // Signals
    reg clk;
    reg reset;
    reg RxD;
    wire [7:0] RxData;

    // Instantiate the Unit Under Test (UUT)
    receiver_RxD uut (
        .clk(clk),
        .reset(reset),
        .RxD(RxD),
        .RxData(RxData)
    );

    // Clock generation (50 MHz, 20 ns period)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Reset initialization
    initial begin
        reset = 1;
        #100;
        reset = 0;
    end

    // Task to send one bit
    task send_bit(input bit);
        begin
            RxD = bit;
            repeat(5208) @(posedge clk); // 104.167 us at 50 MHz
        end
    endtask

    // Task to send a byte
    task send_byte(input [7:0] data);
        integer i;
        begin
            send_bit(0); // Start bit
            for(i = 0; i < 8; i = i + 1) begin
                send_bit(data[i]); // Data bits
            end
            send_bit(1); // Stop bit
        end
    endtask

    // Stimulus and verification
    initial begin
        wait(reset == 0);           // Wait for reset to deassert
        send_byte(8'hAA);           // Send byte 0xAA
        repeat(5208 * 10) @(posedge clk); // Wait for frame
        if(RxData == 8'hAA) begin
            $display("Test Passed: Received %h", RxData);
        end else begin
            $display("Test Failed: Expected 8'hAA, got %h", RxData);
        end
       // $finish;                    // End simulation
		  $stop;
    end

    // Monitor output (optional)
    initial begin
        $monitor("Time: %t, RxData: %h", $time, RxData);
    end
	 
	 

endmodule