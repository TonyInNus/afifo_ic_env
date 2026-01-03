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
    output wire [DATA_WIDTH-1 : 0] rdata
);
    //------------------------------------------------------------------------------------------------
    //---------------------------------------Registers------------------------------------------------
    reg [$clog2(AFIFO_DEEPTH) : 0] wr_ptr, rd_ptr;
    reg [DATA_WIDTH -1 : 0] afifo[AFIFO_DEEPTH -1 : 0];
    reg wr_full, rd_empty;
    //------------------------------------------------------------------------------------------------
    //--------------------------------------Wire_Assign-----------------------------------------------

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
            afifo[wr_ptr] <= wdata;
            wr_ptr        <= wr_ptr + 'd1;
        end
    end
    always @(posedge clk_rd or negedge rst_rd_n) begin
        if (~rst_rd_n) begin
            rd_ptr <= 'd0;
        end else if (rd_en && ~rd_empty) begin
            rdata  <= afifo[rd_ptr];
            rd_ptr <= rd_ptr + 'd1;
        end
    end
    // bin2gray
    reg [$clog2(AFIFO_DEEPTH):0] wr_ptr_g;
    always @(posedge clk_wr or negedge rst_wr_n) begin
        if (~rst_wr_n) begin
            wr_ptr_g <= 'd0;
        end else begin
            wr_ptr_g <= wr_ptr ^ wr_ptr >> 1;
        end
    end
    reg [$clog2(AFIFO_DEEPTH):0] rd_ptr_g;
    always @(posedge clk_rd or negedge rst_rd_n) begin
        if (~rst_rd_n) begin
            rd_ptr_g <= 'd0;
        end else begin
            rd_ptr_g <= rd_ptr ^ rdptr >> 1;
        end
    end

    // wr_ptr_sync
    reg [$clog2(AFIFO_DEEPTH):0] wr_ptr_1d;
    reg [$clog2(AFIFO_DEEPTH):0] wr_ptr_2d;
    always @(posedge clk_wr or negedge rst_wr_n) begin
        if (~rst_wr_n) begin
            wr_ptr_1d <= 'd0;
            wr_ptr_2d <= 'd0;
        end else begin
            wr_ptr_1d <= wr_ptr_g;
            wr_ptr_2d <= wr_ptr_1d;
        end
    end
    // rd_ptr_sync
    reg [$clog2(AFIFO_DEEPTH):0] rd_ptr_1d;
    reg [$clog2(AFIFO_DEEPTH):0] rd_ptr_2d;
    always @(posedge clk_rd or negedge rst_rd_n) begin
        if (~rst_rd_n) begin
            rd_ptr_1d <= 'd0;
            rd_ptr_2d <= 'd0;
        end else begin
            rd_ptr_1d <= rd_ptr_g;
            rd_ptr_2d <= rd_ptr_1d;
        end
    end

    always @(posedge clk_wr or negedge rst_wr_n) begin
        if (~rst_wr_n) begin
            wr_full <= 'd0;
        end else begin
            wr_full <= (wr_ptr_g[AFIFO_DEEPTH]^rd_ptr_g[AFIFO_DEEPTH]) && (wr_ptr_g[AFIFO_DEEPTH-1:0] == rd_ptr_g[AFIFO_DEEPTH-1:0]);
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            rd_empty <= 'd0;
        end else begin
            rd_empty <= wr_ptr_g[AFIFO_DEEPTH:0] == rd_ptr_g[AFIFO_DEEPTH:0];
        end
    end
    //------------------------------------------------------------------------------------------------
    //-------------------------------------------SVA--------------------------------------------------
`ifdef SVA
    default clocking @(posedge clk);
    endclocking

`endif

endmodule
