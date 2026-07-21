// SPDX-License-Identifier: MIT
// Module: SPI Master

module spi_master #(
    parameter CLK_DIV = 4
)(
    input  wire       clk,
    input  wire       rstn,
    input  wire       start,
    input  wire [7:0] tx_byte,
    output reg  [7:0] rx_byte,
    output reg        busy,
    output reg        done,
    output reg        sclk,
    output reg        mosi,
    input  wire       miso,
    output reg        cs_n
);

    localparam IDLE  = 2'd0;
    localparam TRANS = 2'd1;
    localparam DONE  = 2'd2;

    reg [1:0]  state;
    reg [2:0]  bit_cnt;
    reg [15:0] clk_cnt;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state   <= IDLE;
            busy    <= 1'b0;
            done    <= 1'b0;
            sclk    <= 1'b0;
            mosi    <= 1'b0;
            cs_n    <= 1'b1;
            bit_cnt <= 3'd7;
            rx_byte <= 8'd0;
            clk_cnt <= 16'd0;
        end else begin
            done <= 1'b0;
            case (state)
                IDLE: begin
                    sclk <= 1'b0;
                    if (start) begin
                        cs_n    <= 1'b0;
                        busy    <= 1'b1;
                        bit_cnt <= 3'd7;
                        rx_byte <= 8'd0;
                        state   <= TRANS;
                    end
                end
                TRANS: begin
                    if (clk_cnt == (CLK_DIV-1)) begin
                        clk_cnt <= 16'd0;
                        sclk    <= ~sclk;
                        if (sclk) begin
                            rx_byte[bit_cnt] <= miso;
                            mosi <= tx_byte[bit_cnt];
                            if (bit_cnt == 0)
                                state <= DONE;
                            else
                                bit_cnt <= bit_cnt - 1;
                        end
                    end else begin
                        clk_cnt <= clk_cnt + 1;
                    end
                end
                DONE: begin
                    cs_n <= 1'b1;
                    busy <= 1'b0;
                    done <= 1'b1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
