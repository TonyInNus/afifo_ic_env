module tb_AFIFO;

    // Parameter
    parameter DATA_WIDTH = 32;
    parameter AFIFO_DEPTH = 8;

    // Signals
    reg clk_wr;
    reg clk_rd;
    reg rst_wr_n;
    reg rst_rd_n;
    reg wr_en;
    reg rd_en;
    reg [DATA_WIDTH-1:0] wdata;
    wire [DATA_WIDTH-1:0] rdata;
    
    // Instantiate the AFIFO module
    AFIFO #(
        .DATA_WIDTH(DATA_WIDTH),
        .AFIFO_DEEPTH(AFIFO_DEPTH)
    ) uut (
        .clk_wr(clk_wr),
        .clk_rd(clk_rd),
        .rst_wr_n(rst_wr_n),
        .rst_rd_n(rst_rd_n),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .wdata(wdata),
        .rdata(rdata)
    );
    
    // Clock generation
    always begin
        #5 clk_wr = ~clk_wr;  // Write clock with 10ns period
    end

    always begin
        #7 clk_rd = ~clk_rd;  // Read clock with 14ns period
    end

    // Initial block to set signals and run tests
    initial begin
        // Initialize signals
        clk_wr = 0;
        clk_rd = 0;
        rst_wr_n = 0;
        rst_rd_n = 0;
        wr_en = 0;
        rd_en = 0;
        wdata = 0;

        // Apply reset
        #10 rst_wr_n = 1;
        rst_rd_n = 1;
        
        // Test Case 1: Write and read 1 word
        #10;
        wr_en = 1;
        wdata = 32'hA5A5A5A5; // Write data
        #10;
        wr_en = 0;
        
        rd_en = 1; // Start reading
        #14;
        rd_en = 0;

        // Check if data read is correct
        if (rdata != 32'hA5A5A5A5) begin
            $error("Test failed: Read data mismatch! Expected: 32'hA5A5A5A5, Got: %h", rdata);
        end

        // Test Case 2: FIFO full condition
        #20;
        wr_en = 1;
        for (int i = 0; i < AFIFO_DEPTH; i = i + 1) begin
            wdata = i;
            #10;
        end
        wr_en = 0;

        // Ensure FIFO is full
        if (uut.wr_full != 1) begin
            $error("Test failed: FIFO should be full! Current wr_full: %b", uut.wr_full);
        end

        // Test Case 3: FIFO empty condition
        #20;
        rd_en = 1;
        for (int i = 0; i < AFIFO_DEPTH; i = i + 1) begin
            #14; // Read with a delay
        end
        rd_en = 0;
        
        // Ensure FIFO is empty
        if (uut.rd_empty != 1) begin
            $error("Test failed: FIFO should be empty! Current rd_empty: %b", uut.rd_empty);
        end

        // Test Case 4: Write and read more data after empty
        #20;
        wr_en = 1;
        wdata = 32'h12345678;
        #10;
        wr_en = 0;
        
        rd_en = 1;
        #14;
        rd_en = 0;
        
        // Check if data read is correct
        if (rdata != 32'h12345678) begin
            $error("Test failed: Read data mismatch after FIFO was empty! Expected: 32'h12345678, Got: %h", rdata);
        end

        $display("All tests completed!");
        $finish;
    end

    // FSDB waveform display
    initial begin
        $fsdbDumpfile("wave.fsdb");       // Set output FSDB file
        $fsdbDumpvars(0, uut);            // Dump all signals of the AFIFO module
        $fsdbDumpon();                    // Enable FSDB dumping
    end

endmodule
