`timescale 1ns/1ps

module uart_tb;

`include "uart_defines.v"

reg                         clkr;
reg                         wb_rst_ir;
wire [`UART_ADDR_WIDTH-1:0] wb_adr_i;
wire [31:0]                 wb_dat_i;
wire [31:0]                 wb_dat_o;
wire                        wb_we_i;
wire                        wb_stb_i;
wire                        wb_cyc_i;
wire                        wb_ack_o;
wire [3:0]                  wb_sel_i;
wire                        int_o;
wire                        pad_stx_o;
wire                        rts_o;
wire                        dtr_o;
reg                         pad_srx_ir;

// All the signals and regs named with a 1 are receiver fifo signals
wire [`UART_ADDR_WIDTH-1:0] wb1_adr_i;
wire [31:0]                 wb1_dat_i;
wire [31:0]                 wb1_dat_o;
wire                        wb1_we_i;
wire                        wb1_stb_i;
wire                        wb1_cyc_i;
wire                        wb1_ack_o;
wire [3:0]                  wb1_sel_i;
wire                        int1_o;
wire                        stx1_o;
wire                        rts1_o;
wire                        dtr1_o;
reg                         srx1_ir;

wire clk = clkr;
wire wb_rst_i = wb_rst_ir;
wire pad_srx_i = pad_srx_ir;
wire cts_i = 1; //cts_ir;
wire dsr_i = 1; //dsr_ir;
wire ri_i = 1; //ri_ir;
wire dcd_i = 1; //dcd_ir;

wire srx1_i = srx1_ir;
wire cts1_i = 1; //cts1_ir;
wire dsr1_i = 1; //dsr1_ir;
wire ri1_i = 1; //ri1_ir;
wire dcd1_i = 1; //dcd1_ir;

reg [31:0] dat_o;

integer e;

localparam ADDR_W = 32;
localparam DATA_W = 32;

wire clk_i = clk;
wire cke_i = 1'b1;
wire arst_i = wb_rst_i;

wire [0:0] iob_avalid = wb_cyc_i & wb_stb_i;
wire [ADDR_W-1:0] iob_addr = wb_adr_i;
wire [DATA_W-1:0] iob_wdata = wb_dat_i;
wire [DATA_W/8-1:0] iob_wstrb = wb_we_i & wb_sel_i;
wire [0:0] iob_rvalid;
wire [DATA_W-1:0] iob_rdata;
wire [0:0] iob_ready;
assign wb_ack_o = iob_rvalid;
assign wb_dat_o = iob_rdata;

wire [0:0] iob_avalid_1 = wb1_cyc_i & wb1_stb_i;
wire [ADDR_W-1:0] iob_addr_1 = wb1_adr_i;
wire [DATA_W-1:0] iob_wdata_1 = wb1_dat_i;
wire [DATA_W/8-1:0] iob_wstrb_1 = wb1_we_i & wb1_sel_i;
wire [0:0] iob_rvalid_1;
wire [DATA_W-1:0] iob_rdata_1;
wire [0:0] iob_ready_1;
assign wb1_ack_o = iob_rvalid_1;
assign wb1_dat_o = iob_rdata_1;

iob_uart16550 #(
  .ADDR_W(ADDR_W),
  .DATA_W(DATA_W)
) uart_snd(
  `include "iob_s_portmap.vh"

  .txd(pad_stx_o),
  .rxd(pad_srx_i),
  .cts(cts_i),
  .rts(rts_o),
  .interrupt(int_o),

  `include "iob_clkenrst_portmap.vh"
);
iob_uart16550 #(
  .ADDR_W(ADDR_W),
  .DATA_W(DATA_W)
) uart_rcv(
  .iob_avalid_i(iob_avalid_1[0+:1]), //Request valid.
  .iob_addr_i(iob_addr_1[0+:ADDR_W]), //Address.
  .iob_wdata_i(iob_wdata_1[0+:DATA_W]), //Write data.
  .iob_wstrb_i(iob_wstrb_1[0+:(DATA_W/8)]), //Write strobe.
  .iob_rvalid_o(iob_rvalid_1[0+:1]), //Read data valid.
  .iob_rdata_o(iob_rdata_1[0+:DATA_W]), //Read data.
  .iob_ready_o(iob_ready_1[0+:1]), //Interface ready.

  .txd(stx1_o),
  .rxd(srx1_i),
  .cts(cts1_i),
  .rts(rts1_o),
  .interrupt(int1_o),

  `include "iob_clkenrst_portmap.vh"
);

/////////// CONNECT THE UARTS
always @(pad_stx_o) begin
  srx1_ir = pad_stx_o;  
end

`ifdef VCD
initial begin
    $dumpfile("uut.vcd");
    $dumpvars;
end
`endif

initial begin
    clkr = 0;
    #50000 $finish;
end

initial begin
    $display("Data bus is %0d-bit. UART uses %0d-bit addr.", `UART_DATA_WIDTH, `UART_ADDR_WIDTH);
end

always begin
    #5 clkr = ~clk;
end

wire [31:0] aux_wb_adr_i;
assign wb_adr_i = aux_wb_adr_i[4:0];
wb_mast wbm(// Outputs
        .adr  (aux_wb_adr_i),
        .dout (wb_dat_i),
        .cyc  (wb_cyc_i),
        .stb  (wb_stb_i),
        .sel  (wb_sel_i),
        .we   (wb_we_i),
        // Inputs
        .clk  (clk),
        .rst  (wb_rst_i),
        .din  (wb_dat_o),
        .ack  (wb_ack_o),
        .err  (1'b0),
        .rty  (1'b0));

wire [31:0] aux_wb1_adr_i;
assign wb1_adr_i = aux_wb1_adr_i[4:0];
wb_mast wbm1(// Outputs
         .adr (aux_wb1_adr_i),
         .dout(wb1_dat_i),
         .cyc (wb1_cyc_i),
         .stb (wb1_stb_i),
         .sel (wb1_sel_i),
         .we  (wb1_we_i),
         // Inputs
         .clk (clk),
         .rst (wb_rst_i),
         .din (wb1_dat_o),
         .ack (wb1_ack_o),
         .err (1'b0),
         .rty (1'b0));

// The test sequence
initial
begin
  #1 wb_rst_ir = 1;
  #10 wb_rst_ir = 0;
    
  //write to lcr. set bit 7
  //wb_cyc_ir = 1;
  wbm.wb_wr1(`UART_REG_LC, 4'b1000, {8'b10011011, 24'b0});
  // set dl to divide by 3
  wbm.wb_wr1(`UART_REG_DL1,4'b0001, 32'd2);
  @(posedge clk);
  @(posedge clk);
  // restore normal registers
  wbm.wb_wr1(`UART_REG_LC, 4'b1000, {8'b00011011, 24'b0}); //00011011 

  fork begin
    $display("%m : %t : sending : %h", $time, 8'b10000001);
    wbm.wb_wr1(0, 4'b1, 32'b10000001);
    @(posedge clk);
    @(posedge clk);
    $display("%m : %t : sending : %h", $time, 8'b01000010);
    wbm.wb_wr1(0, 4'b1, 32'b01000010);
    wait (uart_snd.uart16550.regs.tstate==0 && uart_snd.uart16550.regs.transmitter.tf_count==0);
  end
  join
end

// receiver side
initial
begin
  #11;
  //write to lcr. set bit 7
  //wb_cyc_ir = 1;
  wbm1.wb_wr1(`UART_REG_LC, 4'b1000, {8'b10011011, 24'b0});
  // set dl to divide by 3
  wbm1.wb_wr1(`UART_REG_DL1, 4'b1, 32'd2);
  @(posedge clk);
  @(posedge clk);
  // restore normal registers
  wbm1.wb_wr1(`UART_REG_LC, 4'b1000, {8'b00011011, 24'b0});
  wbm1.wb_wr1(`UART_REG_IE, 4'b0010, {16'b0, 8'b00001111, 8'b0});
  wait(uart_rcv.uart16550.regs.receiver.rf_count == 2);
  wbm1.wb_rd1(0, 4'b1, dat_o);
  $display("%m : %t : Data out: %h", $time, dat_o);
  @(posedge clk);
  wbm1.wb_rd1(0, 4'b1, dat_o);
  $display("%m : %t : Data out: %h", $time, dat_o);
  $display("%m : Finish");
  $finish;
end

endmodule
