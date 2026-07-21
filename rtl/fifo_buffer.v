// FIFO Buffer for storing received bytes

module fifo_buffer (
    input  wire       clk,
    input  wire       rstn,
    input  wire       wr_en,
    input  wire [7:0] wr_data,
    input  wire       rd_en,
    output wire [7:0] rd_data,
    output wire       empty,
    output wire       full
);
    reg [7:0] mem [0:63];
    reg [5:0] wr_ptr = 0;
    reg [5:0] rd_ptr = 0;

    assign rd_data = mem[rd_ptr];
    assign empty   = (wr_ptr == rd_ptr);
    assign full    = ((wr_ptr + 1) == rd_ptr);

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
        end else begin
            if (wr_en && !full) begin
                mem[wr_ptr] <= wr_data;
                wr_ptr <= wr_ptr + 1;
            end
            if (rd_en && !empty) begin
                rd_ptr <= rd_ptr + 1;
            end
        end
    end
endmodule
