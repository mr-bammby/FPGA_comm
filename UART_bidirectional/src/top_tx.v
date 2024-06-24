module top_tx
#(
    parameter BUFFER_SIZE = 16,
    parameter BIT_PER_WORD = 7,
	parameter DELAY_FRAMES = 2812 // 27,000,000 (27Mhz) / 9600 Baud rate
)
(
    input clk,
    output [1:0] led,
    output uartTx,
	input [BIT_PER_WORD:0] dataIn,
	input data_clk,
	output busy,
	output idle,
	output [2:0] state_out
);

localparam STATE_INIT       = 0;
localparam STATE_LOAD       = 1;
localparam STATE_SEND       = 2;
localparam STATE_WAIT       = 3;
localparam STATE_END_CHK    = 4;

wire done;
wire newBuffer;
reg new_data = 0;
wire [BIT_PER_WORD:0] data;
reg [2:0] state = STATE_INIT;
reg new_transmition = 0; 
reg old_data_clk = 0;
reg buffer_write = 0;
reg buffer_read = 0;
wire empty;
reg idle_reg = 1;

uart_tx #(
	.BIT_PER_WORD(BIT_PER_WORD),
	.DELAY_FRAMES(DELAY_FRAMES)
)
u(  .clk(clk),
.led(led),
.tx_pin(uartTx),
.data(data),
.data_ready(new_data),
.sampled(done));

circular_buffer #(
	.BIT_PER_WORD(BIT_PER_WORD),
	.BUFFER_SIZE(BUFFER_SIZE)
)
buffer(.clk(clk),
.enableIn(buffer_write),
.enableOut(buffer_read),
.dataIn(dataIn),
.dataOut(data),
.full(busy),
.empty(empty)
);

always @(posedge clk) begin
    old_data_clk <= data_clk;
	if ((newBuffer == 1) && (busy == 0)) begin 
		buffer_write <= 1;
	end
	else begin
		buffer_write <= 0;
	end
    case (state)
        STATE_INIT: begin
            if (empty == 0) begin
                state <= STATE_LOAD;
				idle_reg <= 0;
            end
			else begin
				idle_reg <= 1;
			end
        end
		STATE_LOAD: begin
			if (buffer_read == 0) begin
				buffer_read <= 1;
			end
			else begin
				buffer_read <= 0;
				state <= STATE_SEND;
			end
		end
        STATE_SEND: begin
			state <= STATE_WAIT;
			new_data <= 1;
        end
        STATE_WAIT : begin
            if (done == 1 ) begin
                state <= STATE_END_CHK;
                new_data <= 0;
            end
        end
        STATE_END_CHK : begin
            if (empty == 1) begin
                state <= STATE_INIT;
            end else
                state <= STATE_LOAD;       
        end
    endcase
end

assign newBuffer = data_clk && !old_data_clk;
assign state_out = state;
assign idle = idle_reg;


endmodule