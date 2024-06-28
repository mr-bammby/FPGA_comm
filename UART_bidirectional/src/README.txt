File list:
	circular_buffer.v Module holding circular buffer
		Config:
			buffer_size -> 16
			bit_per_word -> 8

    uart_transmitter.v Module that can stream data via UART tx.
        Config:
            baudrate -> 9600
            bit_per_word -> 8
            stop_bit -> 1
	
	uart_receiver.v Module that can stream data drom UART rx.
        Config:
            baudrate -> 9600
            bit_per_word -> 8
            stop_bit -> 1
    
    top_tx.v: Module saving bytes into circular_buffer and than one by one sending them over uart_transmitter
	    Config:
            baudrate -> 9600
            bit_per_word -> 8
            stop_bit -> 1
			buffer_size -> 16

	top.v: Simple program that asks for four letter pin and check it against preprogrammed one.
			Sending triggerd by pressing "button".

    top.cst configuration for top module compatible with Tang Nano 9k dev board.