module rgb2lcd #(
    //parameter define
    parameter    VID_IN_DATA_WIDTH = 24,
    parameter    REDDEPTH   = 5,
    parameter    GREENDEPTH = 6,
    parameter    BULEDEPTH  = 5,
    parameter    VID_OUT_DATA_WIDTH = REDDEPTH + GREENDEPTH + BULEDEPTH
)(
    //VID_OUT
    input [VID_IN_DATA_WIDTH-1:0]     rgb_data ,
    input                             rgb_vde  ,
    input                             rgb_hsync,
    input                             rgb_vsync,

    input                             pixel_clk,
    input                             vid_rst  ,
    
    //RGB LCD
    output                            lcd_pclk ,
    output                            lcd_rst  ,
    output    reg                     lcd_hs   ,
    output    reg                     lcd_vs   ,
    output    reg                     lcd_de   ,
    output                            lcd_bl   ,
    
    //LCD ID
    output    reg  [2:0]              lcd_id   ,  
    
    //LCD数据引脚为双向引脚,改成三态引脚的形式  
    input  [VID_OUT_DATA_WIDTH-1:0]   lcd_rgb_i,
    output [VID_OUT_DATA_WIDTH-1:0]   lcd_rgb_o,
    output [VID_OUT_DATA_WIDTH-1:0]   lcd_rgb_t
);

//reg define
reg    [VID_IN_DATA_WIDTH-1:0]   int_pData ;
reg                              rd_id_flag=1'b0;

//wire define
wire   [REDDEPTH-1:0]            lcd_red   ;
wire   [GREENDEPTH-1:0]          lcd_green ;
wire   [BULEDEPTH-1:0]           lcd_blue  ;

//*****************************************************
//**                  main code
//*****************************************************

//LCD 数据赋值
always @(posedge pixel_clk or negedge vid_rst) begin
    if(!vid_rst)
        int_pData <= 0;
    else if (rgb_vde == 1'b1)
       int_pData <= rgb_data;                        
    else
       int_pData <= {VID_IN_DATA_WIDTH{1'b0}};
end

//LCD控制信号赋值
always @(posedge pixel_clk or negedge vid_rst) begin
    if(!vid_rst) begin
        lcd_de <= 1'b0  ;
        lcd_hs <= 1'b0;
        lcd_vs <= 1'b0;    
    end
    else begin                                       
        lcd_de <= rgb_vde  ;
        lcd_hs <= rgb_hsync;
        lcd_vs <= rgb_vsync;
    end
end

//读取LCD屏ID
always @(posedge pixel_clk or negedge vid_rst) begin
    if(!vid_rst) begin
        lcd_id <= 3'd0;
        rd_id_flag <= 1'b0;
    end
    else if(!rd_id_flag) begin
        lcd_id <= {lcd_rgb_i[BULEDEPTH - 1],lcd_rgb_i[GREENDEPTH + BULEDEPTH - 1],
            lcd_rgb_i[REDDEPTH + GREENDEPTH +BULEDEPTH - 1]};
        rd_id_flag <= 1'b1;    
    end
end

assign lcd_pclk = pixel_clk;
assign lcd_rst  = vid_rst;
assign lcd_bl   = 1'b1;
assign lcd_red = int_pData[VID_IN_DATA_WIDTH - 1:VID_IN_DATA_WIDTH - REDDEPTH];
assign lcd_green = int_pData[VID_IN_DATA_WIDTH/3 * 2 - 1:
           VID_IN_DATA_WIDTH/3 * 2 - GREENDEPTH];
assign lcd_blue = int_pData[VID_IN_DATA_WIDTH/3 - 1:VID_IN_DATA_WIDTH/3 - BULEDEPTH];
assign lcd_rgb_o = rd_id_flag ? {lcd_red,lcd_green,lcd_blue} 
           : {VID_OUT_DATA_WIDTH{1'bz}};
assign lcd_rgb_t = ~{VID_OUT_DATA_WIDTH{rd_id_flag}};

endmodule
