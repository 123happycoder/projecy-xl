`timescale 1ns/1ps

module axi_stream_insert_header #(
    parameter DATA_WD = 32,
    parameter DATA_BYTE_WD = DATA_WD / 8,
    parameter BYTE_CNT_WD = $clog2(DATA_BYTE_WD)
) (
    input clk,
    input rst_n,
    // AXI Stream input original data
    input valid_in,
    input [DATA_WD-1 : 0] data_in,
    input [DATA_BYTE_WD-1 : 0] keep_in,
    input last_in,
    output ready_in,
    // AXI Stream output with header inserted
    output valid_out,
    output [DATA_WD-1 : 0] data_out,
    output [DATA_BYTE_WD-1 : 0] keep_out,
    output last_out,
    input ready_out,
    // The header to be inserted to AXI Stream input
    input valid_insert,
    input [DATA_WD-1 : 0] data_insert,
    input [DATA_BYTE_WD-1 : 0] keep_insert,
    input [BYTE_CNT_WD : 0] byte_insert_cnt,
    output ready_insert
);

// 定义缓存寄存器
reg [DATA_WD-1:0] data_buffer;
reg [DATA_BYTE_WD-1:0] keep_buffer;
reg last_buffer;

// 控制信号
wire insert_ready;
wire data_ready;

//定义控制信号
assign insert_ready = ready_insert && valid_insert && last_in;
assign data_ready = ready_in && valid_in;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_buffer <= 0;
        keep_buffer <= 0;
        last_buffer <= 0;
    end else begin
        if (insert_ready) begin
            data_buffer <= data_insert & {{8{keep_insert[3]}},{8{keep_insert[2]}},{8{keep_insert[1]}},{8{keep_insert[0]}}};//{{(DATA_WD-8*byte_insert_cnt)*1'b0},data_insert[(8*byte_insert_cnt-1)+:0]};
            keep_buffer <= keep_in;
            last_buffer <= 0;
        end else if (data_ready) begin
            data_buffer <= data_in; 
            keep_buffer <= keep_in;
            last_buffer <= last_in;
        end
    end
end

// 输出控制信号
assign valid_out = insert_ready || data_ready;
assign data_out = data_buffer;
assign keep_out = keep_buffer;
assign last_out = last_buffer;

assign ready_in = ready_out && !valid_insert;
assign ready_insert = ready_out && !valid_in;

endmodule