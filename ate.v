module ate(clk,reset,pix_data,bin,threshold);

////////////////
//input&output//
////////////////

input 		 clk;
input 	     reset;
input [7:0]  pix_data;
output 		 bin;
output [7:0] threshold;


//////////////////
//def somethings//
//////////////////
reg [7:0] threshold;
reg       bin;


reg [7:0] in_buffer  [63:0];
reg [63:0] out_buffer ;


reg [5:0] counter;
reg [4:0] block_count;
integer   i;


reg  [7:0] std_min;
reg  [7:0] std_max;
wire [8:0] std_total ;
wire [7:0] reg_threshold;
//////////
//DESIGN//
//////////



always@(posedge clk or posedge reset)
begin
	if(reset)
		counter <= 6'd0 ;
	else
		counter <= counter + 6'd1 ;
end

always@(posedge clk or posedge reset)
begin
	if(reset)
		block_count <= 5'd0 ;
	else if (counter == 6'd63)
		block_count <= block_count + 5'd1 ;
	else
		block_count <= block_count ;
end

always@(posedge clk or posedge reset)
begin
	if(reset)
		threshold <= 8'd0 ;
	else if(block_count==5'd1||block_count==5'd7||block_count==5'd13||block_count==5'd19)
		threshold <= 8'd0 ;
	else if(block_count==5'd6||block_count==5'd12||block_count==5'd18||block_count==5'd24)
		threshold <= 8'd0 ;
	else if(counter == 6'd0)
		threshold <= reg_threshold ; 
	else
		threshold <= threshold ;
	
end

always@(posedge clk or posedge reset)
begin
	if(reset)
		bin <= 1'd0 ;
	else if(block_count==5'd1||block_count==5'd7||block_count==5'd13||block_count==5'd19)
		bin <= 1'd0 ;
	else if(block_count==5'd6||block_count==5'd12||block_count==5'd18||block_count==5'd24)
		bin <= 1'd0 ;
	else  
		bin <= out_buffer[counter] ;
end 

always@(posedge clk)
begin
	in_buffer[counter] <= pix_data ;
end


always@(posedge clk)
begin
	if(counter == 6'd0)
		std_max <= pix_data ;
	else if (std_max < pix_data) 
		std_max <= pix_data ;
	else
		std_max <= std_max ;
end

always@(posedge clk)
begin
	if(counter == 6'd0)
		std_min <= pix_data ;
	else if (std_min > pix_data) 
		std_min <= pix_data ;
	else
		std_min <= std_min ;
end


assign std_total = (std_max + std_min) ; 
assign reg_threshold = (std_total[0] == 1'd1) ? (std_total + 9'd1 ) >> 1 : std_total >> 1 ;


always@(negedge clk)
begin
	if(counter==6'd0)    
	for(i=0 ; i<64 ; i=i+1)
	begin
			if(in_buffer[i]>=reg_threshold)
				out_buffer[i] <= 1'd1 ;
			else
				out_buffer[i] <= 1'd0 ;
	end
	else
	for(i=0 ; i<64 ; i=i+1)
	begin
		out_buffer[i] <= out_buffer[i] ;
	end

end



endmodule