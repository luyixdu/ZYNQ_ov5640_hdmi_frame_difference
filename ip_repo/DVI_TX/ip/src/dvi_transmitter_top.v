
`timescale 1ns / 1ps

module dvi_transmitter_top(
    input        pclk,           // pixel clock
    input        pclk_x5,        // pixel clock x5
    input        reset_n,        // reset
    
    input [23:0] video_din,      // RGB888 video in
    input        video_hsync,    // hsync data
    input        video_vsync,    // vsync data
    input        video_de,       // data enable
    
    output       tmds_clk_p,    // TMDS ʱ��ͨ��
    output       tmds_clk_n,
    output [2:0] tmds_data_p,   // TMDS ����ͨ��
    output [2:0] tmds_data_n,
    output       tmds_oen       // TMDS ���ʹ��
    );
    
//wire define    
wire        reset;
    
//��������
wire [9:0]  red_10bit;
wire [9:0]  green_10bit;
wire [9:0]  blue_10bit;
wire [9:0]  clk_10bit;  
  
//��������
wire [2:0]  tmds_data_serial;
wire        tmds_clk_serial;

//*****************************************************
//**                    main code
//***************************************************** 
assign tmds_oen = 1'b1;  
assign clk_10bit = 10'b1111100000;

//�첽��λ��ͬ���ͷ�
asyn_rst_syn reset_syn(
    .reset_n    (reset_n),
    .clk        (pclk),
    
    .syn_reset  (reset)    //����Ч
    );
  
//��������ɫͨ�����б���
dvi_encoder encoder_b (
    .clkin      (pclk),
    .rstin	    (reset),
    
    .din        (video_din[7:0]),
    .c0			(video_hsync),
    .c1			(video_vsync),
    .de			(video_de),
    .dout		(blue_10bit)
    ) ;

dvi_encoder encoder_g (
    .clkin      (pclk),
    .rstin	    (reset),
    
    .din		(video_din[15:8]),
    .c0			(1'b0),
    .c1			(1'b0),
    .de			(video_de),
    .dout		(green_10bit)
    ) ;
    
dvi_encoder encoder_r (
    .clkin      (pclk),
    .rstin	    (reset),
    
    .din		(video_din[23:16]),
    .c0			(1'b0),
    .c1			(1'b0),
    .de			(video_de),
    .dout		(red_10bit)
    ) ;
    
//�Ա��������ݽ��в���ת��
serializer_10_to_1 serializer_b(
    .reset              (reset),                // ��λ,����Ч
    .paralell_clk       (pclk),                 // ���벢������ʱ��
    .serial_clk_5x      (pclk_x5),              // ���봮������ʱ��
    .paralell_data      (blue_10bit),           // ���벢������

    .serial_data_out    (tmds_data_serial[0])   // �����������
    );    
    
serializer_10_to_1 serializer_g(
    .reset              (reset),
    .paralell_clk       (pclk),
    .serial_clk_5x      (pclk_x5),
    .paralell_data      (green_10bit),

    .serial_data_out    (tmds_data_serial[1])
    );
    
serializer_10_to_1 serializer_r(
    .reset              (reset),
    .paralell_clk       (pclk),
    .serial_clk_5x      (pclk_x5),
    .paralell_data      (red_10bit),

    .serial_data_out    (tmds_data_serial[2])
    );
            
serializer_10_to_1 serializer_clk(
    .reset              (reset),
    .paralell_clk       (pclk),
    .serial_clk_5x      (pclk_x5),
    .paralell_data      (clk_10bit),

    .serial_data_out    (tmds_clk_serial)
    );
    
//ת������ź�  
OBUFDS #(
    .IOSTANDARD         ("TMDS_33")    // I/O��ƽ��׼ΪTMDS
) TMDS0 (
    .I                  (tmds_data_serial[0]),
    .O                  (tmds_data_p[0]),
    .OB                 (tmds_data_n[0]) 
);

OBUFDS #(
    .IOSTANDARD         ("TMDS_33")    // I/O��ƽ��׼ΪTMDS
) TMDS1 (
    .I                  (tmds_data_serial[1]),
    .O                  (tmds_data_p[1]),
    .OB                 (tmds_data_n[1]) 
);

OBUFDS #(
    .IOSTANDARD         ("TMDS_33")    // I/O��ƽ��׼ΪTMDS
) TMDS2 (
    .I                  (tmds_data_serial[2]), 
    .O                  (tmds_data_p[2]), 
    .OB                 (tmds_data_n[2])  
);

OBUFDS #(
    .IOSTANDARD         ("TMDS_33")    // I/O��ƽ��׼ΪTMDS
) TMDS3 (
    .I                  (tmds_clk_serial), 
    .O                  (tmds_clk_p),
    .OB                 (tmds_clk_n) 
);
  
endmodule