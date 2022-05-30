`timescale 1ns/1ps

`include "uart_defines.v"

module iob_uart16550
  # (
     parameter DATA_W = 32, //PARAM & 32 & 64 & CPU data width
     parameter ADDR_W = 32 //CPU address section width
     )
  (
   //CPU interface
   input                 valid, //Native CPU interface valid signal
   input [`ADDR_W-1:0] address, //Native CPU interface address signal
   input [`DATA_W-1:0]   wdata, //Native CPU interface data write signal
   input [`DATA_W/8-1:0] wstrb, //Native CPU interface write strobe signal
   output [`DATA_W-1:0]  rdata, //Native CPU interface read data signal
   output                ready, //Native CPU interface ready signal

   //IO rs232
   output txd, //Serial transmit line
   input  rxd, //Serial receive line
   input  cts, //Clear to send; the destination is ready to receive a transmission sent by the UART
   output rts, //Ready to send; the UART is ready to receive a transmission from the sender.
   //output interrupt, //to be done

   input  clk,
   input  rst
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

   assign wb_addr_in = address[`UART_ADDR_WIDTH-1:0];
   assign wb_data_in = wdata;
   assign rdata = wb_data_out;
   assign wb_write_enable_in = wstrb[3] | wstrb[2] | wstrb[1] | wstrb[0];
   assign wb_valid_in = valid;
   assign wb_ready_in = valid&(~ready);
   assign wb_strb_in = wstrb;
   assign wb_select_in = 1<<address[1:0];
   assign ready = wb_ready_out;

   uart_top uart0
     (
      .wb_clk_i(clk),
      // WISHBONE interface
      .wb_rst_i(rst),
      .wb_adr_i(wb_addr_in),
      .wb_dat_i(wb_data_in),
      .wb_dat_o(wb_data_out),
      .wb_we_i(wb_write_enable_in),
      .wb_stb_i(wb_ready_in),
      .wb_cyc_i(wb_valid_in),
      .wb_sel_i(wb_select_in),
      .wb_ack_o(wb_ready_out),
      .int_o(/*interrupt*/),

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
