
module tb_top();
	reg clk = 0;
	reg uart_rx = 1;
	wire uart_tx;
	wire [5:0] led;
	reg btn = 1;
	reg [7:0] test;

	top
	#(
		.DELAY_FRAMES(2)
	)
	u(
		.clk(clk),
		.uartRx(uart_rx),
		.uartTx(uart_tx),
		.led(led),
		.btn(btn)
	);

	localparam PASS_LEN = 4;
	
	reg [7:0] testMemory [PASS_LEN-1:0];
	initial begin
		testMemory[0] = "1";
		testMemory[1] = "a";
		testMemory[2] = "2";
		testMemory[3] = "B";
	end

	reg [7:0] testMemory2 [PASS_LEN-1:0];
	initial begin
		testMemory2[0] = "1";
		testMemory2[1] = "a";
		testMemory2[2] = "2";
		testMemory2[3] = "2";
	end


	integer i,j;
	

	always
    	#1  clk = ~clk;
	
	initial begin
		$display("Starting UART RX");
		#10		btn=0;
		#6		btn=1;
		#520;
		for (i = 0; i < PASS_LEN; i = i + 1) begin
			uart_rx = 0;
			#4;
			test = testMemory[i];
			for (j = 0; j <= 7; j = j + 1) begin
				uart_rx = (testMemory[i] >> j) & 1'b1;
				#4;
			end
			uart_rx = 1;
			#4;
		end
		#550 	btn=0;
		#6		btn=1;
				#520;
		for (i = 0; i < PASS_LEN; i = i + 1) begin
			uart_rx = 0;
			#4;
			test = testMemory2[i];
			for (j = 0; j <= 7; j = j + 1) begin
				uart_rx = (testMemory2[i] >> j) & 1'b1;
				#4;
			end
			uart_rx = 1;
			#4;
		end
		#550 $finish;
	end

	initial begin
	    $dumpfile("tb_top.vcd");
    	$dumpvars(0,tb_top);
  	end
endmodule