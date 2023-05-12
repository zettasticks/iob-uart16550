`timescale 1ns/1ps

`include "uart_defines.v"
`include "iob_lib.vh"
`include "iob_uart16550_conf.vh"

module iob_uart16550 #(    
  `include "iob_uart16550_params.vh"
  ) (
  `include "iob_uart16550_io.vh"
  );

  wire [`UART_ADDR_WIDTH-1:0] m_wb_adr;
  wire [`UART_DATA_WIDTH/8-1:0] m_wb_sel;
  wire m_wb_we;
  wire m_wb_cyc;
  wire m_wb_stb;
  wire [`UART_DATA_WIDTH-1:0] m_wb_dat_req;
  wire m_wb_ack;
  wire [`UART_DATA_WIDTH-1:0] m_wb_dat_resp;

  iob_iob2wishbone #(
    ADDR_W, DATA_W, 1
  ) iob2wishbone (
    clk_i, cke_i, arst_i, // General input/outputs
    iob_avalid_i, iob_addr_i, iob_wdata_i, iob_wstrb_i, iob_rvalid_o, iob_rdata_o, iob_ready_o, // IOb-bus input/outputs
    m_wb_adr, m_wb_sel, m_wb_we, m_wb_cyc, m_wb_stb, m_wb_dat_req, m_wb_ack, m_wb_dat_resp // WishBone input/outputs
  );

  uart_top uart16550 (
    .wb_clk_i(clk_i),
    // WISHBONE interface
    .wb_rst_i(arst_i),
    .wb_adr_i(m_wb_adr),
    .wb_sel_i(m_wb_sel),
    .wb_we_i(m_wb_we),
    .wb_cyc_i(m_wb_cyc),
    .wb_stb_i(m_wb_stb),
    .wb_dat_i(m_wb_dat_req),
    .wb_ack_o(m_wb_ack),
    .wb_dat_o(m_wb_dat_resp),
    .int_o(interrupt),

`ifdef UART_HAS_BAUDRATE_OUTPUT
    .baud1_o(),
`endif
    // UART	signals
    .srx_pad_i(rxd),
    .stx_pad_o(txd),
    .rts_pad_o(rts),
    .cts_pad_i(cts),
    .dtr_pad_o(),
    .dsr_pad_i(1'b1),
    .ri_pad_i(1'b0),
    .dcd_pad_i(1'b0)
    );

endmodule
