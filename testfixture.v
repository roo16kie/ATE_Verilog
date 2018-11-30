`timescale 1ns/100ps

`define CYCLE 22  /*you can modify this value*/
`define LATENCY 1

`define tb1
`define PICIN "tb1.map"
`define BINOUT "tb1.bin"
`define THRESHOLDOUT "tb1.threshold"
`define BLOCKS 24


`define SDFFILE "ate.sdf"


module testfixture();

reg clk, reset;
reg [7:0] pix_data;
wire bin;
wire [7:0] threshold;
    

reg [7:0] picin [0:1535];
reg [63:0] binout [0:23];
reg [7:0] thresholdout [0:23];


reg [7:0] expect_threshold;
reg expect_bin;
real cycle = `CYCLE;
real helfCYCLE;
initial  helfCYCLE = cycle/2;     
integer inputblock,outputblock;
integer inputpixel,outputpixel;
integer startcompare;
integer i;
integer stcycle;
integer goterror;
reg [63:0] block_bin;
     
ate00  ate(.clk(clk), .reset(reset), .pix_data(pix_data), .bin(bin), .threshold(threshold));
            

initial 
begin
    `ifdef FSDB
        $fsdbDumpfile("ate.fsdb");
        $fsdbDumpvars;
    `endif
    /*
    $dumpvars;
    $dumpfile("ate.vcd");
    */

    `ifdef SDF
        $sdf_annotate(`SDFFILE,ate);
    `endif

    $readmemh (`PICIN,picin);
    $readmemb (`BINOUT,binout);
    $readmemh (`THRESHOLDOUT,thresholdout);
    
end

always #helfCYCLE clk = ~clk;

initial
begin
clk = 1'b1;
reset = 1'b0;
#helfCYCLE reset = 1'b1;
$write("\nblock              bin output");
#`CYCLE     reset =1'b0;

end

always @(posedge clk)
begin

// //  $fsdbDumpMem(ate.block_tmp, 0, 64);
//        $fsdbDumpMem(binout,0,24);

    if(reset) begin
        inputblock=0;
        inputpixel=-1;
        goterror=0;
        startcompare=0;
    end
    #helfCYCLE 
    inputpixel=inputpixel+1;
    if(startcompare==1) outputpixel=outputpixel+1;
    if(inputpixel==64) begin
        inputblock=inputblock+1;
        inputpixel=0;
    end
    i=inputblock*64+inputpixel;
    pix_data=picin[i];

    if(outputpixel==64) begin
        outputblock=outputblock+1;
        outputpixel=0;
        $write("\n%4d  ",outputblock);
    end

    stcycle=64+`LATENCY;
    if((inputblock*64+inputpixel) == stcycle) begin
        startcompare=1;
        outputblock=0;
        outputpixel=0;
        $write("\n%4d  ",outputblock);
    end

    /*compare*/
    if((startcompare==1) && (outputblock < `BLOCKS)) begin
        block_bin = binout[outputblock];
        expect_bin = block_bin[63-outputpixel];
        expect_threshold = thresholdout[outputblock];
        $write("%d",bin);
        if(threshold !== expect_threshold) begin
	        $write("\nthreshold error found at block%4d, pixel%4d : expect %h, got %h",outputblock,outputpixel,expect_threshold,threshold);
            	goterror=1;

        end
        if(bin !==expect_bin) begin
            $write("\nbin error found at block %2d , pixel %2d : expect bin: %h, got bin: %h",outputblock, outputpixel,expect_bin,bin);
            goterror=1;
        end
        if(goterror==1) begin
            $write ("\n\n");
            #20
            $finish;
        end
        
    end

    if(outputblock== `BLOCKS) begin
        $display("");
        $display("");
        $display("                           ,-.__.-,                           ");
        $display("                          (``-''-//).___..--'''`-._           ");
        $display("                           `6_ 6  )   `-.  (     ).`-.__.`)   ");
        $display("                           (_Y_.)'  ._   )  `._ `. ``-..-'    ");
        $display("                         _..`--'_..-_/  /--'_.' ,'            ");
        $display("                        (il),-''  (li),'  ((!.-'              ");
        $display("  Congratulations !");
        $display("  Simulation Complete!!");
        $display("");
        $finish;
    end
end
  

endmodule
                                                                                    
