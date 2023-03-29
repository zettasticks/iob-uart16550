`timescale 1ns/1ps

`include "uart_defines.v"
`include "iob_lib.vh"
`include "iob_uart16550_conf.vh"

module iob_uart16550 #(    
  `include "iob_uart16550_params.vh"
  ) (
  `include "iob_uart16550_io.vh"
  );

  wire [`UART_ADDR_WIDTH-1:0] wb_addr_in;
  wire [`UART_DATA_WIDTH-1:0] wb_data_in;
  wire [`UART_DATA_WIDTH-1:0] wb_data_out;
  wire wb_write_enable_in;
  wire wb_valid_in;
  wire wb_ready_in;
  wire [`UART_DATA_WIDTH/8-1:0] wb_strb_in;
  wire [`UART_DATA_WIDTH/8-1:0] wb_select_in;
  wire wb_ready_out;

  /** IOb-bus accesses */
  reg iob_rvalid_reg;
  assign iob_rvalid_o = iob_rvalid_reg;
  //The core supports zero-wait state accesses on all transfers.
  always @(posedge clk_i, posedge arst_i) begin
    if (arst_i) begin
      iob_rvalid_reg <= 1'b0;
    end else if (~wb_write_enable_in) begin
      iob_rvalid_reg <= wb_ready_out;
    end
  end 
  // Ready signal
  assign iob_ready_o = 1'b1;

  // IOb to WishBone converter
  assign wb_addr_in = iob_addr_i[`UART_ADDR_WIDTH-1:0];
  assign wb_data_in = iob_wdata_i;
  assign iob_rdata_o = wb_data_out;
  assign wb_write_enable_in = |iob_wstrb_i;
  assign wb_valid_in = iob_avalid_i;
  assign wb_ready_in = iob_avalid_i&(~iob_rvalid_o);
  assign wb_strb_in = iob_wstrb_i;
  assign wb_select_in = 1<<iob_addr_i[1:0];

  uart_top uart16550 (
    .wb_clk_i(clk_i),
    // WISHBONE interface
    .wb_rst_i(arst_i),
    .wb_adr_i(wb_addr_in),
    .wb_dat_i(wb_data_in),
    .wb_dat_o(wb_data_out),
    .wb_we_i(wb_write_enable_in),
    .wb_stb_i(wb_ready_in),
    .wb_cyc_i(wb_valid_in),
    .wb_sel_i(wb_select_in),
    .wb_ack_o(wb_ready_out),
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
