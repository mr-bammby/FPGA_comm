module circular_buffer
#(
    parameter BUFFER_SIZE = 16,
    parameter BIT_PER_WORD = 7  // one less as actulal lenght
)
(
	input clk,
	input enableIn,
	input enableOut,
	input [BIT_PER_WORD: 0] dataIn,
	output [BIT_PER_WORD: 0] dataOut,
	output full,
	output empty
);
	integer i;
	reg [BIT_PER_WORD:0] bufferMemory [BUFFER_SIZE-1:0];
	initial begin
		for (i = 0; i < BUFFER_SIZE; i = i + 1) begin
			bufferMemory[i] = 0;
		end
	end

	reg [7:0]writeCnt = 0;
	reg [7:0]readCnt = 0;
	reg [BIT_PER_WORD:0]regOut = 0;

	always @(posedge clk) begin
		if ((enableIn == 1) && (full == 0)) begin
			bufferMemory[writeCnt] <= dataIn;
			if (writeCnt == (BUFFER_SIZE-1)) begin
				writeCnt <= 0;
			end
			else begin
				writeCnt <= writeCnt + 1;
			end
		end
		if ((enableOut == 1) && (empty == 0)) begin
			regOut <= bufferMemory[readCnt];
			if (readCnt == (BUFFER_SIZE-1)) begin
				readCnt <= 0;
			end
			else begin
				readCnt <= readCnt + 1;
			end
		end
	end

	assign empty = (writeCnt == readCnt);
	assign full = ((readCnt - 1) == writeCnt) || ((readCnt == 0) && (writeCnt == (BUFFER_SIZE - 1)));
	assign dataOut = regOut;
endmodule