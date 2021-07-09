# 基于帧差法的运动目标检测系统

## 一、系统实现功能介绍

利用带硬核的ZYNQ平台，合理利用以并行运算见长的FPGA和以控制见长的ARM核，用帧差法高效地实现了对OV5640采集的运动目标进行检测，并通过HDMI输出到显示器上。在PL端主要实现视频图像的采集、灰度转换、帧间差分算法的设计，而PS端主要完成了对OV5640摄像头的配置以及和DDR3存储器的读取。采用软硬件协同的方式，通过OV5640进行视频图像的采集，使用VDMA IP核将数据存储到DDR中，在经过处理后将结果通过HDMI输出至显示器显示。该系统能够实时检测出运动目标，并在很大程度上解决了当前运动目标检测跟踪有关的算法在嵌入式平台上运行实时性差、耗费资源大、功耗高的问题。基于该硬核实现的的智能信息处理系统，具有创新性、实用性和具体的应用场景。

## 二、系统架构图与软硬件功能划分

本系统利用利用带硬核的ZYNQ 7020进行设计，采用软硬件协同的设计方法，完成运动目标检测系统的实现。

系统的架构如图2-1所示，PL端通过OV5640摄像头进行图像采集后，先要将图像数据转换成AXI4-Stream的格式，才能通过VDMA的写通道写入帧缓存中。本系统采用Xilinx提供的Video in to AXI4-Stream IP核，以实现将采集的RGB格式视频数据流转换成AXI4-Stream流，与VDMA IP之间进行数据通信,实现把数据通过VDMA0写入到 DDR3。每次写入一幅图像的数据的同时，通过VDMA0读出前一帧数据，送往运动目标检测加速器进行帧差运算，最后通过VDMA1发出去。VDMA1与AXI4-Stream to Video Out IP核相连，实现将VDMA1输出的AXI-Stream数据流转换成视频协议的数据流。该数据流通过自行封装的HDMP驱动IP DVI_Transmitter后，显示在具备HDMI的显示器上。
![](https://graph-1301143676.cos.ap-chengdu.myqcloud.com/FPGA/DigilentCUP/0709diff/2%25F%7DH686SQ%5D%608%60%60MYAEGS%605.png)
整个系统PL部分主要工作是图像采集、目标检测加速以及图像显示，PS部分主要是完成对OV5640摄像头配置以及对 DDR的读写控制。

## 三、开源软核与硬核使用情况

本系统采用带硬核的ZYNQ的平台进行设计，未使用开源软核，使用板载硬核处理器完成对OV5640摄像头配置以及对 DDR的读写控制。

### 3.1 ZYNQ硬核简介

Zynq-7000 SoC基于Xilinx 全可编程的可扩展处理平台结构，用户可根据自身需求对SoC进行设计，将定制逻辑映射到基于Xilinx FPGA资源的可编程逻辑PL部分，将软件开发放到基于ARM Cortex-A9多核处理器的处理系统PS部分，实现对系统的软硬件开发。此外，28nm、高k金属栅极工艺也让该器件在高性能运行的同时，有着跟同类Cortex-A9双核处理器相比更低的功耗。图3-1为Zynq-7000 SoC内部结构图。
![](https://graph-1301143676.cos.ap-chengdu.myqcloud.com/FPGA/DigilentCUP/0709diff/clipboard_20210709090111.png)
Zynq-7000 SoC的PS部分以ARM处理器为核心，不同于传统配置FPGA的方法，Zynq-7000 SoC总是最先启动PS内的ARM 处理器。因此，可以把配置PL的过程设置成启动过程的一部分实现对PL的完全配置，也可以在系统启动后根据使用需求通过处理器实现对PL的部分可重配置。

Zynq-7000 SoC内通过PS-PL接口的实现PL内定制的知识产权IP核与PS内的ARM处理器及相关资源的连接，同时PS 到PL的接口也提供了可用于PL内定制IP核的所有可用信号。因此，PS和PL之间有功能接口和配置信号这两种类型的接口。

### 3.2 PS端OV5640摄像头配置

本系统采用OV5640图像传感器，其内部结构如图3-2所示，具有500万像素。为了设置摄像头采集的图像数据的输出格式，可通过兼容I2C总线的SCCB控制接口对摄像头进行相应的配置。

摄像头配置的过程，就是往摄像头寄存器写入控制字的过程。在该模块的设计中，将需要配置的所有寄存器地址以及数据构造成一个查找表，按照查找表的地址索引依次读取相应寄存器的地址以及控制字的数据值，对图像传感器进行配置。通过I2C总线配置完一个寄存器后，相对应的查找表的地址加1，然后开始对下一个寄存器进行配置，直至配置完所有的寄存器。
![](https://graph-1301143676.cos.ap-chengdu.myqcloud.com/FPGA/DigilentCUP/0709diff/clipboard_20210709090212.png)
OV5640使用的是两线式SCCB接口总线，用16位（两个字节）表示寄存器地址，其写传输协议如图3-3所示。
![](https://graph-1301143676.cos.ap-chengdu.myqcloud.com/FPGA/DigilentCUP/0709diff/clipboard_20210709090239.png)
其中ID ADDRESS 是由 7 位器件地址和 1 位读写控制位构成，OV5640 的器件地址为0X3C，所以在写传输协议中，ID Address（W）= 0X78；Sub-address(H) 为高8 位寄存器地址，Sub-address(L)为低 8 位寄存器地址，在OV5640 众多寄存器中，有些寄存器是可改写的，有些是只读的，只有可改写的寄存器才能正确写入；Write Data 为C8 位写数据，每一个寄存器地址对应8 位的配置数据。

在OV5640 正常工作之前，必须先对传感器进行初始化，即通过配置寄存器使其工作在预期的工作模式，以及得到较好画质的图像。因SCCB 的写传输协议和 I2C 几乎相同，故直接使用 I2C 的驱动程序来配置摄像头。
![](https://graph-1301143676.cos.ap-chengdu.myqcloud.com/FPGA/DigilentCUP/0709diff/_9F6%28A3SQQB0MXM5746~~OK.png)
图3-4表示摄像头配置模块流程图，根据该流程，通过I2C总线依次对摄像头寄存器进行配置。在配置过程中，每配置一个寄存器，需要传输的数据包括从设备地址、摄像头寄存器地址以及寄存器控制字。当前I2C设备地址为0X78，OV5640传感器寄存器地址数据为16位，寄存器控制字数据为8位。因此通过I2C对摄像头进行配置时，每对一个寄存器进行配置，需要依次传输设备地址、图像传感器寄存器地址以及寄存器控制字数据，总共32位数据，即需要连续写入4个字节的数据。

按照上图流程对摄像头配置模块进行设计，通过该模块对摄像头相关寄存器进行配置，使摄像头能够正常采集外部图像信息，将采集而来的图像数据输送到后端进行处理。

OV5640初始化完毕之后，可使用vsma_api对VDMA以及动态时钟进行配置，如下所示。
```c
//配置VDMA
	run_vdma_frame_buffer(&vdma, VDMA_ID, vd_mode.width, vd_mode.height,
							frame_buffer_addr,0,0,BOTH);

	//配置VDMA1
	run_vdma_frame_buffer(&vdma1,VDMA_ID1,vd_mode.width, vd_mode.height,
							frame_buffer_addr,0,0,ONLY_READ);

    //初始化Display controller
	DisplayInitialize(&dispCtrl, DISP_VTC_ID, DYNCLK_BASEADDR);
    //设置VideoMode
	DisplaySetMode(&dispCtrl, &vd_mode);
	DisplayStart(&dispCtrl);
```

### 3.3 DDR读写

在系统设计中，由于在图像处理算法的计算过程中需要对部分或者整帧图像数据进行计算。为了保证系统在进行图像数据计算过程中能够满足时序要求，通常需要对图像数据进行缓存操作。由摄像头采集的实时视频图像数据量较为庞大，一般采用外部存储器来实现对图像数据的缓存。

本系统PL端使用VDMA，通过AXI_HP接口对PS段DDR进行读写。其中，AXI VDMA是Xilinx专门针对视频应用提供的一种高带宽的解决方案，旨在实现AXI4-Stream视频接口和AXI4接口之间的高带宽接入，可以方便地实现双缓冲和多缓冲机制。
由于本系统需要频繁对摄像头的当前帧图像进行写入、对前一帧图像进行读出，使用单帧缓存会造成图像叠加，故本系统使用VDMA的多帧缓存方案。VDMA 用于将AXI Stream 格式的数据流转换为Memory Map 格式或将Memory Map 格式的数据转换为AXI Stream 数据流，提供从AXI4 域到AXI4-Stream 域的视频读/写传输功能，反之亦然，从而实现DDR3和基于AXI4-Stream 的目标视频IP 之间的高速数据移动。其框图如图3-5所示。
![](https://graph-1301143676.cos.ap-chengdu.myqcloud.com/FPGA/DigilentCUP/0709diff/3%5B%7DA%24NST%7B%5D%7DVP%60F7DAJ_%5DAD.png)
AXI4-Lite可以对寄存器进行编程（配置），从而实现软件动态配置VDMA的功能。通过AXI4-Lite接口对寄存器进行编程后，控制/状态逻辑块会为DataMover生成适当的命令，以在AXI4主接口上启动写入和读取命令。可配置的异步line buffer用于在将像素数据写入AXI4-Memory Map接口或AXI4-Stream接口之前临时保存像素数据。

VDMA数据接口可以分为读、写两个通道，且写入和读取独立运行。用户可以通过写通道将AXI-Stream类型的数据流写入DDR3。在读通道中，VDMA使用AXI4主接口从系统存储器读取数据并在AXI4-Stream主接口上输出。VDMA本质上是一个数据搬运的IP，可看作为视频图像处理做特殊优化的带有帧缓冲功能的高性能DMA。VDMA通过AXI Smartconnect IP核与AXI_HP端口进行连接，从而高效访问DDR3。

![](https://graph-1301143676.cos.ap-chengdu.myqcloud.com/FPGA/DigilentCUP/0709diff/clipboard_20210709090824.png)

## 四、硬件加速器详细设计 

### 4.1 帧间差分算法硬件加速器设计

#### 4.1.1 整体设计

当视频中存在移动物体的时候，相邻帧之间在灰度上会有差别，求取两帧图像灰度差的绝对值，则静止的物体在差值图像上表现出来全是0，而移动物体特别是移动物体的轮廓处由于存在灰度变化为非0，当绝对值超过一定阈值时，即可判断为运动目标，从而实现目标的检测功能。 帧间差分法对光线等场景变化不太敏感，能够适应各种动态环境，有着比较强的鲁棒性，在道路上车辆的智能监控，安防边界监控等领域有较大应用场景。本系统设计的帧间差分算法硬件加速器如图4-1所示。

![](https://graph-1301143676.cos.ap-chengdu.myqcloud.com/FPGA/DigilentCUP/0709diff/clipboard_20210709090951.png)

最终实现的帧间差分硬件加速器如图4-2所示。

![](https://graph-1301143676.cos.ap-chengdu.myqcloud.com/FPGA/DigilentCUP/0709diff/clipboard_20210709091039.png)

#### 4.1.2 同步处理

其中，s0_axis接口为当前帧视频流输入，该视频流由OV5640摄像头采集；s1_AXIS接口为前一帧视频流输入，该视频流通过VMDA0从DDR3中读取。两路视频流均是经过Video in to AXI4-Stream IP处理后转化的AXI Stream类型的数据流。由于从DDR3读取的视频流和OV5640采集的视频流之间存着不可避免的微小时间差，为保证差值运算时两帧图像像素点一一对齐，摄像头输入像素的同时，从FIFO中读出VDMA像素，即先对前一帧存入FIFO进行缓存，以进行帧差运算。等待FIFO中缓存一定量的数据之后，检测摄像头输入SOF后才打开读FIFO使能，使得与FIFO中读取的VMDA视频同步。待当前帧视频流输入完成后，需对FIFO中的数据进行读取，在写入FIFO和读取FIFO的过程中，存在2个时钟周期的时间差，为了与FIFO中读出的数据同步，在灰度运算前，需对当前帧进行两节拍延时，使摄像头输入视频也延迟两个时钟周期。其具体实现如下所示。

```verilog
always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        s0_axis_tdata_dly1 <=  24'd0;
        s0_axis_tdata_dly2 <=  24'd0;
	end
    else begin
        s0_axis_tdata_dly1 <=  s0_axis_tdata;
        s0_axis_tdata_dly2 <=  s0_axis_tdata_dly1;
	end
end	
```

### 4.1.3 灰度化

将图像数据进行差值运算之前，为便于数据的处理，通常将原始图像图像转为灰度图像。故只需将RGB格式的图像转化为YcbCr格式，将其Y分量的值作为该像素点的灰度值，将灰度图像数据送入到运动目标检测模块中进行计算。RGB色彩空间与YCbCr色彩空间之间的转换公式如式4-1所示。
![](https://graph-1301143676.cos.ap-chengdu.myqcloud.com/FPGA/DigilentCUP/0709diff/clipboard_20210709093013.png)
由公式4-1可知，该运算会涉及到浮点运算，而在硬件实现过程中，不便于直接对浮点数进行计算，需要将浮点数进行取整。为了减少计算量，降低设计复杂度，通常采用的方法是将小数扩大倍数限制为2的整数幂，代入方程进行计算，将最后的结果进行移位计算。将公式4-1中的小数进行转换代入后，转换后的计算如式4-2所示。
![](https://graph-1301143676.cos.ap-chengdu.myqcloud.com/FPGA/DigilentCUP/0709diff/clipboard_20210709093041.png)
为统一节拍，进一步缩减时钟周期，可将公式4-2转换为
![](https://graph-1301143676.cos.ap-chengdu.myqcloud.com/FPGA/DigilentCUP/0709diff/clipboard_20210709093102.png)
RGB转YCbCr模块的硬件结构图如图4-3所示，在该模块的整个计算过程中涉及的操作包括乘法计算、加法计算、减法计算以及移位计算。
![](https://graph-1301143676.cos.ap-chengdu.myqcloud.com/FPGA/DigilentCUP/0709diff/clipboard_20210709093137.png)
该模块将RGB格式数据按照4-3所示的结构进行计算。通过该模块对原始图像数据进行处理，将其转为YCbCr格式的图像数据，便于帧间差分法的差值运算。整个模块按照流水线的方式进行处理，保证了数据的实时处理。其部分代码描述如下所示。
```verilog
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n) begin
		img_Y_r0	<=	0; 		
		img_Cb_r0	<=	0; 		
		img_Cr_r0	<=	0; 	
    end
	else begin
		img_Y_r0	<=	img_red_r0 + 	img_green_r0 + img_blue_r0; 		
		img_Cb_r0	<=	img_blue_r1 - img_red_r1 	- img_green_r1	+	16'd32768; 
		img_Cr_r0	<=	img_red_r2 - img_green_r2 	- img_blue_r2	    +	16'd32768; 
    end
end

```

#### 4.1.4 差值运算与边界检测

帧差法通过对连续的两帧图像的灰度求差获得运动物体的边界信息。由于物体与背景在图像中的灰度一般有较大差异，物体的运动就会导致边界上的同一像素点在两帧图像之间出现较大变化，由此即可检测出运动物体的边界位置。差值运算具体实现如下所示。

```verilog
    if(s0_img_y > s1_img_y) begin
		if(s0_img_y - s1_img_y > Diff_Threshold)	//灰度差大于阈值
			frame_difference_flag <= 1'b1; 
		else
			frame_difference_flag <= 1'b0;	 
		end
	else begin
		if(s1_img_y - s0_img_y > Diff_Threshold)	//灰度差大于阈值
			frame_difference_flag <= 1'b1; 
		else
			frame_difference_flag <= 1'b0;
	end
```

获得灰度图后，根据算法原理对两帧图像进行求差运算并设置阈值，当差值超过阈值时输出为1否则为0，得到只含有0和1的矩阵，其中的1即为物体运动造成的两帧之间像素灰度超出阈值的差异，代表了一块以灰度大小没有突变作为区分的运动物体的边界。然后边界检测模块对矩阵进行遍历，分别得到行和列两个维度值为1的元素索引的最大值与最小值，由此构造代表物体边界的矩形框，与原当前帧图像进行叠加后输出。其原理框图如图4-4所示。

![](https://graph-1301143676.cos.ap-chengdu.myqcloud.com/FPGA/DigilentCUP/0709diff/clipboard_20210709093443.png)

### 4.2 HDMI视频传输驱动加速器设计

DVI和HDMI接口协议在物理层使用TMDS（Transition Minimized Differential Signaling，最小化传输差分信号）标准传输音视频数据，使用差分信号传输高速串行数据。TMDS差分传输技术使用两个引脚来传输一路信号，利用这两个引脚间的电压差的正负极性和大小来决定传输数据的数值。

如图4-5是TMDS发送端和接收端的连接示意图。DVI或HDMI视频传输所使用的TMDS连接通过四个串行通道实现。对于DVI来说，其中三个通道分别用于传输视频中每个像素点的红、绿、蓝三个颜色分量（RGB 4:4:4格式）。HDMI默认也是使用三个RGB通道，但是它同样可以选择传输像素点的亮度和色度信息。第四个通道是时钟通道，用于传输像素时钟。独立的TMDS时钟通道为接收端提供接收的参考频率，保证数据在接收端能够正确恢复.

![](https://graph-1301143676.cos.ap-chengdu.myqcloud.com/FPGA/DigilentCUP/0709diff/clipboard_20210709093537.png)

在视频输出时，需要将RGB格式的视频图像转换成TMDS数据输出，其转换模块如图4-6所示（参考Xilinx应用笔记XAPP460）。

![](https://graph-1301143676.cos.ap-chengdu.myqcloud.com/FPGA/DigilentCUP/0709diff/clipboard_20210709093612.png)

Encoder模块负责对数据进行编码，Serializer模块对编码后的数据进行并串转换，最后通过OBUFDS转化成TMDS差分信号传输。
整个系统需要两个输入时钟，一个是视频的像素时钟Pixel Clk，另外一个时钟Pixel Clk x5的频率是像素时钟的五倍。并串转换过程的实现的是10:1的转换率，理论上转换器需要一个10倍像素时钟频率的串行时钟。由于OSERDESE2模块可以实现DDR的功能，即它在五倍时钟频率的基础上又实现了双倍数据速率，故本系统只用一个5倍的时钟频率。
TMDS连接的时钟通道采用与数据通道相同的并转串逻辑来实现。通过对10位二进制序列10’b11111_00000在10倍像素时钟频率下进行并串转换，就可以得到像素时钟频率下的TMDS参考时钟。
最终封装的HDMI视频传输驱动加速器如图4-7所示。

![](https://graph-1301143676.cos.ap-chengdu.myqcloud.com/FPGA/DigilentCUP/0709diff/clipboard_20210709093639.png)

## 五、测试结果

如图5-1所示，摄像头采集图像，当测试物体——电感在运动时，该系统可以有效得将其框出并进行跟踪。详细演示视频见（4）作品多媒体展示文件夹。

![](https://graph-1301143676.cos.ap-chengdu.myqcloud.com/FPGA/DigilentCUP/0709diff/clipboard_20210709093734.png)