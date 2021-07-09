

`timescale 1ns / 1ps

module serializer_10_to_1(
    input           reset,              // ��λ,����Ч
    input           paralell_clk,       // ���벢������ʱ��
    input           serial_clk_5x,      // ���봮������ʱ��
    input   [9:0]   paralell_data,      // ���벢������

    output 			serial_data_out     // �����������
    );
    
//wire define
wire		cascade1;     //��������OSERDESE2�������ź�
wire		cascade2;
  
//*****************************************************
//**                    main code
//***************************************************** 
    
//����OSERDESE2ԭ�ʵ�ֲ���ת��,Masterģʽ
OSERDESE2 #(
    .DATA_RATE_OQ   ("DDR"),       // ����˫����������
    .DATA_RATE_TQ   ("SDR"),       // DDR, BUF, SDR
    .DATA_WIDTH     (10),           // ����Ĳ������ݿ���Ϊ10bit
    .SERDES_MODE    ("MASTER"),    // ����ΪMaster������10bit������չ
    .TBYTE_CTL      ("FALSE"),     // Enable tristate byte operation (FALSE, TRUE)
    .TBYTE_SRC      ("FALSE"),     // Tristate byte source (FALSE, TRUE)
    .TRISTATE_WIDTH (1)             // 3-state converter width (1,4)
)
OSERDESE2_Master (
    .CLK        (serial_clk_5x),    // ��������ʱ��,5��ʱ��Ƶ��
    .CLKDIV     (paralell_clk),     // ��������ʱ��
    .RST        (reset),            // 1-bit input: Reset
    .OCE        (1'b1),             // 1-bit input: Output data clock enable
    
    .OQ         (serial_data_out),  // �����������
    
    .D1         (paralell_data[0]), // D1 - D8: ������������
    .D2         (paralell_data[1]),
    .D3         (paralell_data[2]),
    .D4         (paralell_data[3]),
    .D5         (paralell_data[4]),
    .D6         (paralell_data[5]),
    .D7         (paralell_data[6]),
    .D8         (paralell_data[7]),
   
    .SHIFTIN1   (cascade1),         // SHIFTIN1 ����λ����չ
    .SHIFTIN2   (cascade2),         // SHIFTIN2
    .SHIFTOUT1  (),                 // SHIFTOUT1: ����λ����չ
    .SHIFTOUT2  (),                 // SHIFTOUT2
        
    .OFB        (),                 // ������δʹ���ź�
    .T1         (1'b0),             
    .T2         (1'b0),
    .T3         (1'b0),
    .T4         (1'b0),
    .TBYTEIN    (1'b0),             
    .TCE        (1'b0),             
    .TBYTEOUT   (),                 
    .TFB        (),                 
    .TQ         ()                  
);
   
//����OSERDESE2ԭ�ʵ�ֲ���ת��,Slaveģʽ
OSERDESE2 #(
    .DATA_RATE_OQ   ("DDR"),       // ����˫����������
    .DATA_RATE_TQ   ("SDR"),       // DDR, BUF, SDR
    .DATA_WIDTH     (10),           // ����Ĳ������ݿ���Ϊ10bit
    .SERDES_MODE    ("SLAVE"),     // ����ΪSlave������10bit������չ
    .TBYTE_CTL      ("FALSE"),     // Enable tristate byte operation (FALSE, TRUE)
    .TBYTE_SRC      ("FALSE"),     // Tristate byte source (FALSE, TRUE)
    .TRISTATE_WIDTH (1)             // 3-state converter width (1,4)
)
OSERDESE2_Slave (
    .CLK        (serial_clk_5x),    // ��������ʱ��,5��ʱ��Ƶ��
    .CLKDIV     (paralell_clk),     // ��������ʱ��
    .RST        (reset),            // 1-bit input: Reset
    .OCE        (1'b1),             // 1-bit input: Output data clock enable
    
    .OQ         (),                 // �����������
    
    .D1         (1'b0),             // D1 - D8: ������������
    .D2         (1'b0),
    .D3         (paralell_data[8]),
    .D4         (paralell_data[9]),
    .D5         (1'b0),
    .D6         (1'b0),
    .D7         (1'b0),
    .D8         (1'b0),
   
    .SHIFTIN1   (),                 // SHIFTIN1 ����λ����չ
    .SHIFTIN2   (),                 // SHIFTIN2
    .SHIFTOUT1  (cascade1),         // SHIFTOUT1: ����λ����չ
    .SHIFTOUT2  (cascade2),         // SHIFTOUT2
        
    .OFB        (),                 // ������δʹ���ź�
    .T1         (1'b0),             
    .T2         (1'b0),
    .T3         (1'b0),
    .T4         (1'b0),
    .TBYTEIN    (1'b0),             
    .TCE        (1'b0),             
    .TBYTEOUT   (),                 
    .TFB        (),                 
    .TQ         ()                  
);  
        
endmodule