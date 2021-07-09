//将RGB格式的像素数据转成YCbCr，消耗三个时钟周期

module RGB888_YCbCr444(
	input				clk,  				
	input				rst_n,				

	input		[7:0]	in_img_red,		
	input		[7:0]	in_img_green,		
	input		[7:0]	in_img_blue,		

	output	reg [7:0]	out_img_Y,			
	output	reg [7:0]	out_img_Cb,		
	output	reg [7:0]	out_img_Cr			
);

//--------------------------------------------
/*********************************************
	Y 	=	(77 *R 	+ 	150*G 	+ 	29 *B)>>8
	Cb 	=	(-43*R	- 	85 *G	+ 	128*B)>>8 + 128
	Cr 	=	(128*R 	-	107*G  	-	21 *B)>>8 + 128
--->
	Y 	=	(77 *R 	+ 	150*G 	+ 	29 *B)>>8
	Cb 	=	(-43*R	- 	85 *G	+ 	128*B + 32768)>>8
	Cr 	=	(128*R 	-	107*G  	-	21 *B + 32768)>>8
**********************************************/

//Step 1
reg	[15:0]	img_red_r0,		img_red_r1,		img_red_r2;	
reg	[15:0]	img_green_r0,	img_green_r1,	img_green_r2; 
reg	[15:0]	img_blue_r0,	img_blue_r1,	img_blue_r2; 

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n) begin
		img_red_r0		<=	0; 		
		img_red_r1		<=	0; 		
		img_red_r2		<=	0; 	
        
		img_green_r0	<=	0; 		
		img_green_r1	<=	0; 		
		img_green_r2	<=	0; 	
        
		img_blue_r0		<=	0; 		
		img_blue_r1		<=	0; 		
		img_blue_r2		<=	0; 			
    end
	else begin
		img_red_r0		<=	in_img_red 	    * 	8'd77; 		
		img_red_r1		<=	in_img_red 	    * 	8'd43; 	
		img_red_r2		<=	in_img_red 	    * 	8'd128; 
		
		img_green_r0	<=	in_img_green 	* 	8'd150; 		
		img_green_r1	<=	in_img_green 	* 	8'd85; 			
		img_green_r2	<=	in_img_green 	* 	8'd107; 
        
		img_blue_r0		<=	in_img_blue 	* 	8'd29; 		
		img_blue_r1		<=	in_img_blue 	* 	8'd128; 			
		img_blue_r2		<=	in_img_blue 	* 	8'd21; 		
    end
end

//--------------------------------------------------

//Step 2
reg	[15:0]	img_Y_r0;	
reg	[15:0]	img_Cb_r0; 
reg	[15:0]	img_Cr_r0; 

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n) begin
		img_Y_r0	<=	0; 		
		img_Cb_r0	<=	0; 		
		img_Cr_r0	<=	0; 	
    end
	else begin
		img_Y_r0	<=	img_red_r0 	+ 	img_green_r0 	+ 	img_blue_r0; 		
		img_Cb_r0	<=	img_blue_r1 - 	img_red_r1 		- 	img_green_r1	+	16'd32768; 		
		img_Cr_r0	<=	img_red_r2 	- 	img_green_r2 	- 	img_blue_r2		+	16'd32768; 		
    end
end

//--------------------------------------------------

//Step 3
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n) begin
		out_img_Y 	<=	0; 		
		out_img_Cb	<=	0; 		
		out_img_Cr	<=	0; 	
    end
	else begin
		out_img_Y 	<=	img_Y_r0[15:8];
		out_img_Cb	<=	img_Cb_r0[15:8];
		out_img_Cr	<=	img_Cr_r0[15:8]; 
    end
end


endmodule 