//----EP2----OUT----00----READ-----EMPTY
//----EP4----OUT----01----
//----EP6----IN-----10----WRITE----FULL
//----EP8----IN-----11----

//----FLAGA----EP6 EMPTY
//----FLAGB----EP6 FULL
//----FLAGC----EP2 EMPTY
//----FLAGD----EP2 FULL

`timescale 1ns/10ps

module Cy_Driver (
    input  clk,
    input  rstn,
    //external fifo for data out, txf = tx_fifo
    input  txf_empty_in, //active high
    output txf_rden_out,
    input  [15:0] txf_dout_in,
    output rx_sync_out, //write rx_din_out to external module
    output [15:0] rx_data_out, //write
    //slave fifo interface
    input  flaga, //flagabcd active low
    input  flagb_full, //default full,  fixed to IN  endpoint, 1 -> not full,  0 -> full
    input  flagc_empty, //default empty, fixed to OUT endpoint, 1 -> not empty, 0 -> empty
    input  flagd,
    output ifclk, //external clk
    output sloe,
    output slrd,
    output slwr,
    output pktend,
    output [1:0] faddr,
    inout  [15:0] fdata,
    output wakeup,
    output wakeup2
);

reg fdata_in_sync_r;
//reg sloe_r;
//reg slrd_r;
//reg slwr_r;
//reg pktend_r;
reg [15:0] fdata_in_r;

localparam ST_IDLE      = 4'h0;
localparam ST_R1        = 4'h1;
localparam ST_R2        = 4'h2;
localparam ST_W1        = 4'h3;
localparam ST_W2        = 4'h4;
localparam ST_PKTEND    = 4'h5;

reg [3:0] state, next_state;

//generate ifclk, half freq of clk
//clk=50m, ifclk=25m
reg ifclk_r;
always @(posedge clk or negedge rstn) begin
    if (rstn == 1'b0) ifclk_r <= 1'b1;
    else ifclk_r <= ~ifclk_r;
end
assign ifclk = ifclk_r;

always @(posedge clk or negedge rstn) begin
    if (rstn == 1'b0) state <= ST_IDLE;
    else if (ifclk_r == 1'b1) state <= next_state;
end

always @(*) begin
    if (rstn == 1'b0) begin
        next_state <= ST_IDLE;
    end else begin
        next_state <= state;
        case (state)
            ST_IDLE: begin
                if (flagc_empty == 1'b1) //reading has higher priority
                    next_state <= ST_R1; //when EP2 is not empty, start to read
                else if (flagb_full == 1'b1 && txf_empty_in == 1'b0)
                    next_state <= ST_W1; //when EP6 is not full and data is ready for tx (not empty), start to write
                else
                    next_state <= ST_IDLE;
            end
            ST_R1: begin
                if (flagc_empty == 1'b1)
                    next_state <= ST_R1;
                else
                    next_state <= ST_IDLE;
            end
            ST_W1: begin
                next_state <= ST_W2;
            end
            ST_W2: begin
                if (flagb_full == 1'b0)
                    next_state <= ST_IDLE; //if EP6 full, go to IDLE
                else if (txf_empty_in == 1'b1)
                    next_state <= ST_PKTEND; //if EP6 is not full but external FIFO is empty, go to PKTEND
                else
                    next_state <= ST_W2; //if EP6 is not full and external FIFO is not empty, continue to write
            end
            ST_PKTEND: begin
                next_state <= ST_IDLE;
            end
            default:
                next_state <= ST_IDLE;
        endcase
    end
end

assign sloe = (state == ST_R1) ? 1'b0 : 1'b1;
//assign sloe = (state == ST_R1 || state == ST_R2) ? 1'b0 : 1'b1;
assign slrd = (state == ST_R1) ? 1'b0 : 1'b1;
assign slwr = (state == ST_W2) ? 1'b0 : 1'b1;
assign pktend = (state == ST_PKTEND) ? 1'b0 : 1'b1;
assign faddr = (state == ST_IDLE || state == ST_R1) ? 2'b00 : 2'b10;

assign txf_rden_out = (state == ST_W1 || state == ST_W2) && (flagb_full) && (!txf_empty_in) && ifclk_r;

//fdata_in_sync_r & fdata_in_r for fpga to read
always @ (posedge clk or negedge rstn) begin
    if (rstn == 1'b0) begin
        fdata_in_sync_r <= 1'b0;
        fdata_in_r <= 16'hFFFF;
    end else begin
        if (slrd == 1'b0 && ifclk_r == 1'b0) begin
            fdata_in_sync_r <= 1'b1;
            fdata_in_r <= fdata;
        end else begin
            fdata_in_sync_r <= 1'b0;
        end
    end
end
assign rx_sync_out = fdata_in_sync_r;
assign rx_data_out = fdata_in_r;

//assign sloe = sloe_r;
//assign slrd = slrd_r;
//assign slwr = slwr_r;
//assign pktend = pktend_r;
//assign faddr = faddr_r;
assign wakeup = 1'b0;
assign wakeup2 = 1'b0;

//if sloe = 1'b0, fdata (FPGA pins) samples data from FX2LP
//if sloe = 1'b1, fdata (FPGA pins) transmits data to FX2LP
assign fdata = (sloe == 1'b0) ? 16'hz : txf_dout_in;

endmodule
