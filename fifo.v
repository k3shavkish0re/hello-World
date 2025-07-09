module fifo_8to32 (
    input  wire        clk,
    input  wire        rst_n,

    // Write interface
    input  wire        wr_en,
    input  wire [7:0]  wr_data,
    output wire        full,

    // Read interface
    input  wire        rd_en,
    output reg  [31:0] rd_data,
    output wire        empty
);

    // Internal memory: 8 entries of 8-bit (total 64 bits)
    reg [7:0] mem [0:7];

    // Pointers and counters
    reg [2:0] wr_ptr;      // 3-bit pointer: 0 to 7
    reg [2:0] rd_ptr;      // pointer to the read 32-bit word
    reg [3:0] byte_count;  // tracks total number of valid bytes (0 to 8)

    // Write logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 3'd0;
            byte_count <= 4'd0;
        end else if (wr_en && !full) begin
            mem[wr_ptr] <= wr_data;
            wr_ptr <= wr_ptr + 3'd1;
            byte_count <= byte_count + 4'd1;
        end
    end

    // Read logic (reads 4 bytes = 32 bits)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr  <= 3'd0;
            rd_data <= 32'd0;
        end else if (rd_en && !empty) begin
            rd_data <= {mem[rd_ptr+3], mem[rd_ptr+2], mem[rd_ptr+1], mem[rd_ptr]};
            rd_ptr  <= rd_ptr + 3'd4;
            byte_count <= byte_count - 4'd4;
        end
    end

    // Full when 8 bytes written and not yet read
    assign full  = (byte_count == 4'd8);

    // Empty when fewer than 4 bytes available to read
    assign empty = (byte_count < 4'd4);

endmodule
