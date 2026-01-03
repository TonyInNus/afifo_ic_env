module asy_fifo_tb;
    parameter width = 8;
    parameter depth = 8;

    reg wr_clk, wr_en, wr_rstn;
    reg rd_clk, rd_en, rd_rstn;

    reg [width - 1 : 0] wr_data;

    wire fifo_full, fifo_empty;

    wire [width - 1 : 0] rd_data;

    //实例化
    // asy_fifo myfifo (
    //     .wr_clk(wr_clk),
    //     .rd_clk(rd_clk),
    //     .wr_rstn(wr_rstn),
    //     .rd_rstn(rd_rstn),
    //     .wr_en(wr_en),
    //     .rd_en(rd_en),
    //     .wr_data(wr_data),
    //     .rd_data(rd_data),
    //     .fifo_empty(fifo_empty),
    //     .fifo_full(fifo_full)
    // );

    AFIFO #(
        .DATA_WIDTH  (32),
        .AFIFO_DEEPTH(8)
    ) u_AFIFO (
        // CRG--------------------------------------------------------------------------------------
        .clk_wr  (wr_clk),
        .clk_rd  (rd_clk),
        .rst_wr_n(wr_rstn),
        .rst_rd_n(rd_rstn),
        // Fun1-------------------------------------------------------------------------------------
        .wr_en   (wr_en),
        .rd_en   (rd_en),
        .wdata   (wdata),
        .rdata   (rdata)
    );
    
    //时钟
    initial begin
        rd_clk = 0;
        forever #25 rd_clk = ~rd_clk;
    end

    initial begin
        wr_clk = 0;
        forever #30 wr_clk = ~wr_clk;
    end

    //波形显示
    initial begin
        $fsdbDumpfile("wave.fsdb");
        $fsdbDumpvars(0, myfifo);
        $fsdbDumpon();
    end

    //赋值
    initial begin
        wr_en   = 0;
        rd_en   = 0;
        wr_rstn = 1;
        rd_rstn = 1;

        #10;
        wr_rstn = 0;
        rd_rstn = 0;

        #20;
        wr_rstn = 1;
        rd_rstn = 1;

        @(negedge wr_clk) wr_data = {$random} % 30;
        wr_en = 1;

        repeat (7) begin
            @(negedge wr_clk) wr_data = {$random} % 30;
        end

        @(negedge wr_clk) wr_en = 0;

        @(negedge rd_clk) rd_en = 1;

        repeat (7) begin
            @(negedge rd_clk);
        end

        @(negedge rd_clk) rd_en = 0;

        #150;

        @(negedge wr_clk) wr_en = 1;
        wr_data = {$random} % 30;

        repeat (15) begin
            @(negedge wr_clk) wr_data = {$random} % 30;
        end

        @(negedge wr_clk) wr_en = 0;

        #50;
        $finish;
    end

endmodule
