module top
#(
    parameter TX_BUFFER_SIZE = 16,
    parameter BIT_PER_WORD = 7,
	parameter DELAY_FRAMES = 2812 // 27,000,000 (27Mhz) / 9600 Baud rate
)
(
    input clk,
    output [5:0] led,
    output uartTx,
	input uartRx,
    input btn
);

localparam STATE_INIT       			= 0;
localparam STATE_LOAD_QUERY				= 1;
localparam STATE_SEND					= 2;
localparam STATE_RECIEVE_QUERY			= 3;
localparam STATE_COMPARE				= 4;
localparam STATE_LOAD_ANSWER_CORRECT	= 5;
localparam STATE_LOAD_ANSWER_WRONG		= 6;

localparam DELAY = 2;

localparam PASS_LENGTH = 4;

reg [7:0] passMemory [PASS_LENGTH-1:0];


reg [7:0] passCheck [PASS_LENGTH-1:0];
initial begin
    passCheck[0] = "1";
    passCheck[1] = "a";
    passCheck[2] = "2";
    passCheck[3] = "B";
end

localparam QUERY_LENGTH = 12;
reg [7:0] queryMemory [QUERY_LENGTH-1:0];
initial begin
    queryMemory[0] = "E";
    queryMemory[1] = "n";
    queryMemory[2] = "t";
    queryMemory[3] = "e";
    queryMemory[4] = "r";
    queryMemory[5] = " ";
    queryMemory[6] = "P";
    queryMemory[7] = "a";
    queryMemory[8] = "s";
    queryMemory[9] = "s";
    queryMemory[10] = ":";
    queryMemory[11] = " ";
end

localparam POSITIVE_ANS_LENGTH = 9;
reg [7:0] positiveAnsMemory [POSITIVE_ANS_LENGTH-1:0];
initial begin
    positiveAnsMemory[0] = "C";
    positiveAnsMemory[1] = "o";
    positiveAnsMemory[2] = "r";
    positiveAnsMemory[3] = "r";
    positiveAnsMemory[4] = "e";
    positiveAnsMemory[5] = "c";
    positiveAnsMemory[6] = "t";
    positiveAnsMemory[7] = "!";
    positiveAnsMemory[8] = " ";
end

localparam NEGATIVE_ANS_LENGTH = 7;
reg [7:0] negativeAnsMemory [NEGATIVE_ANS_LENGTH-1:0];
initial begin
    negativeAnsMemory[0] = "W";
    negativeAnsMemory[1] = "r";
    negativeAnsMemory[2] = "o";
    negativeAnsMemory[3] = "n";
    negativeAnsMemory[4] = "g";
    negativeAnsMemory[5] = "!";
    negativeAnsMemory[6] = " ";
end

integer i;
reg done_loading = 0;
reg data_clk = 0;
reg new_data = 0;
reg [7:0] data = 0;
reg [5:0] data_cnt = 0;
reg [5:0] load_cnt = 0;
reg [5:0] pass_cnt = 0;
reg [1:0] delay_cnt = 0;
reg [3:0] state = STATE_INIT;
reg [3:0] old_state = STATE_INIT;
reg loading = 0;
reg new_transmition = 0; 
reg old_btn = 1;
wire new_click;
wire busy_tx;
wire idle_tx;

wire err;
wire ready_rx;
reg old_ready_rx = 1;
wire [7:0] dataOut;
reg [3:0]  out_reg = 0;
reg pass_check;

wire [2:0] tx_state;

uart_rx
#(
	.BIT_PER_WORD(BIT_PER_WORD),
	.DELAY_FRAMES(DELAY_FRAMES)
) 
u2(  .clk(clk),
.led(led[5:2]),
.rx_pin(uartRx),
.data(dataOut),
.data_ready(ready_rx),
.comm_err(err));

top_tx
#(
	.BIT_PER_WORD(BIT_PER_WORD),
	.DELAY_FRAMES(DELAY_FRAMES),
	.BUFFER_SIZE(TX_BUFFER_SIZE)
) 
u1(  .clk(clk),
.led(led[1:0]),
.uartTx(uartTx),
.dataIn(data),
.data_clk(data_clk),
.busy(busy_tx),
.idle(idle_tx),
.state_out(tx_state));

always @(posedge clk) begin
    old_btn <= btn;
	old_ready_rx <= ready_rx;
    case (state)
        STATE_INIT: begin
            if (new_click == 1) begin
                data_cnt <= 0;
                state <= STATE_LOAD_QUERY;
                new_transmition <= 0;
				load_cnt <= 0;
            end
        end
        STATE_LOAD_QUERY: begin
			if (busy_tx == 0) begin
				if (data_clk == 0) begin
					if (load_cnt < QUERY_LENGTH) begin
						load_cnt <= load_cnt + 1;
						data <= queryMemory[load_cnt];
					end
					data_clk <=  1;
				end
				else begin
					data_clk <=  0;
					if (load_cnt == QUERY_LENGTH) begin
						old_state <= STATE_LOAD_QUERY;
						state <= STATE_SEND;
					end	
				end
			end
        end
        STATE_SEND: begin
            if (idle_tx == 1 ) begin
                if (old_state == STATE_LOAD_QUERY) begin
					state <= STATE_RECIEVE_QUERY;
					pass_cnt <= 0;
					pass_check <= 1;
					load_cnt <= 0;
				end else begin
					state <= STATE_INIT;
					load_cnt <= 0;
				end
            end
        end
        STATE_RECIEVE_QUERY: begin
            if (new_rx == 1) begin
				if ((dataOut >= " ") && (dataOut <= "~")) begin
        			passMemory[pass_cnt] <= dataOut;
					pass_cnt <= pass_cnt + 1;
					done_loading <= 0;
				end
				else
					state <= STATE_INIT;
			end
			if (pass_cnt == PASS_LENGTH) begin
				for (i = 0; i < PASS_LENGTH; i = i + 1) begin
					if (passMemory[i] != passCheck[i])
						pass_check <= 0;
				end
				state <= STATE_COMPARE;
			end
        end
		STATE_COMPARE: begin
			if (pass_check == 1)
				state <= STATE_LOAD_ANSWER_CORRECT;
			else
				state <= STATE_LOAD_ANSWER_WRONG;
			load_cnt <= 0;
		end
		STATE_LOAD_ANSWER_CORRECT: begin
			if (busy_tx == 0) begin
				if (data_clk == 0) begin
					load_cnt <= load_cnt + 1;
					data <= positiveAnsMemory[load_cnt];
					data_clk <=  1;
				end
				else begin
					data_clk <=  0;
					if (load_cnt == POSITIVE_ANS_LENGTH) begin
						state <= STATE_SEND;
						old_state <= STATE_LOAD_ANSWER_CORRECT;
					end
				end
			end
        end
		STATE_LOAD_ANSWER_WRONG: begin
			if (busy_tx == 0) begin
				if (data_clk == 0) begin
					load_cnt <= load_cnt + 1;
					data <= negativeAnsMemory[load_cnt];
					data_clk <=  1;
				end
				else begin
					data_clk <=  0;
					if (load_cnt == NEGATIVE_ANS_LENGTH) begin
						state <= STATE_SEND;
						old_state <= STATE_LOAD_ANSWER_WRONG;
					end
				end
			end
        end
    endcase
end

assign new_click = !btn && old_btn;
assign new_rx = ready_rx && !old_ready_rx;
assign state_out = state;
assign click = new_click; 

endmodule