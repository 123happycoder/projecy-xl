`timescale 1ns/1ps

module tb_axi_stream_insert_header #(
    parameter DATA_WD = 32,
    parameter DATA_BYTE_WD = DATA_WD / 8,
    parameter BYTE_CNT_WD = $clog2(DATA_BYTE_WD)
);
    reg clk;
    reg rst_n;

    // AXI Stream input original data
    reg valid_in;
    reg [31:0] data_in;
    reg [3:0] keep_in;
    reg last_in;
    wire ready_in;

    // AXI Stream output with header inserted
    wire valid_out;
    wire [31:0] data_out;
    wire [3:0] keep_out;
    wire last_out;
    reg ready_out;

    // The header to be inserted to AXI Stream input
    reg valid_insert;
    reg [31:0] data_insert;
    reg [3:0] keep_insert;
    reg [BYTE_CNT_WD:0] byte_insert_cnt;
    wire ready_insert;
	
    reg [1:0] cnt1;
    reg [1:0] cnt2;
    reg [3:0] t_keep_in1;
    reg [3:0] t_keep_in2;

    // 例化
    axi_stream_insert_header DUT (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(valid_in),
        .data_in(data_in),
        .keep_in(keep_in),
        .last_in(last_in),
        .ready_in(ready_in),
        .valid_out(valid_out),
        .data_out(data_out),
        .keep_out(keep_out),
        .last_out(last_out),
        .ready_out(ready_out),
        .valid_insert(valid_insert),
        .data_insert(data_insert),
        .keep_insert(keep_insert),
        .byte_insert_cnt(byte_insert_cnt),
        .ready_insert(ready_insert)
    );

    // 时钟设置
    always begin
        #5 clk = ~clk;
    end

    initial begin
        // 初始化信号
        clk = 0;
        rst_n = 0;
        valid_in = 0;
        data_in = 0;
        keep_in = 4'b1111;
        last_in = 0;
        ready_out = 0;
        valid_insert = 0;
        data_insert = 0;
        keep_insert = 4'b1111;
        byte_insert_cnt = 2'b00;
        cnt1=2'b00;
        cnt2=2'b00;
        t_keep_in1=4'b0000;
        t_keep_in2=4'b0000;

        // 复位信号拉高
        #10 rst_n = 1;
        
		
        // 控制信号随机赋值，并随机重复1000遍，尽可能覆盖
        repeat (1000) begin
           cnt1 = {$random}%3;
           cnt2 = {$random}%4;
           case(cnt1)
                2'b00:t_keep_in1 = 4'b1110;
                2'b01:t_keep_in1 = 4'b1100;
                2'b10:t_keep_in1 = 4'b1000;
           endcase
           case(cnt2)
                2'b00:t_keep_in2 = 4'b0001;
                2'b01:t_keep_in2 = 4'b0011;
                2'b10:t_keep_in2 = 4'b0111;
                2'b11:t_keep_in2 = 4'b1111;
           endcase
           valid_in = $random;
           data_in = $random;
           last_in = $random;
           keep_in = (last_in) ? (t_keep_in1) : 4'b1111;
           ready_out = $random;
           valid_insert = $random;
           data_insert = $random;
           keep_insert = t_keep_in2;
           byte_insert_cnt = cnt2+1;

            #10;
        end

        // 结束仿真
        $finish;
    end
endmodule