//instantiate core in system

  //
  // UART
  //
  wire uartInterrupt;

  iob_uart16550 #(
      .DATA_W(32), //PARAM & 32 & 64 & CPU data width
      .ADDR_W(32) //CPU address section width
    ) uart (
      //RS232 interface
      .txd       (uart_txd),
      .rxd       (uart_rxd),
      .rts       (uart_rts),
      .cts       (uart_cts),

      //CPU interface
      .clk       (clk),
      .rst       (reset),
      .valid(slaves_req[`valid(`UART16550)]),
      .address(slaves_req[`address(`UART16550,32)]),
      .wdata(slaves_req[`wdata(`UART16550)]),
      .wstrb(slaves_req[`wstrb(`UART16550)]),
      .rdata(slaves_resp[`rdata(`UART16550)]),
      .ready(slaves_resp[`ready(`UART16550)]),

      .interrupt(uartInterrupt)
      );
