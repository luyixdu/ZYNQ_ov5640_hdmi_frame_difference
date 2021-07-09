//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           main.c
// Last modified Date:  2019/07/07 15:59:46
// Last Version:        V1.0
// Descriptions:        OV5640摄像头驱动LCD示例
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2019/07/07 15:59:52
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

/***************************** Include Files *********************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "xil_types.h"
#include "xil_cache.h"
#include "xparameters.h"
#include "xaxivdma.h"
#include "xaxivdma_i.h"
#include "display_ctrl_hdmi/display_ctrl.h"
#include "vdma_api/vdma_api.h"
#include "emio_sccb_cfg/emio_sccb_cfg.h"
#include "ov5640/ov5640_init.h"

//宏定义
#define DYNCLK_BASEADDR  XPAR_AXI_DYNCLK_0_BASEADDR  //动态时钟基地址
#define VDMA_ID          XPAR_AXIVDMA_0_DEVICE_ID    //VDMA器件ID
#define VDMA_ID1         XPAR_AXIVDMA_1_DEVICE_ID
#define DISP_VTC_ID      XPAR_VTC_0_DEVICE_ID        //VTC器件ID

//全局变量
//frame buffer的起始地址
unsigned int const frame_buffer_addr = (XPAR_PS7_DDR_0_S_AXI_BASEADDR
										+ 0x1000000);
XAxiVdma     vdma;
XAxiVdma     vdma1;
DisplayCtrl  dispCtrl;
VideoMode    vd_mode;

int main(void)
{
	u32 status;
	u16 cmos_h_pixel;                    //ov5640 DVP 输出水平像素点数
	u16 cmos_v_pixel;                    //ov5640 DVP 输出垂直像素点数
	u16 total_h_pixel;                   //ov5640 水平总像素大小
	u16 total_v_pixel;                   //ov5640 垂直总像素大小

//	cmos_h_pixel = 1280;                 //设置OV5640输出分辨率为1280*720
//	cmos_v_pixel = 720;

	cmos_h_pixel = 640;                 //设置OV5640输出分辨率为1280*720
	cmos_v_pixel = 480;

	total_h_pixel = 2570;
	total_v_pixel = 980;

	emio_init();                         //初始化EMIO
	status = ov5640_init( cmos_h_pixel,  //初始化ov5640
						  cmos_v_pixel,
						 total_h_pixel,
						 total_v_pixel);
	if(status == 0)
		xil_printf("OV5640 detected successful!\r\n");
	else
		xil_printf("OV5640 detected failed!\r\n");

	vd_mode = VMODE_640x480;

	//配置VDMA
	run_vdma_frame_buffer(&vdma, VDMA_ID, vd_mode.width, vd_mode.height,
							frame_buffer_addr,0,0,BOTH);

	//配置VDMA1
	run_vdma_frame_buffer(&vdma1, VDMA_ID1, vd_mode.width, vd_mode.height,
							frame_buffer_addr,0,0,ONLY_READ);

    //初始化Display controller
	DisplayInitialize(&dispCtrl, DISP_VTC_ID, DYNCLK_BASEADDR);
    //设置VideoMode
	DisplaySetMode(&dispCtrl, &vd_mode);
	DisplayStart(&dispCtrl);

    return 0;
}
 
