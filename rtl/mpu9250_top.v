module mpu9250_top (
    input  wire clk,
    input  wire rstn,
    input  wire start_burst,   // Trigger to start burst read
    // SPI interface
    input  wire miso,
    output wire mosi,
    output wire sclk,
    output wire cs_n,
    // FIFO read interface
    input  wire fifo_rd_en,
    output wire [7:0] fifo_data_out,
    output wire fifo_empty
);

    // Internal signals
    wire        fifo_wr_en;
    wire [7:0]  fifo_wr_data;

    // SPI burst read and FIFO writer
    mpu9250_spi_burst #(
        .N_BYTES(6)  // Number of bytes to read (e.g., 6 for accelerometer)
    ) burst_reader (
        .clk(clk),
        .rstn(rstn),
        .start(start_burst),
        .start_addr(8'h3B),  // ACCEL_XOUT_H
        .busy(),
        .done(),
        .sclk(sclk),
        .mosi(mosi),
        .miso(miso),
        .cs_n(cs_n),
        .fifo_wr_en(fifo_wr_en),
        .fifo_wr_data(fifo_wr_data)
    );

    // FIFO buffer
    fifo_buffer fifo_inst (
        .clk(clk),
        .rstn(rstn),
        .wr_en(fifo_wr_en),
        .wr_data(fifo_wr_data),
        .rd_en(fifo_rd_en),
        .rd_data(fifo_data_out),
        .empty(fifo_empty),
        .full()
    );

endmodule
