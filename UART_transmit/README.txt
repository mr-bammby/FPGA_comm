File list:
    uart_transmitter.v modul that can stream data via UART tx.
        Config:
            baudrate -> 9600
            bit_per_word -> 8
            stop_bit -> 1¸
    
    top.v: hello world modul using uart_transmitter as submodule
            Sending triggerd by pressing "button" 

    top.cst configuration for top module compatible with Tang Nano 9k dev board