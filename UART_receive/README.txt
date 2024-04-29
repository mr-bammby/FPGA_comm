File list:
    uart_receiver.v modul that can stream data drom UART rx.
        Config:
            baudrate -> 9600
            bit_per_word -> 8
            stop_bit -> 1¸
    
    top.v: Receving ASCII digit and displaying it withon board LED using uart_receiver.

    top.cst configuration for top module compatible with Tang Nano 9k dev board