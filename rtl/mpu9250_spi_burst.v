// MPU9250 SPI Burst Reader with FIFO buffer

module mpu9250_spi_burst #(
    parameter N_BYTES = 6  // Number of registers to read
)(
    input  wire       clk,
    input  wire       rstn,
    input  wire       start,
    input  wire [7:0] start_addr,
    output reg        busy,
    output reg        done,
    // SPI interface
    output wire       sclk,
    output wire       mosi,
    input  wire       miso,
    output wire       cs_n,
    // FIFO interface
    output reg        fifo_wr_en,
    output reg [7:0]  fifo_wr_data
);

    reg        spi_start;
    reg [7:0]  spi_tx;
    wire [7:0] spi_rx;
    wire       spi_busy, spi_done;

    reg [3:0]  byte_index;
    reg [2:0]  state;

    localparam S_IDLE      = 3'd0;
    localparam S_SEND_ADDR = 3'd1;
    localparam S_SEND_DMY  = 3'd2;
    localparam S_WAIT      = 3'd3;
    localparam S_DONE      = 3'd4;

    spi_master #(.CLK_DIV(8)) spi_i (
        .clk(clk),
        .rstn(rstn),
        .start(spi_start),
        .tx_byte(spi_tx),
        .rx_byte(spi_rx),
        .busy(spi_busy),
        .done(spi_done),
        .sclk(sclk),
        .mosi(mosi),
        .miso(miso),
        .cs_n(cs_n)
    );

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state        <= S_IDLE;
            spi_start    <= 0;
            fifo_wr_en   <= 0;
            fifo_wr_data <= 0;
            busy         <= 0;
            done         <= 0;
            byte_index   <= 0;
        end else begin
            fifo_wr_en <= 0;
            done       <= 0;
            case (state)
                S_IDLE: begin
                    if (start) begin
                        busy      <= 1;
                        byte_index <= 0;
                        spi_tx    <= start_addr | 8'h80;  // Read command
                        spi_start <= 1;
                        state     <= S_SEND_ADDR;
                    end
                end
                S_SEND_ADDR: begin
                    spi_start <= 0;
                    if (spi_done) begin
                        spi_tx    <= 8'd0;  // Dummy for read
                        spi_start <= 1;
                        state     <= S_SEND_DMY;
                    end
                end
                S_SEND_DMY: begin
                    spi_start <= 0;
                    if (spi_done) begin
                        fifo_wr_data <= spi_rx;
                        fifo_wr_en   <= 1;
                        byte_index   <= byte_index + 1;
                        if (byte_index == N_BYTES-1)
                            state <= S_DONE;
                        else begin
                            spi_tx    <= 8'd0;
                            spi_start <= 1;
                            state     <= S_WAIT;
                        end
                    end
                end
                S_WAIT: begin
                    spi_start <= 0;
                    if (spi_done) begin
                        fifo_wr_data <= spi_rx;
                        fifo_wr_en   <= 1;
                        byte_index   <= byte_index + 1;
                        if (byte_index == N_BYTES-1)
                            state <= S_DONE;
                        else begin
                            spi_tx    <= 8'd0;
                            spi_start <= 1;
                            state     <= S_WAIT;
                        end
                    end
                end
                S_DONE: begin
                    busy <= 0;
                    done <= 1;
                    state <= S_IDLE;
                end
            endcase
        end
    end
endmodule
