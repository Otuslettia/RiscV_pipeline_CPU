`include "../rtl/Top.v"
`include "../rtl/SRAM.v"

`define PROG_PATH "../testprog/multi.hex"
`define memptint_base_addr 0
`define memptint_counts 7

module tb_Top;
reg clk;
reg rst;
/*for im*/
wire [31:0] inst;
wire [15:0] im_addr;
wire [3:0] im_w_en;
/*for dm*/
wire [31:0] dm_read_data;
wire [31:0] dm_write_data;
wire [15:0] dm_addr;
wire [3:0] dm_w_en;
/*for ecall*/
wire halt;
wire print_flag;

Top top(
    .rst (rst),
    .clk (clk),

    .inst (inst),
    .im_addr (im_addr),
    .im_w_en (im_w_en),

    .dm_read_data (dm_read_data),
    .dm_write_data (dm_write_data),
    .dm_addr (dm_addr),
    .dm_w_en (dm_w_en),

    .halt (halt),
	.print_flag (print_flag)
);

SRAM dm(
    .clk (clk),
    .w_en (dm_w_en),
    .address (dm_addr),
    .write_data (dm_write_data),
    .read_data (dm_read_data)
);

SRAM im(
    .clk (clk),
    .w_en (im_w_en),
    .address (im_addr),
    .write_data (32'b0),
    .read_data (inst)
);

localparam CLK_PERIOD = 30;
always #(CLK_PERIOD/2) clk=~clk;

initial begin
    $readmemh(`PROG_PATH, im.mem);
    $readmemh(`PROG_PATH, dm.mem);
end

// always@(print_flag) begin
// 	$display("%c", top.regfile.regFile[11]);
// end
integer i;
initial begin
    clk = 1;rst = 0;
    #5 rst=1;
    // #(1000*CLK_PERIOD)
    // for (i=0; i<`memptint_counts; i=i+1 ) begin
    //     $display("mem[%d] : %d", (`memptint_base_addr+i*4), ({top.dm.mem[`memptint_base_addr+3+i*4], top.dm.mem[`memptint_base_addr+2+i*4], top.dm.mem[`memptint_base_addr+1+i*4], top.dm.mem[`memptint_base_addr+i*4]}));
    // end
	//$finish;
    //#(200*CLK_PERIOD);
    //$finish;
    wait (halt)
        for (i=0; i<`memptint_counts; i=i+1 ) begin
            $display("mem[%d] : %d", (`memptint_base_addr+i*8), $signed({dm.mem[`memptint_base_addr+7+i*8], dm.mem[`memptint_base_addr+6+i*8], dm.mem[`memptint_base_addr+5+i*8], dm.mem[`memptint_base_addr+4+i*8],
                                                                  dm.mem[`memptint_base_addr+3+i*8], dm.mem[`memptint_base_addr+2+i*8], dm.mem[`memptint_base_addr+1+i*8], dm.mem[`memptint_base_addr+i*8]}));
        end
    $finish;
end

initial begin
    $dumpfile("tn_multi.vcd");
    $dumpvars;
	//$fsdbDumpMDA(2, top);
end

endmodule
