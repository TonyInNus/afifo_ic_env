//--###############################################################################################
//--#   _   _   ___   ____    ___   _       ___    ____    ___    _   _ 
//--#  | | | | |_ _| / ___|  |_ _| | |     |_ _|  / ___|  / _ \  | \ | |
//--#  | |_| |  | |  \___ \   | |  | |      | |  | |     | | | | |  \| |
//--#  |  _  |  | |   ___) |  | |  | |___   | |  | |___  | |_| | | |\  |
//--#  |_| |_| |___| |____/  |___| |_____| |___|  \____|  \___/  |_| \_|
//--# 
//--# Copyright(c) 2024 , Hisilicon Technologies Co, Ltd. 
//--#             All Rights Reserved. 
//--# File Name		: afifo.v
//--# Author		: Duxinshuai 00899298
//--# Email			: duxinshuai@huawei.com
//--# Design Date	: 2026.01.02
//--# Version		: V1.0
//--# Coding scheme	: UTF-8
//--# Description	: Sequential Module
//--#
//--###############################################################################################

module AFIFO #(
    parameter DATA_WIDTH   = 32,
    parameter AFIFO_DEEPTH = 8
) (
    // CRG--------------------------------------------------------------------------------------
    input wire clk_wr,
    input wire clk_rd,
    input wire rst_wr_n,
    input wire rst_rd_n,

    // Fun1-------------------------------------------------------------------------------------
    input  wire                    wr_en,
    input  wire                    rd_en,
    input  wire [DATA_WIDTH-1 : 0] wdata,
    output reg  [DATA_WIDTH-1 : 0] rdata,
    output reg                     wr_full,
    output reg                     rd_empty
);
    localparam AFIFO_MORE = $clog2(AFIFO_DEEPTH);
    //------------------------------------------------------------------------------------------------
    //---------------------------------------Registers------------------------------------------------
    reg [DATA_WIDTH -1 : 0] afifo[AFIFO_DEEPTH -1 : 0];
    reg [AFIFO_MORE : 0] wr_ptr, rd_ptr;
    //------------------------------------------------------------------------------------------------
    //--------------------------------------Wire_Assign-----------------------------------------------
    wire [AFIFO_MORE-1:0] wr_addr = wr_ptr[AFIFO_MORE-1:0];
    wire [AFIFO_MORE-1:0] rd_addr = rd_ptr[AFIFO_MORE-1:0];
    //------------------------------------------------------------------------------------------------
    //---------------------------------------Interface------------------------------------------------

    //------------------------------------------------------------------------------------------------
    //---------------------------------------Comb_Block-----------------------------------------------

    //------------------------------------------------------------------------------------------------
    //------------------------------------Sequential_Block--------------------------------------------
    // ptr
    always @(posedge clk_wr or negedge rst_wr_n) begin
        if (~rst_wr_n) begin
            wr_ptr <= 'd0;
        end else if (wr_en && ~wr_full) begin
            afifo[wr_addr] <= wdata;
            wr_ptr         <= wr_ptr + 'd1;
        end
    end
    always @(posedge clk_rd or negedge rst_rd_n) begin
        if (~rst_rd_n) begin
            rd_ptr <= 'd0;
        end else if (rd_en && ~rd_empty) begin
            rdata  <= afifo[rd_addr];
            rd_ptr <= rd_ptr + 'd1;
        end
    end
    // bin2gray
    reg [AFIFO_MORE:0] wr_ptr_g;
    always @(posedge clk_wr or negedge rst_wr_n) begin
        if (~rst_wr_n) begin
            wr_ptr_g <= 'd0;
        end else begin
            wr_ptr_g <= wr_ptr ^ wr_ptr >> 1;
        end
    end
    wire [AFIFO_MORE:0] wr_ptr_nxt = wr_ptr + 'd1;
    wire [AFIFO_MORE:0] wr_ptr_nxt_g = wr_ptr_nxt ^ wr_ptr_nxt >> 1;

    reg  [AFIFO_MORE:0] rd_ptr_g;
    always @(posedge clk_rd or negedge rst_rd_n) begin
        if (~rst_rd_n) begin
            rd_ptr_g <= 'd0;
        end else begin
            rd_ptr_g <= rd_ptr ^ rd_ptr >> 1;
        end
    end
    wire [AFIFO_MORE:0] rd_ptr_nxt = rd_ptr + 'd1;
    wire [AFIFO_MORE:0] rd_ptr_nxt_g = rd_ptr_nxt ^ rd_ptr_nxt >> 1;

    // wr_ptr_sync
    reg  [AFIFO_MORE:0] wr_ptr_1d;
    reg  [AFIFO_MORE:0] wr_ptr_2d;
    always @(posedge clk_rd or negedge rst_rd_n) begin
        wr_ptr_1d <= wr_ptr_g;
        wr_ptr_2d <= wr_ptr_1d;
    end
    // rd_ptr_sync
    reg [AFIFO_MORE:0] rd_ptr_1d;
    reg [AFIFO_MORE:0] rd_ptr_2d;
    always @(posedge clk_wr) begin
        rd_ptr_1d <= rd_ptr_g;
        rd_ptr_2d <= rd_ptr_1d;
    end

    always @(posedge clk_wr or negedge rst_wr_n) begin
        if (~rst_wr_n) begin
            wr_full <= 'd0;
        end else begin
            // assign wfull_val = (wgray_next=={~wq2_rptr[ADDR_SIZE:ADDR_SIZE-1], wq2_rptr[ADDR_SIZE-2:0]});
            // nxt wr ptr == rd ptr and high bit ^ =1
            wr_full <=  (wr_ptr_nxt_g[AFIFO_MORE]^rd_ptr_2d[AFIFO_MORE]) && 
                        (wr_ptr_nxt_g[AFIFO_MORE-1]^rd_ptr_2d[AFIFO_MORE-1]) &&
                        (wr_ptr_nxt_g[AFIFO_MORE-2:0] == rd_ptr_2d[AFIFO_MORE-2:0]);
        end
    end

    always @(posedge clk_rd or negedge rst_rd_n) begin
        if (~rst_rd_n) begin
            rd_empty <= 'd0;
        end else begin
            rd_empty <= wr_ptr_2d[AFIFO_MORE:0] == rd_ptr_nxt_g[AFIFO_MORE:0];
        end
    end
    //------------------------------------------------------------------------------------------------
    //-------------------------------------------SVA--------------------------------------------------
`ifdef SVA
    default clocking @(posedge clk);
    endclocking

`endif

endmodule
